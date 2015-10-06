-- Default package - script menu
-- by zorg @ 2015 license: ISC

--[[Notes:
	-- A listing of all scripts, found in the engine's save folder; can give type argument for script.enter if we wish to be picky.
	-- No directory structure, flat file listing, but can be ordered by "hierarchical path", "alphabetical" and "latest modification date".
	-- Since we merged all script menus to this one, we need to have a full list of scripts of -any- type in a table,
	   (re)loaded when entering and when refreshing, then we need to filter that out into the list the user will see.
	--]]

-- Localized love libs

local lfs = love.filesystem
local lg  = love.graphics



-- Modules

local getLastModificationTime = require 'source.lib.zorg.filemodtime' -- love doesn't export this PhysFS function sadly.
local loadScript = require 'source.loadscript'
local scriptTypes = require 'source.scripttypes'



-- Locals

local bgTimer = 0
local transitionTimer = 0
local transition = ''

local selectedOption = false -- number for a script in the list, false for back

local sortTypes = {[0] = "Order: ABC.", [1] = "Order: VER.", [2] = "Order: DATE"}

-- The script parsing function
local parseData; parseData = function(err, script, p, n, e, zipdir)
	local t = {}

	t.path = p
	t.name = n
	t.ext  = e

	t.baseDir = lfs.getRealDirectory(p .. '/' .. n .. '.' .. e) == lfs.getSaveDirectory()       and 'SaveDir ' or
		       (lfs.getRealDirectory(p .. '/' .. n .. '.' .. e) == lfs.getSourceBaseDirectory() and 'Internal' or 'External')

	if err then
		
		if err ~= 'file error' or err ~= 'archive error' then
			local date = getLastModificationTime(p .. '/' .. n .. '.' .. e)
			if date then date = datetime.getDateFormatted("%Y/%m/%d %H:%M:%S", date) else date = '9999/99/99 99:99:99' end
			t.lastModified = date
		end

		t.type = '*'
		t.version = false
		t.title = err
		t.description = script and tostring(script) or "An unknown error has happened."
		t.thumbnail = false

	else

		if type(script) == 'table' and script.type and scriptTypes[script.type] then

			local date = getLastModificationTime(p .. '/' .. n .. '.' .. e)
			if date then date = datetime.getDateFormatted("%Y/%m/%d %H:%M:%S", date) else date = '9999/99/99 99:99:99' end
			t.lastModified = date

			t.type = script.type or '*'
			t.version = script.version or false
			t.title = script.title or ""
			t.description = script.description or ""
			
			if script.thumbnail then
				t.thumbnail = script.thumbnail
				-- Necessary shenanigans
				t.image = lg.newImage(zipdir and (zipdir .. '/' .. t.thumbnail) or (p .. '/' .. t.thumbnail))
			else t.thumbnail = false end

			-- Script-specific fields
			if script.type == 'character' then

				--

			elseif script.type == 'single' then

				t.difficultyLevel = script.difficulty or false
				t.allowedCharacters = script.playableCharacters or false

			elseif script.type == 'plural' then

				t.difficultyLevel = script.difficulty or false
				t.allowedCharacters = script.playableCharacters or false

			elseif script.type == 'stage' then

				t.difficultyLevel = script.difficulty or false
				t.allowedCharacters = script.playableCharacters or false

			elseif script.type == 'package' then

				--

			end

			return t

		else
			-- return false so we don't list a non-script or a script's sub-files.
			return false
		end
	end
end

-- The directory traversing, script listing function (outputs a table) - should be a coroutine, output "loading", false or the table
local recursiveEnum; recursiveEnum = function(directory, output, fileCount, fileCurrent)
	local files = lfs.getDirectoryItems(directory)
	fileCount = (fileCount or 0) + #files
	fileCurrent = fileCurrent or 0

	for i,v in ipairs(files) do
		local data
		local file = directory .. "/" .. v

		if lfs.isFile(file) then

			-- Separate the file to path, name and extension; TODO: maybe there's a cleaner equivalent to the below mess...
			local p,n,e = file:match("(.-)([^\\/]-%.?([^%.\\/]*))$"); n = n:match("(.+)%..*")

			-- If it's an archive, load the information from it;
			if e == 'zip' then
				local ok = lfs.mount(p .. '/' .. n .. '.' .. e, 'temp_package')

				-- If there's an init.lua, it's a package script, so we load in the entrypoint, containing the needed information
				if ok and lfs.isFile('temp_package/init.lua') then
					local init = lfs.load('temp_package/init.lua')
					init = {init()}

					if init[5] and lfs.isFile('temp_package/' .. init[5]) then
						local ok, contents = debug.pcall(lfs.load, 'temp_package/' .. init[5])

						if ok then
							ok, contents = debug.pcall(contents)

							if ok then
								data = parseData(false, contents, p, n, e, 'temp_package')
							else
								data = parseData("script error", contents, p, n, e, 'temp_package')
							end
						else
							data = parseData("chunk error", contents, p, n, e, 'temp_package')
						end
					else
						data = parseData("file error", nil, p, n, e, 'temp_package')
					end
				else
					data = parseData("archive error", nil, p, n, e, 'temp_package')
				end

				-- Cleanup
				lfs.unmount(p .. '/' .. n .. '.' .. e)

			elseif e == 'lua' then
				local ok, contents = debug.pcall(lfs.load, file)

					if ok then
						ok, contents = debug.pcall(contents)

						if ok then
							data = parseData(false, contents, p, n, e)
						else
							data = parseData("script error", contents, p, n, e)
						end
					else
						data = parseData("chunk error", contents, p, n, e)
					end
			end


			if data then
				fileCurrent = fileCurrent + 1
				output[#output+1] = data
			end

		elseif lfs.isDirectory(file) then
			recursiveEnum(file, output, fileCount, fileCurrent)
		end

		coroutine.yield(fileCount, fileCurrent)
	end
end

-- The script filter function - returns a table containing only the scripts of a given type
local filterData; filterData = function(tbl, scriptType)
	local t = {}
	for i,v in ipairs(tbl) do
		if v.type == scriptType then
			table.insert(t,v)
		end
	end
	return t
end

-- The script order function - returns a table having the scripts ordered by a given parameter
local orderData; orderData = function(tbl, criteria)
	if criteria == 0 then
		-- Alphabetical, by full path and filename
		table.sort(tbl, function(a,b)
			return (a.path .. a.name) < (b.path .. b.name)
		end)
	elseif criteria == 1 then
		-- Version, then alphabetical
		table.sort(tbl, function(a,b)
			if a.version ~= b.version then
				return a.version < b.version
			end
			return (a.path .. a.name) < (b.path .. b.name)
		end)
	elseif criteria == 2 then
		-- Date, then alphabetical
		table.sort(tbl, function(a,b)
			if a.lastModified ~= b.lastModified then
				return a.lastModified < b.lastModified
			end
			return (a.path .. a.name) < (b.path .. b.name)
		end)
	end
	return tbl
end

-- Menu
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



-- This module

local script = {}



-- Callbacks

script.init = function(self)

	local path = getPackageDir()

	-- Audio - get rid of this
	self.sfxSelect = audio.newSFX(path..'assets/sfx_select.wav')
	self.sfxMove = audio.newSFX(path..'assets/sfx_move.wav')

	-- Fonts - this too
	self.font     = love.graphics.newFont(path .. 'assets/Cirno.ttf',36)
	self.listFont = love.graphics.newFont(path .. 'assets/Cirno.ttf',24)

	-- Lists

	-- This is "global" in the sense that it has all files that passed parsing.
	self.scriptList = {}

	-- Create empty containers for the displayables, so that the update and draw callbacks don't error when trying to index into them.
	self.localList = {}
	self.localList.list = {} -- stuff goes here so we dont delete the hash part of the table
	self.localList.current = 0
	self.localList.currentData = false
	self.localList.startY = 1
	self.localList.maxLines = math.floor((720 - 60) / (self.listFont:getHeight() + 5))

	self.description = {}

	self.sortCriteria = 0 -- alphabetically by path+filename, 1 - by version, 2 - by last mod. time

	-- Menu

	menu:new("   List    ")
	menu:new(sortTypes[0])
	menu:new("Description")
	menu.current = 1

end

script.enter = function(self, from, scriptType)
	self.scriptType = scriptType

	self.scriptList = {}
	self.localList.list = {}
	self.bgLoader = coroutine.create(recursiveEnum)

	transition = 'entering'
	transitionTimer = 0
end

script.leave = function(self, to)
	transition = ''
	transitionTimer = 0
end

script.update = function(self, dt, tick)

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
			if not selectedOption then
				state.switch(mainMenu)
			else
				-- TODO: Run selected script
				local v = self.localList.list[selectedOption]
				local script = loadScript(v.type, v.path .. '/' .. v.name .. '.' .. v.ext)
				state.push(script)
			end
		end
	end

	-- file loading coroutine
	if coroutine.status(self.bgLoader) ~= 'dead' then
		local ok, msg
		ok, msg = coroutine.resume(self.bgLoader, 'scripts', self.scriptList)
		print("coro:", ok, msg)

		if self.scriptType ~= '*' then
			self.localList.list = filterData(self.scriptList, self.scriptType)
		else
			self.localList.list = {}
			for i,v in ipairs(self.scriptList) do
				self.localList.list[i] = v
			end
		end

		orderData(self.localList.list, self.sortCriteria)

	else
		-- only run when the coroutine finished
		if #self.localList.list > 0 and self.localList.current == 0 then
			if not self.localList.currentData then
				self.localList.current = 1
				local v = self.localList.list[self.localList.current]
				self.localList.currentData = v.path .. v.name .. v.ext .. v.baseDir
			else
				for i,v in ipairs(self.localList.list) do
					local s = v.path .. v.name .. v.ext .. v.baseDir
					if s == self.localList.currentData then
						self.localList.current = i
						self.localList.currentData = s
						break
					end
				end
				local v = self.localList[self.localList.current]
				local s = v.path .. v.name .. v.ext .. v.baseDir
				if self.localList.currentData ~= s then
					-- previously selected entry doesn't exist, make it the same position's data.
					self.localList.currentData = s
				end
			end
		end
	end

	-- key detection

	-- Move between menu states
	if input.isVKeyActive('left') then
		local held = input.getVKeyHeldTicks('left')
		if held == 0 or (held > 15 and (held % 5 == 0)) then

			menu[menu.current].tweenOut = true

			menu.current = ((menu.current - 2) % menu.count) + 1

			print("menu left new",menu.current)

			menu[menu.current].tweenOut = false
			menu[menu.current].tweenIn = true

			audio.playSFX(self.sfxMove, 0.95 + ((love.math.random()*2)-1)/100)
		end
	end

	if input.isVKeyActive('right') then
		local held = input.getVKeyHeldTicks('right')
		if held == 0 or (held > 15 and (held % 5 == 0)) then

			menu[menu.current].tweenOut = true

			menu.current = ((menu.current - 0) % menu.count) + 1

			print("menu right new",menu.current)

			menu[menu.current].tweenOut = false
			menu[menu.current].tweenIn = true

			audio.playSFX(self.sfxMove, 1.05 + ((love.math.random()*2)-1)/100)
		end
	end

	-- Depending on which menu state we're in, either scroll the script list, the description, or change the script sorting algorithm.
	if input.isVKeyActive('up') then
		local held = input.getVKeyHeldTicks('up')
		if held == 0 or (held > 15 and (held % 5 == 0)) then

			if menu.current == 1 and coroutine.status(self.bgLoader) == 'dead' then
				-- Script list, scroll when bg loader is done
				self.localList.current = ((self.localList.current - 2) % #self.localList.list) + 1
				self.localList.startY = math.max(self.localList.startY - 1, 1)
				print("list up new", self.localList.startY)

			elseif menu.current == 2 then
				-- Sorting function, can select it even when loading hasn't finished yet
				self.sortCriteria = (self.sortCriteria - 1) % 3
				menu[2].text = sortTypes[self.sortCriteria]
				orderData(self.localList.list, self.sortCriteria)
				print("sort up new", self.sortCriteria)

			elseif menu.current == 3 then
				-- Description, always, if scrollable

			end

			if not (menu.current == 1 and coroutine.status(self.bgLoader) ~= 'dead') then
				audio.playSFX(self.sfxMove, 1.95 + ((love.math.random()*2)-1)/200)
			end

		end
	end

	if input.isVKeyActive('down') then
		local held = input.getVKeyHeldTicks('down')
		if held == 0 or (held > 15 and (held % 5 == 0)) then

			if menu.current == 1 and coroutine.status(self.bgLoader) == 'dead' then
				-- Script list, scroll when bg loader is done
				self.localList.current = ((self.localList.current + 0) % #self.localList.list) + 1
				self.localList.startY = math.min(math.max(#self.localList.list - self.localList.maxLines, 1), self.localList.startY + 1)
				print("list down new", self.localList.startY)

			elseif menu.current == 2 then
				-- Sorting function, can select it even when loading hasn't finished yet
				self.sortCriteria = (self.sortCriteria + 1) % 3
				menu[2].text = sortTypes[self.sortCriteria]
				orderData(self.localList.list, self.sortCriteria)
				print("sort down new", self.sortCriteria)

			elseif menu.current == 3 then
				-- Description, always, if scrollable

			end

			if not (menu.current == 1 and coroutine.status(self.bgLoader) ~= 'dead') then
				audio.playSFX(self.sfxMove, 2.05 + ((love.math.random()*2)-1)/200)
			end

		end
	end

	-- Refresh list
	if input.getVKeyState('shot') == 'pressed' or input.getVKeyState('select') == 'pressed' then

		if menu.current == 1 then
			transition = 'leaving'
			selectedOption = self.localList.current
		else
			self.scriptList = {}
			self.localList.list = {}
			self.bgLoader = coroutine.create(recursiveEnum)
		end

		audio.playSFX(self.sfxSelect, 1.5)
	end

	-- Go back to main menu
	if input.getVKeyState('bomb') == 'pressed' or input.getVKeyState('back') == 'pressed' then

		transition = 'leaving'
		selectedOption = false
		audio.playSFX(self.sfxSelect, 0.67)

	end

	-- background

	background:update(dt, tick)

end

script.draw = function(self, df)

	local t = bgTimer % 1
	local f = t<=0.5 and t*2 or (0.5-t/2)*4

	-- background

	background:draw(df)

	-- info & menu "underlay"

	love.graphics.setColor(0,0,0,159*transitionTimer)
	love.graphics.rectangle('fill',1280/2,0,1280,720)
	love.graphics.rectangle('fill',0,720-80,1280/2,720)

	-- script list

	lg.setColor(255,255,255,255)

	--go over all files, and print them IF they fit on the screen
	local listWidth = 1280/2
	local maxLines = self.localList.maxLines
	local startY = self.localList.startY
	local fontHeight = self.listFont:getHeight()
	local I = 1

	lg.setFont(self.listFont)

	if #self.localList.list > 0 then
		for i=startY, math.min(maxLines, #self.localList.list) do

			local v = self.localList.list[i]

			if i == self.localList.current then love.graphics.setColor(255,     (f)*159, 255, 255*transitionTimer)
		                                   else love.graphics.setColor(255, 159+(f)* 95, 255, 223*transitionTimer)
			end
			
			-- basedir
			love.graphics.print(
				string.format(
					"%s",
					v.baseDir
				),
				10,
				40+(I-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
			)
			--path-filename
			love.graphics.print(
				string.format(
					"%s%s",
					v.path,
					v.name
				),
				85,
				40+(I-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
			)
			-- type
			love.graphics.print(
				string.format(
					"%s",
					v.ext == 'lua' and 'script' or (v.ext == 'zip' and 'archive')
				),
				360,
				40+(I-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
			)
			-- date
			love.graphics.print(
				string.format(
					"%s",
					v.lastModified
				),
				430,
				40+(I-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
			)
			-- version
			love.graphics.print(
				string.format(
					"%s",
					v.version
				),
				600,
				40+(I-1)*(fontHeight+5)*1.0 -- displacement yet to be implemented
			)

			I = I + 1
		end
	end

	-- buttons

	for i=1,3 do
		if i == menu.current then love.graphics.setColor(255,     (f)*159, 255, 255*transitionTimer)
			                 else love.graphics.setColor(255, 159+(f)* 95, 255, 223*transitionTimer)
		end

		lg.setFont(self.font)
		lg.print(menu[i].text, (i-1)*180, 720 - 60)
	end

	-- thumbnail

	lg.setFont(self.listFont)

	if self.localList.current > 0 and self.localList.list[self.localList.current] and self.localList.list[self.localList.current].thumbnail then
		local v = self.localList.list[self.localList.current]
		love.graphics.setColor(255,255,255,255*transitionTimer)
		love.graphics.draw(
			v.image,
			1280/2,
			0,
			0,
			1/(v.image:getWidth()/(1280/2)),
			1/(v.image:getHeight()/(720/2))
		)
	else
		-- no image
		love.graphics.setColor(0,0,0,255*transitionTimer)
		love.graphics.rectangle("fill",1280/2,0,1280/2,720/2)
		love.graphics.setColor(255,255,255,255*transitionTimer)
		love.graphics.printf("-No Thumbnail-", 1280/2, 720/4 - self.listFont:getHeight()/2, 1280/2, "center")
	end

	-- description

	if self.localList.current > 0 and self.localList.list[self.localList.current] then

		local v = self.localList.list[self.localList.current]

		love.graphics.setColor(255,192+63*(f),255,transitionTimer*255)

		-- todo: make it so line wrapping won't mess these up.
		love.graphics.print(
			"Title:\nDescription:\nDifficulty:\nUsable Characters:",
			1280/2+20,
			720/2+20
		)

		local chars = 'N/A'
		if v.allowedCharacters == true then
			chars = 'ANY'
		elseif v.allowedCharacters == false then
			chars = 'NONE (Observer)'
		elseif type(v.allowedCharacters) == 'table' then
			chars = table.concat(v.allowedCharacters,', ')
		end
		love.graphics.print(
			string.format(
				"%s\n%s\n%s\n%s",
				v.title,
				v.description,
				v.difficultyLevel or 'ANY',
				chars
			),
			1280/2+20+160,
			720/2+20
		)

	end

end



script.render = function(self, df)
	overlay.render(df)
end



----------

return script