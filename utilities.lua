-- Set of useful functions used in the collision detection script

function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

function count_down(time, dt)
    time = time - dt
    if time < 0 then
        time = 0
    end
    return time == 0
end

function rectRect(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
    -- are the sides of one rectangle touching the other?
    if r1x + r1w >= r2x and    -- r1 right edge past r2 left
       r1x <= r2x + r2w and    -- r1 left edge past r2 right
       r1y + r1h >= r2y and    -- r1 top edge past r2 bottom
       r1y <= r2y + r2h then   -- r1 bottom edge past r2 top
        return true
    end
    return false
end

function distPointPoint(x1, x2, y1, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end
