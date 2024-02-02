--[[
    MIT License

    Copyright (c) 2024 Shreejit Murthy

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

require "utilities"

PhysicsWorld = {
    entities = {},
}
PhysicsWorld.__index = PhysicsWorld

entity_types = {"static", "dynamic"}
Entity = {
    etype = "",
    colour = {1, 1, 1},
    alpha = 1,  -- alpha is subject to change and easier to not keep in colour table
    x = 0,
    y = 0,
    lastX = 0,
    lastY = 0,
    idleTimer = 0,
    isIdle = false,
    velocity = {x = 0, y = 0},
    drawn = false,
}

local function initEntity(type, x, y)
    local self = setmetatable({}, {__index = Entity})
    self.etype = type
    self.velocity = {x = x, y = x}
    self.x, self.y = x, y
    self.lastX, self.lastY = self.x, self.y
    return self
end

function Entity:Move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Entity:Update(dt)
    if self.etype ~= "static" then
        self.idleTimer = self.idleTimer + dt

        if self.x ~= self.lastX or self.y ~= self.lastY then
            self.idleTimer = 0
            self.lastX, self.lastY = self.x, self.y
            self.isIdle = false
        end
    
        if self.idleTimer > 3 and not self.isIdle then
            self.isIdle = true
        end
    
        if self.isIdle then
            self.colour = {0.5, 0, 0.5}
        else
            self.colour = {1, 1, 1}
        end
    end
end

function Entity:Draw(alpha, disable_drawn_flag)
    self.alpha = alpha

    love.graphics.setLineWidth(2)
    love.graphics.setColor(self.colour, self.alpha)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.reset()

    if not disable_drawn_flag then
        self.drawn = true
    end
end


function PhysicsWorld.New(gravity)
    local self = setmetatable({}, PhysicsWorld)
    if gravity then self.gravity = gravity end
    return self
end

function PhysicsWorld:NewEntity(entity_type, x, y, width, height)
    if not table_contains(entity_types, entity_type) then
        error("Unknown entity type '" .. entity_type .. "'. Please use the supported types.")
    end

    local entity = initEntity(entity_type, x, y)
    entity.width = width or 32
    entity.height = height or 32

    table.insert(self.entities, entity_type == entity_types[2] and 1 or #self.entities + 1, entity)
    return entity
end

function PhysicsWorld:UpdateCollisionDetection(dt)
    collisionInfo = nil
    local n = #self.entities
    for i = 1, n - 1 do
        for j = i + 1, n do
            local r1 = self.entities[i]
            local r2 = self.entities[j]
            hit = rectRect(r1.x, r1.y, r1.width, r1.height, r2.x, r2.y, r2.width, r2.height)

            -- local dynamic_rect = (r1.etype == "dynamic" and r1) or
            -- (r2.etype == "dynamic" and r2)
            local dynamic_rect = r1
            dynamic_rect:Update(dt)

            if dynamic_rect.isIdle == false then
                if hit then
                    collisionInfo = {i, j, dynamic_rect.isIdle}
                    if dynamic_rect then
                        local dx = (dynamic_rect.x + dynamic_rect.width/2) - (r2.x + r2.width/2)
                        local dy = (dynamic_rect.y + dynamic_rect.height/2) - (r2.y + r2.height/2)
                        local overlapX = (dynamic_rect.width + r2.width) / 2 - math.abs(dx)
                        local overlapY = (dynamic_rect.height + r2.height) / 2 - math.abs(dy)
    
                        -- Adjust the position of the dynamic entity
                        if overlapX < overlapY then
                            if dx > 0 then
                                dynamic_rect.x = dynamic_rect.x + overlapX
                            else
                                dynamic_rect.x = dynamic_rect.x - overlapX
                            end
                        else
                            if dy > 0 then
                                dynamic_rect.y = dynamic_rect.y + overlapY
                            else
                                dynamic_rect.y = dynamic_rect.y - overlapY
                            end
                        end
                    end
                    break
                end
            end

        end
        if collisionInfo then 
            break 
        end
    end
end

local function getCollisionInfo(collisionInfo)
    if collisionInfo then
        if collisionInfo[3] then
            return "Disabled collision checks"
        else
            return string.format("Collision between entities: %d / %d", collisionInfo[1], collisionInfo[2])
        end
    else
        return "No collision detected"
    end
end

function PhysicsWorld:Draw()
    love.graphics.setLineWidth(2)
    font = love.graphics.getFont()

    -- this e.drawn system is cooked but i think it works in making sure there arent double draw calls
    for i, e in ipairs(self.entities) do
        if not e.drawn then
            e:Draw(1, true)
        end

        -- print entity number on entity
        local n = tostring(i)
        fw, fh = font:getWidth(n), font:getHeight()
        love.graphics.print(n, e.x + e.width/2 - fw/2, e.y + e.height/2 - fh/2)
    end

    love.graphics.print(getCollisionInfo(collisionInfo), 10, 10)

    love.graphics.reset()

    -- love.graphics.print(tostring(hit), 10, 10)

    -- local str = string.format("Entity colour: %.2f, %.2f, %.2f", entity.colour.r, entity.colour.g, entity.colour.b)
    -- love.graphics.print(str, 10, 10)
end