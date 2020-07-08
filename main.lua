--[[
    main of simon_says
]]

Class = require 'class'
require 'Box'


WINDOW_WIDTH = 800
WINDOW_HEIGHT = 720

BOX_SIDE = 200

colourRed = {r=1, g=0.2, b=0.2}
colourBlue = {r=0.2, g=0.2, b=1}
colourGreen = {r=0.2, g=1, b=0.2}
colourYellow = {r=1, g=1, b=0.2}

lighterRed = {r=1, g=0.5, b=0.5}
lighterBlue = {r=0.5, g=0.5, b=1}
lighterGreen = {r=0.5, g=1, b=0.5}
lighterYellow = {r=1, g=1, b=0.6}

-- time between beats
timePassed = 0
timeToPass = 1



function love.load()

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = false,
        vsync = true,
        fullscreen = false,
    })

    love.window.setTitle("Simon Says")

    -- sound effects for the boxes
    sounds = {
        ['A'] = love.audio.newSource('sounds_cut/A.wav', 'static'),
        ['G'] = love.audio.newSource('sounds_cut/G.wav', 'static'),
        ['C'] = love.audio.newSource('sounds_cut/C.wav', 'static'),
        ['D'] = love.audio.newSource('sounds_cut/D.wav', 'static'),
    }

    smallFont = love.graphics.newFont(18)
    bigFont = love.graphics.newFont(38)

    offset = 120
    boxes_x = WINDOW_WIDTH / 2 - BOX_SIDE / 2
    boxes_y = WINDOW_HEIGHT / 2 - BOX_SIDE / 2

    box1 = Box(boxes_x - offset, boxes_y - offset, BOX_SIDE , BOX_SIDE , colourRed, lighterRed, sounds['A'])
    box2 = Box(boxes_x + offset, boxes_y - offset, BOX_SIDE , BOX_SIDE , colourGreen, lighterGreen, sounds['G'])
    box3 = Box(boxes_x - offset, boxes_y + offset, BOX_SIDE , BOX_SIDE , colourBlue, lighterBlue, sounds['C'])
    box4 = Box(boxes_x + offset, boxes_y + offset, BOX_SIDE , BOX_SIDE , colourYellow, lighterYellow, sounds['D'])

    boxes = {box1, box2, box3, box4}


    simonSays = ""
    userSays = ""

    score = 0
    highScore = 0

    playing = true

    gameState = 'start'
    --message = "Press enter to play"

    -- to keep track of the beat to play in simonSays
    beatIndex = 0
    -- to keep track of the number of beats the user inputs
    beatCounter = 0

    beatAdded = false
end


function love.keypressed(key)
    if key == 'escape' then
         -- the function LÖVE2D uses to quit the application
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'watch'
        elseif gameState == 'loss' then
            gameState = 'start'
        end
    end
end


-- handles the beats and adds the box number to userSays
function love.mousepressed(x, y, button)
    -- only receive input in play state
    if gameState == 'play' then
        if button == 1 then
            for _,v in ipairs(boxes) do
                v:click(x, y)
            end

            beatCounter = beatCounter + 1

            -- this won't work if a beat is played before another is finished
            if box1.clicked then
                userSays = userSays .. "1"
            elseif box2.clicked then
                userSays = userSays .. "2"
            elseif box3.clicked then
                userSays = userSays .. "3"
            elseif box4.clicked then
                userSays = userSays .. "4"
            end
        end
    end
end


function love.update(dt)
    if gameState == 'start' then
        score = 0
        message = "Press enter to play"
    end

    if gameState == 'watch' then
        beatCounter = 0
        userSays = ""
        message = gameState

        timePassed = timePassed + dt

        if beatAdded == false then
            -- add a new random beat to simonSays
            randomNum = love.math.random(4)
            simonSays = simonSays .. randomNum

            beatAdded = true
        end

        if timePassed > timeToPass then
            -- iterate trough beats in simonSays
            if beatIndex < #simonSays then
                beatIndex = beatIndex + 1

                -- play next beat 
                boxToPlay = boxes[tonumber(simonSays:sub(beatIndex, beatIndex))]
                boxToPlay:play()
            else 
                beatAdded = false
                gameState = 'play'
            end

            timePassed = 0
        end

    end


    if gameState == 'play' then
        beatIndex = 0
        message = gameState

        -- the user has to input as many beats as Simon
        if beatCounter == #simonSays then
            timePassed = timePassed + dt

            -- wait before going to watch state
            if timePassed > timeToPass then
                -- check for win/loss
                if simonSays == userSays then
                    score = score + 1

                    --message = "Win!"
                    gameState = 'watch'
                else
                    message = "You lost!"
                    gameState = 'loss'

                    simonSays = ""
                end

                timePassed = 0
            end
        end
    end

    -- check for a high score
    if score > highScore then
        highScore = score
    end

    
    -- updates the boxes
    for _,v in ipairs(boxes) do
        v:update(dt)
    end
end



function love.draw()
    -- grey bg
    love.graphics.clear(0.2, 0.2, 0.2)

    box1:render()
    box2:render()
    box3:render()
    box4:render()

    -- white font
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(smallFont)
    love.graphics.printf(message , 0, WINDOW_HEIGHT - 120, WINDOW_WIDTH, 'center')

    if gameState == 'loss' then
        -- grey bg
        love.graphics.clear(0.2, 0.2, 0.2)

        love.graphics.printf("Press enter to start again" , 0, WINDOW_HEIGHT / 2 + 25 , WINDOW_WIDTH, 'center')

        love.graphics.setFont(bigFont)
        love.graphics.printf(message , 0, WINDOW_HEIGHT / 2 - 20 , WINDOW_WIDTH, 'center')
        
    end

    love.graphics.setFont(smallFont)
    love.graphics.printf("Score: " .. tostring(score), 0, 82, WINDOW_WIDTH, 'center')
    love.graphics.printf("High Score: " .. highScore, 0, 60, WINDOW_WIDTH , 'center')
    --love.graphics.print("High Score: " .. tostring(highScore), WINDOW_WIDTH / 2 - 84, 60)
    

    --[[ for debugging
    love.graphics.printf("simonSays: " .. simonSays, 0, WINDOW_HEIGHT / 2 - 6, WINDOW_WIDTH, 'center')
    love.graphics.printf(timePassed, 0, WINDOW_HEIGHT / 2 + 6, WINDOW_WIDTH, 'center')
    love.graphics.printf("userSays: " .. userSays, 0, WINDOW_HEIGHT - 100, WINDOW_WIDTH, 'center')
    --love.graphics.printf("beatCounter: " .. beatCounter , 0, WINDOW_HEIGHT - 80, WINDOW_WIDTH, 'center')
    ]]
    

end


--[[
DONE:
- make four boxes X
- make the boxes play a sound when clicked X
- make the boxes change colour when clicked (as if they light up)  X
- make the pc generate a random number X
- make a 'simon' string with the random number X
- make simon play each character (with a for loop) in the string as a button
  (using Box:play() should work) X
- make a different playTime variable to space out the buttons playing (timePassed and timeToPass) X 
- make game states 1 and 2 X
- make a 'user' string with the buttons inputed X
- before checking, wait for the user to input ALL of the beats (use a beatCounter variable that increases with the levels, 
  beatCounter should become equal to #simonSays before the checkings) X
- check if userSays is equal to simonSays (lua may or may not use '==' to do that with strings) X
    - if so, loop to watch state, else, loss state X
    - update score X
- REMEMBER TO CLEAR the user string when at a new watch state (but DO NOT clear simon's string) (userSays = "") X
- make game state 3 X
- make a 'loss' screen with the message 'you lost!' (clear the screen when you get to the loss state) X
- make a bigger font and use it for the score and the message under the boxes X 
- make a way bigger font and use it for 'you lost!' X


TO-DO:

- find shorter audio samples

- reduce the duration of timeToPass (in main) and of playTime (of the boxes)



NOTE ON GAME STATES:
   - 1) during 'watch' state, the buttons are unclickable, simons says
   - 2) during 'play' state, the buttons are clickable and waiting for input, the user says
   - 3) during 'loss' state, a finishing message is displayed, the buttons are not clicked,
        and they can't be.


NOTE ON HOW TO REPRESENT THE BUTTONS TO PRESS:
use two strings, one for what 'simon says' is the sequence of buttons,
and one for what the 'user says' it is, append a number 1-4 depending on
what button is randomly selected (for simon) or clicked/inputed (for the user)

if the strings are equal, than you proceed to another level. User's strings is cleared
and another number is appended to Simon's string and you play again.
]]
