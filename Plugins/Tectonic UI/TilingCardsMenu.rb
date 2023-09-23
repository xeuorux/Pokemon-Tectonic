#===============================================================================
#
#===============================================================================
class TilingCardsMenu_Scene
    BUTTON_COLUMN_LEFT_X = 124
	BUTTON_COLUMN_RIGHT_X = 266
    BUTTON_STARTING_Y = 36
	BUTTON_ROW_HEIGHT = 80

	INACTIVE_BUTTON_COLOR = Color.new(80, 80, 80, 80)

	BASE_TEXT_COLOR         = Color.new(60,60,60)
  	SHADOW_TEXT_COLOR       = Color.new(200,200,200)

	INACTIVE_BASE_TEXT_COLOR = Color.new(105,105,105)
	INACTIVE_SHADOW_TEXT_COLOR = Color.new(130,130,130)

	def cursorFileLocation
		return _INTL("Graphics/Pictures/Pause/cursor_pause")
	end
	def tileFileLocation
		return _INTL("Graphics/Pictures/Pause/pause_menu_tile")
	end
	def backgroundFadeFileLocation
		return _INTL("Graphics/Pictures/Pause/background_fade")
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
		@columnLeft = BUTTON_COLUMN_LEFT_X
		@columnRight = BUTTON_COLUMN_RIGHT_X
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

		pbSEPlay("GUI menu open")

		drawButtons
	end

	def defaultCursorPosition; return 0; end

	def xFromIndex(index)
		info = @cardButtons[@cardButtons.keys[index]]
		if info[:position]
			return info[:position][0]
		end
		return index.even? ? @columnLeft : @columnRight
	end

	def yFromIndex(index)
		info = @cardButtons[@cardButtons.keys[index]]
		if info[:position]
			return info[:position][1]
		end
		return BUTTON_STARTING_Y + (index / 2) * BUTTON_ROW_HEIGHT
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
		#pbDisposeSpriteHash(@sprites)
		@buttonNameOverlay.dispose
		@viewport.dispose
		@tileBitmap.dispose
		@bgBitmap.dispose
		@cursorBitmap.dispose
	end
  
	def drawButtons
		@tiles.each_pair do |buttonID, tileSprite|
			next if buttonActive?(buttonID)
			tileSprite.color =  INACTIVE_BUTTON_COLOR
		end
		@buttonNameOverlay.bitmap.clear
		buttonNamePositions = []
		@cardButtons.keys.each_with_index do |buttonID, index|
			label = @cardButtons[buttonID][:label] || "ERROR"
			x = xFromIndex(index)+8
			y = yFromIndex(index)+8
			if buttonActive?(buttonID)
				baseColor = BASE_TEXT_COLOR
				shadowColor = SHADOW_TEXT_COLOR
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
			onDebug = @buttonSelectionIndex == @cardButtons.keys.index(:DEBUG)
			if Input.trigger?(Input::BACK)
				closeMenu = true
			elsif Input.trigger?(Input::USE)
				if !buttonActive?(@buttonSelectionIndex)
					pbPlayBuzzerSE
					next
				end
				closeMenu = true if pressButton(@buttonSelectionIndex)
			elsif Input.trigger?(Input::UP)
				@buttonSelectionIndex -= 2 unless onDebug
			elsif Input.trigger?(Input::DOWN)
				@buttonSelectionIndex += 2 unless onDebug
			elsif Input.trigger?(Input::RIGHT)
				if $DEBUG && onDebug
					@buttonSelectionIndex = 0
				elsif !onDebug
					if @buttonSelectionIndex.even?
						@buttonSelectionIndex += 1
					else
						@buttonSelectionIndex -= 1
					end
				end
			elsif Input.trigger?(Input::LEFT)
				if @buttonSelectionIndex == 0 && $DEBUG
					@buttonSelectionIndex = @cardButtons.keys.index(:DEBUG)
				elsif !onDebug
					if @buttonSelectionIndex.even?
						@buttonSelectionIndex += 1
					else
						@buttonSelectionIndex -= 1
					end
				end
			end

			if @buttonSelectionIndex >= @cardButtons.keys.length
				@buttonSelectionIndex -= @cardButtons.keys.length
			elsif @buttonSelectionIndex < 0
				@buttonSelectionIndex += @cardButtons.keys.length
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
		if !$Trainer
		  if $DEBUG
			pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
			pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
		  end
		  return
		end
		@scene.pbStartScene
		@scene.promptButtons
		@scene.pbEndScene
  	end
end