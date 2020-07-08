--[[
    box class of simon_says
    
    beat: box playing its sound and changing to lighterColour
]]

Box = Class{}

function Box:init(x, y, width, height, colour, lighterColour, sound)
    self.X = x
    self.Y = y
    self.width = width
    self.height = height
    self.colour = colour
    self.lighterColour = lighterColour
    self.sound = sound

    self.clicked = false
    self.playTime = 2
end

function Box:update(dt)
    -- the buttons play for the duration of playTime
    self.playTime = self.playTime - dt
end

-- returns true if the mouse is hovering this box
function Box:isHovered(x,y)
    if x > self.X and x < self.X + self.width and y > self.Y and y < self.Y + self.height then
        return true
    end
end

-- plays the box sound and triggers the change in look
function Box:play()
    self.sound:play()
    self.clicked = true
end

-- plays the beat if the box is clicked
function Box:click(x, y)
    if self:isHovered(x, y) then
        self:play()
    end
end

-- resets the timer for the change in colour
function Box:clickReset()
    if self.playTime < 0 then
        self.clicked = false
        self.playTime = 1
    end
end


function Box:render()
    if self.clicked and self.playTime > 0 then
        love.graphics.setColor(self.lighterColour['r'], self.lighterColour['g'], self.lighterColour['b'])
    else
        love.graphics.setColor(self.colour['r'], self.colour['g'], self.colour['b'])
    end   
    self:clickReset()

    love.graphics.rectangle('fill', self.X, self.Y, self.width, self.height)
end