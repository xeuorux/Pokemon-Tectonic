class PokemonGameInfoMenu_Scene
	def pbStartScene
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["cmdwindow"] = Window_CommandPokemon.new([])
		@sprites["cmdwindow"].visible = false
		@sprites["cmdwindow"].viewport = @viewport
		@infostate = false
		@helpstate = false
		pbSEPlay("GUI menu open")
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

class PokemonGameInfoMenu < PokemonPauseMenu
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
		cmdTrainer  = -1
		cmdLevelCap = -1
		cmdMainQuestHelp = -1
        cmdAchievements = -1
		infoCommands = []
		infoCommands[cmdMainQuestHelp = infoCommands.length] = _INTL("What Next?") if defined?($main_quest_tracker)
		infoCommands[cmdTrainer = infoCommands.length] = _INTL("{1}'s Card",$Trainer.name)
		infoCommands[cmdLevelCap = infoCommands.length] = _INTL("Level Cap") if LEVEL_CAPS_USED && getLevelCap > 0 && $Trainer.party_count > 0
		infoCommands[cmdAchievements = infoCommands.length] = _INTL("Achievements")
        infoCommands.push(_INTL("Cancel"))
		loop do
			infoCommand = @scene.pbShowCommands(infoCommands)
			if cmdTrainer >= 0 && infoCommand == cmdTrainer
				pbPlayDecisionSE
				pbFadeOutIn {
					scene = PokemonTrainerCard_Scene.new
					screen = PokemonTrainerCardScreen.new(scene)
					screen.pbStartScreen
					@scene.pbRefresh
				}
			elsif cmdLevelCap > -1 && infoCommand == cmdLevelCap
				cap = getLevelCap
				msgwindow = pbCreateMessageWindow
				pbMessageDisplay(msgwindow, _INTL("The current level cap is {1}.", cap))
				pbMessageDisplay(msgwindow, _INTL("Once at level {1}, your Pokémon cannot gain experience or have Candies used on them.", cap))
				pbMessageDisplay(msgwindow,"The level cap can be raised by reading Battle Reports (a consumable item).")
				pbMessageDisplay(msgwindow,"You'll earn Battle Reports after defeating Gym Leaders and major story battles.")
				pbDisposeMessageWindow(msgwindow)
			elsif cmdMainQuestHelp > - 1 && infoCommand == cmdMainQuestHelp
				pbMessage("\\l[7]<b>" + $main_quest_tracker.getCurrentStageName() + "</b>\n" + $main_quest_tracker.getCurrentStageHelp())
            elsif cmdAchievements > -1 && infoCommand == cmdAchievements
                pbFadeOutIn do
                    achievementsListScene = AchievementsListScene.new
                    screen = AchievementsListScreen.new(achievementsListScene)
                    screen.pbStartScreen
                end
			else
				pbPlayCloseMenuSE
				break
			end
		end
		@scene.pbEndScene if endscene
	end
end