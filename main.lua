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



-- Modules

-- System modules, as in, what is needed by the core to work.
local gamestates -- HUMP's (stack)
local loadscript -- only used by the core
local log        -- useful
local ungerm     -- debug, that is.

-- Concern modules, as in, you should use these, if you don't want to hack the engine (but feel free to :3)
--local atlas
local audio      -- extended audio capabilities
local camera     -- very robust
--local collision
local input      -- supports 4-valued and virtual states, among other things
local layers     -- canvas handling

-- Gameish modules, as in you may use these if you want, but they're not mandatory for scripts
--local projectile
--local laser
--local entity

-- Note: The above two kinds are not actually used in the core, but we preload them so they won't be required
--       whenever from a probably time-sensitive script.



-- Top-level callbacks

love.load = function(arg)

	-- HAX: get the identity from the config file, in case someone actually uses the engine to create a standalone game...
	--local identity = {['modules'] = {}}; love.conf(identity); identity = identity.identity;
	-- ...or just use the wiki; don't code when you're tired as jigoku zenbun.
	local identity = love.filesystem.getIdentity()

	-- Init the logging system, and add a default id for system stuff.
	log = require 'source.log'
	log.init()
	log.newLog(false, 'logs/log.txt', identity, 'sys', true) -- append, filepath, identity, name, console

	-- Holds returned script type and the entrypoint's path.
	local scriptType, scriptPath

	-- Initialize the engine
	local init = love.filesystem.load('source/init.lua')()

	-- Returns whether it should execute the main menu, a script, or a full game.
	scriptType, scriptPath = init(arg)

	-- Load in the necessary modules, now that we know we can run the engine.

	-- System
	gamestates = require 'source.lib.vrld.hump.gamestate'
	loadscript = require 'source.loadscript'
	-- logger already loaded
	debugoverlay = require 'source.debugoverlay'

	-- Concern
	audio = require 'source.audio'
	input = require 'source.input'
	--layers = require 'source.layers'

	-- Gameish
	-- bullet = ...

	-- Init modules that need to be.
	debugoverlay.init()

	-- Load the script, and start it!
	local script = loadscript(scriptType, scriptPath)
	gamestates.push(script)

end



-- Pass input data to our input module
-- TODO: extend this with controller support as well, and maybe mouse too, though idk how often that's used in a bullet hell shooter...
love.keypressed = function(key,isrepeat)
	input.keypressed(key,isrepeat)
end

love.keyreleased = function(key)
	input.keyreleased(key)
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

	-- Debug data, printed on top of everything
	-- Note, we are cheating a bit here by not drawing to a canvas
	-- -> TODO: do draw to the topmost canvas since we want the screen to be resizable, and like this, it isn't.
	debugoverlay.render(df)

end
