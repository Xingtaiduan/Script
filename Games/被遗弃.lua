--//GameId: 6331902150
local Library, ThemeManager, SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Library/Obsidian.lua"))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/ESPLibrary.lua"))()
local Options = Library.Options

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 5)
local RootPart = Character:WaitForChild("HumanoidRootPart", 5)

local map = workspace.Map.Ingame:FindFirstChild("Map")

--//Functions

local function GeneratorESP(v)
    local progress = v:FindFirstChild("Progress")
    if not progress then return end
    if progress.Value == 100 then return end
    local ESP = ESPLibrary.Add(v, string.format("发电机[%s%%]", progress.Value), Options.GeneratorESPColor.Value, 15, "GeneratorESP")
    progress:GetPropertyChangedSignal("Value"):Connect(function()
        ESP.Settings.Name = string.format("发电机[%s%%]", progress.Value)
        if progress.Value == 100 then
            ESP:Destroy()
        end
    end)
end

--//Main
local Window = Library:CreateWindow({
    Title = "XA Hub",
    Footer = "被遗弃[beta] v0.0.0.6",
    Center = true,
    AutoShow = true,
    Resizable = true,
    NotifySide = "Right",
	ShowCustomCursor = true,
    Size = UDim2.fromOffset(580, 350)
})

local Tab = Window:AddTab("主要")

local LeftGroup = Tab:AddLeftGroupbox("主要")

LeftGroup:AddToggle("AutoGenerator", {
    Text = "自动修发电机",
    Default = false, 
    Callback = function(Value)
    while Options.AutoGenerator.Value do task.wait()
        if not map then continue end
        for i, v in pairs(map:GetChildren()) do
            if v.Name == "Generator" and v.Progress.Value ~= 100 then
                v.Remotes.RE:FireServer()
            end
        end
        task.wait(math.random(200,350)/100)
    end
    end
})

LeftGroup:AddButton("传送到发电机", function()
    if not map then return end
    for i, v in pairs(map:GetChildren()) do
        if v.Name == "Generator" and v.Progress.Value ~= 100 then
            RootPart.CFrame = v.Positions.Center.CFrame
            break
        end
    end
end)

LeftGroup:AddToggle("InfStamina", {
    Text = "无限体力",
    Default = false, 
    Callback = function(Value)
    local module = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
    while Options.InfStamina.Value do task.wait()
        module.Stamina = 100
    end
    end
})

LeftGroup:AddSlider("WalkSpeed", {
    Text = "移动速度",
    Default = 16,
    Min = 0,
    Max = 25,
    Rounding = 0,
    Compact = true,
})

LeftGroup:AddToggle("EnabledSpeed", {
    Text = "启用速度",
    Default = false, 
    Callback = function(Value)
    while Options.EnabledSpeed.Value do task.wait()
        Humanoid:SetAttribute("BaseSpeed", Options.WalkSpeed.Value)
    end
    end
})

local Tab = Window:AddTab("视觉")

local LeftGroup = Tab:AddLeftGroupbox("透视")

LeftGroup:AddToggle("SurvivorESP", {
    Text = "幸存者",
    Default = false,
    Callback = function(Value)
    if Value then
        for _, v in pairs(workspace.Players.Survivors:GetChildren()) do
            ESPLibrary.Add(v, v.Name, Options.SurvivorESPColor.Value, 15, "SurvivorESP")
        end
    else
        ESPLibrary.Clear("SurvivorESP")
    end
    end
}):AddColorPicker("SurvivorESPColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESPLibrary.Update("SurvivorESP", {Color = Value})
    end
})

LeftGroup:AddToggle("KillerESP", {
    Text = "杀手",
    Default = false,
    Callback = function(Value)
    if Value then
        for _, v in pairs(workspace.Players.Killers:GetChildren()) do
            ESPLibrary.Add(v, v.Name, Options.KillerESPColor.Value, 15, "KillerESP")
        end
    else
        ESPLibrary.Clear("KillerESP")
    end
    end
}):AddColorPicker("KillerESPColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        ESPLibrary.Update("KillerESP", {Color = Value})
    end
})

LeftGroup:AddToggle("GeneratorESP", {
    Text = "发电机",
    Default = false,
    Callback = function(Value)
    if Value then
        for _, v in pairs(workspace.Map.Ingame:GetDescendants()) do
            if v.Name == "Generator" and v.Parent == map then
                GeneratorESP(v)
            end
        end
    else
        ESPLibrary.Clear("GeneratorESP")
    end
    end
}):AddColorPicker("GeneratorESPColor", {
    Default = Color3.new(0, 1, 0),
    Callback = function(Value)
        ESPLibrary.Update("GeneratorESP", {Color = Value})
    end
})

LeftGroup:AddToggle("ItemESP", {
    Text = "物品",
    Default = false,
    Callback = function(Value)
    if Value then
        for _, v in pairs(workspace.Map.Ingame:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("ItemRoot") then
                ESPLibrary.Add(v, v.Name, Options.ItemESPColor.Value, 15, "ItemESP")
            end
        end
    else
        ESPLibrary.Clear("ItemESP")
    end
    end
}):AddColorPicker("ItemESPColor", {
    Default = Color3.fromRGB(0, 255, 230),
    Callback = function(Value)
        ESPLibrary.Update("ItemESP", {Color = Value})
    end
})

local RightGroup = Tab:AddRightGroupbox("其他")

RightGroup:AddToggle("Fullbright", {
    Text = "高亮",
    Default = false,
    Callback = function(Value)
    while Options.Fullbright.Value do task.wait()
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
    end
})

RightGroup:AddToggle("NoFog", {
    Text = "没有雾",
    Default = false,
    Callback = function(Value)
    while Options.NoFog.Value do task.wait()
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v:Destroy() end
        end
        Lighting.FogStart = 0
        Lighting.FogEnd = math.huge
    end
    end
})

local Settings = Window:AddTab("UI设置", "settings")

local MenuGroup = Settings:AddLeftGroupbox("菜单", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "打开按键绑定菜单",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "显示自定义光标",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "左侧", "右侧" },
	Default = "右侧",
	Text = "通知侧边",
	Callback = function(Value)
	    local side = Value == "左侧" and "Left" or "Right"
		Library:SetNotifySide(side)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI缩放",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("菜单绑定"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "菜单按键绑定" })
MenuGroup:AddButton("取消加载", function()
	Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind

--//Connections

Library:GiveSignal(workspace.Players.Survivors.ChildAdded:Connect(function(v)
    if Options.SurvivorESP.Value then
        ESPLibrary.Add(v, v.Name, Options.SurvivorESPColor.Value, 15, "SurvivorESP")
    end
end))

Library:GiveSignal(workspace.Players.Killers.ChildAdded:Connect(function(v)
    if Options.KillerESP.Value then
        ESPLibrary.Add(v, v.Name, Options.KillerESPColor.Value, 15, "KillerESP")
    end
end))

Library:GiveSignal(workspace.Map.Ingame.DescendantAdded:Connect(function(v)
    if Options.GeneratorESP.Value and v.Name == "Generator" and v.Parent == map then
        GeneratorESP(v)
    elseif Options.ItemESP.Value and v:IsA("Tool") and v:FindFirstChild("ItemRoot") then
        ESPLibrary.Add(v, v.Name, Options.ItemESPColor.Value, 15, "ItemESP")
    end
end))

Library:GiveSignal(workspace.Map.Ingame.ChildAdded:Connect(function(v)
    if v:IsA("Model") and v.Name == "Map" then
        map = v
    end
end))

Library:GiveSignal(LP.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end))

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("XA-Hub/Obsidian")
ThemeManager:ApplyToTab(Settings)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("XA-Hub/Obsidian/"..game.PlaceId)
SaveManager:BuildConfigSection(Settings)
SaveManager:LoadAutoloadConfig()
