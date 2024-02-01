# LOVE-collision
love2d collision detection script for my stuff. I made this because I thought windfield/love.physics was too complex for my needs, and bump.lua had some features that I personally would prefer.

Similar to bump.lua, this script features:
* Axis-Aligned Bounding-Box (AABB) collisions.
* Detection *and* basic collision reponse.
* Not focused on being realistic, rather *game* realistic.

The regular collision script can technically be used in any Lua compatible environment, so long as the drawing function is removed. 

## Usage
The `collision.lua` uses a typical approach.
```lua
require "collision"

speed = 250

function love.load()
    world = PhysicsWorld.New()
    player = world:NewEntity("dynamic", 500, 10, 32, 32)   
    box = world:NewEntity("static", 300, 200, 100, 100)    
    platform = world:NewEntity("static", 300, 400, 250, 50)
end

function love.update(dt)
    if love.keyboard.isDown("up") then
        player:Move(0, -speed * dt)
    end
    if love.keyboard.isDown("down") then
        player:Move(0, speed * dt)
    end
    if love.keyboard.isDown("left") then
        player:Move(-speed * dt, 0)
    end
    if love.keyboard.isDown("right") then
        player:Move(speed * dt, 0)
    end

    world:UpdateCollisionDetection()
end

function love.draw()
    world:Draw()
end
```

And that looks like this:
