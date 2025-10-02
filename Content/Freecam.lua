-- Decompiled by Krnl
local v_u_2 = {
    ["Macro"] = {
        [1] = Enum.KeyCode.N
    },
    ["FreecamImage"] = "rbxassetid://9145693009",
    ["ThumbstickVisibleForMobile"] = true,
    ["Advanced"] = {
        ["UpDownSpeed"] = 0.75,
        ["MobileSpeed"] = 0.5,
        ["FovGamepadSpeed"] = 0.25,
        ["ShiftSpeed"] = 0.25,
        ["FovWheelSpeed"] = 1
    }
}

local v_u_4 = math.abs
local v_u_5 = math.clamp
local v_u_6 = math.exp
local v_u_7 = math.rad
local v_u_8 = math.sign
local v_u_9 = math.sqrt
local v_u_10 = math.tan
local v_u_12 = game:GetService("ContextActionService")
local v13 = game:GetService("Players")
local v_u_14 = game:GetService("RunService")
local v_u_15 = game:GetService("StarterGui")
local v_u_16 = game:GetService("UserInputService")
local v_u_17 = game:GetService("Workspace")
local v_u_18 = v13.LocalPlayer
if not v_u_18 then
	v13:GetPropertyChangedSignal("LocalPlayer"):Wait()
	v_u_18 = v13.LocalPlayer
end
local v_u_19 = v_u_17.CurrentCamera
v_u_17:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	-- upvalues: (copy) v_u_17, (ref) v_u_19
	local v20 = v_u_17.CurrentCamera
	if v20 then
		v_u_19 = v20
	end
end)
local _ = Enum.ContextActionPriority.Low.Value
local v_u_21 = Enum.ContextActionPriority.High.Value
local v_u_22 = v_u_2.Macro
local v_u_23 = Vector2.new(0.75, 1) * 8
local v24 = v_u_16.TouchEnabled and 4 or 1
local v25 = v_u_16.TouchEnabled and 2 or 4
local v_u_26 = {}
v_u_26.__index = v_u_26
function v_u_26.new(p27, p28)
	-- upvalues: (copy) v_u_26
	local v29 = v_u_26
	local v30 = setmetatable({}, v29)
	v30.f = p27
	v30.p = p28
	v30.v = p28 * 0
	return v30
end
function v_u_26.Update(p31, p32, p33)
	-- upvalues: (copy) v_u_6
	local v34 = p31.f * 2 * 3.141592653589793
	local v35 = p31.p
	local v36 = p31.v
	local v37 = p33 - v35
	local v38 = v_u_6(-v34 * p32)
	local v39 = p33 + (v36 * p32 - v37 * (v34 * p32 + 1)) * v38
	local v40 = (v34 * p32 * (v37 * v34 - v36) + v36) * v38
	p31.p = v39
	p31.v = v40
	return v39
end
function v_u_26.Reset(p41, p42)
	p41.p = p42
	p41.v = p42 * 0
end
local v_u_43 = Vector3.new()
local v_u_44 = Vector2.new()
local v_u_45 = 0
local v_u_46 = v_u_26.new(1.5, (Vector3.new()))
local v_u_47 = v_u_26.new(v24, Vector2.new())
local v_u_48 = v_u_26.new(v25, 0)
local v_u_49 = {}
local function v_u_51(p50)
	-- upvalues: (copy) v_u_8, (copy) v_u_4, (copy) v_u_6, (copy) v_u_5
	return v_u_8(p50) * v_u_5((v_u_6(2 * ((v_u_4(p50) - 0.15) / 0.85)) - 1) / 6.38905609893065, 0, 1)
end
local v_u_52 = {
	["ButtonX"] = 0,
	["ButtonY"] = 0,
	["DPadDown"] = 0,
	["DPadUp"] = 0,
	["ButtonL2"] = 0,
	["ButtonR2"] = 0,
	["Thumbstick1"] = Vector2.new(),
	["Thumbstick2"] = Vector2.new()
}
local v_u_53 = {
	["W"] = 0,
	["A"] = 0,
	["S"] = 0,
	["D"] = 0,
	["E"] = 0,
	["Q"] = 0,
	["U"] = 0,
	["H"] = 0,
	["J"] = 0,
	["K"] = 0,
	["I"] = 0,
	["Y"] = 0,
	["Up"] = 0,
	["Down"] = 0,
	["LeftShift"] = 0,
	["RightShift"] = 0
}
local v_u_54 = {
	["Delta"] = Vector2.new(),
	["MouseWheel"] = 0
}
local v_u_55 = Vector2.new(1, 1) * 0.04908738521234052
local v_u_56 = Vector2.new(1, 1) * 0.39269908169872414
local v_u_57 = v_u_2.Advanced.FovWheelSpeed
local v_u_58 = v_u_2.Advanced.FovGamepadSpeed
local v_u_59 = v_u_2.Advanced.UpDownSpeed
local v_u_60 = v_u_2.Advanced.ShiftSpeed
local v_u_61 = v_u_2.Advanced.MobileSpeed
local v_u_62 = 1
local v_u_63 = false
v_u_16.InputBegan:Connect(function(p_u_64)
	-- upvalues: (ref) v_u_63
	if p_u_64.KeyCode == Enum.KeyCode.ButtonR1 then
		v_u_63 = true
		local v_u_65 = nil
		v_u_65 = p_u_64.Changed:Connect(function()
			-- upvalues: (copy) p_u_64, (ref) v_u_65, (ref) v_u_63
			if p_u_64.UserInputState == Enum.UserInputState.End then
				v_u_65:Disconnect()
				v_u_63 = false
			end
		end)
	end
end)
function v_u_49.Vel(p66)
	-- upvalues: (ref) v_u_62, (copy) v_u_53, (copy) v_u_59, (copy) v_u_5, (ref) v_u_51, (copy) v_u_52, (copy) v_u_16, (ref) v_u_63, (copy) v_u_60, (copy) v_u_61
	v_u_62 = v_u_5(v_u_62 + p66 * (v_u_53.Up - v_u_53.Down) * v_u_59, 0.01, 4)
	local v67 = v_u_51(v_u_52.Thumbstick1.X)
	local v68 = v_u_51(v_u_52.ButtonR2) - v_u_51(v_u_52.ButtonL2)
	local v69 = v_u_51
	local v70 = -v_u_52.Thumbstick1.Y
	local v71 = Vector3.new(v67, v68, v69(v70)) * Vector3.new(1, 1, 1)
	local v72 = v_u_53.D - v_u_53.A + v_u_53.K - v_u_53.H
	local v73 = v_u_53.E - v_u_53.Q + v_u_53.I - v_u_53.Y
	local v74 = v_u_53.S - v_u_53.W + v_u_53.J - v_u_53.U
	local v75 = Vector3.new(v72, v73, v74) * Vector3.new(1, 1, 1)
	local v76 = v_u_16:IsKeyDown(Enum.KeyCode.LeftShift) or (v_u_16:IsKeyDown(Enum.KeyCode.RightShift) or v_u_63)
	return (v71 + v75) * (v_u_62 * (v76 and v_u_60 or (v_u_16.TouchEnabled and v_u_61 or 1)))
end
function v_u_49.Pan(_)
	-- upvalues: (ref) v_u_51, (copy) v_u_52, (copy) v_u_56, (copy) v_u_54, (copy) v_u_55
	local v77 = Vector2.new(v_u_51(v_u_52.Thumbstick2.Y), v_u_51(-v_u_52.Thumbstick2.X)) * v_u_56
	local v78 = v_u_54.Delta * v_u_55
	v_u_54.Delta = Vector2.new()
	return v77 + v78
end
function v_u_49.Fov(_)
	-- upvalues: (copy) v_u_52, (copy) v_u_58, (copy) v_u_54, (copy) v_u_57
	local v79 = (v_u_52.ButtonX - v_u_52.ButtonY) * v_u_58
	local v80 = v_u_54.MouseWheel * v_u_57
	v_u_54.MouseWheel = 0
	return v79 + v80
end
local function v_u_84(_, p81, p82)
	-- upvalues: (copy) v_u_53
	local v83 = p81 == Enum.UserInputState.Begin and 1 or 0
	v_u_53[p82.KeyCode.Name] = v83
	return Enum.ContextActionResult.Sink
end
local function v_u_87(_, p85, p86)
	-- upvalues: (copy) v_u_52
	v_u_52[p86.KeyCode.Name] = p85 == Enum.UserInputState.Begin and 1 or 0
	return Enum.ContextActionResult.Sink
end
local function v_u_90(_, _, p88)
	-- upvalues: (copy) v_u_54
	local v89 = p88.Delta
	v_u_54.Delta = Vector2.new(-v89.y, -v89.x)
	return Enum.ContextActionResult.Sink
end
local function v_u_92(_, _, p91)
	-- upvalues: (copy) v_u_52
	v_u_52[p91.KeyCode.Name] = p91.Position
	return Enum.ContextActionResult.Sink
end
local function v_u_94(_, _, p93)
	-- upvalues: (copy) v_u_52
	v_u_52[p93.KeyCode.Name] = p93.Position.z
	return Enum.ContextActionResult.Sink
end
globalMouse = v_u_54
globalKp = v_u_84
local function v_u_96(_, _, p95)
	-- upvalues: (copy) v_u_54
	v_u_54[p95.UserInputType.Name] = -p95.Position.z
	return Enum.ContextActionResult.Sink
end
function v_u_49.StartCapture()
	-- upvalues: (copy) v_u_12, (copy) v_u_84, (copy) v_u_21, (copy) v_u_90, (copy) v_u_96, (copy) v_u_87, (copy) v_u_94, (copy) v_u_92
	v_u_12:BindActionAtPriority("FreecamKeyboard", v_u_84, false, v_u_21, Enum.KeyCode.W, Enum.KeyCode.U, Enum.KeyCode.A, Enum.KeyCode.H, Enum.KeyCode.S, Enum.KeyCode.J, Enum.KeyCode.D, Enum.KeyCode.K, Enum.KeyCode.E, Enum.KeyCode.I, Enum.KeyCode.Q, Enum.KeyCode.Y, Enum.KeyCode.Up, Enum.KeyCode.Down)
	v_u_12:BindActionAtPriority("FreecamMousePan", v_u_90, false, v_u_21, Enum.UserInputType.MouseMovement)
	v_u_12:BindActionAtPriority("FreecamMouseWheel", v_u_96, false, v_u_21, Enum.UserInputType.MouseWheel)
	v_u_12:BindActionAtPriority("FreecamGamepadButton", v_u_87, false, v_u_21, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
	v_u_12:BindActionAtPriority("FreecamGamepadTrigger", v_u_94, false, v_u_21, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
	v_u_12:BindActionAtPriority("FreecamGamepadThumbstick", v_u_92, false, v_u_21, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
end
function v_u_49.StopCapture()
	-- upvalues: (ref) v_u_62, (copy) v_u_52, (copy) v_u_53, (copy) v_u_54, (copy) v_u_12
	v_u_62 = 1
	local v97 = v_u_52
	for v98, v99 in pairs(v97) do
		v97[v98] = v99 * 0
	end
	local v100 = v_u_53
	for v101, v102 in pairs(v100) do
		v100[v101] = v102 * 0
	end
	local v103 = v_u_54
	for v104, v105 in pairs(v103) do
		v103[v104] = v105 * 0
	end
	v_u_12:UnbindAction("FreecamKeyboard")
	v_u_12:UnbindAction("FreecamMousePan")
	v_u_12:UnbindAction("FreecamMouseWheel")
	v_u_12:UnbindAction("FreecamGamepadButton")
	v_u_12:UnbindAction("FreecamGamepadTrigger")
	v_u_12:UnbindAction("FreecamGamepadThumbstick")
end
local function v_u_123(p106)
	-- upvalues: (ref) v_u_19, (ref) v_u_45, (copy) v_u_10, (copy) v_u_17
	local v107 = v_u_19.ViewportSize
	local v108 = v_u_10(v_u_45 / 2) * 2
	local v109 = v107.x / v107.y * v108
	local v110 = p106.rightVector
	local v111 = p106.upVector
	local v112 = p106.lookVector
	local v113 = Vector3.new()
	local v114 = 512
	for v115 = 0, 1, 0.5 do
		for v116 = 0, 1, 0.5 do
			local v117 = (v115 - 0.5) * v109
			local v118 = (v116 - 0.5) * v108
			local v119 = v110 * v117 - v111 * v118 + v112
			local v120 = p106.p + v119 * 0.1
			local _, v121 = v_u_17:FindPartOnRay(Ray.new(v120, v119.unit * v114))
			local v122 = (v121 - v120).magnitude
			if v122 < v114 then
				v113 = v119.unit
				v114 = v122
			end
		end
	end
	return v112:Dot(v113) * v114
end
local function v_u_130(p124)
	-- upvalues: (copy) v_u_46, (copy) v_u_49, (copy) v_u_47, (copy) v_u_48, (ref) v_u_45, (copy) v_u_7, (copy) v_u_10, (copy) v_u_9, (copy) v_u_5, (ref) v_u_44, (copy) v_u_23, (ref) v_u_43, (ref) v_u_19, (copy) v_u_123
	local v125 = v_u_46:Update(p124, v_u_49.Vel(p124))
	local v126 = v_u_47:Update(p124, v_u_49.Pan(p124))
	local v127 = v_u_48:Update(p124, v_u_49.Fov(p124))
	local v128 = v_u_9(0.7002075382097097 / v_u_10((v_u_7(v_u_45 / 2))))
	v_u_45 = v_u_5(v_u_45 + v127 * 300 * (p124 / v128), 1, 120)
	v_u_44 = v_u_44 + v126 * v_u_23 * (p124 / v128)
	v_u_44 = Vector2.new(v_u_5(v_u_44.x, -1.5707963267948966, 1.5707963267948966), v_u_44.y % 6.283185307179586)
	local v129 = CFrame.new(v_u_43) * CFrame.fromOrientation(v_u_44.x, v_u_44.y, 0) * CFrame.new(v125 * Vector3.new(64, 64, 64) * p124)
	v_u_43 = v129.p
	v_u_19.CFrame = v129
	v_u_19.Focus = v129 * CFrame.new(0, 0, -v_u_123(v129))
	v_u_19.FieldOfView = v_u_45
end
local v_u_133 = v_u_19
local v_u_135 = {}
local v_u_136 = nil
local v_u_137 = nil
local v_u_138 = nil

local v_u_140 = nil
local v_u_141 = nil
local v_u_142 = {}
local v_u_143 = nil
for _, v144 in pairs(Enum.CoreGuiType:GetEnumItems()) do
	if v144.Name ~= "All" then
		v_u_135[v144.Name] = true
	end
end
local v_u_145 = {
	["BadgesNotificationsActive"] = true,
	["PointsNotificationsActive"] = true
}
function v_u_142.Push() --Disable
	-- upvalues: (copy) v_u_135, (copy) v_u_15, (copy) v_u_145, (ref) v_u_18, (ref) v_u_143, (ref) v_u_133, (ref) v_u_140, (ref) v_u_136, (ref) v_u_137, (ref) v_u_141, (copy) v_u_16, (ref) v_u_138
	for v146 in pairs(v_u_135) do
		v_u_135[v146] = v_u_15:GetCoreGuiEnabled(Enum.CoreGuiType[v146])
		v_u_15:SetCoreGuiEnabled(Enum.CoreGuiType[v146], false)
	end
	for v147 in pairs(v_u_145) do
		v_u_145[v147] = v_u_15:GetCore(v147)
		v_u_15:SetCore(v147, false)
	end

	v_u_143 = v_u_133.FieldOfView
	v_u_133.FieldOfView = 70
	v_u_140 = v_u_133.CameraType
	v_u_133.CameraType = Enum.CameraType.Custom
	v_u_136 = v_u_133.CFrame
	v_u_137 = v_u_133.Focus
	v_u_141 = v_u_16.MouseIconEnabled
	v_u_16.MouseIconEnabled = false
	v_u_138 = v_u_16.MouseBehavior
	v_u_16.MouseBehavior = Enum.MouseBehavior.Default
end
function v_u_142.Pop() --Enable
	-- upvalues: (copy) v_u_135, (copy) v_u_15, (copy) v_u_145,, (ref) v_u_133, (ref) v_u_143, (ref) v_u_140, (ref) v_u_136, (ref) v_u_137, (copy) v_u_16, (ref) v_u_141, (ref) v_u_138
	for v150, v151 in pairs(v_u_135) do
		v_u_15:SetCoreGuiEnabled(Enum.CoreGuiType[v150], v151)
	end
	for v152, v153 in pairs(v_u_145) do
		v_u_15:SetCore(v152, v153)
	end

	v_u_133.FieldOfView = v_u_143
	v_u_143 = nil
	v_u_133.CameraType = v_u_140
	v_u_140 = nil
	v_u_133.CFrame = v_u_136
	v_u_136 = nil
	v_u_133.Focus = v_u_137
	v_u_137 = nil
	v_u_16.MouseIconEnabled = v_u_141
	v_u_141 = nil
	v_u_16.MouseBehavior = v_u_138
	v_u_138 = nil
end
local function v_u_156()
	-- upvalues: (ref) v_u_18, (ref) v_u_133, (ref) v_u_134, (ref) v_u_132, (ref) v_u_131, (copy) v_u_46, (copy) v_u_47, (copy) v_u_48, (copy) v_u_142, (copy) v_u_14, (copy) v_u_130, (copy) v_u_49
	local v155 = v_u_133.CFrame
	v_u_44 = Vector2.new(v155:toEulerAnglesYXZ())
	v_u_43 = v155.p
	v_u_45 = v_u_133.FieldOfView
	v_u_46:Reset((Vector3.new()))
	v_u_47:Reset(Vector2.new())
	v_u_48:Reset(0)
	v_u_142.Push()
	v_u_14:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, v_u_130)
	v_u_49.StartCapture()
end
local v_u_157 = false
local v_u_158 = nil
local function v_u_161(p159)
	-- upvalues: (copy) v_u_16, (ref) v_u_157, (ref) v_u_18, (copy) v_u_49, (copy) v_u_14, (copy) v_u_142, (copy) v_u_156, (ref) v_u_158
	for v160 = 1, #p159 - 1 do
		if not v_u_16:IsKeyDown(p159[v160]) then
			return
		end
	end
	if v_u_157 then
		v_u_49.StopCapture()
		v_u_14:UnbindFromRenderStep("Freecam")
		v_u_142.Pop()
	else
		v_u_156()
	end
	v_u_157 = not v_u_157
	v_u_158(v_u_157)
end
v_u_12:BindActionAtPriority("FreecamToggle", function(_, p162, p163)
	-- upvalues: (copy) v_u_22, (copy) v_u_161
	if p162 == Enum.UserInputState.Begin and p163.KeyCode == v_u_22[#v_u_22] then
		v_u_161(v_u_22)
	end
	return Enum.ContextActionResult.Pass
end, false, v_u_21 + 1, v_u_22[#v_u_22])
game:GetService("ReplicatedStorage")
local v_u_164 = game:GetService("UserInputService")
local v_u_165 = game:GetService("Players").LocalPlayer

-- Decompiled by Krnl

local thumbstick do
local v_u_1 = game:GetService("UserInputService")
local v_u_2 = Vector2.new(0, 0)
thumbstick= {
	["Create"] = function(p_u_3, p4, p5, p_u_6, p_u_7, p_u_8)
		-- upvalues: (copy) v_u_1, (copy) v_u_2
		if p_u_3.thumbstickFrame then
			p_u_3.thumbstickFrame:Destroy()
			p_u_3.thumbstickFrame = nil
			if p_u_3.onTouchMovedConn then
				p_u_3.onTouchMovedConn:Disconnect()
				p_u_3.onTouchMovedConn = nil
			end
			if p_u_3.onTouchEndedConn then
				p_u_3.onTouchEndedConn:Disconnect()
				p_u_3.onTouchEndedConn = nil
			end
		end
		local v9 = p4.AbsoluteSize.X
		local v10 = p4.AbsoluteSize.Y
		local v11 = math.min(v9, v10) <= 500
		p_u_3.thumbstickSize = v11 and 70 or 120
		p_u_3.screenPos = v11 and UDim2.new(0, p_u_3.thumbstickSize / 2 - 10, 1, -p_u_3.thumbstickSize - 20) or UDim2.new(0, p_u_3.thumbstickSize / 2, 1, -p_u_3.thumbstickSize * 1.75)
		p_u_3.thumbstickFrame = Instance.new("Frame")
		p_u_3.thumbstickFrame.Name = "ThumbstickFrame"
		p_u_3.thumbstickFrame.Active = true
		p_u_3.thumbstickFrame.Visible = false
		p_u_3.thumbstickFrame.Size = UDim2.new(0, p_u_3.thumbstickSize, 0, p_u_3.thumbstickSize)
		p_u_3.thumbstickFrame.Position = p_u_3.screenPos
		p_u_3.thumbstickFrame.BackgroundTransparency = 1
		local v12 = Instance.new("ImageLabel")
		v12.Name = "OuterImage"
		v12.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
		v12.ImageRectOffset = Vector2.new()
		v12.ImageRectSize = Vector2.new(220, 220)
		v12.BackgroundTransparency = 1
		v12.Size = UDim2.new(0, p_u_3.thumbstickSize, 0, p_u_3.thumbstickSize)
		v12.Position = UDim2.new(0, 0, 0, 0)
		v12.Parent = p_u_3.thumbstickFrame
		p_u_3.stickImage = Instance.new("ImageLabel")
		p_u_3.stickImage.Name = "StickImage"
		p_u_3.stickImage.Image = "rbxasset://textures/ui/TouchControlsSheet.png"
		p_u_3.stickImage.ImageRectOffset = Vector2.new(220, 0)
		p_u_3.stickImage.ImageRectSize = Vector2.new(111, 111)
		p_u_3.stickImage.BackgroundTransparency = 1
		p_u_3.stickImage.Size = UDim2.new(0, p_u_3.thumbstickSize / 2, 0, p_u_3.thumbstickSize / 2)
		p_u_3.stickImage.Position = UDim2.new(0, p_u_3.thumbstickSize / 2 - p_u_3.thumbstickSize / 4, 0, p_u_3.thumbstickSize / 2 - p_u_3.thumbstickSize / 4)
		p_u_3.stickImage.ZIndex = 2
		p_u_3.stickImage.Parent = p_u_3.thumbstickFrame
		if not p5 then
			p_u_3.stickImage.ImageTransparency = 1
			v12.ImageTransparency = 1
		end
		local v_u_13 = nil
		local v_u_14 = {}
		local function v_u_21(p15)
			-- upvalues: (copy) p_u_7, (copy) p_u_3, (ref) v_u_14, (copy) p_u_6
			if p15 then
				p_u_7()
			else
				local v16 = Vector2.new(p_u_3.moveVector.X, p_u_3.moveVector.Z)
				local v17 = { v16.Y < 0 and Enum.KeyCode.W or Enum.KeyCode.S, v16.X < 0 and Enum.KeyCode.A or Enum.KeyCode.D }
				if v_u_14 and #v_u_14 >= 1 then
					for v18, v19 in pairs(v_u_14) do
						if v17[v18] ~= v19 then
							p_u_6(v19, false)
						end
					end
				end
				for _, v20 in pairs(v17) do
					p_u_6(v20, true)
				end
				v_u_14 = v17
			end
		end
		local function v_u_27(p22)
			-- upvalues: (ref) v_u_13, (copy) p_u_3
			local v23 = Vector2.new(p22.X - v_u_13.X, p22.Y - v_u_13.Y)
			local v24 = v23.magnitude
			local v25 = p_u_3.thumbstickFrame.AbsoluteSize.X / 2
			if p_u_3.isFollowStick and v25 < v24 then
				local _ = v23.unit * v25
			else
				local v26 = math.min(v24, v25)
				v23 = v23.unit * v26
			end
			p_u_3.stickImage.Position = UDim2.new(0, v23.X + p_u_3.stickImage.AbsoluteSize.X / 2, 0, v23.Y + p_u_3.stickImage.AbsoluteSize.Y / 2)
		end
		p_u_3.thumbstickFrame.InputBegan:Connect(function(p28)
			-- upvalues: (copy) p_u_8, (copy) p_u_3, (ref) v_u_13
			p_u_8(true)
			if not p_u_3.moveTouchObject and (p28.UserInputType == Enum.UserInputType.Touch and p28.UserInputState == Enum.UserInputState.Begin) then
				p_u_3.moveTouchObject = p28
				v_u_13 = Vector2.new(p_u_3.thumbstickFrame.AbsolutePosition.X + p_u_3.thumbstickFrame.AbsoluteSize.X / 2, p_u_3.thumbstickFrame.AbsolutePosition.Y + p_u_3.thumbstickFrame.AbsoluteSize.Y / 2)
				Vector2.new(p28.Position.X - v_u_13.X, p28.Position.Y - v_u_13.Y)
			end
		end)
		p_u_3.onTouchMovedConn = v_u_1.TouchMoved:Connect(function(p29, _)
			-- upvalues: (copy) p_u_3, (ref) v_u_13, (copy) v_u_21, (copy) v_u_27
			if p29 == p_u_3.moveTouchObject then
				v_u_13 = Vector2.new(p_u_3.thumbstickFrame.AbsolutePosition.X + p_u_3.thumbstickFrame.AbsoluteSize.X / 2, p_u_3.thumbstickFrame.AbsolutePosition.Y + p_u_3.thumbstickFrame.AbsoluteSize.Y / 2)
				local v30 = Vector2.new(p29.Position.X - v_u_13.X, p29.Position.Y - v_u_13.Y)
				local v31 = v30 / (p_u_3.thumbstickSize / 2)
				local v32 = v31.magnitude
				local v33
				if v32 < 0.05 then
					v33 = Vector3.new()
				else
					local v34 = v31.unit * ((v32 - 0.05) / 0.95)
					local v35 = v34.X
					local v36 = v34.Y
					v33 = Vector3.new(v35, 0, v36)
				end
				p_u_3.direction = v30
				p_u_3.moveVector = v33
				v_u_21()
				v_u_27(p29.Position)
			end
		end)
		p_u_3.onTouchEndedConn = v_u_1.TouchEnded:Connect(function(p37, _)
			-- upvalues: (copy) p_u_3, (copy) p_u_8, (ref) v_u_2, (ref) v_u_14, (copy) v_u_21
			if p37 == p_u_3.moveTouchObject then
				p_u_3.stickImage.Position = UDim2.new(0, p_u_3.thumbstickFrame.Size.X.Offset / 2 - p_u_3.thumbstickSize / 4, 0, p_u_3.thumbstickFrame.Size.Y.Offset / 2 - p_u_3.thumbstickSize / 4)
				p_u_8(false)
				p_u_3.moveVector = Vector3.new(0, 0, 0)
				p_u_3.isJumping = false
				p_u_3.moveTouchObject = nil
				p_u_3.direction = v_u_2
				v_u_14 = {}
				v_u_21(true)
			end
		end)
		p_u_3.thumbstickFrame.Parent = p4
		return p_u_3.thumbstickFrame
	end
}
end

local v_u_168 = nil
local function v188()
	-- upvalues: (copy) v_u_2, (ref) v_u_168, (copy) v_u_164, (ref) v_u_157, (copy) v_u_165
	local v_u_169 = nil
	local v_u_170 = 15
	local v_u_171 = 0
	local v_u_172 = v_u_2.Advanced.FovWheelSpeed * 3 / 4
	local v_u_173 = nil
	local v_u_174 = tick() - 0.1
	v_u_168 = thumbstick:Create(({...})[1], v_u_2.ThumbstickVisibleForMobile, function(p175, p176)
		globalKp(nil, p176 and Enum.UserInputState.Begin or Enum.UserInputState.End, {
			["KeyCode"] = p175
		})
	end, function()
		local v177 = {
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D
		}
		for _, v178 in pairs(v177) do
			globalKp(nil, Enum.UserInputState.End, {
				["KeyCode"] = v178
			})
		end
	end, function(p179)
		-- upvalues: (ref) v_u_173, (ref) v_u_174
		v_u_173 = p179
		v_u_174 = tick()
	end)
	v_u_164.TouchPinch:Connect(function(_, p180, _, p181)
		-- upvalues: (ref) v_u_157, (ref) v_u_173, (ref) v_u_174, (ref) v_u_169, (ref) v_u_170, (ref) v_u_165, (ref) v_u_171, (copy) v_u_172
		if (p181 == Enum.UserInputState.Change or p181 == Enum.UserInputState.End) and (v_u_157 and (not v_u_173 and tick() - v_u_174 > 0.1)) then
			v_u_170 = v_u_170 * (1 + (p180 - v_u_169))
			local v182 = v_u_170
			v_u_170 = math.max(v182, 0)
			v_u_165.CameraMinZoomDistance = 5
			v_u_165.CameraMaxZoomDistance = 5
			local v183 = v_u_170 - v_u_171 < 1 and v_u_172 or -v_u_172
			globalMouse.MouseWheel = v183
			v_u_171 = v_u_170
		end
		v_u_169 = p180
	end)
	local v_u_184 = nil
	v_u_164.TouchPan:Connect(function(_, p185, _, p186)
		-- upvalues: (ref) v_u_157, (ref) v_u_173, (ref) v_u_184
		if (p186 == Enum.UserInputState.Change or p186 == Enum.UserInputState.End) and (v_u_157 and not v_u_173) then
			local v187 = p185 - v_u_184
			globalMouse.Delta = Vector2.new(-v187.Y, -v187.X)
		end
		v_u_184 = p185
	end)
end

		local v_u_190 = 0
		local v_u_191 = 0
	
		local function v_u_192()
			if v_u_168 then
				v_u_168.Visible = true
			end
			v_u_190 = v_u_165.CameraMinZoomDistance
			v_u_191 = v_u_165.CameraMaxZoomDistance
			v_u_157 = true
			if v_u_157 or v_u_140 == nil then
				if v_u_157 and not v_u_140 then
					v_u_156()
				end
			else
				v_u_49.StopCapture()
				v_u_14:UnbindFromRenderStep("Freecam")
				v_u_142.Pop()
			end
		end
		local function v_u_193()
			v_u_157 = false
			if v_u_157 or v_u_140 == nil then
				if v_u_157 and not v_u_140 then
					v_u_156()
				end
			else
				v_u_49.StopCapture()
				v_u_14:UnbindFromRenderStep("Freecam")
				v_u_142.Pop()
			end
	
			v_u_165.CameraMinZoomDistance = v_u_190
			v_u_165.CameraMaxZoomDistance = v_u_191
			if v_u_168 then
				v_u_168.Visible = false
			end
		end
        v_u_158 = function(p193)
			if p193 then enable() else disable() end
		end
	
if v_u_164.TouchEnabled then
	v188()
end

return v_u_192, v_u_193, v_u_2
