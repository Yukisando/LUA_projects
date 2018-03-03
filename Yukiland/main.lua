function love.load()
	start()

	UI = {}
	UI.y = HEIGHT - 100
	items = {}

	function items:new()
		local item = {}
		item.size = 50
		item.color = {random_color, random_color, random_color}
		item.hover = false
		item.grabbed = false
		item.x = 20
		item.y = UI.y + 20
		local newItem = item
		table.insert(items, newItem)
	end

	items:new()


	hand = {}
	hand.size = 10
	hand.color = {230, 50, 50}
	hand.x = MOUSE_X
	hand.y = MOUSE_Y
end

function love.update()
	update()
	hand.x = MOUSE_X
	hand.y = MOUSE_Y
	
	--Hand
	if MOUSE_PRESS then hand.size = 10 else hand.size = 10 * math.sin(iterrator) end
	if MOUSE_PRESSED == 1 and MOUSE_Y > UI.y then items:new() end

	--Pickup item
	for i = 1, #items do
		items[i].hover = collision(hand.x, hand.y, hand.size, hand.size, items[i].x, items[i].y, items[i].size, items[i].size)
		on_UI = MOUSE_Y > UI.y
		items[i].color[4] = 200
		items[i].color[3] = 200

		if items[i].hover then
			items[i].color[4] = 255
		end

		if not MOUSE_PRESS and items[i].grabbed and on_UI then
			items[i].x = 20
			items[i].y = UI.y + 20
			items[i].grabbed = false
		end
		if MOUSE_PRESS and items[i].hover then items[i].grabbed = true end
		if not MOUSE_PRESS and items[i].grabbed then items[i].grabbed = false end

		if items[i].grabbed then
			items[i].color[4] = 100
			items[i].x = hand.x - items[i].size / 2
			items[i].y = hand.y - items[i].size / 2
		end
	end
end

function love.draw()
	--Pickup items
	for i = 1, #items do
		love.graphics.setColor(items[i].color)
		love.graphics.rectangle("fill", items[i].x, items[i].y, items[i].size, items[i].size)
		reset()
	end

	--UI
	love.graphics.setLineWidth(3)
	love.graphics.setColor(100, 100, 100)
	love.graphics.line(0, UI.y, WIDTH, UI.y)
	reset()

	--Hand
	love.graphics.setColor(hand.color)
	love.graphics.setLineWidth(5)
	love.graphics.circle("line", hand.x, hand.y, hand.size, 100)
	reset()
end