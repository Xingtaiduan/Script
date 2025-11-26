local gethui = gethui or function()
    return cloneref(game:GetService("CoreGui"))
end

local GUI = gethui():FindFirstChild("STX_Nofitication")
if not GUI then
    local STX_Nofitication = Instance.new("ScreenGui")
    local STX_NofiticationUIListLayout = Instance.new("UIListLayout")
    STX_Nofitication.Name = "STX_Nofitication"
    STX_Nofitication.Parent = gethui()
    STX_Nofitication.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    STX_Nofitication.ResetOnSpawn = false

    STX_NofiticationUIListLayout.Name = "STX_NofiticationUIListLayout"
    STX_NofiticationUIListLayout.Parent = STX_Nofitication
    STX_NofiticationUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    STX_NofiticationUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    STX_NofiticationUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local Nofitication = {}
local GUI = gethui():FindFirstChild("STX_Nofitication")
function Nofitication:Notify(settings)
    local SelectedType = string.lower(tostring(settings.Type))
    local ambientShadow = Instance.new("ImageLabel")
    local Window = Instance.new("Frame")
    local Outline_A = Instance.new("Frame")
    local WindowTitle = Instance.new("TextLabel")
    local WindowDescription = Instance.new("TextLabel")

    ambientShadow.Name = "ambientShadow"
    ambientShadow.Parent = GUI
    ambientShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientShadow.BackgroundTransparency = 1.000
    ambientShadow.BorderSizePixel = 0
    ambientShadow.Position = UDim2.new(0.91525954, 0, 0.936809778, 0)
    ambientShadow.Size = UDim2.new(0, 0, 0, 0)
    ambientShadow.ScaleType = Enum.ScaleType.Slice
    ambientShadow.SliceCenter = Rect.new(10, 10, 118, 118)

    Window.Name = "Window"
    Window.Parent = ambientShadow
    Window.BackgroundColor3 = Color3.new(0, 0, 0)
    Window.BackgroundTransparency = 0.5
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, 5, 0, 5)
    Window.Size = UDim2.new(0, 230, 0, 80)
    Window.ZIndex = 2
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 8)

    Outline_A.Name = "Outline_A"
    Outline_A.Parent = Window
    Outline_A.BackgroundColor3 = settings.OutlineColor
    Outline_A.BorderSizePixel = 0
    Outline_A.Position = UDim2.new(0, 0, 0, 25)
    Outline_A.Size = UDim2.new(0, 230, 0, 2)
    Outline_A.ZIndex = 5

    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = Window
    WindowTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.BackgroundTransparency = 1.000
    WindowTitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Position = UDim2.new(0, 8, 0, 2)
    WindowTitle.Size = UDim2.new(0, 222, 0, 22)
    WindowTitle.ZIndex = 4
    WindowTitle.Font = Enum.Font.GothamSemibold
    WindowTitle.Text = settings.Title
    WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.TextSize = 12.000
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left

    WindowDescription.Name = "WindowDescription"
    WindowDescription.Parent = Window
    WindowDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowDescription.BackgroundTransparency = 1.000
    WindowDescription.BorderColor3 = Color3.fromRGB(27, 42, 53)
    WindowDescription.BorderSizePixel = 0
    WindowDescription.Position = UDim2.new(0, 8, 0, 34)
    WindowDescription.Size = UDim2.new(0, 216, 0, 40)
    WindowDescription.ZIndex = 4
    WindowDescription.Font = Enum.Font.GothamSemibold
    WindowDescription.Text = settings.Description
    WindowDescription.TextColor3 = Color3.fromRGB(220, 220, 220)
    WindowDescription.TextSize = 12.000
    WindowDescription.TextWrapped = true
    WindowDescription.TextXAlignment = Enum.TextXAlignment.Left
    WindowDescription.TextYAlignment = Enum.TextYAlignment.Top

    if SelectedType == "default" then
        ambientShadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 80)
        WindowTitle.Position = UDim2.new(0, 24, 0, 2)
        local ImageButton = Instance.new("ImageButton")
        ImageButton.Parent = Window
        ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageButton.BackgroundTransparency = 1.000
        ImageButton.BorderSizePixel = 0
        ImageButton.Position = UDim2.new(0, 4, 0, 4)
        ImageButton.Size = UDim2.new(0, 18, 0, 18)
        ImageButton.ZIndex = 5
        ImageButton.AutoButtonColor = false
        ImageButton.Image = settings.Image
        ImageButton.ImageColor3 = settings.ImageColor

        Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", settings.Time)
        task.wait(settings.Time)
        ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
        task.wait(0.2)
        ambientShadow:Destroy()
    elseif SelectedType == "option" then
        ambientShadow:TweenSize(UDim2.new(0, 240, 0, 110), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 100)
        local No = Instance.new("ImageButton")
        local Yes = Instance.new("ImageButton")

        No.Name = "No"
        No.Parent = Window
        No.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        No.BackgroundTransparency = 1.000
        No.BorderSizePixel = 0
        No.Position = UDim2.new(0, 7, 0, 76)
        No.Size = UDim2.new(0, 18, 0, 18)
        No.ZIndex = 5
        No.AutoButtonColor = false
        No.Image = "http://www.roblox.com/asset/?id=6031094678"
        No.ImageColor3 = Color3.fromRGB(255, 84, 84)

        Yes.Name = "Yes"
        Yes.Parent = Window
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 1.000
        Yes.BorderSizePixel = 0
        Yes.Position = UDim2.new(0, 28, 0, 76)
        Yes.Size = UDim2.new(0, 18, 0, 18)
        Yes.ZIndex = 5
        Yes.AutoButtonColor = false
        Yes.Image = "http://www.roblox.com/asset/?id=6031094667"
        Yes.ImageColor3 = Color3.fromRGB(83, 230, 50)

        local function Cancel()
            pcall(settings.Callback, false)
            ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            task.wait(0.2)
            ambientShadow:Destroy()
        end
        local function Confirm()
            pcall(settings.Callback, true)
            ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            task.wait(0.2)
            ambientShadow:Destroy()
        end
        No.MouseButton1Click:Connect(Cancel)
        Yes.MouseButton1Click:Connect(Confirm)

        Outline_A:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", settings.Time)

        task.wait(settings.Time)

        if ambientShadow.Parent then
            ambientShadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            task.wait(0.2)
            ambientShadow:Destroy()
        end
    end
end
    
local function notify(...)
    local args = {...}
    task.spawn(function()
    Nofitication:Notify({
        Title = args[1],
        Description = args[2],
        Time = args[3],
        Type = "default",
        OutlineColor = Color3.fromRGB(80, 80, 80),
        Image = "http://www.roblox.com/asset/?id=6023426923",
        ImageColor = Color3.fromRGB(255, 84, 84)
    })
    end)
end

getgenv().notify = notify
return notify
