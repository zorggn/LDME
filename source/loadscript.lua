-- Framework script loader function
-- by zorg @ 2015 license: ISC

--[[Notes:
	- This is callable from any script where the wrappers export it
	- TODO: Maybe replace genfunc.lua with more smaller separated files? <-yes
	--]]



-- Uses internal names taken from danmakufu.
local allowedScriptTypes = require "source.scripttypes"
local genericScriptWrprs = require "source.genwrappers"



return function(scriptType, scriptPath)

	local script, wrap

	-- global sandbox for the to-be loaded script
	local environment = {}

	-- Separate the given path to directories and filename.
	local p,n,e = scriptPath:match("(.-)([^\\/]-%.?([^%.\\/]*))$"); n = n:match("(.+)%..*")

	-- Incomplete path fix attemts.	
	if n == nil and (e == nil or e == '') then
		-- If we only gave a directory, then try with "script.lua".
		n, e = 'script', 'lua'

	elseif scriptPath:match('[/][%.]') then
		-- weirdest case, no filename, only extension; Try a generic filename.
		n = 'script'

	elseif n == nil and e and e:len()>0 then
		-- If we didn't give an extension (meaning this will exist, but n will be nil), move the ext. to the name field,
		-- and add the .lua extension to the ext. field.
		n = e; e = 'lua'

	elseif e == nil or e == '' then
		-- Only filename, no extension; give it a lua, and try it.
		e = 'lua'
	end

	scriptPath = tostring(p) .. tostring(n) .. '.' .. tostring(e)

	if not love.filesystem.isFile(scriptPath) then
		error("Error: loadscript: Script '" .. scriptPath .. "' doesn't exist!")
	end

	if allowedScriptTypes[scriptType] then

		script = love.filesystem.load(scriptPath)

		-- Generic script wrappers
		wrap = love.filesystem.load('source/wrappers/genfunc.lua')()
		wrap(environment, false)

		-- Script type dependent wrappers
		wrap = love.filesystem.load('source/wrappers/' .. scriptType .. '.lua')()
		wrap(environment, false)

	else
		error("Error: loadscript: Script type '" .. scriptType .. "' isn't supported!")
	end

	setfenv(script, environment)
	script = script()
	setmetatable(script, {__index = environment})
	
	if not type(script) == 'table' then
		error("Error: loadscript: Script '" .. scriptPath .. "' didn't return a table!")
	end

	-- Set the script's source directory...
	-- ... i admit this is like über-tier hackery, but hey, it works ¯\(°_o)/¯
	script._G._dir = p

	return script
end