function love.load()
	OS = love.system.getOS()
	if OS == "Android" or OS == "iOS" then
		love.window.setMode(1280, 720, {fullscreen = true, fullscreentype = "exclusive", msaa = 4, highdpi = true})
	else
		love.window.setMode(1920, 1080, {fullscreen = true, fullscreentype = "desktop", msaa = 8, display = 1, highdpi = true})
	end

	--UI
	if OS == "Android" or OS == "iOS" then
		scale = (1/love.window.getPixelScale()) * 5.5
	else
		scale = 1.1
	end

	on_UI = false
	UI_width = 80 * scale
	icon_width = UI_width
	icon_height = 70 * scale
	icon_seperation = 6 * scale
	if OS == "Android" or OS == "iOS" then
		icon_displacement = 10 * scale
	else
		icon_displacement = 10
	end

	comfortana = love.graphics.newFont("data/fonts/comfortana.ttf", 30)
	comfortana_s = love.graphics.newFont("data/fonts/comfortana.ttf", 16)
	love.graphics.setFont(comfortana)
	i_eraser = love.graphics.newImage("data/icons/eraser.png")
	i_new = love.graphics.newImage("data/icons/new.png")
	i_copy = love.graphics.newImage("data/icons/copy.png")
	i_play = love.graphics.newImage("data/icons/play.png")
	i_save = love.graphics.newImage("data/icons/save.png")
	i_upload = love.graphics.newImage("data/icons/upload.png")
	i_fill = love.graphics.newImage("data/icons/fill.png")
	i_shape = love.graphics.newImage("data/icons/shape.png")
	i_clear = love.graphics.newImage("data/icons/clear.png")

	--Globals
	height = love.graphics.getHeight()
	width = love.graphics.getWidth()
	p_height = 70 * scale
	p_width = 50 * scale

	--Tools
	menu = false
	menu_button = 5
	menu_width = ((UI_width * 4) * scale) - (UI_width / 2)
	menu_height = (icon_height * menu_button) * scale
	brush_red = 255
	brush_green = 120
	brush_blue = 23
	back_color = 60
	brush_size = 20 * scale
	brush_size_small = 15 * scale
	brush_size_medium = 30 * scale
	brush_size_large = 50 * scale

	mode = "line"
	brush = "triangle"
	copy = false
	eter = 0
	loop_speed = 10
	slider_loop_x = menu_width / 2
	slider_brush_x = menu_width / 2
	loop = false
	clear = false


	--Canvases
	canvas_limit = 51
	current_canvas = 1
	previous_layer = 0
	canvases = {[1] = love.graphics.newCanvas()}
	screenshots = {[1] = love.graphics.newScreenshot()}
end