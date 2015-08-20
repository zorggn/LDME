function love.conf(t)

    -- The name of the framework's own save directory (string)
    -- Packages may overwrite this in their own init functions, if they wish to be a "standalone" game.
    t.identity = "LDME"

    -- The LÖVE version this game was made for (string)
    -- TODO: Update it when löve 0.10 comes out.
    t.version = "0.9.2"                

    -- Attach a console (boolean, Windows only)
    -- TODO: Set to false at initial release, to not barf into people's consoles.
    t.console = true

    -- The window gets programatically created in either the default, or the given init function.
    t.window = false                   
 
    -- Who knows which of these the users want to use, best have them all enabled just-in-case.
    t.modules.audio = true             -- Enable the audio module (boolean)
    t.modules.event = true             -- Enable the event module (boolean)
    t.modules.graphics = true          -- Enable the graphics module (boolean)
    t.modules.image = true             -- Enable the image module (boolean)
    t.modules.joystick = true          -- Enable the joystick module (boolean)
    t.modules.keyboard = true          -- Enable the keyboard module (boolean)
    t.modules.math = true              -- Enable the math module (boolean)
    t.modules.mouse = true             -- Enable the mouse module (boolean)
    t.modules.physics = true           -- Enable the physics module (boolean)
    t.modules.sound = true             -- Enable the sound module (boolean)
    t.modules.system = true            -- Enable the system module (boolean)
    t.modules.timer = true             -- Enable the timer module (boolean)
    t.modules.window = true            -- Enable the window module (boolean)
    t.modules.thread = true            -- Enable the thread module (boolean)

end