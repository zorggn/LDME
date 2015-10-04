-- Framework script loader function
-- by zorg @ 2015 license: ISC

--[[Notes:
	- This is callable from any script where the wrappers export it
	- TODO: Maybe replace genfunc.lua with more smaller separated files? <-yes (genericScriptWrprs table, lists wrapper files)
	--]]



-- Localized love modules

local lfs = love.filesystem



-- Modules

local log = require 'source.log'



-- Locals

local allowedScriptTypes = require "source.scripttypes"
local genericScriptWrprs = require "source.genwrappers"



-- This module

return function(scriptType, scriptPath)

	local script, wrap

	-- Global sandbox for the to-be loaded script.
	local environment = {}

	-- Separate the given path to directories and filename.
	local p,n,e = scriptPath:match("(.-)([^\\/]-%.?([^%.\\/]*))$"); n = n:match("(.+)%..*")

	-- Incomplete path fix attemts.	
	if n == nil and (e == nil or e == '') then
		-- If we only gave a directory, then try with "script.lua".
		n, e = 'script', 'lua'

	elseif scriptPath:match('[/][%.]') then
		-- Weirdest case, no filename, only extension; Try a generic filename.
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

	if not lfs.isFile(scriptPath) then
		local s = string.format("Error: loadscript: Script '%s' doesn't exist!", scriptPath)
		log('sys',s); error(s)
	end

	if allowedScriptTypes[scriptType] then

		script = lfs.load(scriptPath)

		-- Generic script wrappers
		for i,v in ipairs(genericScriptWrprs) do
			wrap = lfs.load('source/wrappers/' .. v .. '.lua')()
			wrap(environment)
		end

		-- Script type dependent wrappers
		wrap = lfs.load('source/wrappers/' .. scriptType .. '.lua')()
		wrap(environment)

	else
		local s = string.format("Error: loadscript: Script type '%s' isn't supported!", scriptType)
		log('sys',s); error(s)
	end

	-- Deep magic happens here...
	setfenv(script, environment)
	script = script()
	setmetatable(script, {__index = environment})
	
	if not type(script) == 'table' then
		local s = string.format("Error: loadscript: Script '" .. scriptPath .. "' didn't return a table!", scriptPath)
		log('sys',s); error(s)
	end

	-- Set the script's source directory...
	-- ... i admit this is like über-tier hackery, but hey, it works ¯\(°_o)/¯
	script._G._dir = p

	return script
end