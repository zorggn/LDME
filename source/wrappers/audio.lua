-- Engine audio functions wrapper
-- by zorg @ 2015 license: ISC

--[[Notes:
	- Allows scripts to use functions defined here as their environment
	--]]

-- Modules
local audio = require 'source.audio'

return function(t, barf) -- if barf, then flatly fill t with these functions, else use "namespaces".

	t.audio = (not barf) and {} or t

	-- Note that Ph3 _sound object_ functions weren't listed here, so the below functions MAY have similar or equivalent ones in those.
	-- Panning is problematic for the stupid directional audio reason, so yeah, no solution for that one...
	-- ..apart from using two mono sources, and fading between them.

	-- Background music

	-- 012: LoadMusic
	-- Ph3: LoadSound
	t.audio.newBGM = audio.newBGM
	-- string path                      - filepath
	-- vararg ...                       - user may store additional data inside
	-- return number, table             - index of the bgm object, and the object itself

	-- 012: PlayMusic
	-- Ph3: PlayBGM
	t.audio.playBGM = audio.playBGM
	-- number id                        - index of the bgm object
	-- number time                      - length of the fadein, in seconds

	-- 012: N/A
	-- Ph3: N/A
	t.audio.pauseBGM = audio.pauseBGM
	-- number id                        - index of the bgm object
	-- number time                      - length of the fadeout, in seconds

	-- 012: FadeOutMusic
	-- Ph3: StopSound (no fade possibility?)
	t.audio.stopBGM = audio.stopBGM
	-- number id                        - index of the bgm object
	-- number time                      - length of the fadeout, in seconds

	-- 012: N/A
	-- Ph3: N/A
	t.audio.fadeBGM = audio.fadeBGM
	-- number id                        - index of the bgm object
	-- number time                      - length of the fade, in seconds
	-- number vol                       - volume level the fade should end at

	-- 012: DeleteMusic
	-- Ph3: RemoveSound
	t.audio.delBGM = audio.delBGM
	-- number id                        - index of the bgm object

	-- 012: N/A
	-- Ph3: N/A
	t.audio.getBGMLoopPoints = audio.getBGMLoopPoints
	-- number id                        - index of the bgm object
	-- return number, number, string    - start and endpoints of the loop, as well as the unit: 'samples' or 'seconds'

	-- 012: N/A
	-- Ph3: N/A
	t.audio.getBGMPitch = audio.getBGMPitch
	-- number id                        - index of the bgm object
	-- return number multiplier         - pitch multiplier

	-- 012: N/A
	-- Ph3: via PlayBGM
	t.audio.setBGMLoopPoints = audio.setBGMLoopPoints
	-- number id                        - index of the bgm object
	-- number start                     - startpoint of the loop
	-- number end                       - endpoint of the loop
	-- string unit                      - unit the loop points are defined in: 'samples' or 'seconds'

	-- 012: N/A
	-- Ph3: N/A
	t.audio.setBGMPitch = audio.setBGMPitch
	-- number id                        - index of the bgm object
	-- number multiplier                - pitch multiplier



	-- Sound effects

	-- 012: LoadSE
	-- Ph3: LoadSound
	t.audio.newSFX = audio.newSFX
	-- string path                      - filepath
	-- number maxVoices                 - how many sources can the object clone for itself for non-interruptive sound restarts
	-- vararg ...                       - user may store additional data inside
	-- return number, table             - index of the sfx object, and the object itself

	-- 012: PlaySE
	-- Ph3: PlaySE
	t.audio.playSFX = audio.playSFX
	-- number id                        - index of the sfx object
	-- number multiplier                - pitch multiplier

	-- 012: StopSE
	-- Ph3: StopSound
	t.audio.stopSFX = audio.stopSFX
	-- number id                        - index of the sfx object

	-- 012: DeleteSE
	-- Ph3: RemoveSound
	t.audio.delSFX = audio.delSFX
	-- number id                        - index of the sfx object

	-- Generic

	-- 012: N/A
	-- Ph3: N/A
	t.audio.getSources = audio.getSources
	-- number id                        - index of the audio object
	-- return table                     - holds the source object(s), useful for advanced manipulation

	-- 012: N/A
	-- Ph3: N/A
	t.audio.getVolume = audio.getVolume
	-- number id                        - index of the audio object
	-- return number                    - volume of the audio object

	-- 012: N/A
	-- Ph3: N/A
	t.audio.setVolume = audio.setVolume
	-- number id                        - index of the audio object
	-- number vol                       - volume to set the object to

	-- End audio

	t.audio = (not barf) and t.audio or nil

end