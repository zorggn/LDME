-- Framework input handling and mapping library
-- by zorg @ 2015 license: ISC

--[[Code Flow:
	require -> this
	main.lua:love.keypressed -> this:keypressed
	main.lua:love.keyreleased -> this:keyreleased
	main.lua:love.update -> this:update
	--]]

--[[Notes:
	- The 4 key states are pressed, held, released and free
	- The update callback needs to sit at the very end of the main update callback,
	  otherwise, there won't be any frames with pressed/released keystates.
	- The type parameter on vkeys allows categorization;
	  Think of multiplayer and debug keys for instance.
	- Also supports key toggles
	- TODO: When the time comes (0.10), update this to use scancodes instead of keycodes.
	--]]



-- Localized love modules

local lkb = love.keyboard



-- Locals

local states = {['pressed']  = true, ['held'] = true,
                ['released'] = true, ['free'] = true}

local truthy = {['pressed']  = true, ['held'] = true}   -- helps if one doesn't care when the keypress started or when the release happened

local list = {}                                         -- holds all keys that were pressed at least once
local map = {}                                          -- holds named assignments (e.g. map["bomb"]='k')



-- This module

local t = {}



-- Callbacks

t.keypressed = function(key, isrepeat)
	if isrepeat then
		-- Don't detect repeated signals, we're already
		-- accounting for them with lkb.isDown.
		-- This allows custom "repeat" delays anywhere.
		return
	end 
	if list[key] then
		list[key].state = 'pressed'
		list[key].ticksHeld = 0
		list[key].toggled = not list[key].toggled
	end
end

t.keyreleased = function(key)
	if list[key] then
		list[key].state = 'released'
	end
end

t.update = function(dt, tick)
	-- No need to go over the vkey map, only the codelist.
	for key,v in pairs(list) do
		if lkb.isDown(key) then
			if v.state == 'pressed' then
				v.state = 'held'
				v.ticksHeld = v.ticksHeld + 1
			elseif v.state == 'held' then
				v.ticksHeld = v.ticksHeld + 1
			end
		else
			if v.state == 'released' then
				v.state = 'free'
			end
		end
	end
end



-- Methods

-- These are the raw code methods.

t.addKey = function(key)
	assert(type(key) == 'string', "Error: Input: addKey: Keycode '" .. key .. "' is not a string!")
	if not list[key] then
		list[key] = {}
		list[key].state = 'free'
		list[key].ticksHeld = 0
		list[key].toggled = false
		return true
	end
	return false
end

t.delKey = function(key)
	if list[key] then
		list[key] = nil
		return true
	end
	return false
end

t.getKeyState = function(key)
	assert(list[key], "Error: Input: getKeyState: Keycode '" .. tostring(key) .. "' not watched!")
	return list[key].state
end

t.getKeyHeldTicks = function(key)
	assert(list[key], "Error: Input: getKeyHeldTicks: Keycode '" .. tostring(key) .. "' not watched!")
	return list[key].ticksHeld
end

t.isKeyActive = function(key)
	assert(list[key], "Error: Input: isKeyActive: Keycode '" .. tostring(key) .. "' not watched!")
	return truthy[list[key].state]
end

t.isKeyToggled  = function(key)
	assert(list[key], "Error: Input: isKeyToggled: Keycode '" .. tostring(key) .. "' not watched!")
	return list[key].toggled
end

-- These are the virtual keycode methods.

t.addVKey = function(vk, key, category)
	if not map[vk] then
		t.addKey(key)
		map[vk] = {key, (category or false)}
		return true
	end
	return false
end

t.delVKey = function(vk)
	if map[vk] then
		t.delKey(map[vk][1])
		map[vk] = nil
		return true
	end
	return false
end

t.getVKeyState = function(vk)
	assert(map[vk],          "Error: Input: getVKeyState: Virtual keycode '" .. tostring(vk) .. "' nonexistent!")
	return t.getKeyState(map[vk][1])
end

t.getVKeyHeldTicks = function(vk)
	assert(map[vk],          "Error: Input: getVKeyHeldTicks: Virtual keycode '" .. tostring(vk) .. "' nonexistent!")
	return t.getKeyHeldTicks(map[vk][1])
end

t.isVKeyActive = function(vk)
	assert(map[vk],          "Error: Input: isVKeyActive: Virtual keycode '" .. tostring(vk) .. "' nonexistent!")
	return t.isKeyActive(map[vk][1])
end

t.isVKeyToggled = function(vk)
	assert(map[vk],          "Error: Input: isVKeyToggled: Virtual keycode '" .. tostring(vk) .. "' nonexistent!")
	return t.isKeyToggled(map[vk][1])
end 

t.getVKeyCategory = function(vk)
	assert(map[vk],          "Error: Input: getVKeyCategory: Virtual keycode '" .. tostring(vk) .. "' nonexistent!")
	return map[vk][2]
end

t.setVKeyCategory = function(vk, category)
	if map[vk] then
		map[vk][2] = (category or false)
		return true
	end
	return false
end

t.setVKeyState = function(vk, state)
	-- ONLY for use by the replay and network systems!
	assert(states[state], "Error: Input: setVKeyState: Invalid state '" .. tostring(state) .. "'' given!")
	if map[vk] then
		list[map[vk][1]].state = state
		return true
	end
	return false
end

t.getVKeyCategoryItems = function(category)
	local t = {}
	for k,v in pairs(map[vk]) do
		if v.category == category then
			t[#t+1] = k
		end
	end
	return #t > 0 and t or false
end


----------

return t