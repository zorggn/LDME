






-- Locals

local bgTimer = 0
local transitionTimer = 0
local transition = ''

local menu = {}
menu.count = 0
menu.current = 0
menu.tweenDuration = 1.0 -- seconds
menu.new = function(self, text)
	local t       = {}				self.count = self.count + 1;
	t.text        = text;           t.timer       = 0
	t.tweenIn     = false;			t.tweenOut    = false
	self[self.count] = t;			return self.count
	end

local list = {}
list.count = 0
list.current = 0
list.new = function(self, text, description, path)
	local t       = {}				self.count = self.count + 1;
	t.text        = text;			t.desc        = description
	t.path        = path;			t.timer       = 0
	t.tweenIn     = false;			t.tweenOut    = false
	self[self.count] = t;			return self.count
	end

local recursiveEnumerate

-- This module

local state = {}



-- Callbacks

state.init = function(self)

	local path = getPackageDir()

	-- fonts
	self.font     = love.graphics.newFont(path .. 'assets/yuyuko.ttf',48)
	self.listFont = love.graphics.newFont(path .. 'assets/Cirno.ttf',24)

	-- menubar
	menu:new("Back",         false, function() state.switch(scriptMenu, 'single')    end)
	menu:new("List",         false, function() state.switch(scriptMenu, 'single')    end)
	menu:new("Refresh",      false, function() state.switch(scriptMenu, 'plural')    end)
	menu:new("Order:  ABC ", false, function() state.switch(scriptMenu, 'stage')     end)
	menu:new("Details",      false, function() state.switch(scriptMenu, 'character') end)

	-- search subfolders for single patterns
	self.search = {}
	recursiveEnumerate = function(dir, scriptType, tbl)
		local files = love.filesystem.getDirectoryItems(dir)
		for i,v in ipairs(files) do

			local file = dir.."/"..v

			if love.filesystem.isFile(file) then

				local p,n,e = file:match("(.-)([^\\/]-%.?([^%.\\/]*))$"); n = n:match("(.+)%..*")

				-- load in the info from the package
				local isArchive = false
				if e == 'zip' then
					isArchive = true
					local ok = love.filesystem.mount(p .. '/' .. n .. '.' .. e, 'temp_package')
					if ok then
						if love.filesystem.isFile('temp_package/init.lua') then
							local init = love.filesystem.load('temp_package/init.lua')
							init = {init()}
							if init[5] and love.filesystem.isFile('temp_package/' .. init[5]) then


					else
						-- TODO: skip all the below code
					end
				end

				if e == 'lua' then

					local ok, contents = debug.pcall(love.filesystem.load, file)

					if ok then

						ok, contents = debug.pcall(contents)

						if ok then

							if type(contents) == 'table' then

								-- script needs to be an accepted type, but if no type filter is given, then we list all accepted script types.
								if contents.type and ((contents.type == scriptType) or not scriptType) then

									print(p,n,e)

									-- import the data to be displayed
									local entry = {}

									-- generic file data
									entry.name = n
									entry.ext = e
									entry.path = p
									entry.baseDir = love.filesystem.getRealDirectory(file) == love.filesystem.getSaveDirectory() and 'SaveDir ' or 'Internal'
									
									-- get last modification date
									local date = getLastModificationTime(file)
									if date then date = datetime.getDateFormatted("%Y/%m/%d %H:%M:%S", date) else date = '9999/99/99 99:99:99' end
									entry.lastModified = date

									-- generic script data
									entry.version = contents.version or false
									entry.title = contents.title or false
									entry.description = contents.description or false
									entry.thumbnail = contents.thumbnail or false

									-- create an image if thumbnail is given
									if entry.thumbnail then
										entry.image = love.graphics.newImage(dir .. '/' .. entry.thumbnail)
									end

									-- specific script data
									-- TODO: wrap these in if-elseif blocks for each script type.
									entry.difficultyLevel = contents.difficulty or false
									entry.allowedCharacters = contents.playableCharacters or false

									-- get rid of the loaded script
									contents = nil

									-- add it to the table
									tbl[#tbl+1] = entry
								end
							end
						end
					end
				end
			elseif love.filesystem.isDirectory(file) then
				recursiveEnumerate(file, scriptType, tbl)
			end
		end
		return tbl
	end
end



state.enter = function(self, from, scriptType)

	self.search = recursiveEnumerate('scripts',scriptType,{})
	print("Found " .. tostring(#self.search) .. " '" ..  scriptType .."' scripts.")

	transition = 'entering'
	transitionTimer = 0
end



state.leave = function(self, to)
	transition = ''
	transitionTimer = 0
end



state.update = function(self, dt, tick)

	-- timers

	bgTimer = bgTimer + dt/4

	-- gamestate transition

	if transition == 'entering' then
		if transitionTimer < 1.0 then
			local v = math.min(1.0, transitionTimer + dt * 2.0) -- 0.5 seconds to full transition
			transitionTimer = v
			-- music
		end
		if transitionTimer == 1.0 then
			transition = ''
		end
	elseif transition == 'leaving' then
		if transitionTimer > 0.0 then
			local v = math.max(0.0, transitionTimer - dt * 1.5) -- 0.5 seconds to full transition
			transitionTimer = v
			-- music
		end
		if transitionTimer == 0.0 then
			menu[menu.current].task()
		end
	end

	-- key detection

	-- depending on the current menu item, do things:
	-- any: back: go to main menu state
	-- any: select: refresh the list
	-- any: left/right: navigate the menubar
	-- list: up/down: select an entry from the list of scripts
	-- order: up/down: select a sorting scheme to use (by abc, by date/abc, by version/abc)
	-- details: up/down: moves the scrollbar of the details window, if the details did not fit on the screen.

	if input.isVKeyActive('left') then
		local held = input.getVKeyHeldTicks('left')
		if held % 15 == 0 then
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

	if input.isVKeyActive('right') then
		local held = input.getVKeyHeldTicks('right')
		if held % 15 == 0 then
			if menu.current ~= 0 then menu[menu.current].tweenOut = true end
			menu.current = ((menu.current - 0) % menu.count) + 1
			menu[menu.current].tweenOut = false
			menu[menu.current].tweenIn = true
			-- sound
			audio.playSFX(self.sfxMove, 1.05 + ((love.math.random()*2)-1)/100)
		end
	end

	-- background

	background:update(dt,tick)

end



state.draw = function(self, df)

	local t = bgTimer % 1
	local f = t<=0.5 and t*2 or (0.5-t/2)*4

	-- background

	background:draw(df)

	-- file list

	love.graphics.setColor(255,192+63*(f),255,transitionTimer*223)

	love.graphics.setFont(self.listFont)

	--go over all files, and print them IF they fit on the screen
	local fontHeight = self.listFont:getHeight()
	local maxLines = math.floor(680 / (fontHeight+5))
	local listWidth = 1280/2
	local halt = false
	local i = 1
	while not halt do
		local v = self.search[i]
		if v then
		-- basedir
		love.graphics.print(
			string.format(
				"%s",
				v.baseDir
			),
			10,
			40+(i-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
		)
		--path-filename
		love.graphics.print(
			string.format(
				"%s%s",
				v.path,
				v.name
			),
			85,
			40+(i-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
		)
		-- type
		love.graphics.print(
			string.format(
				"%s",
				v.ext == 'lua' and 'script' or (v.ext == 'zip' and 'archive')
			),
			360,
			40+(i-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
		)
		-- date
		love.graphics.print(
			string.format(
				"%s",
				v.lastModified
			),
			430,
			40+(i-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
		)
		-- version
		love.graphics.print(
			string.format(
				"%s",
				v.version
			),
			600,
			40+(i-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
		)
		i = i + 1
		end
		if not self.search[i] then halt = true end
		if i > maxLines then halt = true end
	end

	-- draw out selected's extended info
	local v = self.search[1]

		if v.image then
			love.graphics.setColor(255,255,255,255*transitionTimer)
			love.graphics.draw(
				v.image,
				1280/2,
				0,
				0,
				1/(v.image:getWidth()/(1280/2)),
				1/(v.image:getHeight()/(720/2))
			)
		end

		love.graphics.setColor(255,192+63*(f),255,transitionTimer*255)

		-- todo: make it so line wrapping won't mess these up.
		love.graphics.print(
			"Filename:\nTitle:\nDifficulty:\nDescription:\nUsable Characters:",
			1280/2+20,
			720/2+20
		)
		love.graphics.print(
			string.format(
				"%s\n%s\n%s\n%s\n%s",
				v.thumbnail or '<IMG>',
				v.title,
				v.difficultyLevel or 'ANY',
				v.description,
				v.allowedCharacters == true and 'ANY' or (v.allowedCharacters == false and 'NONE' or table.concat(v.allowedCharacters,', '))
			),
			1280/2+20+160,
			720/2+20
		)

	-- draw info overlay

	love.graphics.setColor(0,0,0,159*transitionTimer)
	love.graphics.rectangle('fill',1280/2,0,1280,720)

end



----------

return state