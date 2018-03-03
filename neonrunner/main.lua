function love.load()
	start()

	line_seperation = 100
	line_1 = HEIGHT / 2 - line_seperation
	line_2 = HEIGHT / 2 + line_seperation

	-- f = love.filesystem.newFile("highscore.txt")
	pause = false
	lose = false
	block_hit = false
	block_hit_index = 0

	time = 0
	speed = 20
	iter = 0
	iter_block = 0
	delay = 20 + (love.math.random() * 15)
	spawn = false

	--Player
	player = {	size = 50,
	lives = 1,
	x = 200,
	y = line_2 - 50,
	color = {0, 255, 0, 200},
	speed = 20
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
	level_color = {0, 250, 0, 200}
	blocks:new(WIDTH, line_1, 60, {50, 255, 0})
	-- highscore = love.filesystem.read("highscore.txt")
	
	new_quote = true
	selected_quote = "RIP"
end

function love.update(dt)
	update()

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
			player.y = player.y - player.speed
		end
		if (love.keyboard.isDown("space") or click) and player.y < line_1 then
			player.y = line_1
		end
		if (not love.keyboard.isDown("space") and not click) and player.y + player.size < line_2 then
			player.y = player.y + player.speed
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
				love.system.vibrate(0.1)
				if player.lives > 0 then table.remove(blocks, i) end
			end

			if player.lives <= 0 then lose = true end
		end
	end

	-- if OS ~= "Android" then
	-- 	if lose and score > tonumber(highscore) then
	-- 		f:open("w")
	-- 		f:write(score)
	-- 		f:close()
	-- 	end
	-- end
end


function love.draw()
	love.graphics.setColor(0, 255, 0)
	title("NEON RUNNER")

	if OS == "Android" then
		info("Tap to switch side")
	else
		info2("Hold 'Space' to change side")
		-- info3("Lives left: " .. player.lives)
		if not pause then info("'P'ause") else info("'Space' to resume") end
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
		love.graphics.print("Score: " .. score, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
		love.graphics.print("'C'lear", WIDTH / 2, HEIGHT / 2  + 200, 0, 1.3, 1.3)
		love.graphics.print("'P'ause?", WIDTH / 2, HEIGHT / 2  + 250, 0, 1.3, 1.3)
		love.graphics.print("'Q'uit?", WIDTH / 2, HEIGHT / 2 + 300, 0, 1.3, 1.3)
	end
	if lose then
		love.graphics.rectangle("line", player.x, player.y, player.size, player.size)
		love.graphics.setColor(0, 250, 0)
		love.graphics.print(quote(), WIDTH / 2, HEIGHT / 2)
		
		if OS == "Android" then
			love.graphics.print("Tap to restart", WIDTH / 2, HEIGHT / 2 + 200, 0, 1.3, 1.3)
			love.graphics.print("Score: " .. score, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
		else
			love.graphics.print("Score: " .. score, WIDTH / 2, HEIGHT / 2 + 100, 0, 1.3, 1.3)
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
	"Sucks to be you I guess...",
	"Hahahaha",
	"Ouch!",
	"That has to hurt."
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