-- Framework internals overlay
-- by zorg @ 2015 license: ISC

--[[Notes:
	- For a lack of a better alternative to debug...
	- TODO: 0.10 will break some stuff here; when the time comes, update this file.
	--]]

-- Localized love modules

local lg = love.graphics

-- Locals

local font

local magnitudeCorrect = function(amount)
	if     amount <       1024 then return amount             , 'B'
	elseif amount <    1048576 then return amount /       1024, 'kB'
	elseif amount < 1073741824 then return amount /    1048576, 'MB'
	else                            return amount / 1073741824, 'GB'
	end
end

-- This module

local t = {}

-- Callbacks

t.render = function(interpolation)

	-- Holds stats about Löve's current graphic resources.
	stats = love.graphics.getStats()

	-- Correct for magnitude (original lowercase style kept for consistency in this table)
	stats.texturememory, stats.texturememoryprefix = magnitudeCorrect(stats.texturememory)

	-- For positioning the data onto the screen.
	local width, height = lg.getDimensions()
	local halfWidth = width  /  2
	local fontHeight = height - 24

	lg.push('all')

	lg.origin()
	lg.setFont(font)
	lg.setColor(255,255,255,255)
	lg.setBlendMode('alpha')

	-- Amount of desync between update ticks and draw frames.
	local lag = (1 - interpolation) * 100

	-- Pre-format the strings
	local atomsPerSecond       = string.format("%3.2f a/s", 1/love.timer.getDelta())
	local atomsPerSecondWidth  = font:getWidth("000000.00 aps")
	local ticksPerSecond       = string.format("%3.2f t/s",   love.timer.getTPS())
	local ticksPerSecondWidth  = font:getWidth("00.00 tps___")
	local framesPerSecond      = string.format("%3.2f f/s",   love.timer.getFPS())
	local framesPerSecondWidth = font:getWidth("00.00 fps___")
	local lagPercent           = string.format("%3.0f%% dt/t", lag)

	local drawCalls            = string.format("d(): %4d", stats.drawcalls)
	local drawCallsWidth       = font:getWidth("d(): 0000")
	local canvasSwitches       = string.format("c<>: %4d", stats.canvasswitches)
	local canvasSwitchesWidth  = font:getWidth("c<>: 0000")
	local textureMemory        = string.format("tex: %10f %s", stats.texturememoryprefix, stats.texturememory)
	local textureMemoryWidth   = font:getWidth("tex: 0000000000     " .. stats.texturememoryprefix)
	local imageCount           = string.format("img: %4d", stats.images)
	local imageCountWidth      = font:getWidth("img: 0000")
	local canvasCount          = string.format("cnv: %4d", stats.canvases)
	local canvasCountWidth     = font:getWidth("cnv: 0000")
	local fontCount            = string.format("fnt: %4d", stats.fonts)
	local fontCountWidth       = font:getWidth("fnt: 0000")

	-- Print the preformatted strings
	lg.printf(atomsPerSecond,  0, fontHeight, width-framesPerSecondWidth-ticksPerSecondWidth-atomsPerSecondWidth, 'right')
	lg.printf(ticksPerSecond,  0, fontHeight, width-framesPerSecondWidth-ticksPerSecondWidth,                     'right')
	lg.printf(framesPerSecond, 0, fontHeight, width-framesPerSecondWidth,                                         'right')

	if lag < 0 then lg.setColor(255,0,0,255) end
	lg.printf(lag, 0, fontHeight, width, 'right')
	lg.setColor(255,255,255,255)

	lg.printf(drawCalls,      0, fontHeight-24, width-fontCountWidth-canvasCountWidth-imageCountWidth-textureMemoryWidth-canvasSwitchesWidth, 'right')
	lg.printf(canvasSwitches, 0, fontHeight-24, width-fontCountWidth-canvasCountWidth-imageCountWidth-textureMemoryWidth                    , 'right')
	lg.printf(textureMemory,  0, fontHeight-24, width-fontCountWidth-canvasCountWidth-imageCountWidth                                       , 'right')
	lg.printf(imageCount,     0, fontHeight-24, width-fontCountWidth-canvasCountWidth                                                       , 'right')
	lg.printf(canvasCount,    0, fontHeight-24, width-fontCountWidth                                                                        , 'right')
	lg.printf(fontCount,      0, fontHeight-24, width                                                                                       , 'right')

	lg.pop()

end

-- Methods

t.init = function()

	font = love.graphics.newFont('assets/THSpatial.ttf',24)

end

----------

return t