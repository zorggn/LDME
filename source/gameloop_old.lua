-- Framework game loop
-- modified by zorg @ 2015

--[[Code Flow:
	main.lua -> this
	this -> main.lua:love.load
	this c> main.lua:love.*
	--]]

--[[Notes:
	-- A custom love.run (game loop) implementing constant update - variable fps, 
	-- with a custom call designed to swap buffers on objects that are double buffered.
	--]]



-- Locals

local tickLength = 1/60			-- How many updates the framework and the game does per second
local maxFrameSkip = 1			-- How many render frames can we skip in lieu of updating

local tick = 0					-- Global tick count



-- Addends to love namespace

love.timer.getTPS = function()
	return math.min(1/tickLength,1/love.timer.getDelta())
end



----------
-- This module

return function()
 
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end
 
	if love.event then
		love.event.pump()
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
 	-- Define locals
	local dt = 0
	local lag = 0
	local frameStart = 0
	local skippedFrames = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end


 		lag = lag + dt
 		skippedFrames = 0
		while lag > tickLength do
			if skippedFrames > maxFrameSkip then
				break
			end
			skippedFrames = skippedFrames + 1
			-- Call update
			if love.update then love.update(tickLength,tick) end
			-- Call swap
			if love.swap then love.swap() end
			tick = tick + 1
			lag = lag - tickLength
		end


		-- Call draw
		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw(lag/tickLength) end
			love.graphics.present()
		end

		local _,_,mode = love.window.getMode()
		if (not mode.vsync) and love.timer then love.timer.sleep(0.001) end
	end
 
end