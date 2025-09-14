--if getgenv().ESPLibrary then
    --return getgenv().ESPLibrary
--end

local cloneref = cloneref or function(a) return a end
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LP = Players.LocalPlayer
local Character = LP.Character
local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local function GetDistance(position)
    if RootPart then
        return (RootPart.Position - position).Magnitude
    elseif Camera then
        return (Camera.CFrame.Position - position).Magnitude
    end
    return 9e9
end

local function FindPrimaryPart(instance)
    return (instance:IsA("Model") and instance.PrimaryPart or nil)
        or instance:FindFirstChildWhichIsA("BasePart")
        or instance:FindFirstChildWhichIsA("UnionOperation")
        or instance
end

local Library = {
    ESP = {},
    Tags = {},
    Connections = {},
    ESPFolder = Instance.new("Folder", CoreGui),
    DefaultSettings = {
        Name = "Unnamed",
        Color = Color3.new(1, 1, 1),
        TextSize = 15,
        Tag = "DefaultTag",
        ShowTextLabel = true,
        ShowHighlight = true,
        ShowDistance = true,
        MaxDistance = math.huge,
        ShowTracer = false,
        TracerPosition = "Bottom",
        TracerThickness = 1,
        TracerTransparency = 1
    }
}

Library.ESPFolder.Name = "ESPFolder"
Library.GlobalSettings = setmetatable({}, {
    __newindex = function(_, key, value)
        Library.DefaultSettings[key] = value
        for _, ESP in pairs(Library.ESP) do
            ESP.Settings[key] = value
        end
    end
})

Library.Add = function(...)
    local espSettings
    if typeof(...) == "table" then
        espSettings = ...
    else
        local object, name, color, size, tag = ...
        espSettings = {Object = object,Name = name,Color = color,TextSize = size,Tag = tag}
    end
    
    assert(espSettings.Object, "missing esp object")
    for i, v in pairs(Library.DefaultSettings) do
        if espSettings[i] == nil then
            espSettings[i] = v
        end
    end
    
    local ESP = {
        Index = #Library.ESP+1,
        Settings = espSettings
    }
    ESP.Folder = Instance.new("Folder", Library.ESPFolder)
    ESP.Folder.Name = ESP.Settings.Tag
    
    if Library.Tags[ESP.Settings.Tag] == nil then
        Library.Tags[ESP.Settings.Tag] = true
    end
    
    local BillboardGui = Instance.new("BillboardGui", ESP.Folder)
    BillboardGui.Name = ESP.Settings.Tag
    BillboardGui.Enabled = false
    BillboardGui.ResetOnSpawn = false
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.Adornee = ESP.Settings.Object
    BillboardGui.StudsOffset = Vector3.new(0, 0, 0)
    ESP.BillboardGui = BillboardGui
        
    local TextLabel = Instance.new("TextLabel", BillboardGui)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextWrapped = true
    TextLabel.RichText = true
    TextLabel.TextStrokeTransparency = 0.5
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = ESP.Settings.Name
    TextLabel.TextColor3 = ESP.Settings.Color
    TextLabel.TextSize = ESP.Settings.TextSize
    Instance.new("UIStroke", TextLabel)
    ESP.TextLabel = TextLabel
    
    local Highlight = Instance.new("Highlight", ESP.Folder)
    Highlight.Adornee = nil
    Highlight.FillColor = ESP.Settings.Color
    Highlight.OutlineColor = ESP.Settings.Color
    Highlight.FillTransparency = 0.65
    Highlight.OutlineTransparency = 0
    ESP.Highlight = Highlight
    
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = ESP.Settings.Color
    Tracer.Thickness = ESP.Settings.TracerThickness
    Tracer.Transparency = ESP.Settings.TracerTransparency
    ESP.Tracer = Tracer
    
    function ESP:Destroy()
        ESP.Folder:Destroy()
        if ESP.Tracer then
            ESP.Tracer:Remove()
        end
        Library.ESP[ESP.Index] = nil
    end
    
    function ESP:ToggleVisibility(Value)
        if ESP.BillboardGui and ESP.Settings.ShowTextLabel then
            ESP.BillboardGui.Enabled = Value
        end
        if ESP.Highlight and ESP.Settings.ShowHighlight then
            ESP.Highlight.Adornee = Value and ESP.Settings.Object or nil
        end
        if ESP.Tracer and ESP.Settings.ShowTracer then
            ESP.Tracer.Visible = Value
        end
    end
    ESP:ToggleVisibility(Library.Tags[ESP.Settings.Tag])

    Library.ESP[ESP.Index] = ESP
    return ESP
end

Library.SetEnabled = function(tag, value)
    Library.Tags[tag] = value
end

Library.ForEachTag = function(tag, callback)
    for _, ESP in pairs(Library.ESP) do
        if ESP.Settings.Tag == tag then
            callback(ESP)
        end
    end
end

Library.Update = function(tag, newSettings)
    Library.ForEachTag(tag, function(ESP)
        for i, v in pairs(newSettings) do
            ESP.Settings[i] = v
        end
    end)
end

Library.Clear = function(tag)
    Library.ForEachTag(tag, function(ESP)
        ESP:Destroy()
    end)
end

Library.Destroy = function()
    Library.ESPFolder:Destroy()
    for _, v in pairs(Library.Connections) do
        v:Disconnect()
    end
    table.clear(Library)
    getgenv().ESPLibrary = nil
end

table.insert(Library.Connections, LP.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    RootPart = Character:WaitForChild("HumanoidRootPart")
end))

table.insert(Library.Connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end))

table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
    for _, ESP in pairs(Library.ESP) do
        if not ESP.Settings.Object or not ESP.Settings.Object.Parent then
            ESP:Destroy()
            continue
        end
        if not Library.Tags[ESP.Settings.Tag] then
            ESP:ToggleVisibility(false)
            continue
        end
        
        if not ESP.Settings.ModelRoot then
            ESP.Settings.ModelRoot = FindPrimaryPart(ESP.Settings.Object)
        end
        local TargetPosition = ESP.Settings.ModelRoot:GetPivot().Position
        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPosition)
        ESP:ToggleVisibility(OnScreen)
        if not OnScreen then continue end
        
        local Distance = GetDistance(TargetPosition)
        if Distance > ESP.Settings.MaxDistance then
            ESP:ToggleVisibility(false)
            continue
        end
        
        if ESP.BillboardGui then
            ESP.BillboardGui.Enabled = ESP.Settings.ShowTextLabel
            if ESP.BillboardGui.Enabled then
                ESP.TextLabel.TextColor3 = ESP.Settings.Color
                ESP.TextLabel.TextSize = ESP.Settings.TextSize
                if ESP.Settings.ShowDistance then
                    ESP.TextLabel.Text = ("%s\n[%s]"):format(ESP.Settings.Name, math.floor(Distance))
                else
                    ESP.TextLabel.Text = ESP.Settings.Name
                end
            end
        end
        
        if ESP.Highlight then
            ESP.Highlight.Adornee = ESP.Settings.ShowHighlight and ESP.Settings.Object or nil
            if ESP.Highlight.Adornee then
                ESP.Highlight.FillColor = ESP.Settings.Color
                ESP.Highlight.OutlineColor = ESP.Settings.Color
            end
        end
        
        if ESP.Tracer then
            ESP.Tracer.Visible = ESP.Settings.ShowTracer
            if ESP.Tracer.Visible then
                local TracerY
                if ESP.Settings.TracerPosition == "Top" then
                    TracerY = 0
                elseif ESP.Settings.TracerPosition == "Center" then
                    TracerY = Camera.ViewportSize.Y / 2
                elseif ESP.Settings.TracerPosition == "Bottom" then
                    TracerY = Camera.ViewportSize.Y
                end
                ESP.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, TracerY)
                ESP.Tracer.To = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                ESP.Tracer.Color = ESP.Settings.Color
                ESP.Tracer.Thickness = ESP.Settings.TracerThickness
                ESP.Tracer.Transparency = ESP.Settings.TracerTransparency
            end
        end
    end
end))

getgenv().ESPLibrary = Library
return Library
