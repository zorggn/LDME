-- Engine generic functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment.
	- This and all the other wrappers may have "012" and "Ph3" comments;
	  these relate to what functionality these add/replace compared to the two most used Danmakufu versions.
	--]]

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- 012: Coros are tasks, no iterators and numerical arrays only.
	-- Ph3: About the same as above.

	t.__STRICT = __STRICT					-- nil or boolean	-- Testing phase

	t._G = t                                -- table            -- recursively holds everything in the script's environment
	-- t._VERSION = _VERSION				-- string			-- moved to the debug wrapper... sort of
	-- t.arg = arg							-- table			-- no need for this in the scripts
	-- t.assert = assert					-- function			-- moved to the debug wrapper
	-- t.bit = bit							-- table			-- moved to the logic wrapper
	-- t.collectgarbage = collectgarbage	-- function			-- moved to the debug wrapper
	t.coroutine = coroutine					-- table			-- leave these here for now
	-- t.debug = debug						-- table			-- moved to the debug wrapper
	-- t.dofile = dofile					-- function			-- no need for this in the scripts
	-- t.error = error						-- function			-- moved to the debug wrapper
	-- t.gcinfo = gcinfo					-- function			-- moved to the debug wrapper
	-- t.getfenv = getfenv					-- function			-- see: setfenv
	t.getmetatable = getmetatable			-- function			-- leave these here for now
	-- t.io = io							-- table			-- use love's own mechanisms
	t.ipairs = ipairs						-- function			-- leave these here for now
	-- t.jit = jit							-- table			-- moved to the debug wrapper
	-- t.load = load						-- function			-- no need for this in the scripts
	-- t.loadfile = loadfile				-- function			-- no need for this in the scripts
	-- t.loadstring = loadstring			-- function			-- no need for this in the scripts

	t.love = love							-- table			-- leave this here for now, but this should be partitioned up as well

	-- t.math = math						-- table			-- moved to the math wrapper
	-- t.module = module					-- function			-- this became bad practice, so not allowed
	-- t.newproxy = newproxy				-- function			-- undocumented function, removed in lua 5.2, don't use
	t.next = next							-- function			-- leave these here for now
	-- t.os = os							-- table			-- broken up into parts, moved into various wrappers
	--t.require = require					-- function			-- should not be used by scripts, at all; both security risk and error prone
	-- t.package = package					-- table			-- the above goes for this as well, since require is exported by package
	t.pairs = pairs							-- function			-- leave these here for now
	-- t.pcall = pcall						-- function			-- moved to the debug wrapper
	t.print = print							-- function			-- leave these here for now
	t.rawequal = rawequal					-- function			-- leave these here for now
	t.rawget = rawget						-- function			-- leave these here for now
	t.rawset = rawset						-- function			-- leave these here for now
	t.select = select						-- function			-- leave these here for now
	-- t.setfenv = setfenv					-- function			-- no custom function environments; one should modify this file instead (except this line, of course) :3
	t.setmetatable = setmetatable			-- function			-- leave these here for now
	-- t.string = string					-- table			-- moved to the string wrapper
	t.unpack = unpack						-- function			-- leave these here for now
	t.table = table							-- table			-- this is good here for now
	t.tonumber = tonumber					-- function			-- leave these here for now
	t.tostring = tostring					-- function			-- leave these here for now
	t.type = type							-- function			-- leave these here for now
	-- t.xpcall = xpcall					-- function			-- moved to the debug wrapper

end