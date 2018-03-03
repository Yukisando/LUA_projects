function love.conf(t)
	t.window = nil
end

function start()
	love.window.setTitle("The Connor Chronicles")
	love.mouse.setVisible(false)
	OS = love.system.getOS()
	if OS == "Android" or OS == "iOS" then
		love.window.setMode(1280, 720, {fullscreen = true, fullscreentype = "exclusive", msaa = 4, highdpi = true})
	else
		love.window.setMode(1920, 1080, {fullscreen = true, fullscreentype = "desktop", msaa = 8, display = 1, highdpi = true})
	end
	love.graphics.setBackgroundColor(230, 230, 230)
	comfortana = love.graphics.newFont("data/fonts/comfortana.ttf", 40)
	comfortana_t = love.graphics.newFont("data/fonts/comfortana.ttf", 100)
	wrap_limit = 1000
	love.graphics.setFont(comfortana)

	HEIGHT = love.graphics.getHeight()
	WIDTH = love.graphics.getWidth()
	W_MID = WIDTH / 2
	H_MID = HEIGHT / 2
	random_color = love.math.random() * 200
	MOUSE_PRESSED = 0
	iterrator = 0.0
end

function update()
	MOUSE_X = love.mouse.getX()
	MOUSE_Y = love.mouse.getY()
	MOUSE_PRESS = love.mouse.isDown(1)
	random_color =  love.math.random() * 200
	iterrator = iterrator + 0.5

	if MOUSE_PRESS and MOUSE_PRESSED == 0 then
		MOUSE_PRESSED = 1
		elseif MOUSE_PRESS and MOUSE_PRESSED >= 1 then
			MOUSE_PRESSED = 2
			elseif not MOUSE_PRESS then
				MOUSE_PRESSED = 0
			end
		end


function reset()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(comfortana)
end

function title(title)
	love.graphics.setFont(comfortana_t)
	love.graphics.printf(title, WIDTH / 2 - wrap_limit / 2, 50, wrap_limit, "center")
	love.graphics.setFont(comfortana)
end

function button(text, x, y, width, height, color)
	love.graphics.setColor(color)
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(text, x + 20, y + 20)
end

function info(info)
	love.graphics.print(info, 10, HEIGHT - 50)
end

function info2(info)
	love.graphics.print(info, 10, HEIGHT - 100)
end

function info3(info)
	love.graphics.print(info, 10, HEIGHT - 150)
end

function collision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1
end

function grid(bool)
	if bool then
		love.graphics.line(WIDTH / 2, 0, WIDTH / 2, HEIGHT)
		love.graphics.line(0, HEIGHT / 2, WIDTH, HEIGHT / 2)
	end
end