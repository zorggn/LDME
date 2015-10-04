-- Default package - initialization
-- by zorg @ 2015 license: ISC

-- The file we should switch to after initializing the window.
local entryPoint = 'preload.lua'

-- The title of the window.
local title = "Löve Danmaku Maker Engine v" .. _LDME_version

-- The dimensions and other properities of the window we're creating.
local width = 1280
local height = 720
local flags = {
		fullscreen = false,
		fullscreentype = "desktop",
		vsync = false,
		fsaa = 0,
		resizable = false,
		borderless = false,
		centered = true,
		display = 1,
		minwidth = 1,
		minheight = 1,
		highdpi = false,
		srgb = false,
		x = nil,
		y = nil,
	}

return width, height, flags, title, entryPoint