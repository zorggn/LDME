-- Engine main entrypoint
-- by zorg @ 2015 license: ISC

--[[Notes:
	- this main will be a skeleton, like always
	- it should go to the default menu state/structure unless a game or script is passed to it as a parameter
	- have the engine invoke the scripts, cascading through includes, using an "elaborate" gamestate system...
	- all available scripts will be setfenv'd into a shared sandbox;
	- external modules (singletons) will be passed along into that sandbox
	--]]



-- Needed before love.load, since this will call it.
love.run = love.filesystem.load('source/gameloop.lua')()



-- For testing purposes mostly
--require 'source.lib.strict'



-- Locals

-- These are actually used in this file
local gamestates                -- script stack
local log                       -- very handy

local audio
local input

-- The strings are the modules' path pattern from the source folder.
local moduleList = {
	"audio",                     -- extended audio capabilities
	"camera",                    -- robust 2D implementation, extendable
	"input",                     -- supports 4-valued and virtual states, among other things
	"layers",                    -- z-ordering via canvases
}

--local atlas --local collision --local projectile --local laser --local entity



-- Top-level callbacks

love.load = function(arg)

	-- Get the identity from the config file, in case someone actually uses the engine to create a standalone game...
	local identity = love.filesystem.getIdentity()

	-- Init the logging system, and add a default id for system stuff.
	log = require 'source.log'; log.init()
	log.newLog(false, 'logs/log.txt', identity, 'sys', true) -- append, filepath, identity, name, console

	-- Require in the modules, and initialize them
	for i,v in ipairs(moduleList) do
		local module = require('source.' .. v)
		if module.init then module.init() end

		-- temporary hack for the two that we do use for faster access
		if v == 'audio' then audio = module end
		if v == 'input' then input = module end
	end

	-- Initialize the framework; returns whether it should execute the main menu, a script, or a full game;
	-- variables hold returned script type and the entrypoint's path.
	local init = love.filesystem.load('source/init.lua')()
	local scriptType, scriptPath = init(arg)

	-- Load the script
	local loadscript = love.filesystem.load('source/loadscript.lua')()
	local script = loadscript(scriptType, scriptPath)

	-- Load in the state system and start the script
	gamestates = require "source.lib.vrld.hump.gamestate"
	gamestates.push(script)

end

-- The raw game loop cycles, not tick/frame-limited.
love.atomic = function(da)
	audio.update(da)
end

-- Tickrate-limited loop
love.update = function(dt, tick)

	local current = gamestates.current()
	if current.update then current:update(dt, tick) end

	-- Needs to be at the end of the main update callback,
	-- else it will always replace the pressed/released states.
	input.update(dt,tick) 

end

-- After all scripts have done their updating, the code swaps out the old state with the new one,
-- so there isn't any nondeterminism by ordering. (Think: Wrapped (Toroidal) 2D Cellular Automata)
love.swap = function(dt, tick)

	local current = gamestates.current()
	if current.swap then current:swap(dt, tick) end

end

-- Framerate-limited; Every draw here should go to a canvas optimally.
love.draw = function(df)

	local current = gamestates.current()
	if current.draw then current:draw(df) end

end

-- After all scripts have done their drawing, the code renders all canvas layers to the screen.
love.render = function(df)

	local current = gamestates.current()
	if current.render then current:render(df) end

end



-- Internal events

-- Pass input data to our input module
-- TODO: extend this with controller support as well, and maybe mouse too, though idk how often that's used in a bullet hell shooter...
love.keypressed = function(key,isrepeat)
	input.keypressed(key,isrepeat)
end

love.keyreleased = function(key)
	input.keyreleased(key)
end