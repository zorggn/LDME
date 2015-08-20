-- Framework main entrypoint
-- by zorg @ 2015 license: ISC

--[[Code Flow:
	this -> _G:love.run -> this:love.load
	this:love.load -> mainmenu.lua (if no script or package is given as a cmdline arg, or if it needs to fall back)
	--]]

--[[Notes:
	- this main will be a skeleton, like always
	- it should pass itself to the default menu state/structure unless a game is passed to it as a parameter
	- have the engine invoke the scripts, cascading through includes, using an elaborate gamestate system...
	- all available funcs in scripts will be setfenv'd into them; stateful ones will be external modules (singletons though)
	--]]



-- Needed before love.load, since this will call it.
love.run = love.filesystem.load('source/gameloop.lua')()



-- Modules

--require 'source.lib.strict'

local gs

local atlas
local audio
local collision
local input
local layers
local loadscript
local log
local ungerm -- debug, that is.



-- Top-level callbacks

love.load = function(arg)

	-- Init the logging system, and add a default engine id.
	log = require 'source.log'
	log.init()
	log.newLog(false, 'logs/log.txt', 'LDME', 'sys', true)

	-- Holds returned script type and the entrypoint's path.
	local scriptType, scriptPath, script

	-- Initialize the engine
	local init = love.filesystem.load('source/init.lua')()

	-- Returns whether it should execute the main menu, a script, or a full game.
	scriptType, scriptPath = init(arg)

	-- Load in the necessary libraries, now that we know we can run the engine.
	gs = require 'source.lib.vrld.hump.gamestate'

	audio = require 'source.audio'
	input = require 'source.input'
	loadscript = require 'source.loadscript'
	ungerm = require 'source.ungerm'

	-- Init the debug lib.
	ungerm.init()

	-- Load the script, and start it!
	script = loadscript(scriptType, scriptPath)
	gs.push(script)

end



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



love.update = function(dt, tick)

	local current = gs.current()
	if current.update then current:update(dt, tick) end

	-- Needs to be at the end of the main update callback,
	-- else it will always replace the pressed/released states.
	input.update(dt,tick) 

end

-- After all scripts have done their updating, the code swaps out the old state with the new one,
-- so there isn't any nondeterminism by ordering.
love.swap = function(dt, tick)

	local current = gs.current()
	if current.swap then current:swap(dt, tick) end

end

-- Every draw here should go to a canvas optimally.
love.draw = function(df)

	local current = gs.current()
	if current.draw then current:draw(df) end

end

-- After all scripts have done their drawing, the code renders all canvas layers to the screen.
love.render = function(df)

	local current = gs.current()
	if current.render then current:render(df) end

	-- Debug data, printed on top of everything
	ungerm.render(df)

end
