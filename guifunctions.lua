gui = {}

function gui.load()
	gooi.desktopMode()
	gooi.setStyle(raisedbutton)
	zoomslider = gooi.newSlider({w = dp(122), h = dp(36), value = 0.1})
	redo = nB({text = "REDO", w = dp(112), h = dp(36)}):setIcon("icons/white/ic_redo_variant.png"):setOrientation("right")
	undo = nB({text = "UNDO", x = dp(112), y = dp(16), w = dp(112), h = dp(36)}):setIcon("icons/white/ic_undo_variant.png"):setOrientation("right")
	gooi.setStyle(flatbutton)
	file = nB("FILE", 0, 0, dp(60), dp(36)):onRelease(function() gui.toggleFileMenu() end):setOrientation("left")
	options = nB("OPTIONS", 0, 0, dp(60), dp(36))
	edit = nB("EDIT", 0, 0, dp(60), dp(36)):setOrientation("left")
	view = nB("VIEW", 0, 0, dp(60), dp(36)):setOrientation("left"):onPress(function() gui.toggleViewMenu() end)
	selection = nB("SELECTION", 0, 0, dp(60), dp(36)):setOrientation("left")
	glo = gooi.newPanel(0, 0, sw, sh, "game")
	glo:add(redo, "b-r") glo:add(undo, "b-r") glo:add(options, "t-r")
	glo:add(file, "t-l") glo:add(edit, "t-l") glo:add(view, "t-l")
	glo:add(selection, "t-l")
	glo:add(zoomslider, "t-r")
	glo:add(gooi.newLabel("ZOOM:"), "t-r")
	gooi.setStyle(raisedbutton)
	cp = nB({x = sw - dp(46), y = sh/2 - dp(23), w = dp(46), h = dp(46)}):onRelease(function() gui.toggleColorPicker() end)
	cp.bgColor = currentcolor
end 

function gui.toggleFileMenu()
	if fileWindow == nil then
		gooi.setStyle(window)
		fileWindow = gooi.newPanel(defWindowArgs):setOpaque(true)
		fileWindow.components = {}
		local comps = fileWindow.components
		gooi.setStyle(raisedbutton)
		comps.Label = gooi.newLabel("FILE"):setOpaque(false):setOrientation("center")
		comps.newFile = nB("NEW FILE")
		:onRelease(function()
			gooi.confirm("Start a new file?", function() newdata:mapPixel(pixelFunction.allwhite) fn = nil end)
		end)
		comps.openFile = gooi.newButton("OPEN FILE")
		:onPress(function()
			gui.toggleFileMenu()
			gui.toggleFileBrowser()
		end)
		comps.saveFile = gooi.newButton("SAVE FILE")
		:onRelease(function()
			if fn == nil then
				gui.toggleFileMenu()
				gui.toggleSaveMenu()
			else
				newdata:encode("png", fn)
			end
		end)
		fileWindow:add(comps.Label, "1,1")
		fileWindow:add(comps.newFile, "2,1")
		fileWindow:add(comps.openFile, "3,1")
		fileWindow:add(comps.saveFile, "4,1")
	else gooi.removeComponent(fileWindow) fileWindow = nil
	end
end

function gui.toggleFileBrowser()
	if fileBrowser == nil then
		gooi.setStyle(window)
		fileBrowser = gooi.newPanel(largeWindowArgs):setOpaque(true)
		:setColspan(1, 1, 3)
		gooi.setStyle(raisedbutton)
		local dir = love.filesystem.getSaveDirectory()
		local Label = gooi.newLabel(dir):setOrientation("center")
		local textBox = gooi.newText("test")
		local Cancel = gooi.newButton("CANCEL")
		:onRelease(function()
			gui.toggleFileBrowser()
		end)
		Cancel.bgColor = colors.tertairy
		fileBrowser:add(Label, "1,1")
		fileBrowser:add(Cancel, "8,1")
		fileBrowser:add(textBox, "8,2")
		gooi.setStyle(flatbutton)
		local items = love.filesystem.getDirectoryItems("")
		for i,filename in pairs(items) do
			if string.find(filename, ".png") then
				fileBrowser:add(gooi.newButton({text = filename, orientation = "right"})
				:onRelease(function()
					newdata = love.image.newImageData(filename)
					currentimage = love.graphics.newImage(newdata)
					fn = filename
					gooi.removeComponent(fileBrowser) fileBrowser = nil
				end))
			end
		end
	else gooi.removeComponent(fileBrowser) fileBrowser = nil
	end
end

function gui.toggleSaveMenu()
	if saveMenu == nil then
		gooi.setStyle(window)
		saveMenu = gooi.newPanel(defWindowArgs):setOpaque(true)
		saveMenu.components = {}
		local comps = saveMenu.components
		gooi.setStyle(raisedbutton)
		
		comps.Label = gooi.newLabel("SAVE NEW FILE"):setOrientation("center")
		comps.TextBox = gooi.newText("")
		comps.Cancel = gooi.newButton("CANCEL")
		:onRelease(function()
			gui.toggleSaveMenu()
		end)
		comps.Save = gooi.newButton("SAVE")
		:onRelease(function()
			fn = comps.TextBox.text
			newdata:encode("png", fn..".png")
			gui.toggleSaveMenu()
		end)
		
		saveMenu:add(comps.Label, "1,1")
		saveMenu:add(comps.TextBox, "3,1")
		saveMenu:add(comps.Cancel, "5,1")
		saveMenu:add(comps.Save, "6,1")
		
	else gooi.removeComponent(saveMenu) saveMenu = nil
	end
end

function gui.toggleViewMenu()
	 if viewMenu == nil then
			gooi.setStyle(window)
			viewMenu = gooi.newPanel(defWindowArgs):setOpaque(true)
			gooi.setStyle(raisedbutton)
			viewMenuLabel = gooi.newLabel({text = "VIEW", orientation = "center"})
			gridCheck = gooi.newCheck({text= "Show Grid", checked = showgrid})
			recenterImage = nB("RECENTER IMAGE"):onPress(function() camera:lookAt(newdata:getWidth()/2, newdata:getHeight()/2) end)
			close = gooi.newButton("CLOSE")
			:onPress(function()
				gooi.removeComponent(viewMenu) viewMenu = nil 
			end)
			viewMenu:add(viewMenuLabel, "1,1")
			viewMenu:add(recenterImage, "3,1")
			viewMenu:add(gridCheck, "4,1")
			viewMenu:add(close, "6,1")
			close.bgColor = colors.tertairy
		else gooi.removeComponent(viewMenu) viewMenu = nil
		end
end

function gui.toggleColorPicker()
	showfilemenu = not showfilemenu
	isvis = not isvis
	gooi.setGroupVisible("colorpicker", isvis)
	gooi.setGroupEnabled("colorpicker", isvis)
	candraw = not candraw
end