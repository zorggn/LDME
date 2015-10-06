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

-- This module

local t = {}

-- Callbacks

t.render = function(ip)

	-- Locals for all the data we can get from löve
	local width, height, hw, fh, aps, apsw, tps, tpsw, fps, fpsw, lag, lagw, l
	local stats, dcs, dcw, csws, csww, txms, txmw, imgs, imgw, cnvs, cnvw, fnts, fntw, txm, txp

	stats = love.graphics.getStats()

	-- Correct for magnitude
	if stats.texturememory < 1024 then
		txm = stats.texturememory
		txp = 'B'
	elseif stats.texturememory < 1048576 then
		txm = stats.texturememory / 1024
		txp = 'kB'
	elseif stats.texturememory < 1073741824 then
		txm = stats.texturememory / 1048576
		txp = 'MB'
	else
		txm = stats.texturememory / 1073741824
		txp = 'GB'
	end

	-- For displaying all this
	width, height = lg.getDimensions()
	hw = width  /  2
	fh = height - 24

	lg.push('all')

	lg.origin()
	lg.setFont(font)
	lg.setColor(255,255,255,255)
	lg.setBlendMode('alpha')

	-- Lag percentage
	l = (1-ip)*100

	-- Pre-format the strings
	aps  = string.format("%3.2f a/s", 1/love.timer.getDelta())
	apsw = font:getWidth("000000.00 aps")
	tps  = string.format("%3.2f t/s",   love.timer.getTPS())
	tpsw = font:getWidth("00.00 tps___")
	fps  = string.format("%3.2f f/s",   love.timer.getFPS())
	fpsw = font:getWidth("00.00 fps___")
	lag  = string.format("%3.0f%% dt/t", l)

	dcs  = string.format("d(): %4d", stats.drawcalls)
	dcw  = font:getWidth("d(): 0000")
	csws = string.format("c<>: %4d", stats.canvasswitches)
	csww = font:getWidth("c<>: 0000")
	txms = string.format("tex: %10f " .. txp, txm)
	txmw = font:getWidth("tex: 0000000000     " .. txp)
	imgs = string.format("img: %4d", stats.images)
	imgw = font:getWidth("img: 0000")
	cnvs = string.format("cnv: %4d", stats.canvases)
	cnvw = font:getWidth("cnv: 0000")
	fnts = string.format("fnt: %4d", stats.fonts)
	fntw = font:getWidth("fnt: 0000")

	-- Print the preformatted strings
	lg.printf(aps, 0, fh, width-fpsw-tpsw-apsw, 'right')
	lg.printf(tps, 0, fh, width-fpsw-tpsw,      'right')
	lg.printf(fps, 0, fh, width-fpsw,           'right')
	if l < 0 then lg.setColor(255,0,0,255) end
	lg.printf(lag, 0, fh, width,                'right')

	lg.printf(dcs,  0, fh-24, width-fntw-cnvw-imgw-txmw-csww, 'right')
	lg.printf(csws, 0, fh-24, width-fntw-cnvw-imgw-txmw     , 'right')
	lg.printf(txms, 0, fh-24, width-fntw-cnvw-imgw          , 'right')
	lg.printf(imgs, 0, fh-24, width-fntw-cnvw               , 'right')
	lg.printf(cnvs, 0, fh-24, width-fntw                    , 'right')
	lg.printf(fnts, 0, fh-24, width                         , 'right')

	lg.pop()

end

-- Methods

t.init = function()
	font = love.graphics.newFont('assets/THSpatial.ttf',24)
end

----------

return t