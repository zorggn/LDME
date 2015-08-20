-- Framework audio library
-- by zorg @ 2015 license: ISC

--[[Code Flow:
	require -> this
	main.lua:love.update -> this:update
	--]]

--[[Notes:
	- Implements a superset of danmakufu's (either version's) audio functionality, meanwhile exposing only a subset of love's.
	- Functions separated between background music and sound effect related ones, along with four generic ones
	--]]


-- Localized love modules

local la = love.audio
local lfs = love.filesystem
local ls = love.sound



-- Locals

local list = {}											-- the list of objects one has created; sequential keys; table values.
local active = {}										-- the list of active sources; keys are sound objects in the above list; false or id values.



-- This module

local t = {}



-- Callbacks

t.update = function(dt)

	-- iterate through all active sources
	for k,w in pairs(active) do

		local v

		if w then

			-- w at this point can only be a valid id
			v = list[w]

			if v.type == 'BGM' then

				-- if one went past its current loop endpoint, execute logic telling what it needs to do
				local pos = v.source:tell(v.loopUnit)
				if pos < v.loopStart or pos > v.loopEnd then
					v.source:seek(v.loopStart,v.loopUnit)
				end

				-- if there's a fade-in active, handle that
				if v.fadeIn > 0 then
					v.fadeCtr = math.max(0, v.fadeCtr - dt)
					v.source:setVolume(v.volume * (1-(v.fadeCtr/v.fadeIn)))
					if v.fadeCtr == 0 then
						v.fadeIn = 0
					end
				end

				-- similarly with fade-outs
				if v.fadeOut > 0 then
					v.fadeCtr = math.max(0, v.fadeCtr - dt)
					v.source:setVolume(v.volume * (v.fadeCtr/v.fadeOut))
					if v.fadeCtr == 0 then
						v.fadeOut = 0
						if v.fadeTo == 'stop' then
							v.source:stop()
						elseif v.fadeTo == 'pause' then
							v.source:pause()
						end
						active[v] = false
					end
				end

				-- custom volume "bends"
				if v.volSlideEnd ~= v.volume then
					if v.volSlideEnd > v.volume then
						v.volume = v.volume + (dt / v.volSlideAmount)
						if v.volume > v.volSlideEnd then v.volume = v.volSlideEnd end
					elseif v.volSlideEnd < v.volume then
						v.volume = v.volume - (dt / v.volSlideAmount)
						if v.volume < v.volSlideEnd then v.volume = v.volSlideEnd end
					end
				end

			elseif v.type == 'SFX' then

				-- not really applicable, since we can only manually call these, and they can't be looped...
				-- ...at least, that functionality isn't exposed.

			end

		end

	end

end






-- Methods

t.newBGM = function(path, ...)

	assert(lfs.isFile(path), "Error: Audio: newBGM: Nonexistent file path '" .. tostring(path) .. "' given!")

	local o = {}

	-- hack: since decoders can't be queried for the sampleCounts, get it via a temporary sounddata object.
	--       ... and yes, this will eat up some CPU and many megs of RAM when called.

	local temp = ls.newSoundData(path)
	o.sampleCount = temp:getSampleCount()
	o.songLength = temp:getDuration()

	-- hack: decoders might not work seamlessly when looping on OSX; 
	-- todo: get back to this later, if we can test it out on an actual mac; maybe it has been solved.
	if love.system.getOS() == 'OS X' then
		-- faster this way
		o.data = temp
	else
		o.data = ls.newDecoder(path)
	end

	temp = nil

	-- Create the needed fields, and fill them in with values

	o.type = 'BGM'

	-- Looping related
	o.loopUnit = 'seconds'
	o.loopStart = 0
	o.loopEnd = o.songLength

	-- Transitional fades
	o.fadeIn = 0.0
	o.fadeOut = 0.0
	o.fadeCtr = 0.0
	o.fadeTo = 'stop'

	o.volume = 1.0

	-- Volume slides (source volume == this volume * fade volume)
	o.volSlideEnd = 1.0
	o.volSlideAmount = 1.0

	o.user = {...}

	o.source = la.newSource(o.data)

	list[#list+1] = o
	active[o] = false

	return #list, o

end

t.getBGMPitch = function(id)
	assert(list[id], "Error: Audio: getBGMPitch: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: getBGMPitch: Sound object id '" .. tostring(id) .. "' not BGM!")

	local o = list[id]
	return o.source:getPitch()
end

t.setBGMPitch = function(id, mul)
	assert((type(mul) == 'number' and mul > 0.0) or (mul == nil),
		"Error: Audio: setBGMPitch: Errorenous pitch multiplier parameter '" .. tostring(mul) .. "' given!")

	if list[id] and list[id].type == 'BGM' then
		local o = list[id]
		o.source:setPitch(mul)
		return true
	end
	return false
end

t.getBGMLoopPoints = function(id)
	assert(list[id], "Error: Audio: getBGMLoopPoints: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: getBGMLoopPoints: Sound object id '" .. tostring(id) .. "' not BGM!")

	local o = list[id]
	return o.loopStart, o.loopEnd, o.loopUnit
end

t.setBGMLoopPoints = function(id, lStart, lEnd, unit) -- alt. sig.: (id, false) for start-end loop point reset

	assert((unit == 'samples') or (unit == 'seconds') or (unit == nil),
		"Error: Audio: setBGMLoopPoints: Errorenous unit parameter '" .. tostring(unit) .. "' given!")

	if list[id] and list[id].type == 'BGM' then

		local o = list[id]

		if lStart == false --[[and lStart ~= nil]] then
			o.loopStart = 0
			if unit == 'samples' then
				o.loopUnit = 'samples'
				o.loopEnd = o.sampleCount
			elseif unit == 'seconds' then
				o.loopUnit = 'seconds'
				o.loopEnd = o.songLength
			end
			o.source:setLooping(false)
			return true
		end

		assert((type(lStart)=='number') or (lStart==nil),
			"Error: Audio: setBGMLoopPoints: Errorenous loop start parameter '" .. tostring(lStart) .. "' given!")
		assert((type(lEnd)  =='number') or (lStart==nil),
			"Error: Audio: setBGMLoopPoints: Errorenous loop end parameter '" .. tostring(lEnd) .. "' given!")

		o.loopStart = lStart or o.loopStart
		o.loopEnd = lEnd or o.loopEnd
		o.loopUnit = unit or o.loopUnit
		o.source:setLooping(true)
		return true
	end
	return false
end

t.fadeBGM = function(id, time, vol)
	assert(list[id], "Error: Audio: fadeBGM: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: fadeBGM: Sound object id '" .. tostring(id) .. "' not BGM!")
	assert(type(time) == 'number', "Error: Audio: fadeBGM: Errorenous time parameter '" .. tostring(time) .. "' given!")
	assert((type(vol) == 'number' and vol >= 0.0 and vol <= 1.0) or (vol == nil),
		"Error: Audio: fadeBGM: Errorenous volume parameter '" .. tostring(vol) .. "' given!")

	local o = list[id]
	o.volSlideEnd = vol or 0.0
	o.volSlideAmount = (1/(math.max(o.volume, o.volSlideEnd)-math.min(o.volume, o.volSlideEnd))) * time
	return true
end

t.playBGM = function(id, fadeIn)
	assert(list[id], "Error: Audio: playBGM: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: playBGM: Sound object id '" .. tostring(id) .. "' not BGM!")
	assert((type(fadeIn) == 'number' and fadeIn >= 0.0) or (fadeIn == nil),
		"Error: Audio: playBGM: Errorenous fade-in parameter '" .. tostring(fadeIn) .. "' given!")

	local o = list[id]
	if fadeIn == nil or fadeIn == 0 then
		active[o] = id
		o.source:play()
		return true
	elseif not o.source:isPlaying() then
		active[o] = id
		o.fadeIn = fadeIn
		o.fadeCtr = fadeIn
		o.source:setVolume(0.0)
		o.source:play()
		return true
	end
	return false
end

t.pauseBGM = function(id, fadeOut)
	assert(list[id], "Error: Audio: pauseBGM: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: pauseBGM: Sound object id '" .. tostring(id) .. "' not BGM!")
	assert((type(fadeOut) == 'number' and fadeOut >= 0.0) or (fadeOut == nil),
		"Error: Audio: pauseBGM: Errorenous fade-out parameter '" .. tostring(fadeOut) .. "' given!")

	local o = list[id]
	if fadeOut == nil or fadeOut == 0 then
		active[o] = false
		o.source:pause()
		return true
	else
		o.fadeTo = 'pause'
		o.fadeOut = fadeOut
		o.fadeCtr = fadeOut
		return true
	end
	return false
end

t.stopBGM = function(id, fadeOut)
	assert(list[id], "Error: Audio: stopBGM: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: stopBGM: Sound object id '" .. tostring(id) .. "' not BGM!")
	assert((type(fadeOut) == 'number' and fadeOut >= 0.0) or (fadeOut == nil),
		"Error: Audio: stopBGM: Errorenous fade-out parameter '" .. tostring(fadeOut) .. "' given!")

	local o = list[id]
	if fadeOut == nil or fadeOut == 0 then
		active[o] = false
		o.source:stop()
		return true
	else
		o.fadeTo = 'stop'
		o.fadeOut = fadeOut
		o.fadeCtr = fadeOut
		return true
	end
	return false
end

t.delBGM = function(id)
	assert(list[id], "Error: Audio: delBGM: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'BGM', "Error: Audio: delBGM: Sound object id '" .. tostring(id) .. "' not BGM!")

	-- stop it if it's playing
	if o.source:isPlaying() then
		o.source:stop()
	end
	-- remove it
	active[list[id]] = nil
	table.remove(list,id)
	return true
end






t.newSFX = function(path, maxVoices, ...)

	assert(lfs.isFile(path), "Error: Audio: newBGM: Nonexistent file path '" .. tostring(path) .. "' given!")

	-- at least have a param for how many clones this sound should have at maximum <- done
	-- and how the round-robin calls to them should occur (sequentially or randomly) <- later

	local o = {}

	o.data = ls.newSoundData(path)

	o.type = 'SFX'

	o.volume = 1.0

	o.user = {...}

	o.source = {}
	o.sourceCount = 1
	o.sourceMax = maxVoices or 8
	o.nextFreeSource = 1
	o.source[o.sourceCount] = la.newSource(o.data)

	list[#list+1] = o
	active[o] = false

	return #list, o

end

t.playSFX = function(id, mul)
	assert(list[id], "Error: Audio: playSFX: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'SFX', "Error: Audio: playSFX: Sound object id '" .. tostring(id) .. "' not SFX!")
	assert((type(mul) == 'number' and mul > 0.0) or (mul == nil),
		"Error: Audio: playSFX: Errorenous pitch multiplier parameter '" .. tostring(mul) .. "' given!")

	local o = list[id]

	if o.nextFreeSource then

		-- there's at least one that's stopped
		if not o.source[o.nextFreeSource] then
			-- clone the previous source here
			o.source[o.nextFreeSource] = o.source[math.max(1, o.nextFreeSource-1)]:clone()
			o.sourceCount = o.sourceCount + 1
		end

		-- set the frequency to what we specified
		if mul then
			o.source[o.nextFreeSource]:setPitch(mul)
		end

		-- if it's already playing, rewind it
		if o.source[o.nextFreeSource]:isPlaying() then
			o.source[o.nextFreeSource]:stop() --o.source[o.nextFreeSource]:rewind()
		end

		-- set the volume of the to-be-played source to the object's
		o.source[o.nextFreeSource]:setVolume(o.volume)

		-- and play
		o.source[o.nextFreeSource]:play()

		-- go in a linear fashion; round-robin randomness not really useful here
		o.nextFreeSource = ((o.nextFreeSource) % o.sourceMax) + 1
	end
end

t.stopSFX = function(id)
	assert(list[id], "Error: Audio: stopSFX: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'SFX', "Error: Audio: stopSFX: Sound object id '" .. tostring(id) .. "' not SFX!")

	local o = list[id]
	-- stop all instances of the selected sound
	for i,v in ipairs(o.source) do
		v:stop()
	end
	return true
end

t.delSFX = function(id)
	assert(list[id], "Error: Audio: delSFX: Sound object id '" .. tostring(id) .. "' nonexistent!")
	assert(list[id].type == 'SFX', "Error: Audio: delSFX: Sound object id '" .. tostring(id) .. "' not SFX!")

	-- stop all currently playing sources, and also free them up (latter part probably not needed)
	for i= #o.source,1,-1 do
		local v = o.source[i]
		v:stop()
		v = nil
	end
	-- remove them
	active[list[id]] = nil
	table.remove(list,id)
	return true
end






t.getVolume = function(id)
	assert(list[id], "Error: Audio: getVolume: Sound object id '" .. tostring(id) .. "' nonexistent!")

	local o = list[id]
	return o.volume
end

t.setVolume = function(id, vol)
	if list[id] then
		local o = list[id]
		o.volume = math.min(1, math.max(0, vol))
		return true
	end
	return false
end



t.getSources = function(id)
	assert(list[id], "Error: Audio: getVolume: Sound object id '" .. tostring(id) .. "' nonexistent!")

	local o = list[id]
	if o.type == 'BGM' then
		return {o.source}
	elseif o.type == 'SFX' then
		return o.source
	end
end



----------

return t