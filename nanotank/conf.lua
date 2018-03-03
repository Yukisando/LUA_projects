function love.conf(t)
		t.window = nil
end

function start()
	OS = love.system.getOS()
	if OS == "Android" or OS == "iOS" then
		love.window.setMode(1280, 720, {fullscreen = true, fullscreentype = "exclusive", msaa = 4, highdpi = true})
	else
		love.window.setMode(1920, 1080, {fullscreen = true, fullscreentype = "desktop", msaa = 8, display = 1, highdpi = true})
	end
	love.graphics.setBackgroundColor(30, 30, 30)
	comfortana = love.graphics.newFont("data/fonts/comfortana.ttf", 40)
	comfortana_t = love.graphics.newFont("data/fonts/comfortana.ttf", 80)
	wrap_limit = 1000
	love.graphics.setFont(comfortana)
	love.mouse.setVisible(false)

	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
	mid_h = width / 2
	mid_v = height / 2
end

function collision(x1,y1,w1,h1, x2,y2,w2,h2)
  	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

function fps()
	love.graphics.print(love.timer.getFPS(), width - 40, 0, 0, 0.8, 0.8)
end

function reset()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(1)
	love.graphics.setFont(comfortana)
end

function title(title)
	love.graphics.setFont(comfortana_t)
	love.graphics.setColor(100, 155, 155, 200)
	love.graphics.printf(title, width / 2 - wrap_limit / 2, 200, wrap_limit, "center")
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(comfortana)
end

function info(info)
	love.graphics.setColor(100, 155, 155, 200)
	love.graphics.print(info, 0, 0)
	love.graphics.setColor(255, 255, 255)
end
	
function info2(info)
	love.graphics.setColor(100, 155, 155, 200)
	love.graphics.print(info, 0, 50)
	love.graphics.setColor(255, 255, 255)
end
	
function info3(info)
	love.graphics.setColor(100, 155, 155, 200)
	love.graphics.print(info, 0, 100)
	love.graphics.setColor(255, 255, 255)
end
	

function shoot()
	if love.keyboard.isDown('space') then
		if not space_pressed then
			space_pressed = true
			return true
		end
	else
		space_pressed = false
		return false
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	if key == 'r' then
		love.load()
	end
end