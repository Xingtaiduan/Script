local Games = {
    [2440500124] = "Doors",
    [5877971206] = "FPE-S",
    [6331902150] = "被遗弃",
    [3085257211] = "彩虹朋友",
    [4777817887] = "刀刃球",
    [2820580801] = "俄亥俄州",
    [770538576] = "海战",
    [93740418] = "极限捉迷藏",
    [7008097940] = "墨水游戏",
    [1430007363] = "奶奶",
    [66654135] = "破坏者谜团2",
    [7326934954] = "森林中的99夜",
    [4367208330] = "压力",
    [210851291] = "造船寻宝",
    [1526814825] = "战争大亨",
    [65241] = "自然灾害"
}

local cloneref = cloneref or function(a) return a end
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = game:GetService("HttpService")

if not ({...})[1] then
    local name = Games[game.GameId]
    if name then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Xingtaiduan/Script/refs/heads/main/Games/"..HttpService:UrlEncode(name)..".lua"))()
    else
        local message = Instance.new("Message", CoreGui)
        message.Text = "此游戏不受支持"
        task.wait(2)
        message:destroy()
    end
end

return Games
