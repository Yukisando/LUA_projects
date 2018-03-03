local imageFile
local frames = {}

local activeFrame
local currentFrame = 1
function love.load()
	start()

    imageFile = love.graphics.newImage("data/img/connor.PNG")
    frames[1] = love.graphics.newQuad(0,0,64,64,imageFile:getDimensions())
    frames[2] = love.graphics.newQuad(64,0,64,64,imageFile:getDimensions())
    frames[3] = love.graphics.newQuad(0,64,64,64,imageFile:getDimensions())
    frames[4] = love.graphics.newQuad(64,64,128,128,imageFile:getDimensions())
    activeFrame = frames[currentFrame]
    print(select(4,activeFrame:getViewport())/2)
end

function love.draw()
	update()
	--grid(true)
	--Menu
	love.graphics.setBackgroundColor(190, 190, 190)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print(currentFrame)
	title("Happy Birthday Connor!")
    --love.graphics.draw(imageFile,activeFrame)
    love.graphics.draw(imageFile,activeFrame,
	love.graphics.getWidth()/2 - (select(3,activeFrame:getViewport())/2) * 2,
	love.graphics.getHeight()/2 - (select(4,activeFrame:getViewport())/2) * 2, 0, 2, 2)
end

local elapsedTime = 0
function love.update(dt)
    elapsedTime = elapsedTime + dt

    if(elapsedTime > 1) then
        if(currentFrame < 4) then
            currentFrame = currentFrame + 1
        else
        currentFrame = 1
        end
        activeFrame = frames[currentFrame]
        elapsedTime = 0
        end
end