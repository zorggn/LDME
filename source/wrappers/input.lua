-- Engine input functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

-- Modules
local input = require 'source.input'

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	t.input = (not barf) and input or t

	-- Only the VKey functions are dumped
	-- 012: UsedDebugKey can be simulated with getVKeyCategory & getVKeyState; GetKeyState has an equivalent.
	-- Ph3: Keystate list is slightly different; no hardcoded vkey list, keylist is love's own internal keycode list.

	-- End input

	t.input = (not barf) and t.input or nil

end