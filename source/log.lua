-- Framework logging library
-- by zorg @ 2015 license: ISC

--[[Code Flow:
	require -> this
	--]]

--[[Notes:
	- Basic functions are to log a string into a file
	- More advanced is the fact that one can choose to selectively log
	- Even moreso is that one can set what identity the logger will use to find the path it'll use
	- Though the identity swapping might not work, since other files may still be open in the old write dir, causing physfs to not set a new one.
	--]]



-- Localized love modules

local lfs = love.filesystem



-- Locals

local list = {}                                         -- List of logfile data
local timestamp = ''                                    -- Has its uses


-- This module

local t = {}



-- Methods

t.init = function()
	-- Get the correct timezone
	local utcdate   = os.date("!*t")
	local localdate = os.date("*t")
	--localdate.isdst = false -- this is the trick
	local timezone = os.difftime(os.time(localdate), os.time(utcdate))
	local h, m = math.modf(timezone / 3600)
	local Z = string.format("%0+5d", 100 * h + 60 * m)
	timestamp = os.date("%Y%m%d-%H%M%S", os.time(utcdate)) .. Z .. string.format("_%015.8f", love.timer.getTime())
end

t.newLog = function(append, filepath, identity, name, console)
	assert(type(append) == 'boolean', "Error: Log: newLog: Invalid append parameter '" .. tostring(append) .. "' given!")
	assert(type(filepath) == 'string', "Error: Log: newLog: Invalid filepath parameter '" .. tostring(filepath) .. "' given!")
	assert((type(identity) == 'string' or (identity == nil)), "Error: Log: newLog: Invalid identity parameter '" .. tostring(identity) .. "' given!")
	assert((type(name) == 'string' or (name == nil)), "Error: Log: newLog: Invalid name parameter '" .. tostring(name) .. "' given!")
	assert((type(console) == 'boolean' or (console == nil)), "Error: Log: newLog: Invalid console parameter '" .. tostring(console) .. "' given!")

	local s = string.format('%s%s%s%s',append,filepath,identity,name)

	local exists = false
	for i,v in ipairs(list) do
		if v.fingerprint == s then
			exists = i
			break
		end
	end

	if exists then
		error("Error: Log: newLog: This log descriptor already exists with internal id '" .. tostring(i) .. "'!")
	end

	local path, filename, extension = filepath:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
	filename = filename:sub(-#filename, -#extension-2)

	local t = {
		name = (name or false),
		fingerprint = s,
		identity = identity,
		path = path,
		filename = filename,
		extension = extension,
		append = append,
		logToConsole = console or false
	}

	local n = #list
	list[n+1] = t
	return n+1
end

local getLogId = function(name)
	for i,v in ipairs(list) do
		if v.name == name then
			return i
		end
	end
	return false
end

t.setConsoleLogging = function(id, val)

	-- The id can be the name as well.
	if type(id) == 'string' then
		id = getLogId(id)
	end

	assert(list[id], "Error: Log: setConsoleLogging: Given id '" .. tostring(id) .. "' nonexistent!")

	local t = list[id]

	t.logToConsole = val or false

end

t.log = function(id, fstring, ...)

	-- The id can be the name as well.
	if type(id) == 'string' then
		id = getLogId(id)
	end

	assert(list[id], "Error: Log: log: Given id '" .. tostring(id) .. "' nonexistent!")

	local t = list[id]

	-- Check if we need to change the identity, or not.
	local currentIdentity = lfs.getIdentity()
	if t.identity ~= currentIdentity then
		if not lfs.setIdentity(t.identity) then
			error("Error: Log: log: Couldn't set new identity '" .. tostring(identity) .. "'!")
		end
	end

	-- prepare the loggable string
	local s = string.format(fstring, ...)

	-- check directory, create it if missing
	if not lfs.isDirectory(t.path) then
		if not lfs.createDirectory(t.path) then
			error("Error: Log: log: Couldn't create directory tree '" .. tostring(t.path) .. "'!")
		end
	end

	local f
	-- if not append, then tack a timestamp to the end of the file
	if t.append then
		f = t.path .. '/' .. t.filename .. '.' .. t.extension
		if not lfs.append(f, s) then
			error("Error: Log: log: Couldn't append to logfile!")
		end
	else
		f = t.path .. '/' .. t.filename .. '_' .. timestamp .. '.' .. t.extension
		if not lfs.append(f, s) then
			error("Error: Log: log: Couldn't write to logfile!")
		end
	end

	-- log to the console too, if we need to
	if t.logToConsole then 
		print(s)
	end

	-- set back the identity
	if t.identity ~= currentIdentity then
		if not lfs.setIdentity(currentIdentity) then
			error("Error: Log: log: Couldn't set back the original identity '" .. tostring(currentIdentity) .. "'!")
		end
	end
end



----------

setmetatable(t, {__call = function(_, ...) return t.log(...) end})
return t