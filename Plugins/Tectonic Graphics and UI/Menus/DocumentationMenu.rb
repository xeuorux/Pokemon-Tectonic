class PokemonDocumentationMenu_Scene
	def pbStartScene
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["cmdwindow"] = Window_CommandPokemon.new([])
		@sprites["cmdwindow"].visible = false
		@sprites["cmdwindow"].viewport = @viewport
		@sprites["infowindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("",0,0,32,32,@viewport)
		@sprites["helpwindow"].visible = false
		@infostate = false
		@helpstate = false
		pbSEPlay("GUI menu open")
	  end
	
	  def pbShowInfo(text)
		@sprites["infowindow"].resizeToFit(text,Graphics.height)
		@sprites["infowindow"].text    = text
		@sprites["infowindow"].visible = true
		@infostate = true
	  end
	
	  def pbShowHelp(text)
		@sprites["helpwindow"].resizeToFit(text,Graphics.height)
		@sprites["helpwindow"].text    = text
		@sprites["helpwindow"].visible = true
		pbBottomLeft(@sprites["helpwindow"])
		@helpstate = true
	  end
	
	  def pbShowMenu
		@sprites["cmdwindow"].visible = true
		@sprites["infowindow"].visible = @infostate
		@sprites["helpwindow"].visible = @helpstate
	  end
	
	  def pbHideMenu
		@sprites["cmdwindow"].visible = false
		@sprites["infowindow"].visible = false
		@sprites["helpwindow"].visible = false
	  end
	
	  def pbShowCommands(commands)
		ret = -1
		cmdwindow = @sprites["cmdwindow"]
		cmdwindow.commands = commands
		cmdwindow.index    = $PokemonTemp.menuLastChoice
		cmdwindow.resizeToFit(commands)
		cmdwindow.x        = Graphics.width-cmdwindow.width
		cmdwindow.y        = 0
		cmdwindow.visible  = true
		loop do
		  cmdwindow.update
		  Graphics.update
		  Input.update
		  pbUpdateSceneMap
		  if Input.trigger?(Input::BACK)
			ret = -1
			break
		  elsif Input.trigger?(Input::USE)
			ret = cmdwindow.index
			$PokemonTemp.menuLastChoice = ret
			break
		  end
		end
		return ret
	end
	
	def pbEndScene
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end

	def pbRefresh; end
end

class PokemonDocumentationMenu < PokemonPauseMenu
	def pbStartPokemonMenu
		if !$Trainer
			if $DEBUG
			  pbMessage(_INTL("The player trainer was not defined, so the pause menu can't be displayed."))
			  pbMessage(_INTL("Please see the documentation to learn how to set up the trainer player."))
			end
			return
		end
		@scene.pbStartScene
		endscene = true
		cmdMasterDex = -1
        cmdMoveDex = -1
        cmdBattleGuide = -1
        infoCommands = []
        infoCommands[cmdMasterDex = infoCommands.length] = _INTL("MasterDex")
        infoCommands[cmdMoveDex = infoCommands.length] = _INTL("MoveDex")
        infoCommands[cmdBattleGuide = infoCommands.length] = _INTL("Battle Guide")
        infoCommands.push(_INTL("Cancel"))
		loop do
			infoCommand = @scene.pbShowCommands(infoCommands)
			if cmdMasterDex > -1 && infoCommand == cmdMasterDex
                pbFadeOutIn {
                    dexScene = PokemonPokedex_Scene.new
                    screen = PokemonPokedexScreen.new(dexScene)
                    screen.pbStartScreen
                }
            elsif cmdMoveDex > -1 && infoCommand == cmdMoveDex
                openMoveDex
            elsif cmdBattleGuide > -1 && infoCommand == cmdBattleGuide
                showBattleGuide
            else
				pbPlayCloseMenuSE
				break
			end
		end
		@scene.pbEndScene if endscene
	end
end