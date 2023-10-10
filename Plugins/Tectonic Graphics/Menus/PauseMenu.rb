#===============================================================================
#
#===============================================================================
class TilingCardsPauseMenu_Scene < TilingCardsMenu_Scene
	def initializeMenuButtons
		super
		@cardButtons = {
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
						scene.drawButtons
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

						scene.drawButtons
					}
					else
					if $Trainer.pokedex.accessible_dexes.length == 1
						$PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
						pbFadeOutIn {
							dexScene = PokemonPokedex_Scene.new
							screen = PokemonPokedexScreen.new(dexScene)
							screen.pbStartScreen

							scene.drawButtons
						}
						else
						pbFadeOutIn {
							dexScene = PokemonPokedexMenu_Scene.new
							screen = PokemonPokedexMenuScreen.new(dexScene)
							screen.pbStartScreen

							scene.drawButtons
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
					(item) ? scene.pbEndScene : scene.drawButtons
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

						scene.drawButtons
					}
				}
			},
			:GAME_INFO => {
				:label => _INTL("Game Info"),
				:press_proc => Proc.new { |scene|
					storedLastMenuChoice = $PokemonTemp.menuLastChoice
					$PokemonTemp.menuLastChoice = 0
					
					pbPlayDecisionSE
					infoMenuScene = PokemonGameInfoMenu_Scene.new
					infoMenuScreen = PokemonGameInfoMenu.new(infoMenuScene)
					infoMenuScreen.pbStartPokemonMenu

					scene.drawButtons
					
					$PokemonTemp.menuLastChoice = storedLastMenuChoice
				},
			},
			:OPTIONS => {
				:label => _INTL("Options"),
				:press_proc => Proc.new { |scene|
					storedLastMenuChoice = $PokemonTemp.menuLastChoice
					$PokemonTemp.menuLastChoice = 0
					
					pbPlayDecisionSE
					optionScene = PokemonOption_Scene.new
					optionScreen = PokemonOptionMenu.new(optionScene)
					optionScreen.pbStartPokemonMenu

					scene.drawButtons

					$PokemonTemp.menuLastChoice = storedLastMenuChoice
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
						scene.drawButtons
						scene.pbShowMenu
					end
				}
			},
		}
		if $DEBUG
			@yOffset -= 20
			@buttonRowHeight -= 8
			@cardButtons[:DEBUG] = {
				:label => _INTL("Debug"),
				:press_proc => Proc.new { |scene|
					pbPlayDecisionSE
					pbFadeOutIn {
						pbDebugMenu
						scene.drawButtons
					}
				},
			}
		end
	end

	def onMenuClose
		$PokemonTemp.menuLastChoice = @buttonSelectionIndex
	end

	def defaultCursorPosition
		$PokemonTemp.menuLastChoice
	end

	def pbStartScene
		super
		pbSEPlay("GUI menu open")
	end
end
  

class TilingCardsPauseMenu < TilingCardsMenu_Screen
end