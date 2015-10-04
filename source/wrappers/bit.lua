-- Engine bitwise logic functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- 012: Does not have support for bit ops.
	-- Ph3: Does not have support for bit ops.

	t.bit = (not barf) and bit or t

	-- Supports the following operations: (http://bitop.luajit.org/api.html) (https://en.wikipedia.org/wiki/Bitwise_operation)
	-- bit.tobit	- normalizes a number so it can be used in bitops, usually not needed
	-- bit.tohex	- convert first argument to a hexadecimal string
	-- bit.bnot		- bitwise not (~,!)
	-- bit.band		- bitwise and (&&)
	-- bit.bor		- bitwise  or (||)
	-- bit.bxor		- bitwise xor (^)
	-- bit.lshift	- bitwise left shift (<<, lsh)
	-- bit.rshift	- bitwise right shift (>>, rsh)
	-- bit.arshift	- bitwise arithmetic right shift (>>>, ars)
	-- bit.rol		- bitwise rotate left (rol)
	-- bit.ror		- bitwise rotate right (ror)
	-- bit.bswap	- swaps the bytes of the given argument; converts between big and small endinan representations, basically.

	-- End bit

	t.bit = (not barf) and t.bit or nil

end