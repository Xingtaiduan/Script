local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = cloneref(game.CoreGui)
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
Frame.Active = true
Frame.Draggable = true

local up = Instance.new("TextButton")
up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "上升"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

local down = Instance.new("TextButton")
down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "下降"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

local onof = Instance.new("TextButton")
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "飞行"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Fly GUI V3"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

local plus = Instance.new("TextButton")
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true

local speedbox = Instance.new("TextBox")
speedbox.Name = "speed"
speedbox.Parent = Frame
speedbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedbox.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speedbox.Size = UDim2.new(0, 44, 0, 28)
speedbox.Font = Enum.Font.SourceSans
speedbox.Text = "1"
speedbox.TextColor3 = Color3.new(0, 0, 0)
speedbox.TextScaled = true
speedbox.TextSize = 14.000
speedbox.TextWrapped = true

local mine = Instance.new("TextButton")
mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true

local closebutton = Instance.new("TextButton")
closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = "SourceSans"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position = UDim2.new(0, 0, -1, 27)

local mini = Instance.new("TextButton")
mini.Name = "minimize"
mini.Parent = Frame
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = "SourceSans"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)

local mode = Instance.new("TextButton", Frame)
mode.Size = UDim2.new(0, 50, 0, 10)
mode.Position = UDim2.new(0, 10, 1, 3)
mode.TextSize = 16
mode.Font = "SourceSans"
mode.Text = "模式：Velocity"
mode.TextColor3 = Color3.new(1, 1, 1)
mode.BackgroundTransparency = 1

local flyspeed = 1
local flying = false
local flymode = "Velocity"

local lastPosition
onof.MouseButton1Down:connect(function()
    flying = not flying
    local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
    humanoid.PlatformStand = flying
    if not flying then return end
    local rootPart = LP.Character.HumanoidRootPart
    while flying do
        local dt = RunService.Heartbeat:Wait()
        local moveVector = camera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
        local moveDirection = -((camera.CFrame.LookVector * moveVector.Z) - (camera.CFrame.RightVector * moveVector.X))
        if flymode == "Velocity" then
            if moveDirection.Magnitude > 0 then
                rootPart.Anchored = false
                rootPart.Velocity = moveDirection * flyspeed * 10
            else
                rootPart.Velocity = Vector3.zero
                rootPart.Anchored = true
            end
            rootPart.CFrame = CFrame.lookAlong(rootPart.CFrame.Position, camera.CFrame.LookVector)
        else
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
                lastPosition = rootPart.Position + moveDirection * flyspeed * dt * 50
            elseif not lastPosition then
                lastPosition = rootPart.Position
            end
		    rootPart.CFrame = CFrame.new(lastPosition, lastPosition + camera.CFrame.LookVector)
		    rootPart.Velocity = Vector3.zero
        end
    end
    lastPosition = nil
    rootPart.Anchored = false
    humanoid.PlatformStand = false
end)

local tis
up.MouseButton1Down:connect(function()
    tis = up.MouseEnter:connect(function()
        while tis do task.wait()
            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
        end
    end)
end)

up.MouseLeave:connect(function()
    if tis then
        tis:Disconnect()
        tis = nil
    end
end)

local dis
down.MouseButton1Down:connect(function()
    dis = down.MouseEnter:connect(function()
        while dis do task.wait()
            LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
        end
    end)
end)

down.MouseLeave:connect(function()
    if dis then
        dis:Disconnect()
        dis = nil
    end
end)

speedbox:GetPropertyChangedSignal("Text"):Connect(function()
    if tonumber(speedbox.Text) then
        flyspeed = tonumber(speedbox.Text)
    end
end)

plus.MouseButton1Down:connect(function()
    flyspeed = flyspeed + 1
    speedbox.Text = flyspeed
end)

mine.MouseButton1Down:connect(function()
    flyspeed = flyspeed - 1
    speedbox.Text = flyspeed
end)

closebutton.MouseButton1Click:Connect(function()
    flying = false
    main:Destroy()
end)

mode.MouseButton1Click:Connect(function()
    flymode = flymode == "Velocity" and "CFrame" or "Velocity"
    mode.Text = "模式："..flymode
end)

local visible = true
mini.MouseButton1Click:Connect(function()
    visible = not visible
    up.Visible = visible
    down.Visible = visible
    onof.Visible = visible
    plus.Visible = visible
    speedbox.Visible = visible
    mine.Visible = visible
    mode.Visible = visible
    mini.Text = visible and "-" or "+"
    Frame.BackgroundTransparency = visible and 0 or 1
    mini.Position = visible and UDim2.new(0, 44, -1, 27) or UDim2.new(0, 44, -1, 57)
    closebutton.Position = visible and UDim2.new(0, 0, -1, 27) or UDim2.new(0, 0, -1, 57)
end)
