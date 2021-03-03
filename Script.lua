local DEBUG = true

-- 'sendMessage' function
local function sendMessage(text, duration)
	local msg = Instance.new("Message")
	msg.Parent = workspace
	msg.Text = text
	
	game:GetService("Debris"):AddItem(msg, duration)
end

-- make so lightshape cant run more than one time
if not DEBUG then
	if LIGHTSHAPE_LOADED then
		sendMessage("Cannot run Lightshape more than once", 3)
		return
	end
	
	getgenv().LIGHTSHAPE_LOADED = true
end

-- Check if exploit has console functions
do
	local consoleFuncs = {"rconsoleprint", "rconsoleinput", "rconsolename", "rconsoleclear"}
	
	for i, v in ipairs(consoleFuncs) do
		if getfenv()[v] == nil then
			sendMessage("This script does not support your exploit", 3)
			
			return
		end
	end
end

-- Replace console funcs so only Lightshape can use them
do
	local cmdfuncs = {
		print = rconsoleprint,
		read = rconsoleinput,
		clear = rconsoleclear,
		title = rconsolename,
	}

	getgenv().cmd = cmdfuncs
	
	if not DEBUG then
		getgenv().rconsoleclear = function() end
		getgenv().rconsolename = function() end
		getgenv().rconsoleinput = function() end
		getgenv().rconsoleprint = function() end
	end
end
	
	-- output some nice text
cmd.clear()
cmd.title("Lightshape")
cmd.print("@@LIGHT_RED@@")
cmd.print(
[[
<--------------------------------->
 [ Lightshape ] [ Admin commands ]
 [            ] [ Type help      ]
<--------------------------------->
]]
)
cmd.print("@@WHITE@@")
cmd.print("> ")

sendMessage("Welcome to Lightshape", 3)

-- Commands engine
	-- Include command parser
local par = loadstring(game:HttpGet("https://raw.githubusercontent.com/RibeThings/Lightshape/main/CommandParser.lua"))()
	-- Storing commands
local cmds = {}

local function registerCommand(name, func)
	cmds[name] = {
		name = name:lower(),
		func = func,
	}
end

local function run(text)
	local tokens, data = par:parse(text)
		-- Check if parsing had error
	if type(tokens) == "number" then
		cmd.print("@@RED@@")
		cmd.print("Parsing error: " .. (par.errorMessages[tokens]):format(data))
		return
	end
	
	-- If the user didnt input anything
	if #tokens == 0 then
		cmd.print("@@RED@@")
		cmd.print("Please input something")
		return
	end
	
	-- Get which command he did input
	local inputtedCommand = tokens[1]
		-- Check if its something at least valid
	if inputtedCommand.type ~= par.tokenTypes.unknown then
		cmd.print("@@RED@@")
		cmd.print("Syntax error starting at char 1")
		return
	end
	
	local cmddata = cmds[inputtedCommand.token:lower()]
		-- Check if the inputed command exists
	if not cmddata then
		cmd.print("@@RED@@")
		cmd.print(("%s is not a valid command, type help"):format(inputtedCommand.token))
		return
	end
	
	-- Run command
	table.remove(tokens, 1)
	cmddata.func(unpack(tokens))
end

-- Make so user can type commands
local function startTypingCommands()
	return coroutine.wrap(function()
		run(cmd.read())
		
		--
		cmd.print("@@WHITE@@")
		cmd.print("\r\n> ") -- Thanks windows!
	end)
end

startTypingCommands()()

--[[

COMMANDS

]]--

	-- Cool quick vars
local lp = game:GetService("Players").LocalPlayer
local getHum = function()
	return lp.Character and lp.Character:FindFirstChild("Humanoid")
end
local out = function(...)
	for i, v in ipairs({...}) do
		cmd.print(v)
	end
end
local red = "@@RED@@"
local green = "@@GREEN@@"
local lgreen = "@@LIGHT_GREEN@@"
local types = par.tokenTypes

	-- TEST command
if DEBUG then
	registerCommand("say", function(input)
		cmd.print("saying: " .. input.token)
	end)
end

	-- Help command
		-- Thing for adding help
local categories = {}

local function addHelp(commandName, categorie, description)
	if not categories[categorie] then categories[categorie] = {} end
	
	categories[categorie][commandName] = {
		categorie = categorie,
		name = commandName,
		description = description,
	}
end

		-- The command
registerCommand("help", function(categorie)
	if not categorie then
		-- Display categories
		cmd.print("@@LIGHT_BLUE@@")
		cmd.print('do "help [one of the following categories]:"')
		
		local iNum = 0
		for i, v in pairs(categories) do
			iNum = iNum + 1
			local color = (iNum % 2 == 0 and "@@GREEN@@") or "@@LIGHT_GREEN@@"
			
			cmd.print(color)
			cmd.print(("\n  %s"):format(i))
		end
	else
		--	If its not a string/unknown then
		if not (categorie.type == par.tokenTypes.unknown or categorie.type == part.tokenTypes.string) then
			cmd.print("@@RED@@")
			cmd.print("help command error: Invalid categorie")
			return
		end
		
		-- Check if categorie does exist
		local foundCategorie = categories[categorie.token]
		if not foundCategorie then
			cmd.print("@@RED@@")
			cmd.print(("help command error: Categorie %s does not exist"):format(categorie.token))
			return
		end
		
		-- Display the info of that categorie
		local iNum = 0
		for i, v in pairs(foundCategorie) do
			iNum = iNum + 1
			local color = (iNum % 2 == 0 and "@@GREEN@@") or "@@LIGHT_GREEN@@"
			
			cmd.print(color)
			local newLine = iNum ~= 1 and "\n" or ""; cmd.print((newLine .. "  %s: %s"):format(i, v.description))
		end
	end
end)

	-- Character commands
		-- Walkspeed
registerCommand("ws", function(speed)
	-- If speed is not a number
	if speed.type ~= types.number then
		out(red, "ws command error: Input a number as speed")
		return
	end
	
	-- Change walkspeed
	local hum = getHum()
	if hum then hum.WalkSpeed = speed.token end
	out(lgreen, ("Changed walk speed to %d"):format(speed.token))
end)
addHelp("ws [num]", "character", "Changes your character walk speed")

		-- Jumppower
registerCommand("jp", function(power)
	-- If power is not a number
	if power.type ~= types.number then
		out(red, "jp command error: Input a number as power")
		return
	end
	
	-- Change walkspeed
	local hum = getHum()
	if hum then hum.JumpPower = power.token end
	out(lgreen, ("Changed jump power to %d"):format(power.token))
end)
addHelp("jp [num]", "character", "Changes your character jump power")
