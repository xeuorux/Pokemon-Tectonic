#===============================================================================
#
#===============================================================================
class TilingCardsMenu_Scene
	INACTIVE_BUTTON_COLOR = Color.new(80, 80, 80, 80)

	INACTIVE_BASE_TEXT_COLOR = Color.new(105,105,105)
	INACTIVE_SHADOW_TEXT_COLOR = Color.new(130,130,130)

	attr_accessor :xOffset
	attr_accessor :yOffset

	def initialize
		@xOffset = 124
		@yOffset = 40
		@buttonRowHeight = 80
		@buttonColumnWidth = 142

		@columnCount = 2
	end

	def cursorFileLocation
		return addLanguageSuffix(("Graphics/Pictures/Pause/cursor_pause"))
	end
	def tileFileLocation
		path = "Graphics/Pictures/Pause/pause_menu_tile"
		path += "_dark" if darkMode?
		return _INTL(path)
	end
	def backgroundFadeFileLocation
		return addLanguageSuffix(("Graphics/Pictures/Pause/background_fade"))
	end

	def initializeMenuButtons 
		@cardButtons = {
            # Example here:
			# :POKEMON => {
			# 	:label => _INTL("Pokémon"),
			# 	:active_proc => Proc.new {
			# 		$Trainer.party_count > 0
			# 	},
			# 	:press_proc => Proc.new { |scene|
			# 		pbPlayDecisionSE
			# 		pbFadeOutIn {
			# 			sscene = PokemonParty_Scene.new
			# 			sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
			# 			sscreen.pbPokemonScreen
			# 			scene.pbRefresh
			# 		}
			# 	},
			# },
		}
	end
	
	def pbStartScene
		initializeMenuButtons

		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99_999
		@sprites = {}
		@sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["helpwindow"].visible = false
		@bgBitmap = AnimatedBitmap.new(backgroundFadeFileLocation)
		@sprites["bg_fade"] = SpriteWrapper.new(@viewport)
		@sprites["bg_fade"].x = 0
		@sprites["bg_fade"].y = 0
		@sprites["bg_fade"].bitmap = @bgBitmap.bitmap
		@sprites["bg_fade"].visible = true
		@sprites["bg_fade"].opacity = 40
		@cursorBitmap = AnimatedBitmap.new(cursorFileLocation)
		@sprites["cursor"] = SpriteWrapper.new(@viewport)
		@sprites["cursor"].bitmap = @cursorBitmap.bitmap
		@tileBitmap = AnimatedBitmap.new(tileFileLocation)
		@buttonNameOverlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@buttonNameOverlay.z = 2
		pbSetSystemFont(@buttonNameOverlay.bitmap)
		@tiles = {}
		@cardButtons.keys.each_with_index do |buttonID, index|
			newButton = SpriteWrapper.new(@viewport)
			@sprites["button_#{buttonID.to_s}"] = newButton
			newButton.bitmap = @tileBitmap.bitmap
			@tiles[buttonID] = newButton

			newButton.x = xFromIndex(index)
			newButton.y = yFromIndex(index)
			newButton.visible = true
		end

		# Z indexing
		@sprites.each do |k,v|
			v.z = 1
		end
		@sprites["bg_fade"].z = 0

		@infostate = false
		@helpstate = false
		$viewport4 = @viewport

		@buttonSelectionIndex = defaultCursorPosition

		drawButtons
	end

	def defaultCursorPosition; return 0; end

	def xFromIndex(index)
		info = @cardButtons[@cardButtons.keys[index]]
		if info[:position]
			return @xOffset + info[:position][0]
		end
		return @xOffset + (index % @columnCount) * @buttonColumnWidth
	end

	def yFromIndex(index)
		info = @cardButtons[@cardButtons.keys[index]]
		if info[:position]
			return @yOffset + info[:position][1]
		end
		return @yOffset + (index / @columnCount) * @buttonRowHeight
	end
  
	def pbShowInfo(text)
		@sprites["infowindow"].resizeToFit(text,Graphics.height)
		@sprites["infowindow"].text    = text
		@sprites["infowindow"].visible = true
		@infostate = true
	end
  
	def pbShowMenu
		@tiles.values.each do |tile|
			tile.visible = true
		end
		@sprites["infowindow"].visible = @infostate
		@sprites["helpwindow"].visible = @helpstate
	end
  
	def pbHideMenu
		@tiles.values.each do |tile|
			tile.visible = true
		end
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"].visible = false
	end
  
	def pbEndScene
		@tiles.values.each do |tile|
			tile.bitmap.dispose
		end
		pbDisposeSpriteHash(@sprites)
		@buttonNameOverlay.dispose
		@viewport.dispose
		@tileBitmap.dispose
		@bgBitmap.dispose
		@cursorBitmap.dispose
	end
  
	def drawButtons
		# reload the tile bitmap so that dark mode changes are updated. there's gotta be a better way
		@tileBitmap = AnimatedBitmap.new(tileFileLocation)
		@tiles.each_pair do |buttonID, tileSprite|
			@sprites["button_#{buttonID.to_s}"].bitmap = @tileBitmap.bitmap
			next if buttonActive?(buttonID)
			tileSprite.color =  INACTIVE_BUTTON_COLOR
		end
		@buttonNameOverlay.bitmap.clear
		buttonNamePositions = []
		@cardButtons.keys.each_with_index do |buttonID, index|
			label = @cardButtons[buttonID][:label] || "ERROR"
			x = xFromIndex(index) + 8
			y = yFromIndex(index) + @tileBitmap.bitmap.height / 2 - 20
			if buttonActive?(buttonID) 
				baseColor = MessageConfig.pbDefaultTextMainColor
				shadowColor = MessageConfig.pbDefaultTextShadowColor
			else
				baseColor = INACTIVE_BASE_TEXT_COLOR
				shadowColor = INACTIVE_SHADOW_TEXT_COLOR
			end
			buttonNamePositions.push([label,x,y,false,baseColor,shadowColor,false])
		end
		pbDrawTextPositions(@buttonNameOverlay.bitmap,buttonNamePositions)
	end

	def selectedButton?(buttonID)
		buttonID = @cardButtons.keys[buttonID] if buttonID.is_a?(Integer)
		return @cardButtons.keys.index(buttonID) == @buttonSelectionIndex
	end

	def buttonActive?(buttonID)
		buttonID = @cardButtons.keys[buttonID] if buttonID.is_a?(Integer)
		active = true
		if @cardButtons[buttonID][:active_proc]
			active = @cardButtons[buttonID][:active_proc].call
		end
		return active
	end

	def pressButton(buttonID)
		buttonID = @cardButtons.keys[buttonID] if buttonID.is_a?(Integer)
		return @cardButtons[buttonID][:press_proc].call(self) == true
	end

	def moveCursorToButton(buttonIndex)
		@sprites["cursor"].x = xFromIndex(buttonIndex) - 4
		@sprites["cursor"].y = yFromIndex(buttonIndex) - 4
	end

	def promptButtons
		loop do
			moveCursorToButton(@buttonSelectionIndex)
			Graphics.update
			Input.update
			prevButtonSelectionIndex = @buttonSelectionIndex
			if Input.trigger?(Input::BACK)
				closeMenu = true
			elsif Input.trigger?(Input::USE)
				if !buttonActive?(@buttonSelectionIndex)
					pbPlayBuzzerSE
					next
				end
				closeMenu = true if pressButton(@buttonSelectionIndex)
			elsif Input.trigger?(Input::UP)
				@buttonSelectionIndex -= @columnCount
			elsif Input.trigger?(Input::DOWN)
				@buttonSelectionIndex += @columnCount
			elsif Input.trigger?(Input::RIGHT)
				if (@buttonSelectionIndex % @columnCount) < @columnCount - 1
					@buttonSelectionIndex += 1
				else
					@buttonSelectionIndex -= (@columnCount-1)
				end
			elsif Input.trigger?(Input::LEFT)
				if (@buttonSelectionIndex % @columnCount) > 0
					@buttonSelectionIndex -= 1
				else
					@buttonSelectionIndex += (@columnCount - 1)
				end
			end

			buttonCount = @cardButtons.keys.length
			if @buttonSelectionIndex >= buttonCount
				@buttonSelectionIndex -= buttonCount + 1
				@buttonSelectionIndex += 1 while @buttonSelectionIndex < 0
			elsif @buttonSelectionIndex < 0
				@buttonSelectionIndex += buttonCount + 1
				@buttonSelectionIndex -= 1 while @buttonSelectionIndex >= buttonCount
			end

			if closeMenu
				onMenuClose
				pbPlayCloseMenuSE
				return
			end

			if @buttonSelectionIndex != prevButtonSelectionIndex
				pbPlayCursorSE
				drawButtons
			end
		end
	end

	def onMenuClose; end;

	def visible=(value)
		@sprites.each { |k,v| v.visible = value}
		@buttonNameOverlay.visible = value
	end

	def hideTileMenu
		self.visible = false
	end

	def showTileMenu
		self.visible = true
	end

	def update
		@sprites.each { |k,v| v.update}
	end
end

class TilingCardsMenu_Screen
	def initialize(scene)
		@scene = scene
	end

	def pbStartPokemonMenu
		@scene.pbStartScene
		@scene.promptButtons
		@scene.pbEndScene
  	end
end