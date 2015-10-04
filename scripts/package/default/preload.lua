-- Default package - preloader
-- by zorg @ 2015 license: ISC

--[[Notes:
	- This is needed for several reasons:
	- We need to have a "bottom" state, that loads in the background state,
	  pushes it to the state stack, then also pushes the main menu on top of that.
	- This effectively gets us the effects of a "singleton" background state
	  without needing to resort to require and its environment disregarding behaviour.
	- Callbacks like swap and render have been omitted, since this is supposed to be a
	  simple menu implementation.
	- ...Alternatively, we can ditch messing around with the FSM, and just barf everything
	  into the sandboxed global space; loadPackageScript ensures that other chunks will have
	  the same environment as the originator, aka this one.
	--]]



-- global scriptMenu, mainMenu, background

local time, waitTime -- in seconds

local script = {
	version = '0.1.0',
	type = 'package',
	title = 'LDME Default Menu',
	description = 'Loaded in by default',
	thumbnail = false,
}



script.init = function(self)
	local path = getPackageDir()
	scriptMenu  = loadPackageScript(path .. 'scriptmenu.lua')
	mainMenu    = loadPackageScript(path .. 'mainmenu.lua')
	background  = loadPackageScript(path .. 'background.lua')

	background:init(); background.init = nil
	mainMenu:init();   mainMenu.init   = nil
	scriptMenu:init(); scriptMenu.init = nil

	waitTime = 1.5
	time = 0
end

script.enter = function(self, from)
	background:enter(from)
end

script.leave = function(self, to)
	-- nothing
end

script.update = function(self, dt, tick)
	time = time + dt

	background:update(dt, tick)

	if time > waitTime then
		state.push(mainMenu)
		return
	end
end

script.draw = function(self, df)
	background:draw(df)
end

return script