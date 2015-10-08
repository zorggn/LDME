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
local offset = 4
local watchedVariables = {}
local variableOrder = {}

local renderVariable = function(name, x, y, interpolation)
	local value = watchedVariables[name][1](interpolation)
	local format = watchedVariables[name][2]
	local formattedValue = string.format(format, value)

	local textWidth = font:getWidth(formattedValue)
	local textHeight = font:getHeight()

	lg.push('all')
	lg.setColor(0, 0, 0, 150)
	lg.rectangle("fill", x, y, textWidth+offset*2, textHeight+offset*2)
	lg.pop()

	lg.printf(formattedValue, x + offset, y + offset, textWidth, "left")
	return
end

-- This module

local t = {}

-- Callbacks

t.render = function(interpolation)

	lg.push('all')

	lg.origin()
	lg.setFont(font)
	lg.setColor(255,255,255,255)
	lg.setBlendMode('alpha')

	for i=1, #variableOrder do
		renderVariable(variableOrder[i], 0, (i-1)*(font:getHeight()+offset*2), interpolation)
	end

	lg.pop()

end

-- Methods

t.init = function()

	font = love.graphics.newFont('assets/THSpatial.ttf',20)

	t.watchVariable("Atoms per second", function()
		return 1/love.timer.getDelta()
	end, "%3.2f a/s")
	t.watchVariable("Ticks per second", function()
		return love.timer.getTPS()
	end, "%3.2f t/s")
	t.watchVariable("Frames per second", function()
		return love.timer.getFPS()
	end, "%3.2f f/s")
	t.watchVariable("Lag percentage", function(interpolation)
		-- Amount of desync between update ticks and draw frames.
		return 1 - interpolation * 100
	end, "%3.2f dt/t")

	t.watchVariable("Draw calls", function()
		return love.graphics.getStats().drawcalls
	end, "d(): %4d")
	t.watchVariable("Canvas switches", function()
		return love.graphics.getStats().canvasswitches
	end, "c<>: %4d")
	t.watchVariable("Texture Memory", function()
		stats = love.graphics.getStats()
		return (stats.texturememory/1000)
	end, "tex: %10f kB")
	t.watchVariable("Image Count", function()
		return love.graphics.getStats().images
	end, "img: %4d")
	t.watchVariable("Canvas Count", function()
		return love.graphics.getStats().canvases
	end, "cnv: %4d")
	t.watchVariable("Fonts Count", function()
		return love.graphics.getStats().fonts
	end, "fnt: %4d")
end

t.watchVariable = function(name, valueCallback, formatString)
	watchedVariables[name] = {valueCallback, formatString}
	table.insert(variableOrder, name)
end

t.unWatchVariable = function(name)
	table.remove(variableOrder, name)
end

----------

return t
