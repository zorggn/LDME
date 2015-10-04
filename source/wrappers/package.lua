-- Framework package functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

-- Modules

local gs = require 'source.lib.vrld.hump.gamestate'



-- This module

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".
	t.package = (not barf) and {} or t

	-- Give packages the privilege of using require
	t.require = require

	-- A function that kinda works like lfs.loadfile but also sets the chunk's environment to the environment of the state...
	t.loadPackageScript = function(scriptPath)
		local chunk = love.filesystem.load(scriptPath)
		setfenv(chunk,t)
		chunk = chunk()
		setmetatable(chunk, {__index = t})
		return chunk
	end

	-- Gamestate system usable from packages
	t.state = gs

	-- Get the package's path
	t.getPackageDir = function()
		return t._dir
	end

	t.package = (not barf) and t.package or nil
end