local Settings = {
    ["UpDownSpeed"] = 0.75,
    ["MobileSpeed"] = 0.5,
    ["FovGamepadSpeed"] = 0.25,
    ["ShiftSpeed"] = 0.25,
    ["FovWheelSpeed"] = 1
}

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
local PAN_STIFFNESS = UserInputService.TouchEnabled and 4 or 1
local FOV_STIFFNESS = UserInputService.TouchEnabled and 2 or 4

local Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local cameraFov = 0

local velSpring = Spring.new(1.5, (Vector3.new()))
local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
local fovSpring = Spring.new(FOV_STIFFNESS, 0)

local Input = {} do
    local keyboard = {
	    W = 0,
	    A = 0,
	    S = 0,
	    D = 0,
	    E = 0,
	    Q = 0,
	    U = 0,
	    H = 0,
	    J = 0,
	    K = 0,
	    I = 0,
	    Y = 0,
	    Up = 0,
	    Down = 0,
	    LeftShift = 0,
	    RightShift = 0
    }
    
    local mouse = {
	    Delta = Vector2.new(),
	    MouseWheel = 0
    }
    
    local PAN_MOUSE_SPEED = Vector2.new(1, 1) * math.pi/64
    local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
    local navSpeed = 1

    function Input.Vel(dt)
	    navSpeed = math.clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * Settings.UpDownSpeed, 0.01, 4)
	
	    local kKeyboard = Vector3.new(
		    keyboard.D - keyboard.A + keyboard.K - keyboard.H,
		    keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
		    keyboard.S - keyboard.W + keyboard.J - keyboard.U
	    )*NAV_KEYBOARD_SPEED
	
	    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	
	    return kKeyboard * (navSpeed * (shift and Settings.ShiftSpeed or (UserInputService.TouchEnabled and Settings.MobileSpeed or 1)))
    end

    function Input.Pan(dt)
	    local kMouse = mouse.Delta * PAN_MOUSE_SPEED
	    mouse.Delta = Vector2.new()
	    return kMouse
    end

    function Input.Fov(dt)
	    local kMouse = mouse.MouseWheel * Settings.FovWheelSpeed
	    mouse.MouseWheel = 0
	    return kMouse
    end

    local function Keypress(_, state, input)
	    keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
	    return Enum.ContextActionResult.Sink
    end

    local function MousePan(_, _, input)
	    local delta = input.Delta
	    mouse.Delta = Vector2.new(-delta.y, -delta.x)
	    return Enum.ContextActionResult.Sink
    end

    globalMouse = mouse
    globalKp = Keypress
    
    local function MouseWheel(_, _, input)
	    mouse[input.UserInputType.Name] = -input.Position.z
	    return Enum.ContextActionResult.Sink
    end
    
    local function Zero(t)
		for k, v in pairs(t) do
			t[k] = v*0
		end
	end

    function Input.StartCapture()
	    ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
	        Enum.KeyCode.W, Enum.KeyCode.U,
	        Enum.KeyCode.A, Enum.KeyCode.H,
	        Enum.KeyCode.S, Enum.KeyCode.J,
	        Enum.KeyCode.D, Enum.KeyCode.K,
	        Enum.KeyCode.E, Enum.KeyCode.I,
	        Enum.KeyCode.Q, Enum.KeyCode.Y,
	        Enum.KeyCode.Up, Enum.KeyCode.Down
	    )
	    ContextActionService:BindActionAtPriority("FreecamMousePan", MousePan, false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
	    ContextActionService:BindActionAtPriority("FreecamMouseWheel", MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
    end

    function Input.StopCapture()
	    navSpeed = 1
	    Zero(keyboard)
		Zero(mouse)
	    ContextActionService:UnbindAction("FreecamKeyboard")
	    ContextActionService:UnbindAction("FreecamMousePan")
	    ContextActionService:UnbindAction("FreecamMouseWheel")
    end
end

local function GetFocusDistance(cameraFrame)
	local viewport = Camera.ViewportSize
	local projy = 2 * math.tan(cameraFov / 2)
	local projx = viewport.x / viewport.y * projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5) * projx
			local cy = (y - 0.5) * projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset * 0.1
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect) * minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))
	local fov = fovSpring:Update(dt, Input.Fov(dt))
	
	local zoomFactor = math.sqrt(math.tan(math.rad(70/2)) / math.tan((math.rad(cameraFov / 2))))
	cameraFov = math.clamp(cameraFov + fov * 300 * (dt / zoomFactor), 1, 120)
	
	cameraRot = cameraRot + pan * Vector2.new(0.75, 1) * 8 * (dt / zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y % (2*math.pi))
	
	local cameraCFrame = CFrame.new(cameraPos) * CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0) * CFrame.new(vel * Vector3.new(64, 64, 64) * dt)
	cameraPos = cameraCFrame.p
	
	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
    local cameraCFrame = nil
    local cameraFocus = nil
    local mouseBehavior = nil
    local cameraType = nil
    local mouseIconEnabled = nil
    local cameraFieldOfView = nil
    
    function PlayerState.Push()
	    cameraFieldOfView = Camera.FieldOfView
	    Camera.FieldOfView = 70
	
	    cameraType = Camera.CameraType
	    Camera.CameraType = Enum.CameraType.Custom
	
	    cameraCFrame = Camera.CFrame
	    cameraFocus = Camera.Focus
	
	    mouseIconEnabled = UserInputService.MouseIconEnabled
	    UserInputService.MouseIconEnabled = false
	
	    mouseBehavior = UserInputService.MouseBehavior
	    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    function PlayerState.Pop()
	    Camera.FieldOfView = cameraFieldOfView
	    cameraFieldOfView = nil
	
	    Camera.CameraType = cameraType
	    cameraType = nil
	
	    Camera.CFrame = cameraCFrame
	    cameraCFrame = nil
	    
	    Camera.Focus = cameraFocus
	    cameraFocus = nil
	
	    UserInputService.MouseIconEnabled = mouseIconEnabled
	    mouseIconEnabled = nil
	    
	    UserInputService.MouseBehavior = mouseBehavior
	    mouseBehavior = nil
    end
end

local function StartFreecam()
	local cameraCFrame = Camera.CFrame
	cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView
	
	velSpring:Reset((Vector3.new()))
	panSpring:Reset(Vector2.new())
	fovSpring:Reset(0)
	
	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
end

local thumbstick = {
	["Create"] = function(self, ScreenGui, keyInputHandler, OnResetKeys, OnThumbstickTouch)
		if self.thumbstickFrame then
			self.thumbstickFrame:Destroy()
			self.thumbstickFrame = nil
			if self.onTouchMovedConn then
				self.onTouchMovedConn:Disconnect()
				self.onTouchMovedConn = nil
			end
			if self.onTouchEndedConn then
				self.onTouchEndedConn:Disconnect()
				self.onTouchEndedConn = nil
			end
		end
		local isSmallScreen = math.min(ScreenGui.AbsoluteSize.X, ScreenGui.AbsoluteSize.Y) <= 500
		self.thumbstickSize = isSmallScreen and 70 or 120
		self.screenPos = isSmallScreen and UDim2.new(0, self.thumbstickSize / 2 - 10, 1, -self.thumbstickSize - 20) or UDim2.new(0, self.thumbstickSize / 2, 1, -self.thumbstickSize * 1.75)
		
		self.thumbstickFrame = Instance.new("Frame")
		self.thumbstickFrame.Name = "ThumbstickFrame"
		self.thumbstickFrame.Active = true
		self.thumbstickFrame.Visible = false
		self.thumbstickFrame.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		self.thumbstickFrame.Position = self.screenPos
		self.thumbstickFrame.BackgroundTransparency = 1
		
		local outerImage = Instance.new("ImageLabel")
		outerImage.Name = "OuterImage"
		outerImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
		outerImage.ImageRectOffset = Vector2.new()
		outerImage.ImageRectSize = Vector2.new(220, 220)
		outerImage.BackgroundTransparency = 1
		outerImage.Size = UDim2.new(0, self.thumbstickSize, 0, self.thumbstickSize)
		outerImage.Position = UDim2.new(0, 0, 0, 0)
		outerImage.Parent = self.thumbstickFrame
		
		self.stickImage = Instance.new("ImageLabel")
		self.stickImage.Name = "StickImage"
		self.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
		self.stickImage.ImageRectOffset = Vector2.new(220, 0)
		self.stickImage.ImageRectSize = Vector2.new(111, 111)
		self.stickImage.BackgroundTransparency = 1
		self.stickImage.Size = UDim2.new(0, self.thumbstickSize / 2, 0, self.thumbstickSize / 2)
		self.stickImage.Position = UDim2.new(0, self.thumbstickSize / 2 - self.thumbstickSize / 4, 0, self.thumbstickSize / 2 - self.thumbstickSize / 4)
		self.stickImage.ZIndex = 2
		self.stickImage.Parent = self.thumbstickFrame
	
		local centerPosition = nil
		local lastKeyStates = {}
		local function updateKeys(isReset)
			if isReset then
				OnResetKeys()
			else
				local moveVector = Vector2.new(self.moveVector.X, self.moveVector.Z)
				local keyStates = { moveVector.Y < 0 and Enum.KeyCode.W or Enum.KeyCode.S, moveVector.X < 0 and Enum.KeyCode.A or Enum.KeyCode.D }
				if lastKeyStates and #lastKeyStates >= 1 then
					for i, v in pairs(lastKeyStates) do
						if keyStates[i] ~= v then
							keyInputHandler(v, false)
						end
					end
				end
				for _, v in pairs(keyStates) do
					keyInputHandler(v, true)
				end
				lastKeyStates = keyStates
			end
		end
		
		local function MoveStick(pos)
			local relativePosition = Vector2.new(pos.X - centerPosition.X, pos.Y - centerPosition.Y)
			local length = relativePosition.magnitude
			local maxLength = self.thumbstickFrame.AbsoluteSize.X / 2
			if self.isFollowStick and maxLength < length then
				local offset = relativePosition.unit * maxLength
				self.thumbstickFrame.Position = UDim2.new(
				    0, pos.X - self.thumbstickFrame.AbsoluteSize.X/2 - offset.X,
				    0, pos.Y - self.thumbstickFrame.AbsoluteSize.Y/2 - offset.Y)
			else
				length = math.min(length, maxLength)
				relativePosition = relativePosition.unit * length
			end
			self.stickImage.Position = UDim2.new(0, relativePosition.X + self.stickImage.AbsoluteSize.X / 2, 0, relativePosition.Y + self.stickImage.AbsoluteSize.Y / 2)
		end
		
		self.thumbstickFrame.InputBegan:Connect(function(inputObject)
			OnThumbstickTouch(true)
			if not self.moveTouchObject and (inputObject.UserInputType == Enum.UserInputType.Touch and inputObject.UserInputState == Enum.UserInputState.Begin) then
				self.moveTouchObject = inputObject
				centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2, self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2)
				local direction = Vector2.new(inputObject.Position.X - centerPosition.X, inputObject.Position.Y - centerPosition.Y)
			end
		end)
		
		self.onTouchMovedConn = UserInputService.TouchMoved:Connect(function(inputObject, _)
			if inputObject == self.moveTouchObject then
				centerPosition = Vector2.new(self.thumbstickFrame.AbsolutePosition.X + self.thumbstickFrame.AbsoluteSize.X / 2, self.thumbstickFrame.AbsolutePosition.Y + self.thumbstickFrame.AbsoluteSize.Y / 2)
				local direction = Vector2.new(inputObject.Position.X - centerPosition.X, inputObject.Position.Y - centerPosition.Y)
				local currentMoveVector = direction / (self.thumbstickSize / 2)
				local inputAxisMagnitude = currentMoveVector.magnitude
				if inputAxisMagnitude < 0.05 then
					currentMoveVector = Vector3.new()
				else
					currentMoveVector = currentMoveVector.unit * ((inputAxisMagnitude - 0.05) / 0.95)
					currentMoveVector = Vector3.new(currentMoveVector.X, 0, currentMoveVector.Y)
				end
				self.direction = direction
				self.moveVector = currentMoveVector
				updateKeys()
				MoveStick(inputObject.Position)
			end
		end)
		
		self.onTouchEndedConn = UserInputService.TouchEnded:Connect(function(inputObject, _)
			if inputObject == self.moveTouchObject then
				self.stickImage.Position = UDim2.new(0, self.thumbstickFrame.Size.X.Offset / 2 - self.thumbstickSize / 4, 0, self.thumbstickFrame.Size.Y.Offset / 2 - self.thumbstickSize / 4)
				OnThumbstickTouch(false)
				self.moveVector = Vector3.new(0, 0, 0)
				self.isJumping = false
				self.moveTouchObject = nil
				self.direction = Vector2.new(0, 0)
				lastKeyStates = {}
				updateKeys(true)
			end
		end)
		
		self.thumbstickFrame.Parent = ScreenGui
		return self.thumbstickFrame
	end
}

local active = false
local thumbstickFrame = nil
local ScreenGui = ({...})[1]
local function initTouchControl()
	local lastPinchScale = nil
	local currentZoom = 15
	local lastZoom = 0
	local zoomStep = Settings.FovWheelSpeed * 3 / 4
	local isThumbstickActive = nil
	local lastThumbstickTime = tick() - 0.1
	
	thumbstickFrame = thumbstick:Create(ScreenGui, function(keycode, isPressed)
		globalKp(nil, isPressed and Enum.UserInputState.Begin or Enum.UserInputState.End, {
			["KeyCode"] = keycode
		})
	end, function()
		local resetKeys = {
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D
		}
		for _, v in pairs(resetKeys) do
			globalKp(nil, Enum.UserInputState.End, {
				["KeyCode"] = v
			})
		end
	end, function(isTouching)
		isThumbstickActive = isTouching
		lastThumbstickTime = tick()
	end)
	
	UserInputService.TouchPinch:Connect(function(_, scale, _, state)
		if (state == Enum.UserInputState.Change or state == Enum.UserInputState.End) and (active and (not isThumbstickActive and tick() - lastThumbstickTime > 0.1)) then
			currentZoom = currentZoom * (1 + (scale - lastPinchScale))
			currentZoom = math.max(currentZoom, 0)
			LocalPlayer.CameraMinZoomDistance = 5
			LocalPlayer.CameraMaxZoomDistance = 5
			local zoomDelta = currentZoom - lastZoom < 1 and zoomStep or -zoomStep
			globalMouse.MouseWheel = zoomDelta
			lastZoom = currentZoom
		end
		lastPinchScale = scale
	end)
	
	local activeTouchInput = nil
    local lastPos = nil
    UserInputService.TouchStarted:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local screenWidth = Camera.ViewportSize.X
            if pos.X > screenWidth / 2 then
                activeTouchInput = input
                lastPos = pos
            end
        end
    end)

    UserInputService.TouchMoved:Connect(function(input, processed)
        if input == activeTouchInput and lastPos then
            local delta = input.Position - lastPos
			globalMouse.Delta = Vector2.new(-delta.Y, -delta.X)
            lastPos = input.Position
        end
    end)

    UserInputService.TouchEnded:Connect(function(input, processed)
        if input == activeTouchInput then
            activeTouchInput = nil
            lastPos = nil
        end
    end)
end

local minZoomDistance = 0
local maxZoomDistance = 0
	
local function enable()
    active = true
	StartFreecam()
	
	minZoomDistance = LocalPlayer.CameraMinZoomDistance
	maxZoomDistance = LocalPlayer.CameraMaxZoomDistance
	
	if thumbstickFrame then
		thumbstickFrame.Visible = true
	end
end

local function disable()
	active = false
	Input.StopCapture()
	RunService:UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
	
	LocalPlayer.CameraMinZoomDistance = minZoomDistance
	LocalPlayer.CameraMaxZoomDistance = maxZoomDistance
	
	if thumbstickFrame then
		thumbstickFrame.Visible = false
	end
end

if UserInputService.TouchEnabled then
	initTouchControl()
end

return enable, disable, Settings
