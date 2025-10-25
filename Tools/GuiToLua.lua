-- FLOW
-- => Convert(Gui)
-- => LoadDescendants(Res)
--  * Loop all descendants and store them in a reg
-- => WriteInstances(Res) 
--  * Write all instances as long with their properties and attributes
-- => WriteScripts(Res)
--  * Write all scripts routines with their env
-- => Append a default return of the screengui
-- => WriteLogo(Res)
-- return

--// REQUIRES \\--

--local RbxApi = require(script.Parent.rbxapi); 
local RbxApi = (function()

local function SanitizeDump(DumpJSON)
    local Result = {}

    for _, ClassObj in ipairs(DumpJSON.Classes) do
        local skipClass = false

        -- 跳过带有 Deprecated / ReadOnly 标签的类
        if ClassObj.Tags then
            for _, tag in ipairs(ClassObj.Tags) do
                if tag == "Deprecated" or tag == "ReadOnly" then
                    skipClass = true
                    break
                end
            end
        end

        if skipClass then
            continue
        end

        local Members = {}

        for _, Member in ipairs(ClassObj.Members) do
            -- 跳过无效标签
            if Member.Tags then
                local skip = false
                for _, tag in ipairs(Member.Tags) do
                    if tag == "Deprecated" or tag == "ReadOnly" or tag == "Hidden" then
                        skip = true
                        break
                    end
                end
                if skip then
                    continue
                end
            end

            -- 只保留属性类型
            if Member.MemberType ~= "Property" then
                continue
            end

            table.insert(Members, Member.Name)
        end

        Result[ClassObj.Name] = {
            Superclass = ClassObj.Superclass,
            Members = Members
        }
    end

    return Result
end

if not isfile("Version.txt") then writefile("Version.txt", "") end
local Version = game:HttpGet("http://setup.roblox.com/versionQTStudio")
local Dump = isfile("Dump.json") and readfile("Dump.json")

if Version ~= readfile("Version.txt") or not Dump then
    writefile("Version.txt", Version)
    Dump = game:HttpGet("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json")
    writefile("Dump.json", Dump)
end

Dump = game.HttpService:JSONDecode(Dump)
Dump = SanitizeDump(Dump)


--// GLOBALS \\--

-- _Hold all deserialized classes of the dump._
local ROBLOX_REG : {[string]: ClassObject} = {};
-- _Contain all dummy instances used to check default values._
local DUMMIES : {[string]: Instance} = {};
local CACHE : {[string]: PropertiesRes} = {}; -- cache results to avoid loading members & defaults every time

--// STRUCT \\--
export type ValueObject = {Value: any};
export type ClassObject = {
	Name: string,
	Members: {[number]: string},
	Superclass: ClassObject
}
export type PropertiesRes = {[string]: ValueObject} | nil -- Property1: DefaultValue

--// SERIALIZE \\--
for ClassName, ClassObj:ClassObject in pairs(Dump) do
	ClassObj.Name = ClassName;
	-- register class obj
	ROBLOX_REG[ClassName] = ClassObj;
end;

--// CORE \\--

-- Load default values of the passed members dictionary
local function LoadDefaultValues(ClassName:string, Members:PropertiesRes) : nil
	-- make dummy
	local Dummy;
	pcall(function()
		Dummy = DUMMIES[ClassName] or Instance.new(ClassName);
	end);
	-- store dummy
	DUMMIES[ClassName] = Dummy or false;
	-- check dummy integrity
	if not Dummy then
		return;
	end
	-- store default values
	for Member, Default in pairs(Members) do
		pcall(function() -- errors like 'The current identity (5) cannot access...' can occur
			Default.Value = Dummy[Member];
		end);
	end;
end;


-- Return a table containing Members as index and member's DefaultValue as value
local function GetProperties(ClassName:string) : PropertiesRes
	-- check if registred
	local ClassObj = ROBLOX_REG[ClassName];
	if not ClassObj then
		return;
	end
	local Properties : PropertiesRes = {}
	-- Load superclass
	local SuperProp = GetProperties(ClassObj.Superclass);
	-- check if found
	if SuperProp then
		for Member, DefaultValue in pairs(SuperProp) do
			Properties[Member] = DefaultValue;
		end;
	end;
	-- Load class
	for _, Member in pairs(ClassObj.Members) do
		Properties[Member] = {
			Value = nil
		};
	end;
	return Properties;
end

local function GetPropertiesWrapper(ClassName:string) : PropertiesRes
	-- check cache
	if CACHE[ClassName] then
		return CACHE[ClassName];
	end
	-- get properties and load default values by instantiating a dummy instance
	local Properties = GetProperties(ClassName);
	LoadDefaultValues(ClassName, Properties);
	-- cache store
	CACHE[ClassName] = Properties;
	return Properties;
end

local function GetDummy(ClassName:string) : Instance
	return DUMMIES[ClassName];
end

return {
	GetProperties = GetPropertiesWrapper;
	GetDummy = GetDummy;
}
end)()
--local Utils = require(script.Parent.utils);
local Utils = (function()
--// REQUIRE \\--
local G2L;
if false then -- fake block, just load the G2L.ConvertionRes for typechecking
	G2L = require(script.Parent.core);
end

local Utils;
Utils = {
	-- Detect if the plugin is running locally
	IsLocal = function() : boolean
		--return string.find(plugin.Name, ".rbxm") or string.find(plugin.Name, ".lua");
		return true
	end,
	-- Check if plugin has write access to scripts
	HasWriteAccess = function() : boolean
		local Success = pcall(function()
			local Dummy = Instance.new("LocalScript");
			Dummy.Source = "print('Hello World');";
			Dummy.Name = "Test";
			Dummy.Parent = game:GetService("StarterPack");
			Dummy:Destroy();
		end);
		return Success;
	end,
	-- Generate an output folder inside the workspace with the passed name
	GetOutFolder = function(Name) : Folder
		local Out = Instance.new('Folder', game:GetService('StarterPack'));
		Out.Name = Name .. os.time();
		return Out;
	end,
	-- Write parse res Source in a disabled LocalScript, and split it in case roblox
	-- limit the write to the buffer
	WriteConvertionRes = function(Res:G2L.ConvertionRes) : Folder
		local Out = Utils.GetOutFolder(Res.Gui.Name);
		-- split support
		local Parts = {};
		local Idx = 0;
		local SplitSize = 100000;
		while true do
			local Part = Res.Source:sub((SplitSize * Idx) + 1, SplitSize*(Idx+1));
			if Part == '' then
				break;
			end;
			table.insert(Parts, Part);
			Idx += 1;
		end;
		local Integrity = pcall(function()
			for i, Source in next, Parts do
				local LocalScript = Instance.new('LocalScript', Out);
				LocalScript.Name = tostring(i);
				LocalScript.Disabled = true;
				LocalScript.Source = Source;
			end
		end);
		if not Integrity then
			warn("Can't write the converted script in the LocalScript.");
		end
		return Out;
	end;
}

return Utils;
end)()

local RequireProxy = require;
--local Logo = script.Parent.assets.logo.Value;

--// CONST \\--
local F_NEWINST = 
[[
%s["%s"] = Instance.new("%s", %s);
%s
%s
]]; -- %s = Settings.RegName, %s = Id, %s = ClassName, %s = Parent, %s = Properties, %s = Attributes
local F_NEWLUA =
[[
local function %s()
%s
end;
task.spawn(%s);
]] -- %s = ClosureName, %s = ModifiedSource, %s = ClosureName
local F_NEWMOD =
[=[
G2L_MODULES[%s["%s"]] = {
Closure = function()
    local script = %s["%s"];
%s
end;
};
]=] -- %s = RegName, %s = Id, %s = Module.Source, %s = RegName, %s = Id, %s = RegName, %s = Id

local BLACKLIST = {
	Source = true,
	Parent = true,
	DragUDim2 = true
}

--// STRUCT \\--

export type RegInstance = {
	Id: string,
	Instance: Instance,
	Parent: RegInstance
}

export type ConvertionRes = {
	Gui: ScreenGui,
	Settings: Settings,
	Errors: {[number]: string},
	Source: string,
	_INST: {[number]: RegInstance},
	_LUA: {RegInstance}, -- hold local scripts
	_MOD: {RegInstance}  -- hold module scripts
}

export type Settings = {
	RegName: string,
	Comments: boolean,
	--Logo: boolean
}

--// UTIL \\--
local function EncapsulateString(str)
    return "\""..str:gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\"", "\\\"").."\""
end;
--[[
local function EncapsulateString(Str:string)
    local Level = '';
    while true do
        if Str:find(']' .. Level .. ']') then
            Level = Level .. '=';
        else
            break;
        end
    end
    return '['..Level..'[' .. Str .. ']'..Level..']';
end;
]]

--// CORE \\--

local function DefaultSettings() : Settings
	return {
		RegName = 'Main',
		Comments = false,
		--Logo = true
	};
end

local function getUniqueName(tbl, baseName)
	local name = baseName
	local counter = 2
	while tbl[name] do
		name = baseName .. "_" .. counter
		counter += 1
	end
	tbl[name] = true
	return name
end

-- Load descendants and order them in a flatted tree array, in order to provide a y(x) convertion
local function LoadDescendants(Res:ConvertionRes, Inst:Instance, Parent:RegInstance) : nil
	-- register instance
	local Size = #Res._INST+1;
	local RegInst = {
		Parent = Parent,
		Instance = Inst,
		--Id = ('%x'):format(Size); -- hex format simple unique id
		Id = getUniqueName(Res.UsedNames, Inst.Name)
	};
	Res._INST[Size] = RegInst;
	-- check if local script
	if Inst:IsA('LocalScript') then
		Res._LUA[#Res._LUA+1] = RegInst;
	elseif Inst:IsA('ModuleScript') then
		Res._MOD[#Res._MOD+1] = RegInst;
	end;
	-- loop children
	for Idx, Child in next, Inst:GetChildren() do
		LoadDescendants(Res, Child, RegInst) -- recursive time 8)
	end;
end;

local math_round = math.round
local function PrettifyNumber(number: number): number
    return math_round(number * 100000) / 100000
end

-- transpile property to lua
local function TranspileValue(RawValue:any)
    local Value = '';
    local Type = typeof(RawValue);
    if Type == 'string' then
        Value = EncapsulateString(RawValue);
    elseif Type == 'boolean' or Type:match('^Enum') then
        Value = tostring(RawValue);
    -- %.3f format might be better
    elseif Type == 'number' then
		Value = PrettifyNumber(RawValue)
    elseif Type == 'Vector2' then
        Value = ('Vector2.new(%s, %s)'):format(
            PrettifyNumber(RawValue.X), PrettifyNumber(RawValue.Y)
        );
    elseif Type == 'Vector3' then
        Value = ('Vector3.new(%s, %s, %s)'):format(
            PrettifyNumber(RawValue.X), PrettifyNumber(RawValue.Y), PrettifyNumber(RawValue.Z)
        );
    elseif Type == 'UDim2' then
        Value = ('UDim2.new(%s, %s, %s, %s)'):format(
            PrettifyNumber(RawValue.X.Scale), PrettifyNumber(RawValue.X.Offset),
            PrettifyNumber(RawValue.Y.Scale), PrettifyNumber(RawValue.Y.Offset)
        );
    elseif Type == 'UDim' then
        Value = ('UDim.new(%s, %s)'):format(
            PrettifyNumber(RawValue.Scale), PrettifyNumber(RawValue.Offset)
        );
    elseif Type == 'Rect' then
        Value = ('Rect.new(%s, %s, %s, %s)'):format(
            PrettifyNumber(RawValue.Min.X), PrettifyNumber(RawValue.Min.Y),
            PrettifyNumber(RawValue.Max.X), PrettifyNumber(RawValue.Max.Y)
        );
    elseif Type == "Font" then
        Value = ('Font.new(%s, %s, %s)'):format(
			EncapsulateString(RawValue.Family), tostring(RawValue.Weight), tostring(RawValue.Style)
		);
    elseif Type == 'Color3' then
        -- convert rgb float value to decimal
        local R, G, B = math.ceil(RawValue.R * 255), math.ceil(RawValue.G * 255), math.ceil(RawValue.B * 255);
        Value = ('Color3.fromRGB(%s, %s, %s)'):format(
            R, G, B
        );
    elseif Type == "ColorSequence" then
        local Keypoints = '';
        for Idx, KeyPoint:ColorSequenceKeypoint in next, RawValue.Keypoints do
            Keypoints = Keypoints .. ('ColorSequenceKeypoint.new(%.3f, %s),'):format(
                KeyPoint.Time, TranspileValue(KeyPoint.Value)
            );
        end;
        -- remove last comma
        Keypoints = Keypoints:sub(1, -2);
        Value = ('ColorSequence.new{%s}'):format(Keypoints);
	elseif Type == "NumberSequence" then
		local Keypoints = '';
		for Idx, KeyPoint:NumberSequenceKeypoint in next, RawValue.Keypoints do
			Keypoints = Keypoints .. ('NumberSequenceKeypoint.new(%.3f, %s),'):format(
				KeyPoint.Time, TranspileValue(KeyPoint.Value)
			);
		end;
		Keypoints = Keypoints:sub(1, -2);
		Value = ('NumberSequence.new{%s}'):format(Keypoints);
	elseif Type == "CFrame" then
		local Position = RawValue.Position;
		local LookVector = RawValue.LookVector;
		Value = ('CFrame.new(Vector3.new(%s, %s, %s), Vector3.new(%s, %s, %s))'):format(
			PrettifyNumber(Position.X), PrettifyNumber(Position.Y), PrettifyNumber(Position.Z),
			PrettifyNumber(LookVector.X), PrettifyNumber(LookVector.Y), PrettifyNumber(LookVector.Z)
		)
	end
    return Value;
end

local function TranspileProperties(Res:ConvertionRes, Inst:RegInstance) : string
	local Properties = '';
	local Members = RbxApi.GetProperties(Inst.Instance.ClassName);
	for Member, Default:RbxApi.ValueObject in pairs(Members) do
		-- special case skip
		if BLACKLIST[Member] then
			continue;         
			-- default property case
		else
			local CanSkip = false;
			-- skip if default value is set
			local Integrity = pcall(function()
				CanSkip = Inst.Instance[Member] == Default.Value;
			end);
			if CanSkip or not Integrity then
				continue;
			end
			-- transpile value
			local Transpiled = TranspileValue(Inst.Instance[Member]);
			-- if transpiled value is not resolved
			if Transpiled == '' then 
				if Utils.IsLocal() then
					Properties = Properties .. '-- '; -- comment property to debug it
				else
					continue; -- skip property
				end;
			end
			-- append transpiled property to properties
			Properties =  Properties .. ('%s.%s.%s = %s;\n'):format(
			Res.Settings.RegName, Inst.Id,
			Member, Transpiled
			);
		end;
	end;
	-- remove last newline from Properties
	Properties = Properties:sub(1, -2);
	return Properties;
end;

local function TranspileAttributes(Res:ConvertionRes, Inst:RegInstance) : string
	local Attributes = '';
	local Found = false;
	-- loop attributes and transpile them
	for Attribute, RawValue in next, Inst.Instance:GetAttributes() do
		local Transpiled = TranspileValue(RawValue);
		-- if transpiled value is not resolved
		if Transpiled == '' then 
			if Utils.IsLocal() then
				Attributes = Attributes .. '-- '; -- comment property to debug it
			else
				continue; -- skip property
			end;
		end;
		Found = true;
		-- append transpiled attribute to attributes
		Attributes = Attributes .. ('%s["%s"]:SetAttribute(%s, %s);\n'):format(
		Res.Settings.RegName, Inst.Id,
		EncapsulateString(Attribute), Transpiled
		);
	end;
	-- apply comment if attributes found
	if Found and Res.Settings.Comments then
		Attributes =  '-- Attributes\n' .. Attributes;
	end;
	return Attributes;
end


local function WriteInstances(Res:ConvertionRes)
	for _, Inst in next, Res._INST do
		-- set comment
		local Comment = '';
		if Res.Settings.Comments then
			Comment = '-- ' .. Inst.Instance:GetFullName() .. '\n';
		end
		-- solve parent
		local Parent = '';
		if Inst.Parent == nil then -- gui case
			-- TODO: let user choice wich parent use for the ScreenGui from Settings
			Parent = 'game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")';
		else
			Parent = ('%s["%s"]'):format(
			Res.Settings.RegName, Inst.Parent.Id
			); -- we have to get the id to reference the right parent
		end
		-- write instance
		Res.Source =  Res.Source .. Comment.. F_NEWINST:format(
			Res.Settings.RegName,
			Inst.Id,
			Inst.Instance.ClassName,
			Parent,
			TranspileProperties(Res, Inst), TranspileAttributes(Res, Inst)
		);
	end
end;

local function WriteScripts(Res:ConvertionRes)
	-- write require proxy before loading all modules
	if #Res._MOD > 0 then
		if Res.Settings.Comments then
			Res.Source = Res.Source .. ('-- Require G2L wrapper\n'):format(#Res._MOD);
		end;
		Res.Source = Res.Source .. RequireProxy.Source .. '\n\n';
	end;
	-- register all modules state in the G2L_MODULES
	for _, Module in next, Res._MOD do
		Res.Source = Res.Source .. F_NEWMOD:format(
			Res.Settings.RegName, Module.Id,
			Res.Settings.RegName, Module.Id,
			Module.Instance.Source
		);
	end
	for _, Script in next, Res._LUA do
		-- skip case
		if Script.Instance.Disabled then
			continue;
		end
		local ClosureName = 'C_' .. Script.Id;
		-- set comment
		local Comment = '';
		if Res.Settings.Comments then
			Comment = '-- ' .. Script.Instance:GetFullName() .. '\n';
		end
		-- fix tabulation and apply script variable in the env
		local Source = ('local script = %s["%s"];\n\t'):format(
		Res.Settings.RegName, Script.Id
		) .. Script.Instance.Source:gsub('\n', '\n\t');
		-- write
		Res.Source = Res.Source .. Comment .. F_NEWLUA:format(
			ClosureName, Source,
			ClosureName
		);
	end
end

local function Convert(Gui:ScreenGui, Settings:Settings?) : ConvertionRes
	Settings = Settings or DefaultSettings();
	local Res : ConvertionRes = {
		Gui = Gui,
		Settings = Settings,
		Errors = {},
		Source = '',
		_INST = {},
		_LUA = {},
		_MOD = {}
	};
	Res.UsedNames = {}
	Res.Source = ('local %s = {};\n\n'):format(Settings.RegName);
	LoadDescendants(Res, Gui, nil);
	WriteInstances(Res);
	WriteScripts(Res);
	--Res.Source = Res.Source .. ('\nreturn %s["%s"], require;'):format(Settings.RegName, Res._INST[1].Id);
	-- apply comments
	if Settings.Comments then
		local Info = ('-- Instances: %d | Scripts: %d | Modules: %d\n'):format(
		#Res._INST, #Res._LUA, #Res._MOD
		);
		Res.Source = Info .. Res.Source;
	end
	-- apply logo
	--if Settings.Logo then
	--	Res.Source = Logo .. '\n\n' .. Res.Source
	--end
	return Res;
end;

getgenv().gui2lua=Convert
