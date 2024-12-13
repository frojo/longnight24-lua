StreamerScreen = {
	Colors = {
		upperText = "Default text",
		upperBorder = "Upper box border",
		upperBoxFill = "Upper box background",
		lowerText = "Lower box text",
		lowerBorder = "Lower box border",
		lowerBoxFill = "Lower box background",
	},
}

StreamerScreen.Buttons = {
	AttemptsCountEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.StreamerScreen.ButtonEdit end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 14, 23, 11 },
		draw = function(self, shadowcolor)
			-- Draw the Label text to its left
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			local y = self.box[2]
			Drawing.drawText(x, y, Resources.StreamerScreen.LabelAttemptsCount .. ":", Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) StreamerScreen.openEditAttemptsWindow() end,
	},
	WelcomeMessageEdit = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.StreamerScreen.ButtonEdit end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 112, Constants.SCREEN.MARGIN + 29, 23, 11 },
		draw = function(self, shadowcolor)
			-- Draw the Label text to its left
			local x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3
			local y = self.box[2]
			Drawing.drawText(x, y, Resources.StreamerScreen.LabelWelcomeMessage .. ":", Theme.COLORS[self.textColor], shadowcolor)
		end,
		onClick = function(self) StreamerScreen.openEditWelcomeMessageWindow() end,
	},
	ShowFavorites = {
		type = Constants.ButtonTypes.CHECKBOX,
		optionKey = "Show on new game screen",
		getText = function(self) return Resources.StreamerScreen.OptionDisplayFavorites end,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 64, Constants.SCREEN.RIGHT_GAP - 12, 8 },
		box = {	Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 64, 8, 8 },
		toggleState = false, -- update later in initialize
		updateSelf = function(self) self.toggleState = (Options[self.optionKey] == true) end,
		onClick = function(self)
			self.toggleState = Options.toggleSetting(self.optionKey)
			Program.redraw(true)
		end,
	},
	PokemonFavorite1 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 8, 75, 32, 32 },
		pokemonID = 1,
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	PokemonFavorite2 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 53, 75, 32, 32 },
		pokemonID = 4,
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	PokemonFavorite3 = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 79, 32, 29 },
		box = 			{ Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 98, 75, 32, 32 },
		pokemonID = 7,
		getIconId = function(self) return self.pokemonID, SpriteData.Types.Idle end,
		onClick = function(self)
			StreamerScreen.openPokemonPickerWindow(self, self.pokemonID)
			Program.redraw(true)
		end,
	},
	StreamConnectOpen = {
		type = Constants.ButtonTypes.ICON_BORDER,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		getText = function(self) return Resources.StreamerScreen.ButtonStreamConnect end,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 10, Constants.SCREEN.MARGIN + 115, 100, 16 },
		updateSelf = function(self)
			if Network.CurrentConnection.State == Network.ConnectionState.Established then
				self.image = Constants.PixelImages.CHECKMARK
				self.iconColors = { "Positive text" }
			elseif Network.CurrentConnection.State == Network.ConnectionState.Listen then
				self.image = Constants.PixelImages.CLOCK
				self.iconColors = { "Intermediate text" }
			elseif Network.CurrentConnection.State == Network.ConnectionState.Closed then
				self.image = Constants.PixelImages.CROSS
				self.iconColors = { "Negative text" }
			end
		end,
		onClick = function(self) StreamConnectOverlay.open() end,
	},
	Back = Drawing.createUIElementBackButton(function()
		if StreamConnectOverlay.isDisplayed then
			StreamConnectOverlay.close()
		end
		Program.changeScreenView(NavigationMenu)
	end),
}

function StreamerScreen.initialize()
	for _, button in pairs(StreamerScreen.Buttons) do
		if button.textColor == nil then
			button.textColor = StreamerScreen.Colors.upperText
		end
		if button.boxColors == nil then
			button.boxColors = { StreamerScreen.Colors.upperBorder, StreamerScreen.Colors.upperBoxFill }
		end
	end

	StreamerScreen.Buttons.ShowFavorites.toggleState = Options["Show on new game screen"] or false

	StreamerScreen.loadFavorites()
end

function StreamerScreen.refreshButtons()
	for _, button in pairs(StreamerScreen.Buttons) do
		if button.updateSelf ~= nil then button:updateSelf() end
	end
end

function StreamerScreen.openEditAttemptsWindow()
	local form = ExternalUI.BizForms.createForm(Resources.StreamerScreen.PromptEditAttemptsTitle, 320, 130)

	form:createLabel(Resources.StreamerScreen.PromptEditAttemptsDesc, 48, 10)
	local textBox = form:createTextBox(tostring(Main.currentSeed), 50, 30, 200, 30, "UNSIGNED", false, true)
	form:createButton(Resources.AllScreens.Save, 72, 60, function()
		local formInput = ExternalUI.BizForms.getText(textBox)
		if not Utils.isNilOrEmpty(formInput) then
			local newAttemptsCount = tonumber(formInput)
			if newAttemptsCount ~= nil and Main.currentSeed ~= newAttemptsCount then
				Main.currentSeed = newAttemptsCount
				Main.WriteAttemptsCountToFile(Main.GetAttemptsFile(), newAttemptsCount)
				Program.redraw(true)
			end
		end
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Cancel, 157, 60, function()
		form:destroy()
	end)
end

function StreamerScreen.openEditWelcomeMessageWindow()
	local form = ExternalUI.BizForms.createForm(Resources.StreamerScreen.PromptEditWelcomeTitle, 515, 235)

	local welcomeMsg = Utils.formatSpecialCharacters(Options["Welcome message"])
	welcomeMsg = Utils.encodeDecodeForSettingsIni(welcomeMsg, false)

	form:createLabel(Resources.StreamerScreen.PromptEditWelcomeDesc, 9, 10)
	local welcomeTextBox = form:createTextBox(welcomeMsg, 10, 35, 480, 120, "", true, false, "Vertical")
	form:createButton(Resources.AllScreens.Save, 120, 165, function()
		local newMessage = Utils.formatSpecialCharacters(ExternalUI.BizForms.getText(welcomeTextBox))
		newMessage = Utils.encodeDecodeForSettingsIni(newMessage, true)
		Options["Welcome message"] = newMessage
		Main.SaveSettings(true)
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Clear, 205, 165, function()
		ExternalUI.BizForms.setText(welcomeTextBox, "")
	end)
	form:createButton(Resources.AllScreens.Cancel, 290, 165, function()
		form:destroy()
	end)
end

function StreamerScreen.openPokemonPickerWindow(iconButton, initPokemonID)
	if iconButton == nil then return end
	if not PokemonData.isValid(initPokemonID) then
		initPokemonID = Utils.randomPokemonID()
	end

	local form = ExternalUI.BizForms.createForm(Resources.StreamerScreen.PromptChooseFavoriteTitle, 330, 145)

	local allPokemon = PokemonData.namesToList()
	local pokemonName = PokemonData.Pokemon[initPokemonID].name

	form:createLabel(Resources.StreamerScreen.PromptChooseFavoriteDesc, 24, 10)
	local pokedexDropdown = form:createDropdown(allPokemon, 50, 30, 145, 30, pokemonName)
	form:createButton(Resources.AllScreens.Save, 200, 29, function()
		local optionSelected = ExternalUI.BizForms.getText(pokedexDropdown)
		iconButton.pokemonID = PokemonData.getIdFromName(optionSelected) or 0
		StreamerScreen.saveFavorites()
		Program.redraw(true)
		form:destroy()
	end)
	form:createButton(Resources.AllScreens.Cancel, 120, 69, function()
		form:destroy()
	end)
end

function StreamerScreen.loadFavorites()
	local favorites = Options["Startup favorites"] or "1,4,7" -- Default bulbasaur, charmander, squirtle
	local first, second, third = string.match(favorites, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
	first = first or "1"
	second = second or "4"
	third = third or "7"
	StreamerScreen.Buttons.PokemonFavorite1.pokemonID = tonumber(first) or 1
	StreamerScreen.Buttons.PokemonFavorite2.pokemonID = tonumber(second) or 4
	StreamerScreen.Buttons.PokemonFavorite3.pokemonID = tonumber(third) or 7
end

function StreamerScreen.saveFavorites()
	local favoriteIds = {
		StreamerScreen.Buttons.PokemonFavorite1.pokemonID or 0,
		StreamerScreen.Buttons.PokemonFavorite2.pokemonID or 0,
		StreamerScreen.Buttons.PokemonFavorite3.pokemonID or 0,
	}
	Options["Startup favorites"] = table.concat(favoriteIds, ",")
	Main.SaveSettings(true)
end

-- USER INPUT FUNCTIONS
function StreamerScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, StreamerScreen.Buttons)
end

-- DRAWING FUNCTIONS
function StreamerScreen.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local topBox = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
		y = Constants.SCREEN.MARGIN + 10,
		width = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
		height = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2) - 10,
		text = Theme.COLORS[StreamerScreen.Colors.upperText],
		border = Theme.COLORS[StreamerScreen.Colors.upperBorder],
		fill = Theme.COLORS[StreamerScreen.Colors.upperBoxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[StreamerScreen.Colors.upperBoxFill]),
	}
	-- Will use the bottom-box later for OAuth Twitch stuff
	local botBox = {
		x = topBox.x,
		y = topBox.y + topBox.height + 5,
		width = topBox.width,
		height = Constants.SCREEN.HEIGHT - topBox.height - 15,
		text = Theme.COLORS[StreamerScreen.Colors.lowerText],
		border = Theme.COLORS[StreamerScreen.Colors.lowerBorder],
		fill = Theme.COLORS[StreamerScreen.Colors.lowerBoxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[StreamerScreen.Colors.lowerBoxFill]),
	}
	local textLineY = topBox.y + 2

	-- Draw top border box
	gui.defaultTextBackground(topBox.fill)
	gui.drawRectangle(topBox.x, topBox.y, topBox.width, topBox.height, topBox.border, topBox.fill)

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources.StreamerScreen.Title)
	local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	Drawing.drawText(topBox.x, Constants.SCREEN.MARGIN - 2, headerText, Theme.COLORS["Header text"], headerShadow)
	textLineY = textLineY + Constants.SCREEN.LINESPACING

	-- Draw Favorites Label
	Drawing.drawText(topBox.x + 3, topBox.y + 40, Resources.StreamerScreen.LabelFavorites .. ":", topBox.text, topBox.shadow)

	-- Draw bottom border box
	-- gui.defaultTextBackground(botBox.fill)
	-- gui.drawRectangle(botBox.x, botBox.y, botBox.width, botBox.height, botBox.border, botBox.fill)

	-- Draw all buttons
	for _, button in pairs(StreamerScreen.Buttons) do
		local buttonShadow
		if button.boxColors[2] == StreamerScreen.Colors.upperBoxFill then
			buttonShadow = topBox.shadow
		else
			buttonShadow = botBox.shadow
		end
		Drawing.drawButton(button, buttonShadow)
	end
end