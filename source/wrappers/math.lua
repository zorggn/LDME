-- Engine math functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- 012: Implements all of the MATH functions.
	-- Ph3: Implements all of the math functions, except the explicit add/sub/mul/div shit, which is unneeded imo (also slower than +-*/).

	t.math = (not barf) and _G.math or t

	-- Not gonna do this per-function.
	t.math = math

	-- Better and missing functions. note: this will overwrite t.math.random, which is something we want.
	for k,v in pairs(love.math) do
		if type(v) == 'function' then
			t.math[k] = v
		end
	end
	-- also remove the lua randomseed function, since love already added an alternative.
	t.math.randomseed = nil

	-- TODO: add in functions from mathEx
	-- needed at minimum: trunc, round, integral, derivative






	-- End Math

	t.math = (not barf) and t.math or nil

end