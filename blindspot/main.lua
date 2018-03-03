function love.load()
	start()

	boom_radius = 0
end

function love.update(dt)
	update()

end


function love.draw()
	info1("Click to blink")
	grid(true)

	--Cursor:
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.circle("fill", MOUSE_X, MOUSE_Y, 5)
	reset()

	--Boom
	if MOUSE_PRESSED == 2 or MOUSE_PRESSED == 1 then
		if boom_radius < 50 then
			boom_radius = iterrator * 15
		end

		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.circle("line", MOUSE_X, MOUSE_Y, boom_radius)
	else
		boom_radius = 0
		iterrator = 0
	end
	reset()

end