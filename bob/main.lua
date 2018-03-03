function love.load()
	start()
	stage = 1
	current_level = 1

	platform = {}
	gate = {}
	steve = {}
	bob = {}
	bullets = {}

	function bullets:new(x, y, size, speed, color)
		local size = 10
		local speed = 20
		local x = bob.x + bob.size
		local y = bob.y + bob.size / 2
		local color = bob.color
		local new_bullet = {x = x, y = y, size = size, speed = speed, color = color}
		table.insert(bullets, new_bullet)
	end

	platform.width = width
	platform.height = height
	platform.x = 0
	platform.y = platform.height -300

	gravity = -1000
	player_collision = false
	gate.color = {255, 0, 0, 150}
	gate.x = platform.width - 5
	gate.open = false

	steve.there = true
	steve.size = 70
	steve.x = mid_h + 300
	steve.y = platform.y - steve.size - 10000
	steve.color = {255, 255, 100}
	steve.speed = 500
	steve.ground = platform.y - steve.size
	steve.velocity = 0
	steve.jump_height = -500

	bob.size = 50
	bob.x = mid_h
	bob.y = platform.y - bob.size -100
	bob.color = {255, 100, 255}
	bob.speed = 500
	bob.ground = platform.y - bob.size
	bob.velocity = 0
	bob.jump_height = -500
end

function love.update(dt)
	delta = dt
	if stage == 1 then current_level = 1 else current_level = stage - 1 end
	inputs()

	--Collision detection
	if steve.there then player_collision = collision(bob.x, bob.y, bob.size, bob.size, steve.x, steve.y, steve.size, steve.size) 
		else player_collision = false end

	if player_collision then
		if steve.size > bob.size then
			if bob.x + bob.size / 2 < steve.x + bob.size / 2 then
				bob.x = bob.x - 5
			else
				bob.x = bob.x + 5
			end
		else
			if steve.x + steve.size / 2 < bob.x + steve.size / 2 then
				steve.x = steve.x - 5
			else
				steve.x = steve.x + 5
			end
		end
	end

   	--GAME
   	--stage one "Help from a friend"
   	if stage == 1 and (bob.x  + bob.size < platform.x or bob.x > platform.width) then stage = 2 end

   	--Transition
   	if stage == 2 then
		steve.there = false
		bob.x = mid_h
		stage = 3
	end

	--stage two "Thanks Steve"
	if stage == 3 then
		if gate.color[1] > 5 and gate.color[2] < 250 and gate.open == false then
			if gate.color[1] < 255 then
				gate.color[1] = gate.color[1] + 15
				if gate.color[1] > 255 then gate.color[2] = 255 end
			end
			if gate.color[2] > 0 then
				gate.color[2] = gate.color[2] - 15
				if gate.color[2] < 0 then gate.color[2] = 0 end
			end

			for i = #bullets, 1, -1 do
				if bullets[i].x > gate.x and bullets[i].x < gate.x then
					table.remove(bullets, i)
					gate.y = gate.y - 5
					gate.color[1] = gate.color[1] - 20
					gate.color[2] = gate.color[2] + 20
				end
			end
		else
			gate.open = true
		end

		--Transition
		if bob.x > platform.width and gate.open then stage = 4 end

		--state three "Hidden in plane sight"
		if stage == 4 then
			steve.here = false
			bob.x = mid_h
			stage = 5
		end
	end
end

function inputs()
	--Skip stage
	if skip('backspace') then stage = stage + 1 end

	--Bob movements
	if current_level ~= 1 and bob.x + bob.size > platform.width then bob.x = platform.width - bob.size end
	if bob.x < platform.x then bob.x = platform.x end

	if not player_collision then
		if love.keyboard.isDown('d') then
			if current_level == 1 then 
				if bob.x + bob.size < platform.width then
					bob.x = bob.x + (bob.speed * delta)
				end
			else
				bob.x = bob.x + (bob.speed * delta)
			end
		end

		if love.keyboard.isDown('a') then
			bob.x = bob.x - (bob.speed * delta)
		end
		if love.keyboard.isDown('w') then
			if bob.velocity == 0 then
				bob.velocity = bob.jump_height
			end
		end
		if love.keyboard.isDown('up') then
			if bob.velocity == 0 then
				bob.velocity = bob.jump_height
			end
		end
	end

	if bob.velocity ~= 0 or bob.y + bob.size < platform.y then                                  
		bob.y = bob.y + bob.velocity * delta            
		bob.velocity = bob.velocity - gravity * delta
	end
	    
	if bob.y > bob.ground then
		bob.velocity = 0   
	 	bob.y = bob.ground
	end


	--Steve movements
	if steve.there then
		if not player_collision then
			if love.keyboard.isDown('right') then
				if steve.x < (width - steve.size) then
					steve.x = steve.x + (steve.speed * delta)
				end
			elseif love.keyboard.isDown('left') then
				if steve.x > 0 then 
					steve.x = steve.x - (steve.speed * delta)
				end
			end
			if love.keyboard.isDown('up') then
				if steve.velocity == 0 then
					steve.velocity = steve.jump_height
				end
			end
		end	
	end

    if steve.velocity ~= 0 or steve.y + steve.size < platform.y then                                  
		steve.y = steve.y + steve.velocity * delta            
		steve.velocity = steve.velocity - gravity * delta
	end
    
    if steve.y > steve.ground then
		steve.velocity = 0   
   		steve.y = steve.ground
   	end

	--Bullets
	if shoot('space') then bullets:new() end
	if bullets ~= nil then
		for i = 1, #bullets do
			bullets[i].x = bullets[i].x + bullets[i].speed
		end
	end
end

function love.draw()
	--Platform
	reset()
	love.graphics.line(0, platform.y, width, platform.y)
	love.graphics.setColor(100, 155, 155, 100)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

	--Steve
	if steve.there then
		love.graphics.setColor(steve.color)
		love.graphics.rectangle("fill", steve.x, steve.y, steve.size, steve.size)
		if steve.y > 0 then
			if steve.x > bob.x - 100 and steve.x < bob.x + bob.size + 100 then
				love.graphics.printf("Steve", steve.x + steve.size / 2 - wrap_limit / 2, platform.y + 85, wrap_limit, "center")
			else
				love.graphics.printf("Steve", steve.x + steve.size / 2 - wrap_limit / 2, platform.y + 50, wrap_limit, "center")
			end
		end
	end

	--Bob
	love.graphics.setColor(bob.color)
	love.graphics.rectangle("fill", bob.x, bob.y, bob.size, bob.size)
	if bob.y > 0 then
		love.graphics.printf("Bob", bob.x + bob.size / 2 - wrap_limit / 2, platform.y + 50, wrap_limit, "center")
	end

	--Levels
	if stage == 1 then
		love.graphics.setColor(100, 155, 155, 200)
		love.graphics.print("Sometimes, all you need to escape is a little help from a friend.")
		title("The great escape")
	end

	if stage == 3 then
		love.graphics.setColor(100, 155, 155, 200)
		love.graphics.print("Good guy Steve.")
		title("The Doppler effect")

		--Bullets
		for i = 1, #bullets do
			love.graphics.setColor(bullets[i].color)
			love.graphics.circle("fill", bullets[i].x, bullets[i].y, bullets[i].size)
			reset()
		end

		--Walls
		love.graphics.rectangle("fill", 0, platform.y - 200, 5, 200)
		love.graphics.setColor(gate.color)
		if  gate.open then
			love.graphics.rectangle("fill", gate.x, platform.y - 400, 5, 200)
		else
			love.graphics.rectangle("fill", gate.x, platform.y - 200, 5, 200)
		end
		reset()
	end

	if stage == 4 then
		love.graphics.setColor(100, 155, 155, 200)
		love.graphics.print("Smart!")
		title("Hidden in plane sight")
	end

	--HUD
	fps()
	love.graphics.setColor(30, 30, 30)
	love.graphics.print("Level: " .. current_level, 0, height - 100)
	love.graphics.print("Controls: WASD, Space", 0, height - 50)
end