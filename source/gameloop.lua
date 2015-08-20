-- Framework game loop
-- modified by zorg @ 2015

--[[Code Flow:
	main.lua -> this
	this -> main.lua:love.load
	this c> main.lua:love.* callbacks/events
	--]]

--[[Notes:
	-- A custom love.run (game loop) implementing constant update - variable fps, 
	-- with a custom call designed to swap buffers on objects that are double buffered.
	-- Added love.swap callback designed to swap buffers on double-buffered objects. (deterministic simulation)
	-- De-hooked both update and draw from the atomic loop.
	-- Forced both renderframe and updatetick speed consistencies via variables and checks.
	-- Added the detection of the screen's framerate, so it can automatically sync the render loop.
	-- Added love.updateAtomic callback to be used by the audio module, for precise loop timing.
	-- Added love.render callback for separating gamestate to-canvas drawing, and canvas to-screen rendering. (ordering)
	--]]



-- Locals

local optimalTPS = 1/60         -- How many updates the framework and the game does per second
local optimalFPS = 1/75         -- Optimally, this is the current screen's vsync value
local maxFrameSkip = 1          -- How many render frames can we skip in lieu of updating

local tick = 0                  -- Global tick count



-- Addends to love namespace

-- Note: lt.getDelta will return the atomic time taken for each loop, whether it runs a tick or a frame, or not.
love.timer.getTPS = function()
	return math.min(1/optimalTPS,1/love.timer.getDelta())
end

-- Overwrite the FPS function, because it'll be invalid with the modified game loop
love.timer.getFPS = function()
	return math.min(1/optimalFPS,1/love.timer.getDelta())
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



 	-- Loads in modules and runs init function.
	if love.load then love.load(arg) end



	-- Assuming initialization happened without errors in love.load, we have a window now;
	-- We need to get the current screen's framerate, so we can implement a "manual" vsync of sorts.
	if not love.window.isCreated then
		error("Error: love.run: Window not initialized!")
	end

	local _, _, flags = love.window.getMode()

	-- set a default if it can't be detected
	optimalFPS = flags.refreshrate ~= 0 and 1/flags.refreshrate or 1/60



	-- Define locals for the loop itself:

	-- Atomic deltatime independent of updates or rendering.
	local da = 0

	-- Accumulators, and the time that remained after the update/draw routines did all the constant time cycles they could.
	local dt = 0
	local df = 0

	-- Implemented as the stopping criteria of multiple update cycles without a render cycle.
	local skippedFrames = 0



	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

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
 


		-- Update atomic timer, as we'll be passing it to update.
		if love.timer then
			love.timer.step()
			da = love.timer.getDelta()
		end

		--print("da = ",da)

		-- Atomic update routine.
		if love.atomic then love.atomic(da) end



		-- Constant-time update core.

 		dt = math.min(dt + da, optimalTPS*2)

 		skippedFrames = 0

		-- Skips execution if not enough time has accumulated in dt.
		while dt >= optimalTPS do

			-- If we have frame skipping, break out if max frames have been reached
			if skippedFrames > maxFrameSkip then
				break
			end
			skippedFrames = skippedFrames + 1

			--print("dt = ",dt)

			-- Call update
			if love.update then love.update(optimalTPS,tick) end

			-- Call swap
			if love.swap then love.swap() end

			tick = tick + 1

			dt = dt - optimalTPS
		end



		-- Constant-time render core

		df = math.min(df + da, optimalFPS*2)

		if df >= optimalFPS then

			df = df % optimalFPS

			--print("df = ",df)

			if love.window and love.graphics and love.window.isCreated() then

				love.graphics.clear()
				love.graphics.origin()

				if love.draw then love.draw(dt/optimalTPS) end

				if love.render then love.render(dt/optimalTPS) end

				love.graphics.present()
			end

		end



		-- Check for vsync state; as long as it's not set, we need to sleep.
		local _,_,flags = love.window.getMode()
		if love.timer then
			love.timer.sleep(0.001)
		end
		optimalFPS = flags.refreshrate ~= 0 and 1/flags.refreshrate or 1/60

	end
 
end