-- Engine debug functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

-- Modules
local log = require 'source.log'

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	t.debug = (not barf) and debug or t

	-- 012: N/A
	-- Ph3: WriteLog
	t.debug.log = log

	-- 012: RaiseError
	-- Ph3: RaiseError
	-- lua's own error mechanism; we can provide a custom error handler in löve, remember? :3
	t.debug.error = error

	-- 012: assert
	-- Ph3: N/A
	-- lua's own assert mechanism; though, we could write one that takes any function, instead of just a string...
	t.debug.assert = assert
	t.debug.assertEx = function(expr, func) if not expr then error(func()) end end

	-- 012: GetVersion
	-- Ph3: ?
	-- we already have functions for this, just copy them here
	t.debug.getEngineVersion = function() return _LDME_version end
	t.debug.getluaVersion = function() return _VERSION end

	-- This is not usable, since it's a security risk.
	-- t.debug.execute = os.execute

	-- This is unnecessary, since love already has an exit function.
	-- t.debug.exit = os.exit

	-- Allowed for now, don't see the imminent danger of using this. (we can only get info, not set it)
	t.debug.getEnv = os.getenv

	-- Error catching extended, why not.
	t.debug.pcall  =  pcall
	t.debug.xpcall = xpcall

	-- Jit compiler
	t.debug.jit = jit

	-- Garbage collector
	t.debug.gcinfo = gcinfo
	t.debug.collectgarbage = collectgarbage

	-- End debug

	t.debug = (not barf) and t.debug or nil

end