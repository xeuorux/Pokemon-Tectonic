class PokemonPauseMenu_Scene
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
    $viewport4 = @viewport
    pbSEPlay("GUI menu open")
  end
end

class PokemonGameInfoMenu_Scene < PokemonPauseMenu_Scene
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
			else
				pbPlayCloseMenuSE
				break
			end
		end
		@scene.pbEndScene if endscene
	end
end

def pbListScreenExtra(title,lister,breakOnUse = true)
	viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
	viewport.z = 99999
	list = pbListWindow([])
	list.viewport = viewport
	list.z        = 2
	title = Window_UnformattedTextPokemon.newWithSize(title,
	   Graphics.width / 2, 0, Graphics.width / 2, 64, viewport)
	title.z = 2
	lister.setViewport(viewport)
	selectedmap = -1
	commands = lister.commands
	selindex = lister.startIndex
	if commands.length == 0
	  value = lister.value(-1)
	  lister.dispose
	  title.dispose
	  list.dispose
	  viewport.dispose
	  return value
	end
	list.commands = commands
	list.index    = selindex
	loop do
	  Graphics.update
	  Input.update
	  list.update
	  if list.index != selectedmap
		lister.refresh(list.index)
		selectedmap = list.index
	  end
	  if Input.trigger?(Input::BACK)
		selectedmap = -1
		break
	  elsif Input.trigger?(Input::USE) && breakOnUse
		break
	  end
	end
	value = lister.value(selectedmap)
	finalListIndex = list.index
	lister.dispose
	title.dispose
	list.dispose
	viewport.dispose
	Input.update
	return value, finalListIndex
end

class PokemonPauseMenu
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
		commands = []
		cmdPokedex  = -1
		cmdPokemon  = -1
		cmdBag      = -1
		cmdSave     = -1
		cmdOption   = -1
		cmdPokegear = -1
		cmdDexnav	= -1
		cmdTribalBonus = -1
		cmdGameInfo = -1
		cmdDebug    = -1
		cmdQuit     = -1
		cmdEndGame  = -1
		commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
		commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
		if $Trainer.has_pokedex || $DEBUG
			commands[cmdPokedex = commands.length] = _INTL("MasterDex")
		  end
		commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
		commands[cmdDexnav = commands.length]	 = _INTL("DexNav")
		commands[cmdTribalBonus = commands.length]	 = _INTL("Tribal Bonus") if defined?(TribalBonus)
		commands[cmdGameInfo = commands.length]  = _INTL("Game Info")
		if pbInSafari?
		  if Settings::SAFARI_STEPS <= 0
			@scene.pbShowInfo(_INTL("Balls: {1}",pbSafariState.ballcount))
		  else
			@scene.pbShowInfo(_INTL("Steps: {1}/{2}\nBalls: {3}",
			   pbSafariState.steps, Settings::SAFARI_STEPS, pbSafariState.ballcount))
		  end
		  commands[cmdQuit = commands.length]    = _INTL("Quit")
		elsif pbInBugContest?
		  if pbBugContestState.lastPokemon
			@scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
			   pbBugContestState.lastPokemon.speciesName,
			   pbBugContestState.lastPokemon.level,
			   pbBugContestState.ballcount))
		  else
			@scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}",pbBugContestState.ballcount))
		  end
		  commands[cmdQuit = commands.length]    = _INTL("Quit Contest")
		else
		  commands[cmdSave = commands.length]    = _INTL("Save") if $game_system && !$game_system.save_disabled
		end
		commands[cmdOption = commands.length]    = _INTL("Options")
		commands[cmdDebug = commands.length]     = _INTL("Debug") if $DEBUG
		commands[cmdEndGame = commands.length]   = _INTL("Quit Game")
		loop do
		  command = @scene.pbShowCommands(commands)
		  if cmdPokedex>=0 && command==cmdPokedex
			pbPlayDecisionSE
			if Settings::USE_CURRENT_REGION_DEX
			  pbFadeOutIn {
				scene = PokemonPokedex_Scene.new
				screen = PokemonPokedexScreen.new(scene)
				screen.pbStartScreen
				@scene.pbRefresh
			  }
			else
			  if $Trainer.pokedex.accessible_dexes.length == 1
				$PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
				pbFadeOutIn {
				  scene = PokemonPokedex_Scene.new
				  screen = PokemonPokedexScreen.new(scene)
				  screen.pbStartScreen
				  @scene.pbRefresh
				}
			  else
				pbFadeOutIn {
				  scene = PokemonPokedexMenu_Scene.new
				  screen = PokemonPokedexMenuScreen.new(scene)
				  screen.pbStartScreen
				  @scene.pbRefresh
				}
			  end
			end
		  elsif cmdPokemon >= 0 && command == cmdPokemon
			pbPlayDecisionSE
			hiddenmove = nil
			pbFadeOutIn {
			  sscene = PokemonParty_Scene.new
			  sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
			  hiddenmove = sscreen.pbPokemonScreen
			  (hiddenmove) ? @scene.pbEndScene : @scene.pbRefresh
			}
			if hiddenmove
			  $game_temp.in_menu = false
			  pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
			  return
			end
		  elsif cmdBag >=0 && command == cmdBag
			pbPlayDecisionSE
			item = nil
			pbFadeOutIn {
			  scene = PokemonBag_Scene.new
			  screen = PokemonBagScreen.new(scene,$PokemonBag)
			  item = screen.pbStartScreen
			  (item) ? @scene.pbEndScene : @scene.pbRefresh
			}
			if item
			  $game_temp.in_menu = false
			  pbUseKeyItemInField(item)
			  return
			end
		  elsif cmdPokegear >=0 && command == cmdPokegear
			pbPlayDecisionSE
			pbFadeOutIn {
			  scene = PokemonPokegear_Scene.new
			  screen = PokemonPokegearScreen.new(scene)
			  screen.pbStartScreen
			  @scene.pbRefresh
			}
		  elsif cmdDexnav >= 0 && command == cmdDexnav
			pbPlayDecisionSE
			pbFadeOutIn {
				dexnavScene = NewDexNav.new
				@scene.pbEndScene
				return
			}
		  elsif cmdTribalBonus >= 0 && command == cmdTribalBonus
			pbFadeOutIn {
					scene = TribalBonusScene.new
					screen = TribalBonusScreen.new(scene)
					screen.pbStartScreen
					@scene.pbRefresh
				}
		  elsif cmdGameInfo >= 0 && command == cmdGameInfo
			storedLastMenuChoice = $PokemonTemp.menuLastChoice
			$PokemonTemp.menuLastChoice = 0
			infoMenuScene = PokemonGameInfoMenu_Scene.new
		  	infoMenuScreen = PokemonGameInfoMenu.new(infoMenuScene)
			infoMenuScreen.pbStartPokemonMenu
			@scene.pbRefresh
			$PokemonTemp.menuLastChoice = storedLastMenuChoice
		  elsif cmdQuit >= 0 && command == cmdQuit
			@scene.pbHideMenu
			if pbInSafari?
			  if pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
				@scene.pbEndScene
				pbSafariState.decision = 1
				pbSafariState.pbGoToStart
				return
			  else
				pbShowMenu
			  end
			else
			  if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
				@scene.pbEndScene
				pbBugContestState.pbStartJudging
				return
			  else
				pbShowMenu
			  end
			end
		  elsif cmdSave >= 0 && command == cmdSave
			@scene.pbHideMenu
			scene = PokemonSave_Scene.new
			screen = PokemonSaveScreen.new(scene)
			if screen.pbSaveScreen
			  @scene.pbEndScene
			  endscene = false
			  break
			else
			  pbShowMenu
			end
		  elsif cmdOption >= 0 && command == cmdOption
			pbPlayDecisionSE
			pbFadeOutIn {
			  scene = PokemonOption_Scene.new
			  screen = PokemonOptionScreen.new(scene)
			  screen.pbStartScreen
			  pbUpdateSceneMap
			  @scene.pbRefresh
			}
		  elsif cmdDebug >= 0 && command == cmdDebug
			pbPlayDecisionSE
			pbFadeOutIn {
			  pbDebugMenu
			  @scene.pbRefresh
			}
		  elsif cmdEndGame >= 0 && command == cmdEndGame
			@scene.pbHideMenu
			if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
			  scene = PokemonSave_Scene.new
			  screen = PokemonSaveScreen.new(scene)
			  if screen.pbSaveScreen(true)
				@scene.pbEndScene
			  end
			  @scene.pbEndScene
			  $scene = nil
			  return
			else
			  pbShowMenu
			end
		  else
			pbPlayCloseMenuSE
			break
		  end
		end
		@scene.pbEndScene if endscene
  end
end