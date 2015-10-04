-- Framework single script functions wrapper
-- by zorg @ 2015 license: ISC

--[[Code Flow:
	loadscript('single') -> this()
	--]]

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	-- in other words, creates the necessary background structure of a single pattern script so the framework can successfully run it.
	-- metatable and env magics beyond this point! (or maybe not)
	--]]



-- This module

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	---[[
	-- This needs to be its own object (or bullet) module or something :v
	t.objs = {}
	t.spawn = function(x,y,heading,size,color)
		t.objs[#t.objs+1] = {x,y,heading,size,color}
	end
	--]]

	-- Functions exclusive to this script type

	t.getObjectCount = function(objType) return 0 end
	t.scriptEnded = function() return false end

end