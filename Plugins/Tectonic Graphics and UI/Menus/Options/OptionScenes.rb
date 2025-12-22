#===============================================================================
#
#===============================================================================
class PokemonOption_Scene_Base
  def pbUpdate
      pbUpdateSpriteHash(@sprites)
  end

  def optionsName
      return _INTL("Options")
  end

  def pbStartScene(_inloadscreen = false)
      @sprites = {}
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99_999
      @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
          optionsName, 0, 0, Graphics.width, 64, @viewport)
      @sprites["textbox"] = pbCreateMessageWindow
      @sprites["textbox"].text           = _INTL("Speech frame {1}.", 1 + $Options.textskin)
      @sprites["textbox"].letterbyletter = false
      pbSetSystemFont(@sprites["textbox"].contents)
      # These are the different options in the game. To add an option, define a
      # setter and a getter for that option. To delete an option, comment it out
      # or delete it. The game's options may be placed in any order.
      @PokemonOptions = []
      @PokemonOptions = pbAddOnOptions(@PokemonOptions)
      @sprites["option"] = Window_PokemonOption.new(@PokemonOptions, 0,
         @sprites["title"].height, Graphics.width,
         Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
      @sprites["option"].viewport = @viewport
      @sprites["option"].visible  = true
      # Get the values of each option
      for i in 0...@PokemonOptions.length
          @sprites["option"].setValueNoRefresh(i, (@PokemonOptions[i].get || 0))
      end
      @sprites["textbox"].text = @PokemonOptions[0].description
      @sprites["option"].refresh
      pbDeactivateWindows(@sprites)
      pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbAddOnOptions(options)
      return options
  end

  def pbOptions
      oldSystemSkin = $Options.frame # Menu
      oldTextSkin = $Options.textskin # Speech
      oldIndex = @sprites["option"].index
      pbActivateWindow(@sprites, "option") do
          loop do
              Graphics.update
              Input.update
              pbUpdate

              if @sprites["option"].index != oldIndex
                  if @sprites["option"].index < @PokemonOptions.length
                      @sprites["textbox"].text = @PokemonOptions[@sprites["option"].index].description
                  else
                      @sprites["textbox"].text = ""
                  end
              end
              oldIndex = @sprites["option"].index

              if @sprites["option"].mustUpdateOptions
                  # Set the values of each option
                  for i in 0...@PokemonOptions.length
                      @PokemonOptions[i].set(@sprites["option"][i])
                  end
                  if $Options.textskin != oldTextSkin
                      @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
                      oldTextSkin = $Options.textskin
                  end
                  if $Options.frame != oldSystemSkin
                      @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame)
                      @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
                      oldSystemSkin = $Options.frame
                  end
              end
              if Input.trigger?(Input::BACK)
                  break
              elsif Input.trigger?(Input::USE)
                  break if @sprites["option"].index == @PokemonOptions.length
              end
          end
      end
  end

  def pbEndScene
      pbPlayCloseMenuSE
      pbFadeOutAndHide(@sprites) { pbUpdate }
      # Set the values of each option
      for i in 0...@PokemonOptions.length
          @PokemonOptions[i].set(@sprites["option"][i])
      end
      pbDisposeMessageWindow(@sprites["textbox"])
      pbDisposeSpriteHash(@sprites)
      pbRefreshSceneMap
      @viewport.dispose
  end
end

#===============================================================================
# Audio options scene
#===============================================================================
class PokemonOption_Scene_Audio < PokemonOption_Scene_Base
    def optionsName
        return _INTL("Audio Options")
    end

	def pbAddOnOptions(options)
		options.concat([
			SliderOption.new(
                _INTL("Music Volume"),
                _INTL("The loudness of background music, fanfares, and jingles."),
                0, 100, 5,
				proc { $Options.bgmvolume * VOLUME_FAKERY_MULT },
				proc { |value|
					if $Options.bgmvolume * VOLUME_FAKERY_MULT != value
						$Options.bgmvolume = value
						if !$game_system.playing_bgm.nil?
							playingBGM = $game_system.getPlayingBGM
							$game_system.bgm_pause
							$game_system.bgm_resume(playingBGM)
						end
					end
				}
			),
			SliderOption.new(
                _INTL("SE Volume"),
                _INTL("The loudness of sound effects, both in and out of battle."),
                0, 100, 5,
				proc { $Options.sevolume * VOLUME_FAKERY_MULT },
				proc { |value|
					if $Options.sevolume * VOLUME_FAKERY_MULT != value
						$Options.sevolume = value
						unless $game_system.playing_bgs.nil?
							$game_system.playing_bgs.volume = $Options.sevolume
							playingBGS = $game_system.getPlayingBGS
							$game_system.bgs_pause
							$game_system.bgs_resume(playingBGS)
						end
						pbPlayCursorSE
					end
				}
			),
            EnumOption.new(
                _INTL("Bicycle Music"),
                _INTL("Whether to play special music while riding the bicycle."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.bike_bgm },
				proc { |value|
					$Options.bike_bgm = value
				}
			),
		])
	end
end

#===============================================================================
# UI Speed options scene
#===============================================================================
class PokemonOption_Scene_Speed < PokemonOption_Scene_Base
    def optionsName
        return _INTL("User Interface Speed Options")
    end

	def pbAddOnOptions(options)
		options.concat([
			EnumOption.new(
                _INTL("Text Speed"),
                _INTL("How quickly to display text in message boxes."),
                [_INTL("1"), _INTL("2"), _INTL("3"), _INTL("4"), _INTL("5")],
				proc { $Options.textspeed },
				proc { |value|
                    if value >= 4 && $Options.textspeed < 4 && $scene.is_a?(Scene_Map) && !$PokemonGlobal.customSpeedTutorialized
                        playCustomSpeedTutorial
                    end
					$Options.textspeed = value
					MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
				}
			),
			EnumOption.new(
                _INTL("Nicknaming Prompt"),
                _INTL("Whether the game should ask you to set nicknames for newly caught Pokémon."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.nicknaming_prompt },
				proc { |value|
					$Options.nicknaming_prompt = value
				}
			),
            EnumOption.new(
                _INTL("Dex Register Popup"),
                _INTL("Whether to show a species' MasterDex entry when you first catch one."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.dex_shown_register },
				proc { |value|
					$Options.dex_shown_register = value
				}
			),
			EnumOption.new(
                _INTL("Item Popups"),
                _INTL("Whether to show an item's description when you acquire one for the first time."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.show_item_descriptions },
				proc { |value|
					$Options.show_item_descriptions = value
				}
			),
			EnumOption.new(
                _INTL("Trait Unlock Popups"),
                _INTL("Whether to alert you when one of your Pokémon reveals personality traits."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.show_trait_unlocks },
				proc { |value|
					$Options.show_trait_unlocks = value
				}
			),
			EnumOption.new(
                _INTL("Team Snapshots"),
                _INTL("Whether to automatically take screenshots of your Party Showcase after major victories."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.party_snapshots },
				proc { |value|
					$Options.party_snapshots = value
				}
			),
            EnumOption.new(
                _INTL("Prompt Level Moves"),
                _INTL("Whether to let your Pokémon learn new moves when leveling up."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.prompt_level_moves },
				proc { |value|
					$Options.prompt_level_moves = value
				}
			),
            EnumOption.new(
                _INTL("Show Stat Changes"),
                _INTL("Whether to show how your Pokémon's stats change on level up or evolution."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.show_stat_changes },
				proc { |value|
					$Options.show_stat_changes = value
				}
			),
            EnumOption.new(
                _INTL("Aid Kit Animation"),
                _INTL("Whether to play an animation showing your party being healed by the Aid Kit."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.aid_kit_animation },
				proc { |value| $Options.aid_kit_animation = value }
			),
            EnumOption.new(
                _INTL("Quick Evolution"),
                _INTL("Whether to shorten the cutscene that plays when a Pokémon evolves."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.quick_evolution },
				proc { |value| $Options.quick_evolution = value }
			),
		])
	end
end

#===============================================================================
# User Interface options scene
#===============================================================================
class PokemonOption_Scene_UserInterface < PokemonOption_Scene_Base
    def optionsName
        return _INTL("User Interface Options")
    end

	def pbAddOnOptions(options)
		options.concat([
            EnumOption.new(
                _INTL("Screen Size"),
                _INTL("How large the game screen is."),
                [_INTL("S"),_INTL("M"),_INTL("L"),_INTL("XL"),_INTL("Full")],
                proc { [$Options.screensize, 4].min },
                proc { |value|
                if $Options.screensize != value
                    $Options.screensize = value
                    pbSetResizeFactor($Options.screensize)
                end
                }
            ),
            EnumOption.new(
                _INTL("Dark Mode"),
                _INTL("Whether or not user interface elements use a darker color scheme."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.dark_mode },
				proc { |value|
                    $Options.dark_mode = value
                    $Options.setSystemFrame
                    $Options.setSpeechFrame
                    @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
                    @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
                    @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame)
                }
			),
			NumberOption.new(
                _INTL("Speech Frame"),
                _INTL("Which frame surrounds message boxes."),
                1, Settings::SPEECH_WINDOWSKINS.length,
				proc { $Options.textskin },
				proc { |value|
					$Options.textskin = value
					@sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame)
				}
			),
			NumberOption.new(
                _INTL("Menu Frame"),
                _INTL("Which frame surrounds other user interface menus."),
                1, Settings::MENU_WINDOWSKINS.length,
				proc { $Options.frame },
				proc { |value|
					$Options.frame = value
                    @sprites["option"].setSkin(MessageConfig.pbGetSystemFrame)
                    @sprites["title"].setSkin(MessageConfig.pbGetSystemFrame)
				}
			),
			EnumOption.new(
                _INTL("Text Entry"),
                _INTL("Which method you want to use to enter text."),
                [_INTL("Cursor"), _INTL("Keyboard")],
				proc { $Options.textinput },
				proc { |value| $Options.textinput = value }
			),
			EnumOption.new(
                _INTL("Bag Sorting"),
                _INTL("How should items in your bag be sorted? Automatic."),
                [_INTL("Off"), _INTL("Name"), _INTL("Type")],
				proc { $Options.bag_sorting },
				proc { |value|
					$Options.bag_sorting = value
					$PokemonBag.sortItems if $scene.is_a?(Scene_Map)
				}
			),
            EnumOption.new(_INTL("Name on Showcase"),
                _INTL("Whether or not to put your player name on Party Showcases."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.name_on_showcases },
				proc { |value|
					$Options.name_on_showcases = value
				}
			),
            EnumOption.new(
                _INTL("Advanced Tutorials"),
                _INTL("Whether to show popups explaining changes and new mechanics."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.tutorial_popups },
				proc { |value|
					$Options.tutorial_popups = value
				}
			),
		])
	end
end

#===============================================================================
# Battle options scene
#===============================================================================
class PokemonOption_Scene_Battle < PokemonOption_Scene_Base
    def optionsName
        return _INTL("Battle Options")
    end

	def pbAddOnOptions(options)
		options.concat([
			EnumOption.new(
                _INTL("Battle Effects"),
                _INTL("How to treat move and effect animations. Fast is 2x speed."),
                [_INTL("Standard"), _INTL("Fast"), _INTL("Off")],
				proc { $Options.battlescene },
				proc { |value| $Options.battlescene = value }
			),
			EnumOption.new(
                _INTL("Battle Transitions"),
                _INTL("Whether to speed up animations like starting battle or switching battlers."),
                [_INTL("Standard"), _INTL("Fast")],
				proc { $Options.battle_transitions },
				proc { |value| $Options.battle_transitions = value }
			),
			EnumOption.new(
                _INTL("Damage Numbers"),
                _INTL("Whether to display how much damage an attack did over the Pokémon's head."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.damage_numbers },
				proc { |value|
					$Options.damage_numbers = value
				}
			),
			EnumOption.new(
                _INTL("Effect. Messages"),
                _INTL("Whether to state how effective a move was."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.effectiveness_messages },
				proc { |value|
					$Options.effectiveness_messages = value
				}
			),
			EnumOption.new(
                _INTL("Weather Messages"),
                _INTL("Whether to show messages about weather mechanics."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.weather_messages },
				proc { |value|
					$Options.weather_messages = value
				}
			),
			EnumOption.new(
                _INTL("Status Messages"),
                _INTL("Whether to show messages about status condition mechanics."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.status_effect_messages },
				proc { |value|
					$Options.status_effect_messages = value
				}
			),
			EnumOption.new(
                _INTL("Move Messages"),
                _INTL("Whether to show messages when moves change base power or category."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.move_clarifying_messages },
				proc { |value|
					$Options.move_clarifying_messages = value
				}
			),
            EnumOption.new(
                _INTL("Avatar Messages"),
                _INTL("Whether to show messages about avatar mechanics."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.avatar_mechanics_messages },
				proc { |value|
					$Options.avatar_mechanics_messages = value
				}
			),
		])
	end
end

#===============================================================================
# Overworld options scene
#===============================================================================
class PokemonOption_Scene_Overworld < PokemonOption_Scene_Base
    def optionsName
        return _INTL("Overworld Options")
    end

	def pbAddOnOptions(options)
		options.concat([
			EnumOption.new(
                _INTL("Default Movement"),
                _INTL("Whether walking or running should be your player character's default."),
                [_INTL("Walking"), _INTL("Running")],
				proc { $Options.runstyle },
				proc { |value| $Options.runstyle = value }
			),
			EnumOption.new(
                _INTL("Autosave"),
                _INTL("Whether the game should save when healing and every 40 steps taken."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.autosave },
				proc { |value|
					$Options.autosave = value
				}
			),
			EnumOption.new(
                _INTL("Pokémon Follow"),
                _INTL("Whether your first Pokémon follows behind you."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.followers },
				proc { |value|
					$Options.followers = value
					pbToggleFollowingPokemon($Options.followers == 0 ? "on" : "off", false) if $scene.is_a?(Scene_Map)
				}
			),
            EnumOption.new(
                _INTL("World Weather"),
                _INTL("Whether overworld areas experience random weathers."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.overworld_weather },
				proc { |value|
					$Options.overworld_weather = value
                    if $scene.is_a?(Scene_Map)
                        if value == 0
                            applyOutdoorEffects
                        else
                            $game_screen.resetWeather
                        end
                    end
				}
			),
            EnumOption.new(
                _INTL("Flashing"),
                _INTL("Whether lightning storms display a flashing lightning effect."),
                [_INTL("On"), _INTL("Off")],
                proc { $Options.flashing_weather },
                proc { |value|
                    $Options.flashing_weather = value
                }
            ),
            EnumOption.new(
                _INTL("Force Time"),
                _INTL("Force the overworld lighting of a certain hour of the day."),
                [_INTL("Off"), _INTL("6"), _INTL("12"), _INTL("18"), _INTL("24")],
				proc { $Options.forced_time_tint },
				proc { |value|
					$Options.forced_time_tint = value
                    PBDayNight.sheduleToneRefresh
				}
			),
		])
	end
end

#===============================================================================
# Advanced Graphics options scene
#===============================================================================
class PokemonOption_Scene_AdvancedGraphics < PokemonOption_Scene_Base
    def optionsName
        return _INTL("Advanced Graphics Options")
    end

	def pbAddOnOptions(options)
		options.concat([
			EnumOption.new(
                _INTL("Color Shifts"),
                _INTL("Whether Pokémon have unique appearances. Disable if laggy."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.color_shifts },
				proc { |value|
					$Options.color_shifts = value
				}
			),
			EnumOption.new(
                _INTL("Particles"),
                _INTL("Whether to display particle effects. Disable if laggy."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.particle_effects },
				proc { |value|
					$Options.particle_effects = value
				}
			),
			EnumOption.new(
                _INTL("Screenshake"),
                _INTL("Whether to use screen shake effects. Disable if laggy."),
                [_INTL("On"), _INTL("Off")],
				proc { $Options.screenshake },
				proc { |value|
					$Options.screenshake = value
				}
			),
		])
	end
end