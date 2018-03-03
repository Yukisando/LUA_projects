require("input")
require("load")

function love.update(dt)
	previous_layer = current_canvas - 1
	previous_layer_2 = current_canvas - 2

	if previous_layer <= 0 then
		previous_layer = current_canvas
	end
	if previous_layer_2 <= 0 then
		previous_layer_2 = current_canvas
	end

	mouse_x = love.mouse.getX()
	mouse_y = love.mouse.getY()

	--On UI
	if mouse_released_1 and (mouse_x < UI_width or mouse_y > height - p_height - 12) or (menu and mouse_x < menu_width and mouse_y < menu_height) then
		on_UI = true
	else
		on_UI = false
	end

	--Loop
	if loop_speed >= 250 then
		loop_speed = 250
	end
	if loop_speed <= 5 then
		loop_speed = 5
	end

	if loop then
		eter = eter + 1
		if eter >= loop_speed then
			current_canvas = (current_canvas + 1)
			if current_canvas > #canvases then
				current_canvas = 1
			end
			eter = 0
		end
	end

	--Preview
	if on_UI and mouse_x > UI_width and mouse_y > height - p_height and mouse_pressed_1 and not mouse_released_1 then
		for i = 1, #canvases do
			if mouse_x > UI_width + p_width * (i - 1) and mouse_x < UI_width + p_width * i then
				current_canvas = i
			end
		end
	end
end

function love.draw()

	--Background
	if background == nil then
		love.graphics.setBackgroundColor(back_color, back_color, back_color)
	else
		for i = 0, love.graphics.getWidth() / background:getWidth() do
			for j = 0, love.graphics.getHeight() / background:getHeight() do
				love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
			end
		end
	end



 
	--Draws the selected canvas
	canvases[current_canvas]:renderTo( function()

		if clear then
	        love.graphics.clear() -- Clear the canvas before drawing lines.
	        clear = not clear
	    end

	    if copy then
	    	love.graphics.draw(canvases[current_canvas - 1])
	    	copy = false
	    end

	    --Draw
	    if mouse_pressed_1 and not on_UI then
	    	local x = mouse_x
	    	local y = mouse_y
	    	love.graphics.setColor(brush_red, brush_green, brush_blue)
	    	if brush == "circle" then
	    		love.graphics.circle(mode, mouse_x, mouse_y, brush_size)
	    	end
	    	if brush == "triangle" then
	    		love.graphics.polygon(mode, triangle_vertices)
	    	end
	    	if brush == "square" then
	    		love.graphics.rectangle(mode, mouse_x - brush_size / 2, mouse_y - brush_size / 2, brush_size, brush_size)
	    	end
	    	reset()
	    end

	    --Erase
	    if mouse_pressed_2 and not on_UI then
	    	local x = mouse_x
	    	local y = mouse_y
	    	love.graphics.setColor(back_color, back_color, back_color)
	    	if brush == "circle" then
	    		love.graphics.circle(mode, mouse_x, mouse_y, brush_size)
	    	end
	    	if brush == "triangle" then
	    		love.graphics.polygon(mode, triangle_vertices)
	    	end
	    	if brush == "square" then
	    		love.graphics.rectangle(mode, triangle_vertices)
	    	end
	    	love.graphics.setColor(255, 255, 255)
	    end
	end)
	love.graphics.draw(canvases[current_canvas])

	--Previews
	love.graphics.setLineWidth(4)
	love.graphics.setColor(30, 30, 30, 255)
	love.graphics.line(UI_width, height - p_height - 2, width, (height - p_height))
	reset()

	for i = 1, #canvases do
		local canvas_scale = 0.1

		if #canvases <= 10 then
			canvas_scale = 0.1
		else
			canvas_scale = 1 / #canvases
		end

		p_width = (canvases[i]:getWidth() - UI_width - 4) * canvas_scale
		p_height = canvases[i]:getHeight() * canvas_scale

      
		love.graphics.draw(canvases[i], UI_width + 2 + (i-1) * p_width, height - p_height - 2, 0, canvas_scale, canvas_scale)

		love.graphics.setLineWidth(4)
		love.graphics.setColor(30, 30, 30, 255)
		if i == current_canvas then
			love.graphics.setColor(200, 200, 200, 255)
		end

		love.graphics.rectangle("line", UI_width + 2 + (i-1) * p_width, height - p_height - 2, p_width, p_height)

		--Close box
		if i == current_canvas then
			close_x = UI_width + (i * p_width) - 12
			close_y = height - p_height + 12

			love.graphics.setColor(255, 00, 00)
			love.graphics.rectangle("line", close_x - 10, close_y - 10, 20, 20)

			if mouse_x > close_x - 10 and mouse_x < close_x + 10 and mouse_y < close_y and mouse_y > close_y + 20 and mouse_pressed_1 then
				back_color = 255
				if current_canvas == 1 then
					clear = not clear
				else
					canvases[current_canvas] = nil
					current_canvas = current_canvas - 1
				end
			end
		end
		reset()
	end

	--Draw previous layer
	love.graphics.setColor(255, 255, 255, 20)
	love.graphics.draw(canvases[previous_layer_2])
	love.graphics.setColor(255, 255, 255, 70)
	love.graphics.draw(canvases[previous_layer])
	reset()

	--On Canvas
	triangle_vertices = {mouse_x, mouse_y - brush_size, mouse_x - brush_size, mouse_y + brush_size, mouse_x + brush_size, mouse_y + brush_size}
	triangle_vertices_size = {width / 2, height / 2 - brush_size, width / 2 - brush_size,	height / 2 + brush_size, width / 2 + brush_size, height / 2 + brush_size}
	triangle_vertices_UI = {UI_width / 2, 10, UI_width / 10, icon_height - 10, UI_width - (UI_width / 10), icon_height - 10}
	triangle_vertices_menu_fill = {UI_width / 2 + icon_width, 10 + icon_height * 2, UI_width / 10 + icon_width, icon_height * 3, UI_width / 10 + icon_width + 70, icon_height * 3}
	triangle_vertices_menu_line = {UI_width / 2 + icon_width * 2, 10 + icon_height * 2, UI_width / 10 + icon_width * 2, icon_height * 3, UI_width / 10 + icon_width * 2 + 70, icon_height * 3}
	
	--UI bar
	if mouse_pressed_1 and on_UI then
		love.graphics.setColor(45, 45, 45, 255)
	else
		love.graphics.setColor(30, 30, 30, 255)
	end
	love.graphics.rectangle("fill", 0, 0, UI_width, height)
	reset()

	----Tools
	love.graphics.setColor(brush_red, brush_green, brush_blue)
	if brush == "circle" then
		love.graphics.circle(mode, UI_width / 2, icon_height / 2, icon_height * 0.4)
	end
	if brush == "triangle" then
		love.graphics.polygon(mode, triangle_vertices_UI)
	end
	if brush == "square" then
		love.graphics.rectangle(mode, UI_width / 4,  icon_height / 4, icon_height * 0.6, icon_height * 0.6)
	end
	reset()

	--Menu
	if menu then
		--Brushes
		love.graphics.setColor(30, 30, 30, 120)
		love.graphics.rectangle("fill", 0, 0, menu_width, menu_height)
		love.graphics.setColor(brush_red, brush_green, brush_blue)

		love.graphics.circle("fill", UI_width * 1 + UI_width / 2, (icon_height / 2), 30)
		love.graphics.circle("line", UI_width * 2 + UI_width / 2, (icon_height / 2), 30)
		love.graphics.rectangle("fill", UI_width * 1 + UI_width / 5, (icon_height / 4) + icon_height, 50, 50)
		love.graphics.rectangle("line", UI_width * 2 + UI_width / 5, (icon_height / 4) + icon_height, 50, 50)
		love.graphics.polygon("fill", triangle_vertices_menu_fill)
		love.graphics.polygon("line", triangle_vertices_menu_line)

		reset()

		--Brush size
		love.graphics.setLineWidth(4)
		love.graphics.setColor(235, 100, 3, 200)
		love.graphics.line(UI_width + UI_width / 4, (icon_height / 4) + icon_height * 4, menu_width - UI_width / 4, (icon_height / 4) + icon_height * 4)

		if mouse_pressed_1 and not mouse_released_1 and mouse_x > UI_width + UI_width / 4 and mouse_x < menu_width - UI_width / 4 and
		 mouse_y > (icon_height / 4) + icon_height * 4 - 50 and mouse_y < ((icon_height / 4) + icon_height * 4 - 10) + 30 then

			slider_brush_x = mouse_x - 5
			brush_size = math.floor(slider_brush_x / 3)

			love.graphics.setColor(20, 150, 150, 150)
			love.graphics.setLineWidth(2)
			if brush == "circle" then
				love.graphics.circle("line", width / 2, height / 2, brush_size)
			end
			if brush == "triangle" then
				love.graphics.polygon("line", triangle_vertices_size)
			end
			if brush == "square" then
				love.graphics.rectangle("line", width / 2, height / 2, brush_size, brush_size)
			end
			love.graphics.setColor(235, 100, 3, 200)
		end
		love.graphics.print("Brush size: " .. brush_size, 100, (icon_height / 4) + icon_height * 4 - 50)
		love.graphics.setColor(255, 120, 23)
		love.graphics.rectangle("fill", slider_brush_x, (icon_height / 4) + icon_height * 4 - 10, 10, 20)
		reset()

		--Loop speed
		love.graphics.setLineWidth(4)
		love.graphics.setColor(235, 100, 3, 200)
		love.graphics.line(UI_width + UI_width / 4, (icon_height / 4) + icon_height * 5, menu_width - UI_width / 4, (icon_height / 4) + icon_height * 5)

		if mouse_pressed_1 and not mouse_released_1 and mouse_x > UI_width + UI_width / 4 and mouse_x < menu_width - UI_width / 4 and
		 mouse_y > (icon_height / 4) + icon_height * 5 - 50 and mouse_y < ((icon_height / 4) + icon_height * 5 - 10) + 30 then

			slider_loop_x = mouse_x - 5
			loop_speed = math.floor(slider_loop_x / 8 - 10)
		end
		love.graphics.print("Loop speed: " .. loop_speed, 100, (icon_height / 4) + icon_height * 5 - 50)
		love.graphics.setColor(255, 120, 23)
		love.graphics.rectangle("fill", slider_loop_x, (icon_height / 4) + icon_height * 5 - 10, 10, 20)
		reset()
	end

	--Red
	love.graphics.setColor(119, 207, 255)
	love.graphics.rectangle("fill", 3, icon_seperation + icon_height * 1, icon_width - 6, icon_height - icon_seperation, 12, 10)
	--Green
	love.graphics.setColor(170, 218, 200)
	love.graphics.rectangle("fill", 3, icon_seperation + icon_height * 2, icon_width - 6, icon_height - icon_seperation, 12, 10)
	--Blue
	love.graphics.setColor(235, 137, 59)
	love.graphics.rectangle("fill", 3, icon_seperation + icon_height * 3, icon_width - 6, icon_height - icon_seperation, 12, 10)
	--White
	love.graphics.setColor(255, 120, 23)
	love.graphics.rectangle("fill", 3, icon_seperation + icon_height * 4, icon_width - 6, icon_height - icon_seperation, 12, 10)
	--Eraser
	love.graphics.setColor(back_color, back_color, back_color)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("fill", 3, icon_seperation + icon_height * 5, icon_width - 6, icon_height - icon_seperation, 12, 10)
	love.graphics.setColor(back_color + 50, back_color + 50, back_color + 50)
	love.graphics.rectangle("line", 3, icon_seperation + icon_height * 5, icon_width - 6, icon_height - icon_seperation, 12, 10)
	reset()

	--New
	love.graphics.setColor(130, 230, 250)
	love.graphics.draw(i_new, 10, icon_height * 6 + icon_displacement - 2, 0, 0.11, 0.11)
	love.graphics.setColor(130, 230, 250)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 6, icon_width - 8, icon_height - icon_seperation, 12, 10)

	--Copy
	love.graphics.setColor(80, 180, 200)
	love.graphics.draw(i_copy, 10, icon_height * 7 + icon_displacement, 0, 0.11, 0.11)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 7, icon_width - 8, icon_height - icon_seperation, 12, 10)

	--Play
	love.graphics.setColor(200, 100, 200)
	love.graphics.draw(i_play, 10, icon_height * 8 + icon_displacement, 0, 0.11, 0.11)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 8, icon_width - 8, icon_height - icon_seperation, 12, 10)

	--Save
	love.graphics.setColor(100, 230, 100)
	love.graphics.draw(i_save, 10, icon_height * 9 + icon_displacement, 0, 0.11, 0.11)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 9, icon_width - 8, icon_height - icon_seperation, 12, 10)

	--Upload
	love.graphics.setColor(100, 100, 230)
	love.graphics.draw(i_upload, 10, icon_height * 10 + icon_displacement, 0, 0.11, 0.11)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 10, icon_width - 8, icon_height - icon_seperation, 12, 10)

	--Clear
	love.graphics.setColor(200, 20, 20)
	love.graphics.draw(i_clear, 10, icon_height * 12 + icon_displacement, 0, 0.11, 0.11)
	love.graphics.rectangle("line", 4, icon_seperation + icon_height * 12 , icon_width - 8, icon_height - icon_seperation, 12, 10)

	reset()

	--Cursor
	love.mouse.setVisible(on_UI)
	
	if not on_UI then
		love.graphics.setFont(comfortana_s)
		love.graphics.print(mouse_x .. " " .. mouse_y, mouse_x + 10 + brush_size, mouse_y + 10 + brush_size, 0, 1, 1)
		love.graphics.circle("fill", mouse_x, mouse_y, 2)
		love.graphics.setColor(20, 150, 150)
		if brush == "circle" then
			love.graphics.circle("line", mouse_x, mouse_y, brush_size)
		end
		if brush == "triangle" then
			love.graphics.polygon("line", triangle_vertices)
		end
		if brush == "square" then
			love.graphics.rectangle("line", mouse_x - brush_size / 2, mouse_y - brush_size / 2, brush_size, brush_size)
		end
		reset()
	end
end

function reset()
	love.graphics.setLineWidth(1)
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(comfortana)
end