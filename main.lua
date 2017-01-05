require "lib.gooi"
require "pixelfunctions"
dp = love.window.toPixels
fd = love.window.fromPixels
lg = love.graphics
nB = gooi.newButton
sw, sh = lg.getDimensions()
a, focus = 0, 0
isvis = false
require "styles"
Camera = require"lib.hump.camera"
showfilemenu = false
showgrid = true
require "guifunctions"
require "colorpicker"
require "toolbar"
function love.load()
	lg.setFont(fonts.rr)
	love.graphics.setDefaultFilter("nearest")
	lg.setBackgroundColor(150, 150, 150)
	newdata = love.image.newImageData(32, 32)
	camera = Camera(newdata:getWidth()/2, newdata:getHeight()/2, 4)
	newdata:mapPixel(pixelFunction.allwhite)
	currentimage = love.graphics.newImage(newdata)
	palettedata = love.image.newImageData("palettes/db32.png")
	paletteImage = love.graphics.newImage(palettedata)
	paletteCamera = Camera(0,0)
	paletteCamera:zoomTo(dp(20))
	local cx, cy = paletteCamera:worldCoords(sw - dp(4), sh)
	local wx, wy = paletteCamera:worldCoords(0, dp(48))
	paletteCamera:lookAt(paletteImage:getWidth() - cx, (-wy))
	candraw = true
	currentcolor = {0, 0, 0, 255}
	gui.load()
	colorpicker.load()
	toolbar.load()
end

function love.update(dt)
	if showfilemenu and a < 255 then
		a = a + 15
		focus = focus + 7.5
	elseif a <= 255 and not showfilemenu and a >= 0 then
		a = a - 15
		focus = focus - 7.5
	end
	if zoomslider.value <= 0.01 then
		camera:zoomTo(1)
	else
		camera:zoomTo(zoomslider.value *dp(50))
	end
	gooi.update(dt)
	do
		local c = colorpicker
	colorpicker.colorbox.bgColor = {c.rslider.value * 255, c.gslider.value * 255, c.bslider.value * 255}
	end
	cp.bgColor = currentcolor
	
	if tool ~= none then
		tool.bgColor = colors.secondary --sets currently selected tools background to red
	end
	
	for i, v in pairs(tools) do
		if tool ~= v then
			v.bgColor = colors.primary
		end
	end
	
	if pencilSlider ~= nil then
		pencilSize = pencilSlider.value
	end
	if gridCheck ~= nil then
		showgrid = gridCheck.checked
	elseif zoomslider.value <= 0.01 then
		showgrid = false
	end
end

function love.draw()
	lg.setColor(255, 255, 255)
	camera:attach()
	lg.draw(currentimage, 0, 0)
	camera:detach()
	drawGrid(1, 1, {0, 0, 0, 50})
	drawGrid(8, 8, {255, 0, 0, 250})
	drawGrid(16, 16, {0, 0, 255, 250})
	lg.setColor(255, 255, 255)
	paletteCamera:attach()
	lg.draw(paletteImage, 0, 0)
	paletteCamera:detach()
	drawPaletteGrid(colors.primary)
	lg.setColor(colors.primary)
	lg.rectangle("fill", 0, 0, sw, dp(44)) --top bar
	--lg.rectangle("fill", 0, dp(46), dp(46), dp(46*6)) --toolbar back
	gooi.draw()
	lg.setColor(0, 0, 0, focus)
	lg.rectangle("fill", 0, 0, sw, sh)
		lg.setColor(255, 255, 255, a)
		lg.rectangle("fill", sw/8 *3, sh/4, sw/4, sh/2, dp(2), dp(2))
		gooi.draw("filemenu")
		gooi.draw("colorpicker")
	lg.setColor(255, 255, 255)
end

function love.touchpressed(id, x, y)
	gooi.pressed(id, x, y)
	touchx, touchy = camera:worldCoords(x, y)
	if y <= dp(46) or x <= dp(44) or isvis or viewWindow ~= nil then candraw = false
	elseif y > dp(46) or x > dp(44) or not isvis then candraw = true
	end
	local palx, paly = paletteCamera:worldCoords(x, y)
	if palx >= 0 and palx <= paletteImage:getWidth() and paly >= 0 and paly <= paletteImage:getHeight() then
		candraw = false
		currentcolor = {palettedata:getPixel(palx, paly)}
	end
	
	drawFunctions()
	currentimage:refresh()
end

function love.touchreleased(id, x, y)
	gooi.released(id, x, y)
	touchx, touchy = nil, nil
	currentimage:refresh()
end

function love.touchmoved(id, x, y)
	gooi.moved(id, x, y)
	if tool ~= tools.pan then
		touchx, touchy = camera:worldCoords(x, y)
	elseif tool == tools.pan and y > dp(46) then
		newtouchx, newtouchy = camera:worldCoords(x, y)
		camera:move(touchx - newtouchx, touchy - newtouchy)
	end
	 drawFunctions()
	 currentimage:refresh()
end

function love.textinput(text)
	gooi.textinput(text)
end

function drawGrid(xsize, ysize, color)
	if showgrid then
		love.graphics.setColor(color)
		love.graphics.setLineWidth(dp(1))
		for i = xsize, (currentimage:getWidth() - 1), xsize do
			local x, y = camera:cameraCoords(i, 0)
			local x2, y2 = camera:cameraCoords(i, currentimage:getHeight())
			love.graphics.line(x, y, x2, y2)
		end
		for i = ysize, (currentimage:getHeight() - 1), ysize do
			local x, y = camera:cameraCoords(0, i)
			local x2, y2 = camera:cameraCoords(currentimage:getWidth(), i)
			love.graphics.line(x, y, x2, y2)
		end
	end
end

function drawPaletteGrid(color)
		love.graphics.setColor(color)
		love.graphics.setLineWidth(dp(1))
		for i = 0, (paletteImage:getWidth()) do
			local x, y = paletteCamera:cameraCoords(i, 0)
			local x2, y2 = paletteCamera:cameraCoords(i, paletteImage:getHeight())
			love.graphics.line(x, y, x2, y2)
		end
		for i = 0, (paletteImage:getHeight()) do
			local x, y = paletteCamera:cameraCoords(0, i)
			local x2, y2 = paletteCamera:cameraCoords(paletteImage:getWidth(), i)
			love.graphics.line(x, y, x2, y2)
		end
end