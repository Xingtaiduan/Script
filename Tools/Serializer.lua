local str_types = {
    ["boolean"] = true,
    ["userdata"] = true,
    ["function"] = true,
    ["number"] = true,
    ["nil"] = true
}

local function count_table(t)
    local c = 0
    for i, v in next, t do
        c = c + 1
    end
    return c
end

local function string_ret(v, typ)
    local ret, mt, old_func
    if typ == "number" then
        if v ~= v then
            return "0/0"
        elseif v == math.huge then
            return "math.huge"
        elseif v == -math.huge then
            return "-math.huge"
        else
            return tostring(v)
        end
    end
    if typ ~= "table" or typ ~= "userdata" then
        return tostring(v)
    end
    mt = (getrawmetatable or getmetatable)(v)
    if not mt then 
        return tostring(v)
    end

    old_func = rawget(mt, "__tostring")
    rawset(mt, "__tostring", nil)
    ret = tostring(v)
    rawset(mt, "__tostring", old_func)
    return ret
end

local function formatstr(str)
    local format = string.format
    local char = string.char
    local cleanTable = {}
    for i = 0, 31 do
        cleanTable[char(i)] = "\\" .. format("%03d", i)
    end
    for i = 127, 255 do
        cleanTable[char(i)] = "\\" .. format("%03d", i)
    end
    return str:gsub("[\0-\31\127-\255]", cleanTable):gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\"", "\\\"")
end

local function GetInstancePath(obj)
    local path = ""
    while obj do
        local indexName
        if string.match(obj.Name,"^[%a_][%w_]*$") then
            indexName = "." .. formatstr(obj.Name)
        else
            indexName = '["'..formatstr(obj.Name)..'"]'
        end
        if obj == game then
            path = "game"..path
            break
        elseif obj.Parent == game then
            if obj == workspace then
                path = "workspace" .. path
                break
            elseif game:FindService(obj.ClassName) then
                indexName = ":GetService(\"" .. obj.ClassName:gsub(" ", "") .. "\")"
            end
        elseif obj.Parent then
            local fc = obj.Parent:FindFirstChild(obj.Name)
            if fc and fc ~= obj then
                local children = obj.Parent:GetChildren()
                local index = table.find(children, obj)
                if index then
                    indexName = ":GetChildren()[" .. index .. "]"
                end
            end
        elseif not obj.Parent then
            path = "Instance.new(\""..obj.ClassName.."\")"
            break
        end
        path = indexName..path
        obj = obj.Parent
    end
    return path
end

local function SerializeTable(Table, Padding, Cache)
    local str = ""
    local count = 1
    local num = count_table(Table)
    local hasEntries = num > 0

    local Cache = Cache or {}
    local Padding = Padding or 1
    
    if Cache[Table] then
        return string_ret(Table) .. " --[[already seen]]"
    end
    Cache[Table] = true

    local function LocalizedFormat(v, isTable, isNaN)
        if isTable then
            return SerializeTable(v, Padding + 1, Cache)
        elseif isNaN then
            return "0/0"
        else
            return formatValue(v)
        end
    end

    for i, v in next, Table do
        local TypeIndex, TypeValue = typeof(i) == "table", typeof(v) == "table"
        local isNaN = false
        if v ~= v then
            isNaN = true
            v = "NaN"
        end

        str = ("%s%s[%s] = %s%s\n"):format(str, string.rep("    ", Padding), LocalizedFormat(i, TypeIndex), LocalizedFormat(v, TypeValue, isNaN), (count < num and "," or ""));
        count = count + 1
    end

    return ("{" .. (hasEntries and "\n" or "")) .. str .. (hasEntries and string.rep("    ", Padding - 1) or "") .. "}"
end

function formatValue(v)
    local typ = typeof(v)

    if str_types[typ] then
        return string_ret(v, typ)
    elseif typ == "table" then
        return SerializeTable(v)
    elseif typ == "string" then
        return "\"".. formatstr(v) .."\""
    elseif typ == "Instance" then
        return GetInstancePath(v)
    elseif typ == "Enums" then
        return "Enum"
    elseif typ == "Enum" then
        return "Enum."..tostring(v)
    elseif typ == "EnumItem" then
        return "Enum."..tostring(v.EnumType).."."..v.Name
    elseif typ == "buffer" then
        return "buffer.fromstring(\""..formatstr(buffer.tostring(v)).."\")"
    else
        return typ..".new(" .. tostring(v) .. ")"
    end
end

local function serializeArgs(...) 
    local serialized = {}
    for i,v in pairs({...}) do
        local idx = #serialized + 1
        serialized[idx] = formatValue(v)
    end
    return table.concat(serialized, ", ")
end

local function serialize(...)
    local args = {...}
    if #args > 1 then return serializeArgs(...) end
    local value = args[1]
    return formatValue(value)
end

getgenv().serialize = serialize
return serialize
