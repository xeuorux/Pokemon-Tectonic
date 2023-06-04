class PokemonGameInfoMenu_Scene
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
		cmdBattleGlossary = -1
		infoCommands = []
		infoCommands[cmdMainQuestHelp = infoCommands.length] = _INTL("What Next?") if defined?($main_quest_tracker)
		infoCommands[cmdBattleGlossary = infoCommands.length] = _INTL("Battle Guide")
		infoCommands[cmdTrainer = infoCommands.length] = _INTL("#{$Trainer.name}'s Card")
		infoCommands[cmdLevelCap = infoCommands.length] = _INTL("Level Cap") if LEVEL_CAPS_USED && getLevelCap > 0 && $Trainer.party_count > 0
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
			elsif cmdBattleGlossary >- 1 && infoCommand == cmdBattleGlossary
				showBattleGuide
			else
				pbPlayCloseMenuSE
				break
			end
		end
		@scene.pbEndScene if endscene
	end
end

def showBattleGuide
	listIndex = 0
	loop do
		id, listIndex = pbListScreenExtra(_INTL("Battle Guide"), BattleGuideLister.new(MAIN_HASH, listIndex))
		case id
		when "Basic Strategy"
			pbListScreenExtra(_INTL("Battle Strategy"), BattleGuideLister.new(BASICS_HASH), false)
		when "Moves"
			pbListScreenExtra(_INTL("Moves"), BattleGuideLister.new(MOVE_HASH), false)
		when "Type Matchups"
			pbListScreenExtra(_INTL("Type Matchups"), BattleGuideLister.new(TYPE_MATCHUPS_HASH), false)
		when "Acquiring Pokémon"
			pbListScreenExtra(_INTL("Acquiring Pokémon"), BattleGuideLister.new(ACQUIRING_POKEMON_HASH), false)
		when "Stats"
			pbListScreenExtra(_INTL("Stats"), BattleGuideLister.new(STATS_HASH), false)
		when "Abilities"
			pbListScreenExtra(_INTL("Abilities"), BattleGuideLister.new(ABILITIES_HASH), false)
		when "Held Items"
			pbListScreenExtra(_INTL("Held Items"), BattleGuideLister.new(HELD_ITEMS_HASH), false)
		when "Status Conditions"
			pbListScreenExtra(_INTL("Status Conditions"), BattleGuideLister.new(STATUS_CONDITIONS_HASH), false)
		when "Trainers"
			pbListScreenExtra(_INTL("Trainers"), BattleGuideLister.new(TRAINERS_HASH), false)
		when "Avatars"
			pbListScreenExtra(_INTL("Avatars"), BattleGuideLister.new(AVATARS_HASH), false)
		when "MasterDex"
			pbListScreenExtra(_INTL("MasterDex"), BattleGuideLister.new(MASTERDEX_HASH), false)
		when "Weathers"
			pbListScreenExtra(_INTL("Weathers"), BattleGuideLister.new(WEATHERS_HASH), false)
		else
			break
		end
	end
end