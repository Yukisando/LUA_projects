function love.load()
	start()

	pause = false
	lose = false
	block_hit = false
	block_hit_index = 0

	platform = HEIGHT / 2
	gravity = -4000
	time = 0
	speed = 20
	iter = 0
	iter_speed = 0
	spawn = false

	--Player
	player = {	
	size = 50,
	lives = 1,
	x = 200,
	y = platform - 50,
	color = {0, 255, 0, 200},
	speed = 2000,
	ground = platform - 50,
	velocity = 0,
	jump_height = -700
}

	--Blocks
	blocks = {}
	function blocks:new(x, y, size_x, size_y, color)
		local size_x = size_x
		local size_y = size_y
		local x = x
		local y = y
		local color = color
		local new_block = {x = x, y = y, size_x = size_x, size_y = size_y, color = color}
		table.insert(blocks, new_block)
	end
	
	--Begin
	score = 0
	level_color = {0, 250, 0, 200}
end

function love.update(dt)
	update()

	if love.keyboard.isDown('p') and not pause and not lose then
		pause = true
		elseif love.keyboard.isDown('space') and pause then
			pause = false
		end

		if not pause and not lose then
			time = time + love.timer.getDelta()
			score = math.floor(time * 4)
		end

	--Block logic
	if not pause and not lose then
		if spawn then
			local size_x = 40
			local size_y = 80
			blocks:new(WIDTH, platform - size_y, size_x, size_y, {0, 255, 0})
			spawn = false
		end

		spawn = false
		iter = iter + 1
		iter_speed = iter_speed + 0.01
		if iter > 40 + love.math.random(150) - iter_speed and spawn == false then
			spawn = true
			iter = 0
		end

		--Block removal
		for i = 1, #blocks do
			blocks[i].x = blocks[i].x - speed
		end

		if blocks[1] ~= nil then
			if blocks[1].x < 0 - blocks[1].size_x then
				table.remove(blocks, 1)
			end
		end
	end

	if player.velocity ~= 0 or player.y + player.size < platform then                                  
		player.y = player.y + player.velocity * dt * 2         
		player.velocity = player.velocity - gravity * dt
	end

	if player.y > player.ground then
		player.velocity = 0   
	 	player.y = player.ground
	end

	--Player position Logic
	if not pause and not lose then
		if (love.keyboard.isDown("space") or click) then
			if player.velocity == 0 then
				player.velocity = player.jump_height
			end
		end
	end

	--Lose state
	for i = #blocks, 1, -1 do
		if player.x + player.size > blocks[i].x and player.x < blocks[i].x + blocks[i].size_x and player.y + player.size > blocks[i].y and player.y < blocks[i].y + blocks[i].size_y then
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
end


function love.draw()
	love.graphics.setColor(0, 255, 0)

	if OS == "Android" then
		info("Tap to switch side")
	else
		info2("Hold 'Space' to jump")
		if not pause then info("'P'ause") else info("'Space' to resume") end
	end

	--HUD
	if not pause and not lose then
		love.graphics.setColor(level_color)
		love.graphics.print(score, 100, 100)
		love.graphics.setLineWidth(3)
		love.graphics.line(0, platform, WIDTH, platform)
		love.graphics.setLineWidth(1)

		--Player
		love.graphics.setLineWidth(3)
		love.graphics.setColor(player.color)
		love.graphics.rectangle("line", player.x, player.y, player.size, player.size)
		love.graphics.setLineWidth(1)

		--Blocks
		for i = 1, #blocks do
			love.graphics.setColor(level_color)
			love.graphics.rectangle("fill", blocks[i].x, blocks[i].y, blocks[i].size_x, blocks[i].size_y)
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
		love.graphics.print("Woops!", WIDTH / 2, HEIGHT / 2)
		
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
				love.graphics.rectangle("line", blocks[block_hit_index].x, blocks[block_hit_index].y, blocks[block_hit_index].size_x, blocks[block_hit_index].size_y)
			end
		end
		love.graphics.setColor(0, 200, 0)
	end
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