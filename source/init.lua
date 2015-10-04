-- Engine initializing code
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Checks commandline arguments
	- if there is at least three, then:
	- if second is "package", try to mount the third arg, assuming it's a zip or a directory if there's no file extension
	- if it's "single", "sequence", "stage" or "character", create the appropriate script handler and execute it directly.
	- Otherwise, use the framework defaults defined in its own package init file (and not conf.lua)
	--]]



-- Engine version (3rd iteration)
-- The ONLY global in this whole framework
-- 0th major version (prerelease) | 1st minor version (not yet versioned) | 5th patch
_LDME_version = "0.1.5"



-- Localized love modules

local lfs = love.filesystem
local lw  = love.window



-- Modules

local log = require 'source.log'



-- Locals

local initPackage
local allowedScriptTypes = require 'source.scripttypes'


-- This module

local init



-- Methods

init = function(arg)

	-- Debug info.
	local cmdline = {('\t'..tostring(arg))}
	for i=-2,#arg do cmdline[#cmdline+1] = '\t' .. string.format('%+2d: ',i) .. tostring(arg[i]) end
	log('sys','Commandline Arguments: \n%s',table.concat(cmdline,' \n') .. '\n')

	if arg[2] and arg[3] and allowedScriptTypes[arg[2]] then
		if arg[2] == "package" then

			-- Assuming 3rd cmdline arg to be a path to either a subfolder in the game's save directory,
			-- or a zip file containing a whole game package, or the package's init.lua file.
			return initPackage(arg[3])

		else -- A "lesser" script

			-- Assuming 3rd argument is the path to the script itself, init with default file,
			-- but load in the given script.
			initPackage('scripts/package/default/init.lua')
			return arg[2], arg[3]

		end
	else
		-- Run internal config for framework mode, which is a normal package script itself, nothing special.
		return initPackage('scripts/package/default/init.lua')
	end
end



-- Private functions

initPackage = function(packagePath)

	-- Test whether packagePath points to an archive, and mount it if it is.
	if lfs.isFile(packagePath) then
		if packagePath:sub(-3) == 'zip' then
			local ok = lfs.mount(packagePath, 'package')
			if not ok then
				local s = string.format("Error: init.lua: Couldn't mount file '%s'. Make sure it is a zip archive!", packagePath)
				log('sys',s); error(s)
			end
			packagePath = 'package/init.lua'
		end
	end

	-- Test whether packagePath points to a directory, append "/init.lua" to it if it is.
	if lfs.isDirectory(packagePath) then
		if packagePath:sub(-1) ~= '/' then packagePath = packagePath .. '/' end
		packagePath = packagePath .. 'init.lua'
	end

	-- Separate the given path to directories and filename
	local p,n,e = packagePath:match("(.-)([^\\/]-%.?([^%.\\/]*))$"); n = n:match("(.+)%..*")

	-- Try loading and executing the file we got from above
	if lfs.isFile(packagePath) then

		local ok = lfs.load(packagePath)
		if not ok then
			local s = string.format("Error: init.lua: Couldn't load file '%s'.", packagePath)
			log('sys',s); error(s)
		end

		-- Call the package's init script; we expect these vars to be returned.
		local width, height, flags, title, entrypoint = ok()

		ok = lw.setMode(width, height, flags)
		if not ok then
			local s = string.format("Error: init.lua: Couldn't set default video mode; please check '%s' for problems.", packagePath)
			log('sys',s); error(s) 
		end

		if title and type(title) == 'string' then
			lw.setTitle(title)
		end

		-- Only allow access to files inside the package's own directory
		return 'package', p .. entrypoint
	else
		local s = string.format("Error: init.lua: File '%s' doesn't exist!", packagePath)
		log('sys',s); error(s)
	end
end



----------

return init