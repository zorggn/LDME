-- Engine string functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- 012: ...were there any in this at all?
	-- Ph3: Implements a superset of the string functions, except we don't treat fonts as string manipulation... so InstallFont goes elsewhere.

	t.string = (not barf) and string or t

	-- TODO: We could probably add in some useful stuff, like patterns and a few functions.



	-- End String

	t.string = (not barf) and t.string or nil

end