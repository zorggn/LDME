-- Engine date, time and timer functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	- Supporting a few calendars other from Gregorian as well!
	--]]

-- Locals
local discordian -- or erisian
local eternal9th -- many bakas made usenet bad circa '93

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- 012: Implements much more of the ones existing in this, though getTime is a tricky one to implement correctly... if we know what that is...
	-- Ph3: Implements a superset of the time functions, though again, GetStageTime and GetPackageTime are not that easy to implement.

	t.datetime = (not barf) and {} or t

	t.datetime.getClock          = love.timer.getTime --os.clock -- love's is more accurate, so no os.clock support
	t.datetime.getDateInSeconds  = os.time
	t.datetime.getDateFormatted  = os.date
	t.datetime.diffTime          = os.difftime

	t.datetime.getDelta          = love.timer.getDelta
	t.datetime.getAverageDelta   = love.timer.getAverageDelta
	t.datetime.getFPS            = love.timer.getFPS
	t.datetime.getTPS            = love.timer.getTPS

	t.datetime.getDDateFormatted = discordian
	t.datetime.getEDateFormatted = eternal9th

	-- think about how to implement the slowdown function;
	-- best bet is to just divide dt by a multiplier in the game loop, seemingly no issues with that.
	-- on the other hand, with script hiearchies, we need to figure out how to apply the slow effect on a per-script basis...
	-- since the loaded scripts share one environment, with the objects and layers as well, we can just have the objects have an internal properity for this...
	--t.datetime.setDeltaMultiplier = love.timer.setDeltaMultiplier -- signature: (Number: multiplier)

	--t.getStageTime
	-- Returns a number with the amount of time that has been elapsed since the start of the main script. The value is in milliseconds.
	-- What constitutes as main script with a package? i'm guessing whatever is topmost... or we should have set*Time functions...
	--t.getPackageTime
	-- Returns a number with the amount of time that has been elapsed since the start of the package script. The value is in milliseconds.
	-- What does it return in danmakufu if we're not running a package script?

	-- End datetime

	t.datetime = (not barf) and t.datetime or nil

end