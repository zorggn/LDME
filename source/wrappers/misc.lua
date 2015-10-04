-- Engine miscellaneous functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	- TODO: Remove this and put the functions into their relevant wrappers.
	--]]

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	-- SaveSnapshot - love has us covered, lg.newScreenshot

	-- ...also, if we'll make a replay system anyway, we could also make a "video" export system;
	-- stepping the tick when a screenshot of a frame has been taken...
	-- or better, defining the FPS we want to record at, we step the deltatime slower instead

	-- AddArchiveFile - same here, lfs.mount

	-- os.remove -- no reason to modify already existing files programmatically... maybe only from packages, but there's lfs for that.
	-- os.rename -- same deal as above
	-- os.setlocale -- NO.   NO NO NO NO NO NO NO NO NO.       No.   The engine is utf-8 capable, thanks to löve, so no locales. ever.   
	-- os.tempname -- Could implement a better uuid generator, if we need one.

end