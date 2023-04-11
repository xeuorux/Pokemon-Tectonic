#===============================================================================
#
#===============================================================================
class PokemonPauseMenu_Scene
	PAUSE_MENU_BUTTONS = {
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
			:label => _INTL("Save"),
			:active_proc => Proc.new {
				next !$game_system.nil? && !$game_system.save_disabled
			},
			:press_proc => Proc.new { |scene|
				scene.pbHideMenu
				saveScene = PokemonSave_Scene.new
				screen = PokemonSaveScreen.new(saveScene)
				if screen.pbSaveScreen
					scene.pbEndScene
				else
					scene.pbRefresh
					scene.pbShowMenu
				end
			}
		},
		:QUIT_GAME => {
			:label => _INTL("Quit Game"),
			:press_proc => Proc.new { |scene|
				scene.pbHideMenu
				if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
					saveScene = PokemonSave_Scene.new
					screen = PokemonSaveScreen.new(saveScene)
					if screen.pbSaveScreen(true)
						scene.pbEndScene
					end
					scene.pbEndScene
					$scene = nil
					return true
				else
					scene.pbRefresh
					scene.pbShowMenu
				end
			},
		},
		# :DEBUG => {
		# 	:label => _INTL("Debug"),
		# 	:active_proc => Proc.new {
		# 		$DEBUG
		# 	},
		# 	:press_proc => Proc.new { |scene|
		# 		pbPlayDecisionSE
		# 		pbFadeOutIn {
		# 			pbDebugMenu
		# 			scene.pbRefresh
		# 		}
		# 	},
		# },
	}

	BUTTON_COLUMN_LEFT_X = 224
	BUTTON_COLUMN_RIGHT_X = 366
	BUTTON_STARTING_Y = 16
	BUTTON_ROW_HEIGHT = 80

	ACTIVE_UNSELECTED_COLOR = Color.new(100, 100, 80, 40)
	INACTIVE_UNSELECTED_COLOR = Color.new(100, 100, 80, 65)

	ACTIVE_SELECTED_COLOR = Color.new(100, 100, 80, 120)
	INACTIVE_SELECTED_COLOR = Color.new(100, 100, 80, 180)

	BASE_COLOR         = Color.new(72,72,72)
	INACTIVE_BASE_COLOR = Color.new(110,110,110)
  	SHADOW_COLOR       = Color.new(184,184,184)
	INACTIVE_SHADOW_COLOR = Color.new(150,150,150)
	
	def pbStartScene
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["helpwindow"].visible = false
		@tileBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Pause/pause_menu_tile"))
		@buttonNameOverlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@buttonNameOverlay.z = 1
		pbSetSystemFont(@buttonNameOverlay.bitmap)
		@tiles = {}
		PAUSE_MENU_BUTTONS.keys.each_with_index do |buttonID, index|
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
		return index.even? ? BUTTON_COLUMN_LEFT_X : BUTTON_COLUMN_RIGHT_X
	end

	def yFromIndex(index)
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
	end
  
	def pbRefresh
		@tiles.each_pair do |buttonID, tileSprite|
			if selectedButton?(buttonID)
				tileSprite.color = buttonActive?(buttonID) ? ACTIVE_SELECTED_COLOR : INACTIVE_SELECTED_COLOR
			else
				tileSprite.color = buttonActive?(buttonID) ? ACTIVE_UNSELECTED_COLOR : INACTIVE_UNSELECTED_COLOR
			end
			
		end
		@buttonNameOverlay.bitmap.clear
		buttonNamePositions = []
		PAUSE_MENU_BUTTONS.keys.each_with_index do |buttonID, index|
			label = PAUSE_MENU_BUTTONS[buttonID][:label] || "ERROR"
			x = xFromIndex(index)+8
			y = yFromIndex(index)+8
			outlined = false
			if selectedButton?(buttonID)
				outlined = true
				y += 4
			end
			if buttonActive?(buttonID)
				baseColor = BASE_COLOR
				shadowColor = SHADOW_COLOR
			else
				baseColor = INACTIVE_BASE_COLOR
				shadowColor = INACTIVE_SHADOW_COLOR
				outlined = false
			end
			buttonNamePositions.push([label,x,y,false,baseColor,shadowColor,outlined])
		end
		pbDrawTextPositions(@buttonNameOverlay.bitmap,buttonNamePositions)
	end

	def selectedButton?(buttonID)
		buttonID = PAUSE_MENU_BUTTONS.keys[buttonID] if buttonID.is_a?(Integer)
		return PAUSE_MENU_BUTTONS.keys.index(buttonID) == @buttonSelectionIndex
	end

	def buttonActive?(buttonID)
		buttonID = PAUSE_MENU_BUTTONS.keys[buttonID] if buttonID.is_a?(Integer)
		active = true
		if PAUSE_MENU_BUTTONS[buttonID][:active_proc]
			active = PAUSE_MENU_BUTTONS[buttonID][:active_proc].call
		end
		return active
	end

	def pressButton(buttonID)
		buttonID = PAUSE_MENU_BUTTONS.keys[buttonID] if buttonID.is_a?(Integer)
		return PAUSE_MENU_BUTTONS[buttonID][:press_proc].call(self) == true
	end

	def promptButtons
		loop do
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
				@buttonSelectionIndex -= 2
			elsif Input.trigger?(Input::DOWN)
				@buttonSelectionIndex += 2
			elsif Input.trigger?(Input::RIGHT)
				if @buttonSelectionIndex.even?
					@buttonSelectionIndex += 1
				else
					@buttonSelectionIndex -= 1
				end
			elsif Input.trigger?(Input::LEFT)
				if @buttonSelectionIndex.even?
					@buttonSelectionIndex += 1
				else
					@buttonSelectionIndex -= 1
				end
			end

			if @buttonSelectionIndex > PAUSE_MENU_BUTTONS.keys.length
				@buttonSelectionIndex -= PAUSE_MENU_BUTTONS.keys.length
			elsif @buttonSelectionIndex < 0
				@buttonSelectionIndex += PAUSE_MENU_BUTTONS.keys.length
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