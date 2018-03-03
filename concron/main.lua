local connor, connor_flipped, connor_dead, connor_cry
local frames = {}
local frames_cry = {}

local activeFrame
local activeFrame_cry
local currentFrame = 1
local currentFrame_cry = 1
local elapsedTime = 0
local elapsedTime_cry = 0


function love.load()
	start()

	line_seperation = 100
	line_1 = HEIGHT / 2 - line_seperation
	line_2 = HEIGHT / 2 + line_seperation

	f = love.filesystem.newFile("highscore.txt")
	pause = false
	lose = false
	block_hit = false
	block_hit_index = 0

	time = 0
	speed = 15
	iter = 0
	iter_block = 0
	delay = 30 + (love.math.random() * 15)
	spawn = false

	--Player
	player = {	size = 50,
	lives = 3,
	x = 200,
	y = line_2 - 50,
	color = {0, 0, 0, 0}
}

	--Blocks
	blocks = {}
	function blocks:new(x, y, size, color)
		local size = size
		local x = x
		local y = y
		local color = color
		local new_block = {x = x, y = y, size = size, color = color}
		table.insert(blocks, new_block)
	end
	
	--Begin
	score = 0
	level_color = {0, 0, 0, 200}
	blocks:new(WIDTH, line_1, 60, {50, 255, 0})
	highscore = love.filesystem.read("highscore.txt")
	sprite_flipped = false
	
	new_quote = true
	selected_quote = "RIP"

	cracker_1_scale = 0
	cracker_2_scale = 0
	cracker_3_scale = 0

	cracker_1 = love.graphics.newImage("data/img/cracker.png")
	cracker_2 = love.graphics.newImage("data/img/cracker.png")
	cracker_3 = love.graphics.newImage("data/img/cracker.png")
	connor = love.graphics.newImage("data/img/connor.png")
	connor_dead = love.graphics.newImage("data/img/connor_dead.png")
	connor_flipped = love.graphics.newImage("data/img/connor_flipped.png")
	connor_cry = love.graphics.newImage("data/img/connor_cry.png")
	connor_cry_width, connor_cry_height = connor_cry:getDimensions( )

	frames[1] = love.graphics.newQuad(0,0,64,64,connor:getDimensions())
	frames[2] = love.graphics.newQuad(64,0,64,64,connor:getDimensions())
	frames[3] = love.graphics.newQuad(0,64,64,64,connor:getDimensions())
	frames[4] = love.graphics.newQuad(64,64,64,64,connor:getDimensions())


	frames[1] = love.graphics.newQuad(0,0,64,64,connor_flipped:getDimensions())
	frames[2] = love.graphics.newQuad(64,0,64,64,connor_flipped:getDimensions())
	frames[3] = love.graphics.newQuad(0,64,64,64,connor_flipped:getDimensions())
	frames[4] = love.graphics.newQuad(64,64,64,64,connor_flipped:getDimensions())

	frames[1] = love.graphics.newQuad(0,0,64,64,connor_dead:getDimensions())
	frames[2] = love.graphics.newQuad(64,0,64,64,connor_dead:getDimensions())
	frames[3] = love.graphics.newQuad(0,64,64,64,connor_dead:getDimensions())
	frames[4] = love.graphics.newQuad(64,64,64,64,connor_dead:getDimensions())

	frames_cry[1] = love.graphics.newQuad(0,0,64,64,connor_cry:getDimensions())
	frames_cry[2] = love.graphics.newQuad(64,0,64,64,connor_cry:getDimensions())
	frames_cry[3] = love.graphics.newQuad(0,64,64,64,connor_cry:getDimensions())
	frames_cry[4] = love.graphics.newQuad(64,64,64,64,connor_cry:getDimensions())

	activeFrame = frames[currentFrame]
	activeFrame_cry = frames_cry[currentFrame_cry]
end

function love.update(dt)
	update()
	elapsedTime = elapsedTime + dt
	elapsedTime_cry = elapsedTime_cry + dt

	if(elapsedTime > 0.1) and not pause then
		if(currentFrame < 4) then
			currentFrame = currentFrame + 1
		else
			currentFrame = 1
		end
		activeFrame = frames[currentFrame]
		elapsedTime = 0
	end

	if(elapsedTime_cry > 0.3) and not pause then
		if(currentFrame_cry < 4) then
			currentFrame_cry = currentFrame_cry + 1
		else
			currentFrame_cry = 1
		end
		activeFrame_cry = frames_cry[currentFrame_cry]
		elapsedTime_cry = 0
	end

	if love.keyboard.isDown('p') and not pause and not lose then
		pause = true
		elseif love.keyboard.isDown('space') and pause then
			pause = false
		end

		speed = speed + 0.01
		line_1 = HEIGHT / 2 - line_seperation
		line_2 = HEIGHT / 2 + line_seperation

		if not pause and not lose then
			time = time + love.timer.getDelta()
			score = math.floor(time * 4)
		end

	--Block logic
	if not pause and not lose then
		if spawn then
			local size = 50 + love.math.random() * 70 + line_seperation / 10
			local side_picker = love.math.random() 

			if side_picker <= 0.49 then 
				blocks:new(WIDTH, line_1, size, {0, 255, 0})
			else 
				blocks:new(WIDTH, line_2 - size, size, {0, 255, 0})
			end
			if delay > 20 then delay = delay - 0.5 else 
				delay = 40
				line_change = true
				if player.lives < 3 then 
					cracker_1_scale = 0
					cracker_2_scale = 0
					cracker_3_scale = 0
					player.lives = player.lives + 1
				end
			end
		end

		spawn = false
		iter = iter + 1
		if iter > delay and spawn == false then
			spawn = true
			iter = 0
		end

		if line_change then
			line_seperation = math.floor(100 + love.math.random() * 150)
			line_change = false
		end

		--Block removal
		for i = 1, #blocks do
			blocks[i].x = blocks[i].x - speed
		end

		if blocks[1] ~= nil then
			if blocks[1].x < 0 - blocks[1].size then
				table.remove(blocks, 1)
			end
		end
	end


	--Player position Logic
	if not pause and not lose then
		if (love.keyboard.isDown("space") or click) and player.y > line_1 then
			sprite_flipped = true
			player.y = player.y - 15
		end
		if (love.keyboard.isDown("space") or click) and player.y < line_1 then
			player.y = line_1
		end
		if (not love.keyboard.isDown("space") and not click) and player.y + player.size < line_2 then
			sprite_flipped = false
			player.y = player.y + 15
		end
		if (not love.keyboard.isDown("space") and not click) and player.y + player.size > line_2 then
			player.y = line_2 - player.size
		end
	end

	--Lose state
	for i = #blocks, 1, -1 do
		if player.x + player.size > blocks[i].x and player.x < blocks[i].x + blocks[i].size and player.y + player.size > blocks[i].y and player.y < blocks[i].y + blocks[i].size then
			block_hit = true
			block_hit_index = i

			if not lose then 
				player.lives = player.lives - 1
				love.system.vibrate(0.2)
				cracker_1_scale = 0
				cracker_2_scale = 0
				cracker_3_scale = 0

				if player.lives > 0 then table.remove(blocks, i) end
			end

			if player.lives <= 0 then lose = true end
		end
	end

	if OS ~= "Android" then
		if lose and score > tonumber(highscore) then
			f:open("w")
			f:write(score)
			f:close()
		end
	end
end


function love.draw()
	love.graphics.setColor(0, 0, 0)
	title("The Connor Chronicles")

	if OS == "Android" then
		info("Tap to switch side")
	else
		info2("Hold 'Space' to change side")
		info3("Lives left: " .. player.lives)
		if not pause then info("'P'ause") else info("'Space' to resume") end
	end

	if not lose then
		love.graphics.setColor(255, 255, 255)
		
		if player.lives > 0 then 
			love.graphics.draw(cracker_1, player.x - 20, line_1 - 100 - math.sin(iterrator), cracker_1_scale, cracker_1_scale)
			if cracker_1_scale < 1 then
				cracker_1_scale = cracker_1_scale + 0.1 
			else
				cracker_1_scale = 1
			end
		end
		if player.lives > 1 then 
			love.graphics.draw(cracker_2, player.x + 30, line_1 - 100 - math.sin(iterrator), cracker_2_scale, cracker_2_scale)
			if cracker_2_scale < 1 then
				cracker_2_scale = cracker_2_scale + 0.1 
			else
				cracker_2_scale = 1
			end
		end
		if player.lives > 2 then 
			love.graphics.draw(cracker_3, player.x + 80, line_1 - 100 - math.sin(iterrator), cracker_3_scale, cracker_3_scale)
			if cracker_3_scale < 1 then
				cracker_3_scale = cracker_3_scale + 0.1 
			else
				cracker_3_scale = 1
			end
		end

		if not sprite_flipped then
			love.graphics.draw(connor, activeFrame,
				player.x - (select(3,activeFrame:getViewport())/2 - 25),
				player.y - (select(4,activeFrame:getViewport())/2 - 20), 0, 1, 1)
		else
			love.graphics.draw(connor_flipped,activeFrame,
				player.x - (select(3,activeFrame:getViewport())/2 - 25),
				player.y - (select(4,activeFrame:getViewport())/2 - 30), 0, 1, 1)
		end
	end

	if lose then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(connor_dead,activeFrame,
			player.x - (select(3,activeFrame:getViewport())/2 - 13),
			player.y - (select(4,activeFrame:getViewport())/2 - 20), 0, 1, 1)

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(connor_cry,activeFrame_cry,
			WIDTH - connor_cry_width * 2 - 30 - (select(3,activeFrame_cry:getViewport())/2),
			HEIGHT - connor_cry_height * 2 + 50 - (select(4,activeFrame_cry:getViewport())/2), 0, 4, 4)
	end

	--HUD
	if not pause and not lose then
		love.graphics.setColor(level_color)
		love.graphics.print(score, 100, 100)
		love.graphics.setLineWidth(3)
		love.graphics.line(0, line_1, WIDTH, line_1)
		love.graphics.line(0, line_2, WIDTH, line_2)
		love.graphics.setLineWidth(1)

		--Player
		love.graphics.setLineWidth(3)
		love.graphics.setColor(player.color)
		love.graphics.rectangle("line", player.x, player.y, player.size, player.size)
		love.graphics.setLineWidth(1)

		--Blocks
		for i = 1, #blocks do
			love.graphics.setColor(level_color)
			love.graphics.rectangle("fill", blocks[i].x, blocks[i].y, blocks[i].size, blocks[i].size)
		end
	end
	if pause then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("PAUSE", WIDTH / 2, HEIGHT / 2)
		love.graphics.print("Score: " .. score .. " | High score: " .. highscore, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
		love.graphics.print("'C'lear", WIDTH / 2, HEIGHT / 2  + 200, 0, 1.3, 1.3)
		love.graphics.print("'P'ause?", WIDTH / 2, HEIGHT / 2  + 250, 0, 1.3, 1.3)
		love.graphics.print("'Q'uit?", WIDTH / 2, HEIGHT / 2 + 300, 0, 1.3, 1.3)
	end
	if lose then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(quote(), WIDTH / 2, HEIGHT / 2)
		
		if OS == "Android" then
			love.graphics.print("Tap to restart", WIDTH / 2, HEIGHT / 2 + 200, 0, 1.3, 1.3)
			love.graphics.print("Score: " .. score, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
		else
			love.graphics.print("Score: " .. score .. " | High score: " .. highscore, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
			love.graphics.print("'R'estart?", WIDTH / 2, HEIGHT / 2 + 200, 0, 1.3, 1.3)
			love.graphics.print("'Q'uit?", WIDTH / 2, HEIGHT / 2 + 250, 0, 1.3, 1.3)
		end


		if block_hit then
			for i = 1, #blocks do
				love.graphics.setColor(200, 0, 0)
				love.graphics.rectangle("line", blocks[block_hit_index].x, blocks[block_hit_index].y, blocks[block_hit_index].size, blocks[block_hit_index].size)
			end
		end
		love.graphics.setColor(0, 200, 0)
	end
end


function quote()
	quotes = {
	"CONtinue?",
	"You CONked out",
	"CONtrole your timing!",
	"You've been disCONtinued",
	"DeCONstructed",
	"UnCONtrolable",
	"OverCONfident?",
	"InCONceivably high score",
	"CONsiderable effort",
	"InCONsistent score",
	"You're unCONscious, try again?",
	"CONfused?",
	"CONgratulations!",
	"New CONtender?",
	"My CONdolences",
	"CONtent with that score?",
	"iCONic!",
	"Have you tried turning it off and on again?",
	"I can't eat that.",
	"Could you stir this for me?",
	"Mini metro?",
	"As far as insects go I think ants are very attractive",
	"Papers please",
	"I actually like the taste of vodka",
	"Would you like a seaweed cracker?",
	"I could take a look at that for you",
	"Watch out for the honey pot",
	"They found a rat in the deep fryer at work"
}

if new_quote then
	selected_quote = quotes[love.math.random(1, #quotes)]
	new_quote = false
end
return selected_quote
end

function love.keypressed(key)
	if key == 'q' then
		love.event.quit()
	end

	if (key == "space") and lose then
		love.load()
	end

	if key == "escape" then
		love.event.quit()
	end
	
	if key == 'r' then
		love.load()
	end

	if key == 'l' then
		lose = true
	end

	if key == 'c' then
		f:open("w")
		f:write(1)
		f:close()
	end

end

function love.mousepressed(x, y, button)
	if button == 1 then
		click = true
		if lose then love.load() end
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		click = false
	end
end