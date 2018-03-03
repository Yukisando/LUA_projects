function love.mousepressed(x, y, button)
	if button == 1 then
		mouse_press_1 = true
		mouse_release_1 = false
	end
	if button == 2 then
		mouse_press_2 = true
		mouse_release_1 = false
	end

	----On UI
	if x < UI_width then
		if y > 0 and y < icon_height and menu == false then
			menu = true
		else
			menu = false
		end

		if y > icon_height * 1 and y < icon_height * 1 + icon_height then
			brush_red = 119
			brush_green = 207
			brush_blue = 229
		end
		if y > icon_height * 2 and y < icon_height * 2 + icon_height then
			brush_red = 117
			brush_green = 230
			brush_blue = 117
		end
		if y > icon_height * 3 and y < icon_height * 3 + icon_height then
			brush_red = 235
			brush_green = 137
			brush_blue = 59
		end
		if y > icon_height * 4 and y < icon_height * 4 + icon_height then
			brush_red = 221
			brush_green = 117
			brush_blue = 221
		end

		--Eraser
		if y > icon_height * 5 and y < icon_height * 5  + icon_height then
			mode = "fill"
			brush_red = back_color
			brush_blue = back_color
			brush_green = back_color
		end

		--New
		if y > icon_height * 6 and y < icon_height * 6  + icon_height then
			if canvases[#canvases + 1] == nil and #canvases + 1 < canvas_limit then
				table.insert(canvases, current_canvas + 1, love.graphics.newCanvas())
				current_canvas = current_canvas + 1
			end
		end

		--Copy
		if y > icon_height * 7 and y < icon_height * 7  + icon_height then
			if canvases[current_canvas + 1] == nil and current_canvas < canvas_limit then
				canvases[current_canvas + 1] = love.graphics.newCanvas()
				current_canvas = current_canvas + 1
				copy = true
			elseif current_canvas < canvas_limit then
				current_canvas = current_canvas + 1
				copy = true
			end
		end

		--Play
		if y > icon_height * 8  and y < icon_height * 8  + icon_height then
			if loop then
				loop = false
			else
				loop = true
			end
		end

		--Save
		if y > icon_height * 9 and y < icon_height * 9 + icon_height then
			for i=1, #canvases do
				screenshots[i] = canvases[i]:newImageData()
				screenshots[i]:encode("png", "Snap_" .. i .. '.png');
			end
		end

		--Upload
		if y > icon_height * 10 and y < icon_height * 10 + icon_height then
			background = love.graphics.newImage("data/images/background.jpg")
		end

		--Clear sketch
		if y > icon_height * 12 and y < icon_height * 12 + icon_height then
			if button == 2 then
				clear_all = true
			else
				background = nil
				clear = not clear
			end
		end
	end

	----On menu
	--Circles fill
	if menu and x > UI_width * 1 and x < UI_width * 2 and y < (menu_height / menu_button) then
		brush = "circle"
		mode = "fill"
	end	

	--Circles line
	if menu and x > UI_width * 2 and x < UI_width * 3 and y < (menu_height / menu_button) then
		brush = "circle"
		mode = "line"
	end	

	--Rect fill
	if menu and x > UI_width * 1 and x < UI_width * 2 and y > (menu_height / menu_button) and y < 2 * (menu_height / menu_button) then
		brush = "square"
		mode = "fill"
	end	

	--Rect line
	if menu and x > UI_width * 2 and x < UI_width * 3 and y > (menu_height / menu_button) and y < 2 * (menu_height / menu_button) then
		brush = "square"
		mode = "line"
	end

	--Triangle fill
	if menu and x > UI_width * 1 and x < UI_width * 2 and y > (menu_height / menu_button) * 2 and y < 3 * (menu_height / menu_button) then
		brush = "triangle"
		mode = "fill"
	end	

	--Triangle line
	if menu and x > UI_width * 2 and x < UI_width * 3 and y > (menu_height / menu_button) * 2 and y < 3 * (menu_height / menu_button) then
		brush = "triangle"
		mode = "line"
	end	
end

function love.mousereleased(x, y, button)
	if button == 1 then
		mouse_press_1 = false
		mouse_release_1 = true
	end

	if button == 2 then
		mouse_press_2 = false
		mouse_release_2 = true
	end
end

if OS == "Android" or OS == "iOS" then
	brush_size = love.touch.getPressure(1)
else
	function love.wheelmoved(x, y)
	    if y > 0 then
	    	if brush_size < 80 then
	    		brush_size = brush_size + 2
	    	end
	    end
	
	    if y < 0 then
	    	if brush_size > 2 then
	    		brush_size = brush_size - 2
	    	end
	    end
	end
end

function love.keypressed(key)

	if key == "escape" then
		love.event.quit()
	end

	if key == "space" then
		if loop then
			loop = false
		else
			loop = true
		end
	end

	if key == "right" then
		if canvases[current_canvas + 1] == nil and current_canvas + 1 < canvas_limit then
			table.insert(canvases, current_canvas + 1, love.graphics.newCanvas())
			current_canvas = current_canvas + 1
		elseif current_canvas < canvas_limit then
			current_canvas = current_canvas + 1
		end
	end

	if key == "left" then
		
		if not (current_canvas - 1 < 1) then
			current_canvas = current_canvas - 1
		else
			current_canvas = 1
		end
	end

	if key == 'd' then
		if current_canvas == 1 then
			clear = not clear
		else
			delete = true
			table.remove(canvases, current_canvas)
			current_canvas = current_canvas - 1
		end
	end

	if key == 'r' then
		love.load()
	end
end