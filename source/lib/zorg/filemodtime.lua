-- A small thing made out of necessity, can access file modification dates, which is useful for ordering file lists...

local ffi = require "ffi"
local liblove = ffi.os == "Windows" and ffi.load "love" or ffi.C

ffi.cdef[[
	int PHYSFS_getLastModTime(const char *filename);
]]

return function(file)
	local seconds = tonumber(liblove.PHYSFS_getLastModTime(file))
	return seconds ~= -1 and seconds or false
end