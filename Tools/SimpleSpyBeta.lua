--!native
--50/50 this breaks but it's a beta for a reason!

--Modification Made By Xingtaiduan

if getgenv().SimpleSpyExecuted and type(getgenv().SimpleSpyShutdown) == "function" then
    getgenv().SimpleSpyShutdown()
end

if identifyexecutor() == "Arceus X" then
    getgenv().getcallbackvalue=nil
end

local realconfigs = {
    logcheckcaller = false,
    autoblock = false,
    funcEnabled = true,
    advancedinfo = false,
    logreturnvalues = false,
    logfireclient = false,
    loginvokeclient = false
}

local configs = newproxy(true)
local configsmetatable = getmetatable(configs)

configsmetatable.__index = function(self,index)
    return realconfigs[index]
end

local running = coroutine.running
local resume = coroutine.resume
local yield = coroutine.yield
local OldDebugId = game.GetDebugId
local info = debug.info

local IsA = game.IsA
local tostring = tostring
local tonumber = tonumber
local spawn = task.spawn
local clear = table.clear
local clone = table.clone

local function blankfunction(...)
    return ...
end

local getinfo = getinfo or blankfunction
local getupvalues = getupvalues or debug.getupvalues or blankfunction
local getconstants = getconstants or debug.getconstants or blankfunction

local getcallingscript = getcallingscript or blankfunction
local getcallbackvalue = getcallbackvalue or getcallbackmember
local newcclosure = newcclosure or blankfunction
local clonefunction = clonefunction or blankfunction
local cloneref = cloneref or blankfunction
local request = request or syn and syn.request

local isreadonly = isreadonly or table.isfrozen

local hookmetamethod = hookmetamethod or (setreadonly and getrawmetatable) and function(obj: object, metamethod: string, func: Function)
    local old = getrawmetatable(obj)

    if hookfunction then
        return hookfunction(old[metamethod],func)
    else
        local oldmetamethod = old[metamethod]
        setreadonly(old, false)
        old[metamethod] = func
        setreadonly(old, true)
        return oldmetamethod
    end
end

local decompile = decompile or newcclosure(function(target)
    local bytecode = getscriptbytecode(target)
    if bytecode then
        local output = request({
            Url = "http://api.plusgiant5.com/konstant/decompile",
            Method = "POST",
            Body = bytecode,
			Headers = {
				["Content-Type"] = "text/plain"
			}
        })
        if output.StatusCode == 200 then
            return output.Body
        end
        return "-- failed to decompile bytecode: " .. output.StatusMessage
    end
	return "-- failed to decompile bytecode"
end)

local function Create(instance, properties, children)
    local obj = Instance.new(instance)

    for i, v in next, properties or {} do
        obj[i] = v
        for _, child in next, children or {} do
            child.Parent = obj;
        end
    end
    return obj;
end

local function SafeGetService(service)
    return cloneref(game:GetService(service))
end

local function IsCyclicTable(tbl)
    local checkedtables = {}

    local function SearchTable(tbl)
        table.insert(checkedtables,tbl)
        
        for i,v in next, tbl do -- Stupid mistake on my part thanks 59it for pointing it out
            if type(v) == "table" then
                return table.find(checkedtables,v) and true or SearchTable(v)
            end
        end
    end

    return SearchTable(tbl)
end

local function deepclone(args: table, copies: table): table
    local copy = nil
    copies = copies or {}

    if type(args) == 'table' then
        if copies[args] then
            copy = copies[args]
        else
            copy = {}
            copies[args] = copy
            for i, v in next, args do
                copy[deepclone(i, copies)] = deepclone(v, copies)
            end
        end
    elseif typeof(args) == "Instance" then
        copy = cloneref(args)
    else
        copy = args
    end
    return copy
end

local function rawtostring(userdata)
    if type(userdata) == "table" or typeof(userdata) == "userdata" then
        local rawmetatable = getrawmetatable(userdata)
        local cachedstring = rawmetatable and rawget(rawmetatable, "__tostring")

        if cachedstring then
            local wasreadonly = isreadonly(rawmetatable)
            if wasreadonly then
                setreadonly(rawmetatable, false)
            end
            rawset(rawmetatable, "__tostring", nil)
            local safestring = tostring(userdata)
            rawset(rawmetatable, "__tostring", cachedstring)
            if wasreadonly then
                setreadonly(rawmetatable, true)
            end
            return safestring
        end
    end
    return tostring(userdata)
end

local CoreGui = SafeGetService("CoreGui")
local Players = SafeGetService("Players")
local RunService = SafeGetService("RunService")
local UserInputService = SafeGetService("UserInputService")
local TweenService = SafeGetService("TweenService")
local TextService = SafeGetService("TextService")
local http = SafeGetService("HttpService")
local GuiInset = game:GetService("GuiService"):GetGuiInset()

local function jsone(str) return http:JSONEncode(str) end
local function jsond(str)
    local suc,err = pcall(http.JSONDecode,http,str)
    return suc and err or suc
end

function ErrorPrompt(Message)
    local MessageBox = loadstring(game:HttpGet("https://pastebin.com/raw/6uBnwKW9"))()
    MessageBox({Position = UDim2.new(0.5,0,0.5,0), Text = "SimpleSpy错误", Description = Message, MessageBoxIcon = "Error", MessageBoxButtons = "OK"})
end

local Highlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/Highlight.lua"))()
local Serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Tools/Serializer.lua"))()

local SimpleSpy3 = Create("ScreenGui",{Name = "SimpleSpy",ResetOnSpawn = false})
local Storage = Create("Folder",{})
local Background = Create("Frame",{Parent = SimpleSpy3,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 170, 0, 100),Size = UDim2.new(0, 450, 0, 268),Active = true,Draggable = true})
local LeftPanel = Create("Frame",{Parent = Background,BackgroundColor3 = Color3.fromRGB(53, 52, 55),BorderSizePixel = 0,Position = UDim2.new(0, 0, 0, 19),Size = UDim2.new(0, 131, 0, 249)})
local LogList = Create("ScrollingFrame",{Parent = LeftPanel,Active = true,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,BorderSizePixel = 0,Position = UDim2.new(0, 0, 0, 9),Size = UDim2.new(0, 131, 0, 232),CanvasSize = UDim2.new(0, 0, 0, 0),ScrollBarThickness = 4})
local UIListLayout = Create("UIListLayout",{Parent = LogList,HorizontalAlignment = Enum.HorizontalAlignment.Center,SortOrder = Enum.SortOrder.LayoutOrder})
local RightPanel = Create("Frame",{Parent = Background,BackgroundColor3 = Color3.fromRGB(37, 36, 38),BorderSizePixel = 0,Position = UDim2.new(0, 131, 0, 19),Size = UDim2.new(0, 319, 0, 249)})
local CodeBox = Create("Frame",{Parent = RightPanel,BackgroundColor3 = Color3.new(0.0823529, 0.0745098, 0.0784314),BorderSizePixel = 0,Size = UDim2.new(0, 319, 0, 119)})
local ScrollingFrame = Create("ScrollingFrame",{Parent = RightPanel,Active = true,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 0, 0.5, 0),Size = UDim2.new(1, 0, 0.5, -9),CanvasSize = UDim2.new(0, 0, 0, 0),ScrollBarThickness = 4})
local UIGridLayout = Create("UIGridLayout",{Parent = ScrollingFrame,HorizontalAlignment = Enum.HorizontalAlignment.Center,SortOrder = Enum.SortOrder.LayoutOrder,CellPadding = UDim2.new(0, 0, 0, 0),CellSize = UDim2.new(0, 94, 0, 27)})
local TopBar = Create("Frame",{Parent = Background,BackgroundColor3 = Color3.fromRGB(37, 35, 38),BorderSizePixel = 0,Size = UDim2.new(0, 450, 0, 19)})
local Simple = Create("TextButton",{Parent = TopBar,BackgroundColor3 = Color3.new(1, 1, 1),AutoButtonColor = false,BackgroundTransparency = 1,Position = UDim2.new(0, 5, 0, 0),Size = UDim2.new(0, 57, 0, 18),Font = Enum.Font.SourceSansBold,Text =  "SimpleSpy",TextColor3 = Color3.new(1, 1, 1),TextSize = 14,TextXAlignment = Enum.TextXAlignment.Left})
local CloseButton = Create("TextButton",{Parent = TopBar,BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902),BorderSizePixel = 0,Position = UDim2.new(1, -19, 0, 0),Size = UDim2.new(0, 19, 0, 19),Font = Enum.Font.SourceSans,Text = "",TextColor3 = Color3.new(0, 0, 0),TextSize = 14})
local ImageLabel = Create("ImageLabel",{Parent = CloseButton,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 5, 0, 5),Size = UDim2.new(0, 9, 0, 9),Image = "http://www.roblox.com/asset/?id=5597086202"})
local MinimizeButton = Create("TextButton",{Parent = TopBar,BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902),BorderSizePixel = 0,Position = UDim2.new(1, -38, 0, 0),Size = UDim2.new(0, 19, 0, 19),Font = Enum.Font.SourceSans,Text = "",TextColor3 = Color3.new(0, 0, 0),TextSize = 14})
local ImageLabel_1 = Create("ImageLabel",{Parent = MinimizeButton,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 5, 0, 5),Size = UDim2.new(0, 9, 0, 9),Image = "http://www.roblox.com/asset/?id=5597105827"})
local ToolTip = Create("Frame",{Parent = SimpleSpy3,BackgroundColor3 = Color3.fromRGB(26, 26, 26),BackgroundTransparency = 0.1,BorderColor3 = Color3.new(1, 1, 1),Size = UDim2.new(0, 200, 0, 50),ZIndex = 3,Visible = false})
local TextLabel = Create("TextLabel",{Parent = ToolTip,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 2, 0, 2),Size = UDim2.new(0, 196, 0, 46),ZIndex = 3,Font = Enum.Font.SourceSans,Text = "This is some slightly longer text.",TextColor3 = Color3.new(1, 1, 1),TextSize = 14,TextWrapped = true,TextXAlignment = Enum.TextXAlignment.Left,TextYAlignment = Enum.TextYAlignment.Top})

--Toggle
local ToggleButton = Create("ImageButton", {Parent = SimpleSpy3, Position = UDim2.new(0,100,0,60), Size = UDim2.new(0,40,0,40), BackgroundColor3 = Color3.fromRGB(53, 52, 55), Image = "rbxassetid://7072720870", Active = true, Draggable = true})
ToggleButton.MouseButton1Down:Connect(function()
    ToggleButton.Image = (Background.Visible and "rbxassetid://7072720870") or "rbxassetid://7072719338"
    Background.Visible = not Background.Visible
end)
Instance.new("UICorner", ToggleButton)

-------------------------------------------------------------------------------

local layoutOrderNum = 999999999
local closed = false
local logs = {}

local selected = nil
local blacklist = {}
local blocklist = {}

local connectedRemotes = {}
local disabledRemotes = {}
local hooks = {}
--- True = hookfunction, false = namecall
local toggle = false
--- used to prevent recursives
local prevTables = {}
--- holds logs (for deletion)
local remoteLogs = {}
--- used for hookfunction
getgenv().SIMPLESPYCONFIG_MaxRemotes = 300
local indent = 4
local scheduled = {}
local schedulerconnect
local SimpleSpy = {}
local topstr = ""
local bottomstr = ""
local remotesFadeIn
local rightFadeIn
local codebox


-- autoblock variables
local history = {}
local excluding = {}

-- if mouse inside gui
local mouseInGui = false

local connections = {}
local DecompiledScripts = {}
local generation = {}
local originalNamecall = getrawmetatable(game).__namecall

local remoteEvent = Instance.new("RemoteEvent",Storage)
local unreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
local remoteFunction = Instance.new("RemoteFunction",Storage)
local NamecallHandler = Instance.new("BindableEvent",Storage)
local IndexHandler = Instance.new("BindableEvent",Storage)
local GetDebugIdHandler = Instance.new("BindableFunction",Storage) --Thanks engo for the idea of using BindableFunctions

local originalEvent = remoteEvent.FireServer
local originalUnreliableEvent = unreliableRemoteEvent.FireServer
local originalFunction = remoteFunction.InvokeServer
local GetDebugIDInvoke = GetDebugIdHandler.Invoke

function GetDebugIdHandler.OnInvoke(obj: Instance) -- To avoid having to set thread identity and ect
    return OldDebugId(obj)
end

local function ThreadGetDebugId(obj: Instance): string 
    return GetDebugIDInvoke(GetDebugIdHandler,obj) -- indexing to avoid having to setnamecall later
end

xpcall(function()
    if isfile and readfile and isfolder and makefolder then
        local cachedconfigs = isfile("SimpleSpy//Settings.json") and jsond(readfile("SimpleSpy//Settings.json"))

        if cachedconfigs then
            for i,v in next, realconfigs do
                if cachedconfigs[i] == nil then
                    cachedconfigs[i] = v
                end
            end
            realconfigs = cachedconfigs
        end

        if not isfolder("SimpleSpy") then
            makefolder("SimpleSpy")
        end
        if not isfolder("SimpleSpy//Assets") then
            makefolder("SimpleSpy//Assets")
        end
        if not isfile("SimpleSpy//Settings.json") then
            writefile("SimpleSpy//Settings.json",jsone(realconfigs))
        end

        configsmetatable.__newindex = function(self,index,newindex)
            realconfigs[index] = newindex
            writefile("SimpleSpy//Settings.json",jsone(realconfigs))
        end
    else
        configsmetatable.__newindex = function(self,index,newindex)
            realconfigs[index] = newindex
        end
    end
end,function(err)
    ErrorPrompt(("An error has occured: (%s)"):format(err))
end)

--- Prevents remote spam from causing lag (clears logs after `getgenv().SIMPLESPYCONFIG_MaxRemotes` or 500 remotes)
function clean()
    local max = getgenv().SIMPLESPYCONFIG_MaxRemotes
    if not typeof(max) == "number" and math.floor(max) ~= max then
        max = 500
    end
    if #remoteLogs > max then
        for i = 100, #remoteLogs do
            local v = remoteLogs[i]
            if typeof(v[1]) == "RBXScriptConnection" then
                v[1]:Disconnect()
            end
            if typeof(v[2]) == "Instance" then
                v[2]:Destroy()
            end
        end
        local newLogs = {}
        for i = 1, 100 do
            table.insert(newLogs, remoteLogs[i])
        end
        remoteLogs = newLogs
    end
end

--- Scales the ToolTip to fit containing text
function scaleToolTip()
    local size = TextService:GetTextSize(TextLabel.Text, TextLabel.TextSize, TextLabel.Font, Vector2.new(196, math.huge))
    TextLabel.Size = UDim2.new(0, size.X, 0, size.Y)
    ToolTip.Size = UDim2.new(0, size.X + 4, 0, size.Y + 4)
end

--- Executed when the toggle button (the SimpleSpy logo) is hovered over
function onToggleButtonHover()
    if not toggle then
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(252, 51, 51)}):Play()
    else
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(68, 206, 91)}):Play()
    end
end

--- Executed when the toggle button is unhovered over
function onToggleButtonUnhover()
    TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end

--- Executed when the X button is hovered over
function onXButtonHover()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}):Play()
end

--- Executed when the X button is unhovered over
function onXButtonUnhover()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(37, 36, 38)}):Play()
end

--- Toggles the remote spy method (when button clicked)
function onToggleButtonClick()
    if toggle then
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(252, 51, 51)}):Play()
    else
        TweenService:Create(Simple, TweenInfo.new(0.5), {TextColor3 = Color3.fromRGB(68, 206, 91)}):Play()
    end
    toggleSpyMethod()
end

--- Reconnects bringBackOnResize if the current viewport changes and also connects it initially
function connectResize()
    if not workspace.CurrentCamera then
        workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    end
    local lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        lastCam:Disconnect()
        if typeof(lastCam) == 'Connection' then
            lastCam:Disconnect()
        end
        lastCam = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
    end)
end

--- Brings gui back if it gets lost offscreen (connected to the camera viewport changing)
function bringBackOnResize()
    validateSize()
    if closed then
        minimizeSize()
    else
        maximizeSize()
    end
    local currentX = Background.AbsolutePosition.X
    local currentY = Background.AbsolutePosition.Y
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if (currentX < 0) or (currentX > (viewportSize.X - (closed and 131 or Background.AbsoluteSize.X))) then
        if currentX < 0 then
            currentX = 0
        else
            currentX = viewportSize.X - (closed and 131 or Background.AbsoluteSize.X)
        end
    end
    if (currentY < 0) or (currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - GuiInset.Y)) then
        if currentY < 0 then
            currentY = 0
        else
            currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - GuiInset.Y
        end
    end
    TweenService.Create(TweenService, Background, TweenInfo.new(0.1), {Position = UDim2.new(0, currentX, 0, currentY)}):Play()
end

--- Expands and minimizes the gui (closed is the toggle boolean)
function toggleMinimize()
    closed = not closed
    if closed then
        ImageLabel_1.Image = "http://www.roblox.com/asset/?id=5597108117"
        LeftPanel.Visible = false
        RightPanel.Visible = false
    else
        ImageLabel_1.Image = "http://www.roblox.com/asset/?id=5597105827"
        LeftPanel.Visible = true
        RightPanel.Visible = true
    end
end

--- Checks if cursor is within resize range
--- @param p Vector2
function isInResizeRange(p)
    local relativeP = p - Background.AbsolutePosition
    local range = 5
    if relativeP.X >= TopBar.AbsoluteSize.X - range and relativeP.Y >= Background.AbsoluteSize.Y - range
        and relativeP.X <= TopBar.AbsoluteSize.X and relativeP.Y <= Background.AbsoluteSize.Y then
        return true, 'B'
    elseif relativeP.X >= TopBar.AbsoluteSize.X - range and relativeP.X <= Background.AbsoluteSize.X then
        return true, 'X'
    elseif relativeP.Y >= Background.AbsoluteSize.Y - range and relativeP.Y <= Background.AbsoluteSize.Y then
        return true, 'Y'
    end
    return false
end

--- Called when mouse enters SimpleSpy
local customCursor = Create("ImageLabel",{Parent = SimpleSpy3,Visible = false,Size = UDim2.fromOffset(200, 200),ZIndex = 1e9,BackgroundTransparency = 1,Image = "",Parent = SimpleSpy3})
function mouseEntered()
    local con = connections["SIMPLESPY_CURSOR"]
    if con then
        con:Disconnect()
        connections["SIMPLESPY_CURSOR"] = nil
    end
    connections["SIMPLESPY_CURSOR"] = RunService.RenderStepped:Connect(function()
        UserInputService.MouseIconEnabled = not mouseInGui
        customCursor.Visible = mouseInGui
        if mouseInGui and getgenv().SimpleSpyExecuted then
            local mouseLocation = UserInputService:GetMouseLocation() - GuiInset
            customCursor.Position = UDim2.fromOffset(mouseLocation.X - customCursor.AbsoluteSize.X / 2, mouseLocation.Y - customCursor.AbsoluteSize.Y / 2)
            local inRange, type = isInResizeRange(mouseLocation)
            if inRange and not closed then
                if not closed then
                    customCursor.Image = type == 'B' and "rbxassetid://6065821980" or type == 'X' and "rbxassetid://6065821086" or type == 'Y' and "rbxassetid://6065821596"
                elseif type == 'Y' or type == 'B' then
                    customCursor.Image = "rbxassetid://6065821596"
                end
            elseif customCursor.Image ~= "rbxassetid://6065775281" then
                customCursor.Image = "rbxassetid://6065775281"
            end
        else
            connections["SIMPLESPY_CURSOR"]:Disconnect()
        end
    end)
end

--- Called when mouse moves
function mouseMoved()
    local mousePos = UserInputService:GetMouseLocation() - GuiInset
    if not closed
    and mousePos.X >= TopBar.AbsolutePosition.X and mousePos.X <= TopBar.AbsolutePosition.X + TopBar.AbsoluteSize.X
    and mousePos.Y >= Background.AbsolutePosition.Y and mousePos.Y <= Background.AbsolutePosition.Y + Background.AbsoluteSize.Y then
        if not mouseInGui then
            mouseInGui = true
            mouseEntered()
        end
    else
        mouseInGui = false
    end
end

--- Adjusts the ui elements to the 'Maximized' size
function maximizeSize(speed)
    if not speed then
        speed = 0.05
    end
    TweenService:Create(LeftPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(RightPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(TopBar, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(ScrollingFrame, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, 110), Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(CodeBox, TweenInfo.new(speed), { Size = UDim2.fromOffset(Background.AbsoluteSize.X - LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(LogList, TweenInfo.new(speed), { Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }):Play()
end

--- Adjusts the ui elements to close the side
function minimizeSize(speed)
    if not speed then
        speed = 0.05
    end
    TweenService:Create(LeftPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(RightPanel, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(TopBar, TweenInfo.new(speed), { Size = UDim2.fromOffset(LeftPanel.AbsoluteSize.X, TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(ScrollingFrame, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, 119), Position = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(CodeBox, TweenInfo.new(speed), { Size = UDim2.fromOffset(0, Background.AbsoluteSize.Y - 119 - TopBar.AbsoluteSize.Y) }):Play()
    TweenService:Create(LogList, TweenInfo.new(speed), { Size = UDim2.fromOffset(LogList.AbsoluteSize.X, Background.AbsoluteSize.Y - TopBar.AbsoluteSize.Y - 18) }):Play()
end

--- Ensures size is within screensize limitations
function validateSize()
    local x, y = Background.AbsoluteSize.X, Background.AbsoluteSize.Y
    local screenSize = workspace.CurrentCamera.ViewportSize
    if x + Background.AbsolutePosition.X > screenSize.X then
        if screenSize.X - Background.AbsolutePosition.X >= 450 then
            x = screenSize.X - Background.AbsolutePosition.X
        else
            x = 450
        end
    elseif y + Background.AbsolutePosition.Y > screenSize.Y then
        if screenSize.X - Background.AbsolutePosition.Y >= 268 then
            y = screenSize.Y - Background.AbsolutePosition.Y
        else
            y = 268
        end
    end
    Background.Size = UDim2.fromOffset(x, y)
end

--- Called on user input while mouse in 'Background' frame
--- @param input InputObject
function backgroundUserInput(input)
    local mousePos = UserInputService:GetMouseLocation() - GuiInset
    local inResizeRange, type = isInResizeRange(mousePos)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and inResizeRange then
        local lastPos = UserInputService:GetMouseLocation()
        local offset = Background.AbsoluteSize - lastPos
        local currentPos = lastPos + offset
        if not connections["SIMPLESPY_RESIZE"] then
            connections["SIMPLESPY_RESIZE"] = RunService.RenderStepped:Connect(function()
                local newPos = UserInputService:GetMouseLocation()
                if newPos ~= lastPos then
                    local currentX = (newPos + offset).X
                    local currentY = (newPos + offset).Y
                    if currentX < 450 then
                        currentX = 450
                    end
                    if currentY < 268 then
                        currentY = 268
                    end
                    currentPos = Vector2.new(currentX, currentY)
                    Background.Size = UDim2.fromOffset((not closed and not closed and (type == "X" or type == "B")) and currentPos.X or Background.AbsoluteSize.X, (not closed and (type == "Y" or type == "B")) and currentPos.Y or Background.AbsoluteSize.Y)
                    validateSize()
                    if closed then
                        minimizeSize()
                    else
                        maximizeSize()
                    end
                    lastPos = newPos
                end
            end)
        end
        table.insert(connections, UserInputService.InputEnded:Connect(function(inputE)
            if input == inputE then
                if connections["SIMPLESPY_RESIZE"] then
                    connections["SIMPLESPY_RESIZE"]:Disconnect()
                    connections["SIMPLESPY_RESIZE"] = nil
                end
            end
        end))
    end
end

--- Runs on MouseButton1Click of an event frame
function eventSelect(frame)
    if selected and selected.Log  then
        if selected.Button then
            spawn(function()
                TweenService:Create(selected.Button, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
            end)
        end
        selected = nil
    end
    for _, v in next, logs do
        if frame == v.Log then
            selected = v
        end
    end
    if selected and selected.Log then
        spawn(function()
            TweenService:Create(frame.Button, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(92, 126, 229)}):Play()
        end)
        codebox:setRaw(selected.GenScript)
    end
end

--- Updates the canvas size to fit the current amount of function buttons
function updateFunctionCanvas()
    ScrollingFrame.CanvasSize = UDim2.fromOffset(UIGridLayout.AbsoluteContentSize.X, UIGridLayout.AbsoluteContentSize.Y)
end

--- Updates the canvas size to fit the amount of current remotes
function updateRemoteCanvas()
    LogList.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X, UIListLayout.AbsoluteContentSize.Y)
end

--- Allows for toggling of the tooltip and easy setting of le description
--- @param enable boolean
--- @param text string
function makeToolTip(enable, text)
    if enable and text then
        if ToolTip.Visible then
            ToolTip.Visible = false
            local tooltip = connections["ToolTip"]
            if tooltip then
                tooltip:Disconnect()
            end
        end
        local first = true
        connections["ToolTip"] = RunService.RenderStepped:Connect(function()
            local MousePos = UserInputService:GetMouseLocation()
            local topLeft = MousePos + Vector2.new(20, -15)
            local bottomRight = topLeft + ToolTip.AbsoluteSize
            local ViewportSize = workspace.CurrentCamera.ViewportSize
            local ViewportSizeX = ViewportSize.X
            local ViewportSizeY = ViewportSize.Y

            if topLeft.X < 0 then
                topLeft = Vector2.new(0, topLeft.Y)
            elseif bottomRight.X > ViewportSizeX then
                topLeft = Vector2.new(ViewportSizeX - ToolTip.AbsoluteSize.X, topLeft.Y)
            end
            if topLeft.Y < 0 then
                topLeft = Vector2.new(topLeft.X, 0)
            elseif bottomRight.Y > ViewportSizeY - 35 then
                topLeft = Vector2.new(topLeft.X, ViewportSizeY - ToolTip.AbsoluteSize.Y - 35)
            end
            if topLeft.X <= MousePos.X and topLeft.Y <= MousePos.Y then
                topLeft = Vector2.new(MousePos.X - ToolTip.AbsoluteSize.X - 2, MousePos.Y - ToolTip.AbsoluteSize.Y - 2)
            end
            if first then
                ToolTip.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
                first = false
            else
                ToolTip:TweenPosition(UDim2.fromOffset(topLeft.X, topLeft.Y), "Out", "Linear", 0.1)
            end
        end)
        TextLabel.Text = text
        TextLabel.TextScaled = true
        ToolTip.Visible = true
        return
    else
        if ToolTip.Visible then
            ToolTip.Visible = false
            local tooltip = connections["ToolTip"]
            if tooltip then
                tooltip:Disconnect()
            end
        end
    end
end

--- Creates new function button (below codebox)
--- @param name string
---@param description function
---@param onClick function
function newButton(name, description, onClick)
    local FunctionTemplate = Create("Frame",{Name = "FunctionTemplate",Parent = ScrollingFrame,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Size = UDim2.new(0, 117, 0, 23)})
    local ColorBar = Create("Frame",{Name = "ColorBar",Parent = FunctionTemplate,BackgroundColor3 = Color3.new(1, 1, 1),BorderSizePixel = 0,Position = UDim2.new(0, 7, 0, 10),Size = UDim2.new(0, 7, 0, 18),ZIndex = 3})
    local Text = Create("TextLabel",{Text = name,Name = "Text",Parent = FunctionTemplate,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 19, 0, 10),Size = UDim2.new(0, 69, 0, 18),ZIndex = 2,Font = Enum.Font.SourceSans,TextColor3 = Color3.new(1, 1, 1),TextSize = 14,TextStrokeColor3 = Color3.new(0.145098, 0.141176, 0.14902),TextXAlignment = Enum.TextXAlignment.Left})
    local Button = Create("TextButton",{Name = "Button",Parent = FunctionTemplate,BackgroundColor3 = Color3.new(0, 0, 0),BackgroundTransparency = 0.69999998807907,BorderColor3 = Color3.new(1, 1, 1),Position = UDim2.new(0, 7, 0, 10),Size = UDim2.new(0, 80, 0, 18),AutoButtonColor = false,Font = Enum.Font.SourceSans,Text = "",TextColor3 = Color3.new(0, 0, 0),TextSize = 14})
    if description():match("ENABLED") then
        ColorBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    elseif description():match("DISABLED") then
        ColorBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
    Button.MouseEnter:Connect(function()
        makeToolTip(true, description())
    end)
    Button.MouseLeave:Connect(function()
        task.wait(0.75)
        makeToolTip(false)
    end)
    FunctionTemplate.AncestryChanged:Connect(function()
        makeToolTip(false)
    end)
    Button.MouseButton1Click:Connect(function(...)
        if description():match("ENABLED") or description():match("DISABLED") then
            TextLabel:GetPropertyChangedSignal("Text"):Once(function()
                if TextLabel.Text:match("ENABLED") then
                    ColorBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif TextLabel.Text:match("DISABLED") then
                    ColorBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end
        onClick(FunctionTemplate, ...)
    end)
    updateFunctionCanvas()
end

--- Adds new Remote to logs
--- @param name string The name of the remote being logged
--- @param type string The type of the remote being logged (either 'function' or 'event')
--- @param args any
--- @param remote any
--- @param function_info string
--- @param blocked any
function newRemote(type, data)
    if layoutOrderNum < 1 then layoutOrderNum = 999999999 end
    local remote = data.remote
    local callingscript = data.callingscript
    local TextColor3 = Color3.new(1, 1, 1)
    if data.remote:IsA("BindableEvent") or data.remote:IsA("BindableFunction") then
        TextColor3 = Color3.fromRGB(255, 165, 0)
    end

    local RemoteTemplate = Create("Frame",{LayoutOrder = layoutOrderNum,Name = "RemoteTemplate",Parent = LogList,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Size = UDim2.new(0, 117, 0, 27)})
    local ColorBar = Create("Frame",{Name = "ColorBar",Parent = RemoteTemplate,BackgroundColor3 = (type == "event" and Color3.fromRGB(255, 242, 0)) or Color3.fromRGB(99, 86, 245),BorderSizePixel = 0,Position = UDim2.new(0, 0, 0, 1),Size = UDim2.new(0, 7, 0, 18),ZIndex = 2})
    local Text = Create("TextLabel",{TextTruncate = Enum.TextTruncate.AtEnd,Name = "Text",Parent = RemoteTemplate,BackgroundColor3 = Color3.new(1, 1, 1),BackgroundTransparency = 1,Position = UDim2.new(0, 12, 0, 1),Size = UDim2.new(0, 105, 0, 18),ZIndex = 2,Font = Enum.Font.SourceSans,Text = remote.Name,TextColor3 = TextColor3,TextSize = 14,TextXAlignment = Enum.TextXAlignment.Left})
    local Button = Create("TextButton",{Name = "Button",Parent = RemoteTemplate,BackgroundColor3 = Color3.new(0, 0, 0),BackgroundTransparency = 0.75,BorderColor3 = Color3.new(1, 1, 1),Position = UDim2.new(0, 0, 0, 1),Size = UDim2.new(0, 117, 0, 18),AutoButtonColor = false,Font = Enum.Font.SourceSans,Text = "",TextColor3 = Color3.new(0, 0, 0),TextSize = 14})
    
    remote:GetPropertyChangedSignal("Name"):Connect(function()
        Text.Text = remote.Name
    end)

    local log = {
        Name = remote.name,
        Function = data.infofunc or "--Function Info is disabled",
        Remote = remote,
        method = data.method,
        DebugId = data.id,
        metamethod = data.metamethod,
        args = data.args,
        Log = RemoteTemplate,
        Button = Button,
        Blocked = data.blocked,
        Source = callingscript,
        traceback = data.traceback,
        returnvalue = data.returnvalue,
        GenScript = "-- Generating, please wait...\n-- (If this message persists, the remote args are likely extremely long)"
    }

    logs[#logs + 1] = log
    local connect = Button.MouseButton1Click:Connect(function()
        eventSelect(RemoteTemplate)
        log.GenScript = genScript(log.Remote, log.args, log.method)
        if blocked then
            log.GenScript = "-- THIS REMOTE WAS PREVENTED FROM FIRING TO THE SERVER BY SIMPLESPY\n\n" .. log.GenScript
        end
        if selected == log and RemoteTemplate then
            eventSelect(RemoteTemplate)
        end
    end)
    layoutOrderNum -= 1
    table.insert(remoteLogs, 1, {connect, RemoteTemplate})
    clean()
    updateRemoteCanvas()
end

--- Generates a script from the provided arguments (first has to be remote path)
function genScript(remote, args, method)
    prevTables = {}
    local gen = ""
    if #args > 0 then
        gen = "local args = "..Serialize(args) .. "\n"
        if method == "OnClientEvent" then
            gen ..= "firesignal("..Serialize(remote)..".OnClientEvent, unpack(args))"
        elseif method == "OnClientInvoke" then
            gen ..= "getcallbackvalue("..Serialize(remote)..", \"OnClientInvoke\")(unpack(args))"
        else
            gen ..= Serialize(remote) .. ":"..method.."(unpack(args))"
        end
    else
        if method == "OnClientEvent" then
            gen ..= "firesignal("..Serialize(remote) .. ".OnClientEvent)"
        elseif method == "OnClientInvoke" then
            gen ..= "getcallbackvalue("..Serialize(remote)..", \"OnClientInvoke\")()"
        else
            gen ..= Serialize(remote) .. ":"..method.."()"
        end
    end
    prevTables = {}
    return gen
end

--- value-to-variable
--- @param t any
function v2v(t)
    topstr = ""
    bottomstr = ""
    local ret = ""
    local count = 1
    for i, v in next, t do
        if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
            ret = ret .. "local " .. i .. " = " .. Serialize(v) .. "\n"
        elseif rawtostring(i):match("^[%a_]+[%w_]*$") then
            ret = ret .. "local " .. rawtostring(i):lower() .. "_" .. rawtostring(count) .. " = " .. Serialize(v, nil, nil, rawtostring(i):lower() .. "_" .. rawtostring(count), true) .. "\n"
        else
            ret = ret .. "local " .. type(v) .. "_" .. rawtostring(count) .. " = " .. Serialize(v) .. "\n"
        end
        count = count + 1
    end
    if #topstr > 0 then
        ret = topstr .. "\n" .. ret
    end
    if #bottomstr > 0 then
        ret = ret .. bottomstr
    end
    return ret
end

--- value-to-path (in table)
local p
function v2p(x, t, path, prev)
    if not path then
        path = ""
    end
    if not prev then
        prev = {}
    end
    if rawequal(x, t) then
        return true, ""
    end
    for i, v in next, t do
        if rawequal(v, x) then
            if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
                return true, (path .. "." .. i)
            else
                return true, (path .. "[" .. Serialize(i) .. "]")
            end
        end
        if type(v) == "table" then
            local duplicate = false
            for _, y in next, prev do
                if rawequal(y, v) then
                    duplicate = true
                end
            end
            if not duplicate then
                table.insert(prev, t)
                local found
                found, p = v2p(x, v, path, prev)
                if found then
                    if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
                        return true, "." .. i .. p
                    else
                        return true, "[" .. Serialize(i) .. "]" .. p
                    end
                end
            end
        end
    end
    return false, ""
end

--- schedules the provided function (and calls it with any args after)

function schedule(f, ...)
    table.insert(scheduled, {f, ...})
end

--- yields the current thread until the scheduler gives the ok
function scheduleWait()
    local thread = running()
    schedule(function()
        resume(thread)
    end)
    yield()
end

--- the big (well tbh small now) boi task scheduler himself, handles p much anything as quicc as possible
local function taskscheduler()
    if not toggle then
        scheduled = {}
        return
    end
    if #scheduled > SIMPLESPYCONFIG_MaxRemotes + 100 then
        table.remove(scheduled, #scheduled)
    end
    if #scheduled > 0 then
        local currentf = scheduled[1]
        table.remove(scheduled, 1)
        if type(currentf) == "table" and type(currentf[1]) == "function" then
            pcall(unpack(currentf))
        end
    end
end

local function tablecheck(tabletocheck,instance,id)
    return tabletocheck[id] or tabletocheck[instance.Name]
end

function remoteHandler(data)
    if configs.autoblock then
        local id = data.id

        if excluding[id] then
            return
        end
        if not history[id] then
            history[id] = {badOccurances = 0, lastCall = tick()}
        end
        if tick() - history[id].lastCall < 1 then
            history[id].badOccurances += 1
            return
        else
            history[id].badOccurances = 0
        end
        if history[id].badOccurances > 3 then
            excluding[id] = true
            return
        end
        history[id].lastCall = tick()
    end

    if data.remote:IsA("BaseRemoteEvent") or data.remote:IsA("BindableEvent") then
        newRemote("event", data)
    elseif data.remote:IsA("RemoteFunction") or data.remote:IsA("BindableFunction") then
        newRemote("function", data)
    end
end

local newindex = function(method,originalfunction,...)
    if typeof(...) == 'Instance' then
        local remote = cloneref(...)

        if remote:IsA("BaseRemoteEvent") or remote:IsA("RemoteFunction") then

            if not configs.logcheckcaller and checkcaller() and method ~= "OnClientEvent" and method ~= "OnClientInvoke" then return originalfunction(...) end

            local id = ThreadGetDebugId(remote)
            local blockcheck = tablecheck(blocklist,remote,id)
            local args = {select(2,...)}

            if not tablecheck(blacklist,remote,id) and not IsCyclicTable(args) then
                local data = {
                    method = method,
                    remote = remote,
                    args = deepclone(args),
                    infofunc = info(2,"f"),
                    callingscript = nil,
                    traceback = debug.traceback(),
                    metamethod = "__index",
                    blockcheck = blockcheck,
                    id = id,
                    returnvalue = {}
                }
                args = nil

                local calling = getcallingscript()
                data.callingscript = calling and cloneref(calling) or nil

                schedule(remoteHandler,data)
                
                if configs.logreturnvalues and IsA(remote, "RemoteFunction") and not blockcheck then
                    local returndata = originalfunction(...)
                    data.returnvalue.data = returndata
                    return returndata
                end
            end
            if blockcheck then return end
        end
    end
    return originalfunction(...)
end

local newnamecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local lower = method:lower()
    if lower == "fireserver" or lower == "invokeserver" or lower == "fire" or lower == "invoke" then
        if typeof(self) == 'Instance' then
            local remote = cloneref(self)

            if IsA(remote,"BaseRemoteEvent") or IsA(remote,"RemoteFunction") or IsA(remote, "BindableEvent") or IsA(remote, "BindableFunction") then
                if not configs.logcheckcaller and checkcaller() then return originalNamecall(self, ...) end
                local id = ThreadGetDebugId(remote)
                local blockcheck = tablecheck(blocklist,remote,id)
                local args = {...}

                if not tablecheck(blacklist,remote,id) and not IsCyclicTable(args) then
                    local data = {
                        method = method,
                        remote = remote,
                        args = deepclone(args),
                        infofunc = info(2,"f"),
                        callingscript = nil,
                        traceback = debug.traceback(),
                        metamethod = "__namecall",
                        blockcheck = blockcheck,
                        id = id,
                        returnvalue = {}
                    }
                    args = nil

                    local calling = getcallingscript()
                    data.callingscript = calling and cloneref(calling) or nil

                    schedule(remoteHandler,data)
                    
                    if configs.logreturnvalues and IsA(remote, "RemoteFunction") and not blockcheck then
                        local returndata = originalNamecall(self, ...)
                        data.returnvalue.data = returndata
                        return returndata
                    end
                end
                if blockcheck then return end
            end
        end
    end
    return originalNamecall(self, ...)
end)

local newFireServer = newcclosure(function(...)
    return newindex("FireServer",originalEvent,...)
end)

local newUnreliableFireServer = newcclosure(function(...)
    return newindex("FireServer",originalUnreliableEvent,...)
end)

local newInvokeServer = newcclosure(function(...)
    return newindex("InvokeServer",originalFunction,...)
end)

local function disablehooks()
    if hookmetamethod then
        hookmetamethod(game,"__namecall",originalNamecall)
    else
        hookfunction(getrawmetatable(game).__namecall,originalNamecall)
    end
    hookfunction(Instance.new("RemoteEvent").FireServer, originalEvent)
    hookfunction(Instance.new("RemoteFunction").InvokeServer, originalFunction)
    hookfunction(Instance.new("UnreliableRemoteEvent").FireServer, originalUnreliableEvent)
end

--- Toggles on and off the remote spy
function toggleSpy()
    if not toggle then
        if hookmetamethod then
            originalNamecall = hookmetamethod(game, "__namecall", newnamecall)
        else
            originalNamecall = hookfunction(getrawmetatable(game).__namecall, newnamecall)
        end
        originalEvent = hookfunction(Instance.new("RemoteEvent").FireServer, newFireServer)
        originalFunction = hookfunction(Instance.new("RemoteFunction").InvokeServer, newInvokeServer)
        originalUnreliableEvent = hookfunction(Instance.new("UnreliableRemoteEvent").FireServer, newUnreliableFireServer)
    else
        disablehooks()
    end
end

--- Toggles between the two remotespy methods (hookfunction currently = disabled)
function toggleSpyMethod()
    toggleSpy()
    toggle = not toggle
end

-- Log OnClientEvent, OnClientInvoke
local function receiveRemote(v)
    if IsA(v, "BaseRemoteEvent") then
        connectedRemotes[#connectedRemotes+1] = v.OnClientEvent:Connect(function(...)
            if configs.logfireclient and toggle then
                newindex("OnClientEvent", blankfunction, v, ...)
            end
        end)
    elseif IsA(v, "RemoteFunction") then
        local callback = getcallbackvalue and getcallbackvalue(v, "OnClientInvoke")
        if callback then
            v.OnClientInvoke = function(...)
                if configs.loginvokeclient and toggle then
                    return newindex("OnClientInvoke", callback, v, ...)
                end
                return callback(...)
            end
            hooks[#hooks+1] = function()
                v.OnClientInvoke = callback
            end
        end
    end
end

connections["DescendantAdded"] = game.DescendantAdded:Connect(receiveRemote)
for _, v in pairs({game:GetDescendants(), getnilinstances()}) do
    for _, instance in pairs(v) do
        receiveRemote(instance)
    end
end

local __newindex
__newindex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
    if not checkcaller() and self:IsA("RemoteFunction") then
        if key == "OnClientInvoke" then
            return __newindex(self, key, function(...)
                if configs.loginvokeclient and toggle then
                    return newindex("OnClientInvoke", value, self, ...)
                end
                return value(...)
            end)
        end
    end
    return __newindex(self, key, value)
end))

local function disableRemote()
    if selected and selected.method == "OnClientEvent" then
        for i, v in pairs(getconnections(selected.Remote.OnClientEvent)) do
            if v.Function and getfenv(v.Function).script ~= script then
                v:Disable()
                table.insert(disabledRemotes, function()
                    v:Enable()
                end)
            end
       end
    end
end

--- Shuts down the remote spy
local function shutdown()
    if schedulerconnect then
        schedulerconnect:Disconnect()
    end
    for _, connection in next, connections do
        connection:Disconnect()
    end
    for _, connection in next, connectedRemotes do
        connection:Disconnect()
    end
    for _, v in next, hooks do
        spawn(v)
    end
    clear(connections)
    clear(logs)
    clear(remoteLogs)
    disablehooks()
    hookmetamethod(game, "__newindex", __newindex)
    SimpleSpy3:Destroy()
    Storage:Destroy()
    UserInputService.MouseIconEnabled = true
    getgenv().SimpleSpyExecuted = false
end

-- main
if not getgenv().SimpleSpyExecuted then
    local succeeded,err = pcall(function()
        if not RunService:IsClient() then
            error("SimpleSpy cannot run on the server!")
        end
        getgenv().SimpleSpyShutdown = shutdown
        onToggleButtonClick()
        if not hookmetamethod then
            ErrorPrompt("Simple Spy V3 will not function to it's fullest capablity due to your executor not supporting hookmetamethod.")
        end
        codebox = Highlight.new(CodeBox)
        codebox:setRaw("SimpleSpy V3")
        getgenv().SimpleSpy = SimpleSpy
        Background.MouseEnter:Connect(function(...)
            mouseInGui = true
            mouseEntered()
        end)
        Background.MouseLeave:Connect(function(...)
            mouseInGui = false
            mouseEntered()
        end)
        TextLabel:GetPropertyChangedSignal("Text"):Connect(scaleToolTip)
        MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
        Simple.MouseButton1Click:Connect(onToggleButtonClick)
        CloseButton.MouseEnter:Connect(onXButtonHover)
        CloseButton.MouseLeave:Connect(onXButtonUnhover)
        Simple.MouseEnter:Connect(onToggleButtonHover)
        Simple.MouseLeave:Connect(onToggleButtonUnhover)
        CloseButton.MouseButton1Click:Connect(shutdown)
        table.insert(connections, UserInputService.InputBegan:Connect(backgroundUserInput))
        connectResize()
        SimpleSpy3.Enabled = true
        spawn(function()
            task.delay(1,onToggleButtonUnhover)
        end)
        schedulerconnect = RunService.Heartbeat:Connect(taskscheduler)
        bringBackOnResize()
        SimpleSpy3.Parent = (gethui and gethui()) or CoreGui
        spawn(function()
            local lp = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
            generation = {
                [OldDebugId(lp)] = 'game:GetService("Players").LocalPlayer',
                [OldDebugId(lp:GetMouse())] = 'game:GetService("Players").LocalPlayer:GetMouse',
                [OldDebugId(game)] = "game",
                [OldDebugId(workspace)] = "workspace"
            }
        end)
    end)
    if succeeded then
        getgenv().SimpleSpyExecuted = true
    else
        shutdown()
        ErrorPrompt("An error has occured:\n"..rawtostring(err))
        return
    end
else
    SimpleSpy3:Destroy()
    return
end

function SimpleSpy:newButton(name, description, onClick)
    return newButton(name, description, onClick)
end

newButton(
    "复制代码",
    function() return "Click to copy code" end,
    function()
        setclipboard(codebox:getString())
        TextLabel.Text = "Copied successfully!"
    end
)

newButton(
    "复制事件路径",
    function() return "Click to copy the path of the remote" end,
    function()
        if selected and selected.Remote then
            setclipboard(Serialize(selected.Remote))
            TextLabel.Text = "Copied!"
        end
    end
)

newButton("运行代码",
    function() return "Click to execute code" end,
    function()
        local Remote = selected and selected.Remote
        if Remote then
            TextLabel.Text = "Executing..."
            xpcall(function()
                local returnvalue
                if selected.method == "OnClientEvent" then
                    returnvalue = firesignal(Remote.OnClientEvent, unpack(selected.args))
                elseif selected.method == "OnClientInvoke" then
                    returnvalue = getcallbackvalue and getcallbackvalue(v, "OnClientInvoke")
                else
                    returnvalue = Remote[selected.method](Remote, unpack(selected.args))
                end
                TextLabel.Text = ("Executed successfully!\n%s"):format(Serialize(returnvalue))
            end,function(err)
                TextLabel.Text = ("Execution error!\n%s"):format(err)
            end)
            return
        end
        TextLabel.Text = "Source not found"
    end
)

newButton(
    "复制脚本路径",
    function() return "Click to copy calling script to clipboard\nWARNING: Not super reliable, nil == could not find" end,
    function()
        if selected then
            if not selected.Source then
                selected.Source = rawget(getfenv(selected.Function),"script")
            end
            setclipboard(Serialize(selected.Source))
            TextLabel.Text = "Done!"
        end
    end
)

newButton("函数信息",function() return "Click to view calling function information" end,
function()
    local func = selected and selected.Function
    local funcinfo = ""
    if func then
        local typeoffunc = typeof(func)

        if typeoffunc ~= 'string' and configs.funcEnabled then
            codebox:setRaw("--[[Generating Function Info please wait]]")
            RunService.Heartbeat:Wait()
            local lclosure = islclosure(func)
            local SourceScript = rawget(getfenv(func),"script")
            local CallingScript = selected.Source or nil
            local info = {}
            
            info = {
                info = getinfo(func),
                constants = lclosure and deepclone(getconstants(func)) or "N/A --Lua Closure expected got C Closure",
                upvalues = lclosure and deepclone(getupvalues(func)) or "N/A --Lua Closure expected got C Closure",
                script = {
                    SourceScript = SourceScript or 'nil',
                    CallingScript = CallingScript or 'nil'
                }
            }
                    
            if configs.advancedinfo then
                local Remote = selected.Remote

                info["advancedinfo"] = {
                    Metamethod = selected.metamethod,
                    DebugId = {
                        SourceScriptDebugId = SourceScript and typeof(SourceScript) == "Instance" and OldDebugId(SourceScript) or "N/A",
                        CallingScriptDebugId = CallingScript and typeof(SourceScript) == "Instance" and OldDebugId(CallingScript) or "N/A",
                        RemoteDebugId = OldDebugId(Remote)
                    },
                    Protos = lclosure and getprotos(func) or "N/A --Lua Closure expected got C Closure"
                }

                if Remote:IsA("RemoteFunction") then
                    info["advancedinfo"]["OnClientInvoke"] = getcallbackvalue and (getcallbackvalue(Remote,"OnClientInvoke") or "N/A") or "N/A --Missing function getcallbackvalue"
                elseif getconnections then
                    info["advancedinfo"]["OnClientEvents"] = {}

                    for i,v in next, getconnections(Remote.OnClientEvent) do
                        info["advancedinfo"]["OnClientEvents"][i] = {
                            Function = v.Function or "N/A",
                            State = v.State or "N/A"
                        }
                    end
                end
            end
            codebox:setRaw("--[[Converting table to string please wait]]")
            funcinfo = v2v({functionInfo = info})
        end
        if configs.advancedinfo then
            funcinfo ..= "\nTraceback:\n"..selected.traceback
        end
        codebox:setRaw("-- Calling function info\n-- Generated by the SimpleSpy V3 Serializer\n\n"..funcinfo)
        TextLabel.Text = "Done! Function info generated by the SimpleSpy V3 Serializer."
    else
        TextLabel.Text = "Error! Selected function was not found."
    end
end)

newButton(
    "清除日志",
    function() return "Click to clear logs" end,
    function()
        TextLabel.Text = "Clearing..."
        clear(logs)
        for i,v in next, LogList:GetChildren() do
            if not v:IsA("UIListLayout") then
                v:Destroy()
            end
        end
        codebox:setRaw("")
        selected = nil
        TextLabel.Text = "Logs cleared!"
    end
)

newButton(
    "排除 (i)",
    function() return "Click to exclude this Remote.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable." end,
    function()
        if selected then
            blacklist[OldDebugId(selected.Remote)] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

newButton(
    "排除 (n)",
    function() return "Click to exclude all remotes with this name.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable." end,
    function()
        if selected then
            blacklist[selected.Name] = true
            TextLabel.Text = "Excluded!"
        end
    end
)

newButton("清除黑名单",
function() return "Click to clear the blacklist.\nExcluding a remote makes SimpleSpy ignore it, but it will continue to be usable." end,
function()
    blacklist = {}
    TextLabel.Text = "Blacklist cleared!"
end)

newButton(
    "阻止 (i)",
    function() return "Click to stop this remote from firing.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server." end,
    function()
        if selected then
            disableRemote()
            blocklist[OldDebugId(selected.Remote)] = true
            TextLabel.Text = "Blocked!"
        end
    end
)

newButton("阻止 (n)",function()
    return "Click to stop remotes with this name from firing.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server." end,
    function()
        if selected then
            disableRemote()
            blocklist[selected.Name] = true
            TextLabel.Text = "Blocked!"
        end
    end
)

newButton(
    "清除阻止列表",
    function() return "Click to stop blocking remotes.\nBlocking a remote won't remove it from SimpleSpy logs, but it will not continue to fire the server." end,
    function()
        for i, v in next, disabledRemotes do
            task.spawn(v)
        end
        disabledRemotes = {}
        blocklist = {}
        TextLabel.Text = "Blocklist cleared!"
    end
)

newButton("反编译",
    function()
        return "Decompile source script"
    end,function()
        if selected and selected.Source then
            local Source = selected.Source
            if not DecompiledScripts[Source] then
                codebox:setRaw("--[[Decompiling]]")

                xpcall(function()
                    DecompiledScripts[Source] = decompile(Source)
                end,function(err)
                    return codebox:setRaw(("--[[\nAn error has occured\n%s\n]]"):format(err))
                end)
            end
            codebox:setRaw(DecompiledScripts[Source] or "--No Source Found")
           TextLabel.Text = "Done!"
       else
           TextLabel.Text = "Source not found!"
       end
    end
)

newButton(
    "获取返回值",
    function() return "Get a Remote's return data" end,
    function()
        if selected then
            local Remote = selected.Remote
            if Remote and Remote:IsA("RemoteFunction") then
                if not configs.logreturnvalues then
                    codebox:setRaw("Enable log returnvalues first")
                    return
                end
                codebox:setRaw("return "..Serialize(selected.returnvalue.data))
            else
                codebox:setRaw("RemoteFunction expected got "..(Remote and Remote.ClassName))
            end
        end
    end
)

newButton(
    "显示函数信息",
    function() return string.format("[%s] Toggle function info (because it can cause lag in some games)", configs.funcEnabled and "ENABLED" or "DISABLED") end,
    function()
        configs.funcEnabled = not configs.funcEnabled
        TextLabel.Text = string.format("[%s] Toggle function info (because it can cause lag in some games)", configs.funcEnabled and "ENABLED" or "DISABLED")
    end
)

newButton(
    "自动阻止",
    function() return string.format("[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs", configs.autoblock and "ENABLED" or "DISABLED") end,
    function()
        configs.autoblock = not configs.autoblock
        TextLabel.Text = string.format("[%s] [BETA] Intelligently detects and excludes spammy remote calls from logs", configs.autoblock and "ENABLED" or "DISABLED")
        history = {}
        excluding = {}
    end
)

newButton("记录客户端调用",function()
    return ("[%s] Log remotes fired by the client"):format(configs.logcheckcaller and "ENABLED" or "DISABLED")
end,
function()
    configs.logcheckcaller = not configs.logcheckcaller
    TextLabel.Text = ("[%s] Log remotes fired by the client"):format(configs.logcheckcaller and "ENABLED" or "DISABLED")
end)

newButton("记录返回值",function()
    return ("[BETA] [%s] Log RemoteFunction's return values"):format(configs.logreturnvalues and "ENABLED" or "DISABLED")
end,
function()
    configs.logreturnvalues = not configs.logreturnvalues
    TextLabel.Text = ("[BETA] [%s] Log RemoteFunction's return values"):format(configs.logreturnvalues and "ENABLED" or "DISABLED")
end)

newButton("高级信息",function()
    return ("[%s] Display more remoteinfo"):format(configs.advancedinfo and "ENABLED" or "DISABLED")
end,
function()
    configs.advancedinfo = not configs.advancedinfo
    TextLabel.Text = ("[%s] Display more remoteinfo"):format(configs.advancedinfo and "ENABLED" or "DISABLED")
end)

newButton("Log FireClient",function()
    return ("[%s] Log Server FireClient"):format(configs.logfireclient and "ENABLED" or "DISABLED")
end,
function()
    configs.logfireclient = not configs.logfireclient
    TextLabel.Text = ("[%s] Log Server FireClient"):format(configs.logfireclient and "ENABLED" or "DISABLED")
end)

newButton("Log InvokeClient",function()
    return ("[%s] Log Server InvokeClient"):format(configs.loginvokeclient and "ENABLED" or "DISABLED")
end,
function()
    configs.loginvokeclient = not configs.loginvokeclient
    TextLabel.Text = ("[%s] Log Server InvokeClient"):format(configs.loginvokeclient and "ENABLED" or "DISABLED")
end)
