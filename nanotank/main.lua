function love.load()
	start()

	platform = {}
	bob = {}
	steve = {}
	cannon = {}
	shell = {}

	gravity = -400
	player_collision = false
	turn = "bob"

	platform.width = width
	platform.height = height
	platform.x = 0
	platform.y = platform.height -300

	bob_hit = false
	bob.alive = true
	bob.size = 30
	bob.x = platform.x + 300
	bob.y = platform.y - bob.size - 500
	bob.color = {255, 100, 255}
	bob.speed = 500
	bob.ground = platform.y - bob.size
	bob.velocity = 0
	bob.jump_height = -500

	steve_hit = false
	steve.alive = true
	steve.size = 30
	steve.x = platform.width - 300
	steve.y = platform.y - steve.size - 500
	steve.color = {255, 255, 100}
	steve.speed = 500
	steve.ground = platform.y - steve.size
	steve.velocity = 0
	steve.jump_height = -500

	cannon.size = 40
	cannon.angle = 0
	cannon.x = bob.x + bob.size / 2
	cannon.y = bob.y + bob.size / 2
	cannon.x2 = (bob.x + bob.size / 2) - cannon.size
	cannon.y2 = (bob.y + bob.size / 2) - cannon.size

	if turn == "bob" then
		x = bob.x + bob.size
		y = bob.y + bob.size / 2
		color = bob.color
	else
		x = steve.x + steve.size
		y = steve.y + steve.size / 2
		color = steve.color
	end

	iter = 0.1
end

function love.update(dt)
	delta = dt
	inputs()
	--iter = iter + 0.1
	--platform.y = platform.y + 1 * math.cos(iter)

	--Collision detection
	player_collision = collision(bob.x, bob.y, bob.size, bob.size, steve.x, steve.y, steve.size, steve.size)

	bob_hit = collision(shell.x, shell.y, shell.size, shell.size, bob.x, bob.y, bob.size, bob.size)
	steve_hit = collision(shell.x, shell.y, shell.size, shell.size, steve.x, steve.y, steve.size, steve.size)

	if bob_hit and turn == "steve" then bob.alive = false end
	if steve_hit and turn == "bob" then steve.alive = false end

	if not (bob_hit or steve_hit) and turn == "steve" and (shell.x < 0 or shell.y > platform.y or shell.x > platform.width) then
		turn = "bob"
	elseif not (bob_hit or steve_hit) and turn == "bob" and (shell.x < 0 or shell.y > platform.y or shell.x > platform.width) then
		turn = "steve"
	end


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

   	--Cannon
   	if turn == "bob" then
   	cannon.x = bob.x + bob.size / 2
   	cannon.y = bob.y + bob.size / 2
   	cannon.x2 = (bob.x + bob.size / 2) - cannon.size * math.cos(cannon.angle)
   	cannon.y2 = (bob.y + bob.size / 2) - cannon.size * math.sin(cannon.angle)
   	else
   	cannon.x = steve.x + steve.size / 2
   	cannon.y = steve.y + steve.size / 2
   	cannon.x2 = (steve.x + steve.size / 2) - cannon.size * math.cos(cannon.angle)
   	cannon.y2 = (steve.y + steve.size / 2) - cannon.size * math.sin(cannon.angle)
   	end

   	if bob.y + bob.size > platform.y then bob.y = platform.y - bob.size end
   	if bob.y + bob.size < platform.y then bob.y = bob.y + gravity * delta end
   	if steve.y + steve.size > platform.y then steve.y = platform.y - steve.size end
   	if steve.y + steve.size < platform.y then steve.y = steve.y + gravity * delta end
end

function inputs()
	--Player turn
	if love.keyboard.isDown('b') then
		turn = "bob"
	elseif love.keyboard.isDown('s') then
		turn = "steve"
	end

	--Bounds
	if bob.x + bob.size > platform.width then bob.x = platform.width - bob.size end
	if bob.x < platform.x then bob.x = platform.x end
	if steve.x + steve.size > platform.width then steve.x = platform.width - steve.size end
	if steve.x < platform.x then steve.x = platform.x end

	--Player movements
	if not player_collision and not shell.shot then
		if love.keyboard.isDown('right') then
			if turn == "steve" then
				steve.x = steve.x + (steve.speed * delta)	
			else 
				bob.x = bob.x + (bob.speed * delta)
			end
		elseif love.keyboard.isDown('left') then
			if turn == "steve" then 
				steve.x = steve.x - (steve.speed * delta)
			else 
				bob.x = bob.x - (bob.speed * delta)
			end
		end

		if love.keyboard.isDown('ralt') then
			if turn == "steve" then
				if steve.velocity == 0 then
					steve.velocity = steve.jump_height
				end
			else
				if bob.velocity == 0 then
					bob.velocity = bob.jump_height
				end
			end
		end

		if bob.y > bob.ground then
			bob.velocity = 0   
			bob.y = bob.ground
		end

		if bob.velocity ~= 0 or bob.y + bob.size < platform.y then                                  
			bob.y = bob.y + bob.velocity * delta            
			bob.velocity = bob.velocity - gravity * delta
		end

		if steve.velocity ~= 0 or steve.y + steve.size < platform.y then                                  
			steve.y = steve.y + steve.velocity * delta            
			steve.velocity = steve.velocity - gravity * delta
		end
		if steve.y > steve.ground then
			steve.velocity = 0   
			steve.y = steve.ground
		end
	end

	if cannon.angle >= 0 and cannon.angle <= math.pi then
		if love.keyboard.isDown('up') and not shell.shot then 
			cannon.angle = math.fmod(cannon.angle + math.pi / 100, 2 * math.pi)
		end
		if love.keyboard.isDown('down') and not shell.shot then
			cannon.angle = math.fmod(cannon.angle - math.pi / 100, 2 * math.pi)
		end
	end
	if cannon.angle < 0 then
		cannon.angle = 0
	elseif cannon.angle > math.pi then
		cannon.angle = math.pi
	end

	if not shell.shot then
		shell.speed = cannon.size / 3
		shell.size = 15
		shell.velocity = 0
		shell.x = cannon.x - shell.size / 2
		shell.y = cannon.y - shell.size / 2
		if turn == "steve" then
			shell.color = steve.color
		else
			shell.color = bob.color
		end

	end

	if love.keyboard.isDown('space') then
		shell.shot = true
	end
	if shell.shot and shell.x > platform.x and shell.x < platform.width and shell.y < platform.y - shell.size then
		shell.x = shell.x - shell.speed * math.cos(cannon.angle)
		shell.y = shell.y - shell.speed * math.sin(cannon.angle)
	else 
		shell.shot = false
		shell.speed = 20
		shell.size = 20
		shell.x = cannon.x - shell.size / 2
		shell.y = cannon.y - shell.size / 2
		shell.color = {255, 50, 50}
	end

	if shell.velocity ~= 0 or shell.y + shell.size < platform.y then                                  
		shell.y = shell.y + shell.velocity * delta            
		shell.velocity = shell.velocity - gravity * delta
	end

end

function love.draw()
	--Platform
	reset()
	love.graphics.line(0, platform.y, width, platform.y)
	love.graphics.setColor(100, 155, 155, 100)
	love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

	--Bob
	love.graphics.setColor(bob.color)
	if bob.alive then love.graphics.rectangle("fill", bob.x, bob.y, bob.size, bob.size)
		else love.graphics.rectangle("line", bob.x, bob.y, bob.size, bob.size) end
	if bob.y > 0 then
		love.graphics.printf("Bob", bob.x + bob.size / 2 - wrap_limit / 2, platform.y + 50, wrap_limit, "center")
	end
	reset()

	--Steve
	love.graphics.setColor(steve.color)
	if steve.alive then love.graphics.rectangle("fill", steve.x, steve.y, steve.size, steve.size)
		else love.graphics.rectangle("line", steve.x, steve.y, steve.size, steve.size) end

	if steve.y > 0 then
		if steve.x > bob.x - 100 and steve.x < bob.x + bob.size + 100 then
			love.graphics.printf("Steve", steve.x + steve.size / 2 - wrap_limit / 2, platform.y + 85, wrap_limit, "center")
		else
			love.graphics.printf("Steve", steve.x + steve.size / 2 - wrap_limit / 2, platform.y + 50, wrap_limit, "center")
		end
	end
	reset()

	--Cannon
	love.graphics.setLineWidth(cannon.size / 4)
	love.graphics.line(cannon.x, cannon.y, cannon.x2, cannon.y2)
	reset()

	--shell
	if shell.shot then
		love.graphics.setColor(shell.color)
		love.graphics.rectangle("fill", shell.x, shell.y, shell.size, shell.size)
		reset()
	end

	--HUD
	fps()
	if bob.alive == false then
		title("Steve wins!")
	elseif steve.alive == false then
		title("Bob wins!")
	else
		title(turn .. "'s turn")
	end
	love.graphics.setColor(30, 30, 30)
	love.graphics.print("Controls: Left, Right, Up, Down, alt, ctrl, Spacebar", 0, height - 50)
end