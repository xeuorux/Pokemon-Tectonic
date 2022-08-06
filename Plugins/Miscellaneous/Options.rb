class PokemonSystem
	attr_accessor :followers
	attr_accessor :autosave
	attr_accessor :particle_effects
	attr_accessor :skip_fades
	attr_accessor :gendered_look
	attr_accessor :damage_numbers
	attr_accessor :show_item_descriptions
	attr_accessor :effectiveness_messages
  attr_accessor :status_effect_messages
  attr_accessor :nicknaming_prompt

  def initialize
    @textspeed   		          = 1 # Text speed (0=slow, 1=normal, 2=fast, 3=rapid)
    @battlescene 		          = 0 # Battle effects (animations) (0=on, 1=fast, 2=off)
    @battlestyle 		          = 1 # Battle style (0=switch, 1=set)
    @frame      		          = 0 # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin    		          = 0 # Speech frame
    @font        		          = 0 # Font (see also Settings::FONT_OPTIONS)
    @screensize  		          = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language    		          = 0 # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle    		          = 0 # Default movement speed (0=walk, 1=run)
    @bgmvolume  		          = 30 # Volume of background music and ME
    @sevolume    		          = 30 # Volume of sound effects
    @textinput   		          = 1 # Text input mode (0=cursor, 1=keyboard)
    @followers   		          = 0	# Follower Pokemon enabled (0=true, 1=false)
    @autosave	 		            = 1	# Autosave enabled (0=true, 1=false)
    @particle_effects 	      = 0 # (0=true, 1=false)
    @skip_fades 		          = 1 # (0=true, 1=false)
    @gendered_look 		        = 0 # (0 = Masc, 1 = Fem)
    @damage_numbers 	        = 0 # (0=true, 1=false)
    @show_item_descriptions   = 0 # (0=true, 1=false)
    @effectiveness_messages   = 0 # (0=true, 1=false)
    @status_effect_messages   = 0 # (0=true, 1=false)
    @nicknaming_prompt        = 0 # (0=true, 1=false)
  end
end

class PokemonOption_Scene
  def pbStartScene(inloadscreen=false)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = [
       SliderOption.new(_INTL("Music Volume"),0,100,5,
         proc { $PokemonSystem.bgmvolume },
         proc { |value|
           if $PokemonSystem.bgmvolume!=value
             $PokemonSystem.bgmvolume = value
             if $game_system.playing_bgm!=nil && !inloadscreen
               playingBGM = $game_system.getPlayingBGM
               $game_system.bgm_pause
               $game_system.bgm_resume(playingBGM)
             end
           end
         }
       ),
       SliderOption.new(_INTL("SE Volume"),0,100,5,
         proc { $PokemonSystem.sevolume },
         proc { |value|
           if $PokemonSystem.sevolume!=value
             $PokemonSystem.sevolume = value
             if $game_system.playing_bgs!=nil
               $game_system.playing_bgs.volume = value
               playingBGS = $game_system.getPlayingBGS
               $game_system.bgs_pause
               $game_system.bgs_resume(playingBGS)
             end
             pbPlayCursorSE
           end
         }
       ),
       EnumOption.new(_INTL("Text Speed"),[_INTL("1"),_INTL("2"),_INTL("3"),_INTL("4"),_INTL("5")],
         proc { $PokemonSystem.textspeed },
         proc { |value|
           $PokemonSystem.textspeed = value
           MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
         }
       ),
       EnumOption.new(_INTL("Battle Effects"),[_INTL("Standard"),_INTL("Fast"),_INTL("Off")],
         proc { $PokemonSystem.battlescene },
         proc { |value| $PokemonSystem.battlescene = value }
       ),
       EnumOption.new(_INTL("Default Movement"),[_INTL("Walking"),_INTL("Running")],
         proc { $PokemonSystem.runstyle },
         proc { |value| $PokemonSystem.runstyle = value }
       ),
       NumberOption.new(_INTL("Speech Frame"),1,Settings::SPEECH_WINDOWSKINS.length,
         proc { $PokemonSystem.textskin },
         proc { |value|
           $PokemonSystem.textskin = value
           MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
         }
       ),
       NumberOption.new(_INTL("Menu Frame"),1,Settings::MENU_WINDOWSKINS.length,
         proc { $PokemonSystem.frame },
         proc { |value|
           $PokemonSystem.frame = value
           MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
         }
       ),
       EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
         proc { $PokemonSystem.textinput },
         proc { |value| $PokemonSystem.textinput = value }
       ),
       EnumOption.new(_INTL("Nicknaming Prompt"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.nicknaming_prompt },
         proc { |value|
			    $PokemonSystem.nicknaming_prompt = value
         }
       ),
       EnumOption.new(_INTL("Damage Numbers"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.damage_numbers },
         proc { |value|
			    $PokemonSystem.damage_numbers = value
         }
       ),
       EnumOption.new(_INTL("Effectiveness Msgs"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.effectiveness_messages },
         proc { |value|
			    $PokemonSystem.effectiveness_messages = value
         }
       ),
      EnumOption.new(_INTL("Status Condition Msgs"),[_INTL("On"),_INTL("Off")],
        proc { $PokemonSystem.status_effect_messages },
        proc { |value|
          $PokemonSystem.status_effect_messages = value
        }
      ),
      EnumOption.new(_INTL("Item Desc Popups"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.show_item_descriptions },
         proc { |value|
			    $PokemonSystem.show_item_descriptions = value
         }
       ),
      EnumOption.new(_INTL("Autosave"),[_INTL("On"),_INTL("Off")],
        proc { $PokemonSystem.autosave },
        proc { |value|
          $PokemonSystem.autosave = value
        }
        ),
      EnumOption.new(_INTL("Particles (Adv.)"),[_INTL("On"),_INTL("Off")],
        proc { $PokemonSystem.particle_effects },
        proc { |value|
            $PokemonSystem.particle_effects = value
        }
      ),
      EnumOption.new(_INTL("Look"),[_INTL("Masc."),_INTL("Fem.")],
         proc { $PokemonSystem.gendered_look },
         proc { |value|
          pbChangePlayer(value)
         }
      ),
	    EnumOption.new(_INTL("Pokemon Follow"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.followers },
         proc { |value|
			      $PokemonSystem.followers = value
            pbToggleFollowingPokemon($PokemonSystem.followers == 0 ? "on" : "off",false)
         }
      ),
    ]
	  @PokemonOptions.push(EnumOption.new(_INTL("Skip Fades"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.skip_fades },
         proc { |value|
			      $PokemonSystem.skip_fades = value
         }
       )) if $DEBUG
    @PokemonOptions = pbAddOnOptions(@PokemonOptions)
    @sprites["option"] = Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"].setValueNoRefresh(i,(@PokemonOptions[i].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
 end

 module MessageConfig
	def self.pbSettingToTextSpeed(speed)
		case speed
		when 0 then return 2
		when 1 then return 1
		when 2 then return -2
		when 3 then return -5
		when 4 then return -20
		end
    return TEXT_SPEED || 1
  end
end

class Window_PokemonOption < Window_DrawableCommand
  def drawItem(index,_count,rect)
    rect = drawCursor(index,rect)
    optionname = (index==@options.length) ? _INTL("Exit") : @options[index].name
    optionwidth = rect.width*9/20
    pbDrawShadowText(self.contents,rect.x,rect.y,optionwidth,rect.height,optionname,
       @nameBaseColor,@nameShadowColor)
    return if index==@options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length>1
        totalwidth = 0
        for value in @options[index].values
          totalwidth += self.contents.text_size(value).width
        end
        spacing = (optionwidth-totalwidth)/(@options[index].values.length-1)
        spacing = 0 if spacing<0
        xpos = optionwidth+rect.x
        ivalue = 0
        for value in @options[index].values
          pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
             (ivalue==self[index]) ? @selBaseColor : self.baseColor,
             (ivalue==self[index]) ? @selShadowColor : self.shadowColor
          )
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents,rect.x+optionwidth,rect.y,optionwidth,rect.height,
           optionname,self.baseColor,self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value = _INTL("Type {1}/{2}",@options[index].optstart+self[index],
         @options[index].optend-@options[index].optstart+1)
      xpos = optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    elsif @options[index].is_a?(SliderOption)
      value = sprintf(" %d",@options[index].optend)
      sliderlength = optionwidth-self.contents.text_size(value).width
      xpos = optionwidth+rect.x
      self.contents.fill_rect(xpos,rect.y-2+rect.height/2,
         optionwidth-self.contents.text_size(value).width,4,self.baseColor)
      self.contents.fill_rect(
         xpos+(sliderlength-8)*(@options[index].optstart+self[index])/@options[index].optend,
         rect.y-8+rect.height/2,
         8,16,@selBaseColor)
      value = sprintf("%d",@options[index].optstart+self[index])
      xpos += optionwidth-self.contents.text_size(value).width
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    end
  end
end

SaveData.register(:pokemon_system) do
  ensure_class :PokemonSystem
  save_value { $PokemonSystem }
  load_value { |value| $PokemonSystem = value }
  new_game_value { PokemonSystem.new }
  from_old_format { |old_format| old_format[3] }
end