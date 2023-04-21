#===============================================================================
#
#===============================================================================
class PokemonPauseMenu_Scene
	def initializePauseMenuButtons 
		@pauseMenuButtons = {
			:POKEMON => {
				:label => _INTL("Pokémon"),
				:active_proc => Proc.new {
					$Trainer.party_count > 0
				},
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					pbFadeOutIn {
						sscene = PokemonParty_Scene.new
						sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
						sscreen.pbPokemonScreen
						scene.pbRefresh
					}
				},
			},
			:MASTERDEX =>  {
				:label => _INTL("MasterDex"),
				:active_proc => Proc.new {
					$Trainer.has_pokedex || $DEBUG
				},
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					if Settings::USE_CURRENT_REGION_DEX
					pbFadeOutIn {
						dexScene = PokemonPokedex_Scene.new
						screen = PokemonPokedexScreen.new(dexScene)
						screen.pbStartScreen

						scene.pbRefresh
					}
					else
					if $Trainer.pokedex.accessible_dexes.length == 1
						$PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
						pbFadeOutIn {
							dexScene = PokemonPokedex_Scene.new
							screen = PokemonPokedexScreen.new(dexScene)
							screen.pbStartScreen

							scene.pbRefresh
						}
						else
						pbFadeOutIn {
							dexScene = PokemonPokedexMenu_Scene.new
							screen = PokemonPokedexMenuScreen.new(dexScene)
							screen.pbStartScreen

							scene.pbRefresh
						}
						end
					end
				},
			},
			:BAG => {
				:label => _INTL("Item Bag"),
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					item = nil
					pbFadeOutIn {
					bagScene = PokemonBag_Scene.new
					screen = PokemonBagScreen.new(bagScene,$PokemonBag)
					item = screen.pbStartScreen
					(item) ? scene.pbEndScene : scene.pbRefresh
					}
					if item
					$game_temp.in_menu = false
					pbUseKeyItemInField(item)
					next true
					end
				},
			},
			:DEXNAV => {
				:label => _INTL("DexNav"),
				:active_proc => Proc.new {
					next dexNavActive?
				},
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					pbFadeOutIn {
						dexnavScene = NewDexNav.new
						scene.pbEndScene
						next true
					}
				}
			},
			:TRIBAL_BONUS => {
				:label => _INTL("Tribes"),
				:press_proc => Proc.new { |scene|
					pbFadeOutIn {
						tribalBonusScene = TribalBonusScene.new
						screen = TribalBonusScreen.new(tribalBonusScene)
						screen.pbStartScreen

						scene.pbRefresh
					}
				}
			},
			:GAME_INFO => {
				:label => _INTL("Game Info"),
				:press_proc => Proc.new { |scene|
					storedLastMenuChoice = $PokemonTemp.menuLastChoice
					
					$PokemonTemp.menuLastChoice = 0
					infoMenuScene = PokemonGameInfoMenu_Scene.new
					infoMenuScreen = PokemonGameInfoMenu.new(infoMenuScene)
					infoMenuScreen.pbStartPokemonMenu

					scene.pbRefresh
					
					$PokemonTemp.menuLastChoice = storedLastMenuChoice
				},
			},
			:OPTIONS => {
				:label => _INTL("Options"),
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					pbFadeOutIn {
						optionsScene = PokemonOption_Scene.new
						screen = PokemonOptionScreen.new(optionsScene)
						screen.pbStartScreen
						pbUpdateSceneMap

						scene.pbRefresh
					}
				},
			},
			:SAVE => {
				:label => _INTL("Save/Quit"),
				:active_proc => Proc.new {
					next !$game_system.nil? && !$game_system.save_disabled
				},
				:press_proc => Proc.new { |scene|
					scene.pbHideMenu
					saveScene = PokemonSave_Scene.new
					screen = PokemonSaveScreen.new(saveScene)
					if screen.pbSaveScreen(true)
						scene.pbEndScene
						$scene = nil
						next true
					else
						scene.pbRefresh
						scene.pbShowMenu
					end
				}
			},
		}
		@columnLeft = BUTTON_COLUMN_LEFT_X
		@columnRight = BUTTON_COLUMN_RIGHT_X
		if $DEBUG
			@columnLeft += 48
			@columnRight += 48
			@pauseMenuButtons[:DEBUG] = {
				:label => _INTL("Debug"),
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					pbFadeOutIn {
						pbDebugMenu
						scene.pbRefresh
					}
				},
				:position => [@columnLeft - 142, BUTTON_STARTING_Y]
			}
		end
	end

	BUTTON_COLUMN_LEFT_X = 124
	BUTTON_COLUMN_RIGHT_X = 266
	BUTTON_STARTING_Y = 36
	BUTTON_ROW_HEIGHT = 80

	INACTIVE_BUTTON_COLOR = Color.new(80, 80, 80, 80)

	BASE_TEXT_COLOR         = Color.new(60,60,60)
  	SHADOW_TEXT_COLOR       = Color.new(200,200,200)

	INACTIVE_BASE_TEXT_COLOR = Color.new(105,105,105)
	INACTIVE_SHADOW_TEXT_COLOR = Color.new(130,130,130)
	
	def pbStartScene
		initializePauseMenuButtons

		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99_999
		@sprites = {}
		@sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["helpwindow"].visible = false
		@bgBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pause/background_fade"))
		@sprites["bg_fade"] = SpriteWrapper.new(@viewport)
		@sprites["bg_fade"].x = 0
		@sprites["bg_fade"].y = 0
		@sprites["bg_fade"].bitmap = @bgBitmap.bitmap
		@sprites["bg_fade"].visible = true
		@sprites["bg_fade"].opacity = 20
		@sprites["bg_fade"].z = -1
		@cursorBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pause/cursor_pause"))
		@sprites["cursor"] = SpriteWrapper.new(@viewport)
		@sprites["cursor"].bitmap = @cursorBitmap.bitmap
		@tileBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pause/pause_menu_tile"))
		@buttonNameOverlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@buttonNameOverlay.z = 1
		pbSetSystemFont(@buttonNameOverlay.bitmap)
		@tiles = {}
		@pauseMenuButtons.keys.each_with_index do |buttonID, index|
			newButton = SpriteWrapper.new(@viewport)
			@sprites["button_#{buttonID.to_s}"] = newButton
			newButton.bitmap = @tileBitmap.bitmap
			@tiles[buttonID] = newButton

			newButton.x = xFromIndex(index)
			newButton.y = yFromIndex(index)
			newButton.visible = true
		end
		@infostate = false
		@helpstate = false
		$viewport4 = @viewport

		@buttonSelectionIndex = $PokemonTemp.menuLastChoice || 0

		pbSEPlay("GUI menu open")

		pbRefresh
	end

	def xFromIndex(index)
		info = @pauseMenuButtons[@pauseMenuButtons.keys[index]]
		if info[:position]
			return info[:position][0]
		end
		return index.even? ? @columnLeft : @columnRight
	end

	def yFromIndex(index)
		info = @pauseMenuButtons[@pauseMenuButtons.keys[index]]
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
		pbDisposeSpriteHash(@sprites)
		@buttonNameOverlay.dispose
		@viewport.dispose
		@tileBitmap.dispose
		@bgBitmap.dispose
		@cursorBitmap.dispose
	end
  
	def pbRefresh
		@tiles.each_pair do |buttonID, tileSprite|
			next if buttonActive?(buttonID)
			tileSprite.color =  INACTIVE_BUTTON_COLOR
		end
		@buttonNameOverlay.bitmap.clear
		buttonNamePositions = []
		@pauseMenuButtons.keys.each_with_index do |buttonID, index|
			label = @pauseMenuButtons[buttonID][:label] || "ERROR"
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
		buttonID = @pauseMenuButtons.keys[buttonID] if buttonID.is_a?(Integer)
		return @pauseMenuButtons.keys.index(buttonID) == @buttonSelectionIndex
	end

	def buttonActive?(buttonID)
		buttonID = @pauseMenuButtons.keys[buttonID] if buttonID.is_a?(Integer)
		active = true
		if @pauseMenuButtons[buttonID][:active_proc]
			active = @pauseMenuButtons[buttonID][:active_proc].call
		end
		return active
	end

	def pressButton(buttonID)
		buttonID = @pauseMenuButtons.keys[buttonID] if buttonID.is_a?(Integer)
		return @pauseMenuButtons[buttonID][:press_proc].call(self) == true
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
			onDebug = @buttonSelectionIndex == @pauseMenuButtons.keys.index(:DEBUG)
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
					@buttonSelectionIndex = @pauseMenuButtons.keys.index(:DEBUG)
				elsif !onDebug
					if @buttonSelectionIndex.even?
						@buttonSelectionIndex += 1
					else
						@buttonSelectionIndex -= 1
					end
				end
			end

			if @buttonSelectionIndex >= @pauseMenuButtons.keys.length
				@buttonSelectionIndex -= @pauseMenuButtons.keys.length
			elsif @buttonSelectionIndex < 0
				@buttonSelectionIndex += @pauseMenuButtons.keys.length
			end

			if closeMenu
				$PokemonTemp.menuLastChoice = @buttonSelectionIndex
				pbPlayCloseMenuSE
				return
			end

			if @buttonSelectionIndex != prevButtonSelectionIndex
				pbPlayCursorSE
				pbRefresh
			end
		end
	end
end
  

class PokemonPauseMenu
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