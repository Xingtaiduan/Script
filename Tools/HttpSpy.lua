if getgenv().Loaded then
    warn("HttpSpy is already running!")
    return
else
    getgenv().Loaded = true
    print("HttpSpy Enabled")
end

local config = {
    tologs = {
        HttpGet = true,
        HttpGetAsync = true,
        HttpPost = true,
        HttpPostAsync = true,
        GetObjects = true,
        Request = true
    },
    BlockWebhook = true
}
local tologs = config.tologs

local serialize = loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Tools/Serializer.lua"))()
local HttpService = game:GetService("HttpService")

local clonef = clonefunction or function(a) return a end
local date = clonef(os.date)
local isfile = clonef(isfile)
local writefile = clonef(writefile)
local appendfile = clonef(appendfile)
local newcclosure = clonef(newcclosure)
local checkcaller = clonef(checkcaller)
local format = clonef(string.format)
local match = clonef(string.match)
local getnamecallmethod = clonef(getnamecallmethod)

local logname = format("%s.%s_log.txt", date("%m"), date("%d"))
if not isfile(logname) then writefile(logname, "") end

local function printf(...)
    appendfile(logname, ...)
end

printf(date("%H:%M\n\n"))

local nilfunc = function() end

local HttpFunction = {
    HttpGet = game.HttpGet or nilfunc,
    HttpGetAsync = game.HttpGetAsync or nilfunc,
    HttpPost = game.HttpPost or nilfunc,
    HttpPostAsync = game.HttpPostAsync or nilfunc,
    GetObjects = game.GetObjects or nilfunc,
    RequestInternal = HttpService.RequestInternal
}

local HttpMethod = function(self, method, ...)
    local url = typeof(...) == "table" and (...).Url or ...
    printf(format("%s:%s(%s)\n\n", serialize(self), method, serialize(...)))
    if config.BlockWebhook and typeof(url) == "string" and match(url, "webhook") then
        printf("Successfully blocked webhook url: "..url.."\n\n")
        return
    end
    return HttpFunction[method](self, ...)
end

local oldnamecall
oldnamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if checkcaller() then
        if self == game and tologs[method] then
            return HttpMethod(self, method, ...)
        elseif self == HttpService and tologs.Request and method == "RequestInternal" then
            return HttpMethod(self, method, ...)
        end
    end
    return oldnamecall(self, ...)
end))

local oldindex
oldindex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if checkcaller() then
        if self == game and tologs[key] then
            return newcclosure(function(self, ...)
                return HttpMethod(self, key, ...)
            end)
        elseif self == HttpService and tologs.Request and key == "RequestInternal" then
            return newcclosure(function(self, ...)
                return HttpMethod(self, key, ...)
            end)
        end
    end
    return oldindex(self, key)
end))

local oldrequest
local requestfunc = newcclosure(function(data)
    if tologs.Request then
        printf("request("..serialize(data)..")\n\n")
    end
    if config.BlockWebhook and match(data.Url, "webhook") then
        printf("Successfully blocked webhook url: "..data.Url.."\n\n")
        return { Success = true, StatusCode = 200, StatusMessage = "OK", Headers = {}, Body = "" }
    end
    return oldrequest(data)
end)
--oldrequest = hookfunction(request, requestfunc)
oldrequest = request
getgenv().request = requestfunc
getgenv().http_request = requestfunc
setreadonly(http, false)
getgenv().http.request = requestfunc
if syn and syn.request then
    setreadonly(syn, false)
    syn.request = requestfunc
end
