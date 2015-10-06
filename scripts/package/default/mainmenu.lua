-- Default package - main menu
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Cleanup phase
	--]]



-- Locals

local bgTimer = 0
local waveTimer = 0
local transitionTimer = 0
local transition = ''

local menu = {}
menu.count = 0
menu.current = 0
menu.tweenDuration = 1.0 -- seconds
menu.new = function(self, text, description, bgmMute, task)
	local t       = {}				self.count = self.count + 1;
	t.text        = text;			t.desc        = description
	t.task        = task;			t.timer       = 0
	t.tweenIn     = false;			t.tweenOut    = false
	t.bgmMute     = bgmMute;		--
	self[self.count] = t;			return self.count
	end



-- This module

local script = {}



-- Callbacks

script.init = function(self)

	local path = getPackageDir()

	-- vkeys (raw keys are added automatically)

	input.addVKey('up',     'up',       'player1')
	input.addVKey('down',   'down',     'player1')
	input.addVKey('left',   'left',     'player1')
	input.addVKey('right',  'right',    'player1')
	input.addVKey('focus',  'lshift',   'player1')
	input.addVKey('shot',   'y',        'player1')
	input.addVKey('bomb',   'x',        'player1')
	input.addVKey('spec',   'c',        'player1')

	input.addVKey('select', 'return')
	input.addVKey('back',   'escape')

	input.addVKey('debugInfo',   'f1',  'debug')
	input.addVKey('noCollisions','f2',  'debug')
	input.addVKey('maxHealth',   'f3',  'debug')
	input.addVKey('maxPower',    'f4',  'debug')
	input.addVKey('maxBombs',    'f5',  'debug')

	-- audio stuff

	self.bgm = audio.newBGM(path..'assets/menu.ogg')
	audio.setBGMLoopPoints(self.bgm)

	self.sfxSelect = audio.newSFX(path..'assets/sfx_select.wav')
	self.sfxMove = audio.newSFX(path..'assets/sfx_move.wav')

	-- fonts

	self.font = love.graphics.newFont(path..'assets/yuyuko.ttf',48)
	self.ttFont = love.graphics.newFont(path..'assets/Cirno.ttf',20--[[16]])

	-- menu

	--temporary
	menu:new("All",       "Scripts of all types, for listing purposes...",            false, function() state.switch(scriptMenu, '*')         end)
	--permanent
	menu:new("Pattern",   "Single scripts; shots, mooks, bombs, spellcards.",         false, function() state.switch(scriptMenu, 'single')    end)
	menu:new("Sequence",  "Plural scripts; bosses, single or multiple simultaneous.", false, function() state.switch(scriptMenu, 'plural')    end)
	menu:new("Stage",     "Stage scripts; waves of bullets, mooks and bosses!",       false, function() state.switch(scriptMenu, 'stage')     end)
	menu:new("Character", "Player scripts; playtest your characters or teams!",       false, function() state.switch(scriptMenu, 'character') end)
	menu:new("Package",   "Complete games; kinda immersion breaking, but meh.",       false, function() state.switch(scriptMenu, 'package')   end)
	menu:new("Exit",      "Do be back soon! :3",                                      true,  function() love.event.quit()                     end)
end



script.enter = function(self)

	transition = 'entering'
	transitionTimer = 0

	local s = audio.getSources(self.bgm)
	s = s[1]
	if s:isPlaying() then
		audio.fadeBGM(self.bgm, 2.0, 1.0)
	else
		audio.playBGM(self.bgm, 2.0)
	end
end



script.leave = function(self)
	transition = ''
	transitionTimer = 0
end



script.update = function(self, dt, tick)

	-- timers

	bgTimer = bgTimer + dt/4
	waveTimer = waveTimer + dt

	-- gamestate transition

	if transition == 'entering' then
		if transitionTimer < 1.0 then
			local v = math.min(1.0, transitionTimer + dt * 2.0) -- 0.5 seconds to full transition
			transitionTimer = v
		end
		if transitionTimer == 1.0 then
			transition = ''
		end
	elseif transition == 'leaving' then
		if transitionTimer > 0.0 then
			local v = math.max(0.0, transitionTimer - dt * 1.5) -- 0.5 seconds to full transition
			transitionTimer = v
		end
		if transitionTimer == 0.0 then
			menu[menu.current].task()
		end
	end

	-- key detection

	if transition == '' then

		if input.isVKeyActive('up') then
			local held = input.getVKeyHeldTicks('up')
			if held == 0 or (held > 15 and (held % 5 == 0)) then
				if menu.current == 0 then 
					menu.current = menu.count
				else
					menu[menu.current].tweenOut = true
					menu.current = ((menu.current - 2) % menu.count) + 1
				end
				menu[menu.current].tweenOut = false
				menu[menu.current].tweenIn = true
				-- sound
				audio.playSFX(self.sfxMove, 0.95 + ((love.math.random()*2)-1)/100)
			end
		end

		if input.isVKeyActive('down') then
			local held = input.getVKeyHeldTicks('down')
			if held == 0 or (held > 15 and (held % 5 == 0)) then
				if menu.current ~= 0 then menu[menu.current].tweenOut = true end
				menu.current = ((menu.current - 0) % menu.count) + 1
				menu[menu.current].tweenOut = false
				menu[menu.current].tweenIn = true
				-- sound
				audio.playSFX(self.sfxMove, 1.05 + ((love.math.random()*2)-1)/100)
			end
		end

		if input.getVKeyState('shot') == 'pressed' or input.getVKeyState('select') == 'pressed' then
			if menu.current == 0 then
				menu.current = ((menu.current - 0) % menu.count) + 1
				menu[menu.current].tweenOut = false
				menu[menu.current].tweenIn = true
			else
				transition = 'leaving'
				if menu[menu.current].bgmMute then
					audio.fadeBGM(self.bgm, 1.5, 0.0)
				end
			end
			-- sound
			audio.playSFX(self.sfxSelect, 1.0)
		end

		if input.getVKeyState('bomb') == 'pressed' or input.getVKeyState('back') == 'pressed' then
			if menu.current ~= menu.count then
				if menu.current ~= 0 then
					menu[menu.current].tweenOut = true
				end
				menu.current = menu.count
				menu[menu.current].tweenOut = false
				menu[menu.current].tweenIn = true
			end
			-- sound
			audio.playSFX(self.sfxSelect, 0.67)
		end
		
	end

	-- tooltip tweening (alpha + swimIn from left just below the main menu options)

	for i,v in ipairs(menu) do
		if v.tweenIn then
			v.timer = math.min(v.timer + dt*3, 1.0)
			if v.timer == 1.0 then v.tweenIn = false end
		elseif v.tweenOut then
			v.timer = math.max(v.timer - dt*3, 0.0)
			if v.timer == 0.0 then v.tweenOut = false end
		end
	end

	-- background

	background:update(dt, tick)

end



script.draw = function(self, df)

	local t = bgTimer % 1
	local f = t<=0.5 and t*2 or (0.5-t/2)*4

	-- background

	background:draw(df)

	-- menu elements

	love.graphics.setBlendMode('additive')

	local n = menu.count

	for i,v in ipairs(menu) do

		local m = f * transitionTimer -- still in the [0,1] range

		-- menu texts

		love.graphics.setFont(self.font)

		if menu.current == i then love.graphics.setColor(255,     (f)*159, 255, 255*transitionTimer)
		                     else love.graphics.setColor(255, 159+(f)* 95, 255, 223*transitionTimer)
		end

		local wx,rx = math.modf((640-self.font:getWidth(v.text)/2) + math.sin(waveTimer+(i*(2*math.pi/n)))*10)
		local wy,ry = math.modf(((i-1) * (720/(n+1))) + (720/(2*n)))
		love.graphics.print( v.text, wx, wy, 0, 1, 1, -rx, -ry)

		-- menu tooltip tweens

		love.graphics.setFont(self.ttFont)

		love.graphics.setColor(255,192+(1-f)*63,64+(f)*191,191*v.timer*transitionTimer)

		wx,rx = math.modf((640-self.font:getWidth(v.text)/2)-100 + (v.timer*100) + math.cos(waveTimer+(i*(2*math.pi/n)))*10)
		wy,ry = math.modf(((i-1) * (720/(n+1))) + (720/(2*n))*2)
		love.graphics.print(v.desc, wx, wy, 0, 1, 1, -rx, -ry)
		--love.graphics.print(v.desc, wx, wy, 0, 1, 1, 0, 0)

	end

end



script.render = function(self, df)
	overlay.render(df)
end



----------

return script