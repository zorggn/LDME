# LDME ~ 新藍弾 (ShinAiDan ~ New Indigo Bullet)

	Folder Structure: (not all defined necessarily)

app -- Application folder (Location of main.lua, or LDME.love if fused.)
	src -- Source code
		lib -- External libraries
		scr -- Scripts
	res -- Resources
		ani -- Animation files
		bgm -- Background music, stream format only
		gfx -- Graphics files, even "pre-animated" like gifs
		map -- Map files
		mid -- MIDI or similar notation-only files
		mod -- Tracker modules, including notation and sound samples
		ost -- Original soundtrack
		shd -- Shaders
		sfx -- Sound effects
		vox -- Voice tracks / dubbing
		vtx -- Meshes (Vertex)


usr -- Where the game looks for user content
	hsc -- High scores folder
	log -- Folder where usage logs go to
	pic -- Screenshots
	rpl -- Replay files
	scr -- Scripts folder
		obj -- Various objects, like playable characters, enemies, bosses, bullet patterns, etc.
		scn -- Scenes, as in bgs and whatnot
		lvl -- Levels, with many scenes
		pkg -- Whole packages, with optional gui systems
	

---------------------------------------

Movement

Basic members
	- Locative
	Position     (x,y coords)
	Velocity     (magnitude (speed), angle scalars)
	Acceleration (magnitude, angle scalars)
	Angular velocity (magnitude)
	Angular acceleration (magnitude)
	- Pointing
	Orientation  (angle)
	Angular velocity (magnitude)
	Angular acceleration (magnitude)

Implementable behaviours
	Move to x,y with r velo. magnitude (speed) then stop.
	Move to x,y in t ticks
	Move to x,y in s seconds
	Move to random(x,y) via any of the above methods, with l,r,t,b boundaries
	All of the above with non-linear movement.

Extra behaviours not in danmakufu movement functions
	Move with r,phi velocity for t ticks / s seconds.
	_endpoint,speed; endpoint,time; speed,time. All types accounted for._

Angle shenanigans
	Reinterpret 0 degrees in various ways:
		Absolute: 0 is to the right of the screen, and it goes ccw.
		Relative: 0 is whatever you set it to. (like players, enemies, parents) Also set chirality (cw or ccw)

Coordinate system shenanigans
	Reinterpret 0,0 in various ways:
		Absolute: top-left of the screen is 0,0 (y rises downwards)
		Relative: 0,0 is whatever you set it to (including parents)

Movement types
	moveTo(x,y,func,...)
	moveBy()

---------------------------------------

Entities - Exist inside a playfield
Playfields - Exist according to a system
System - Defines how the game works and is presented

---------------------------------------

Shot - Entity

Delete After f frames / s seconds
Delay For f frames / s seconds
new: position, velocity --(CartesianToPolar(dx, dy) -> r,phi)
new: position, initVelo, Accel, min/max speed --(CartesianToPolar(dx, dy) -> r,phi) x3

for (var isPlayerDead = 0, playerHP = 42; !isPlayerDead;) 0 >= playerHP ? (isPlayerDead = 1, console.log("Player is Dead")) : (console.log("Not dead. Curr HP " + playerHP), playerHP -= 1);

local isPlayerDead, playerHP = 0, 42; while not isPlayerDead do if playerHP <= 0 then isPlayerDead = true; print("Player is dead") else print("Not dead. Curr HP " .. playerHP); playerHP = playerHP - 1 end -- semicolons optional.