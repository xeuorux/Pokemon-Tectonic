LEVEL_CAPS_USED = true

class PokeBattle_Battle
  #=============================================================================
  # Gaining Experience
  #=============================================================================
  def pbGainExp
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
	if $game_switches[95] # Boss battle
      @battlers.each do |b|
        next if !b || !b.opposes?   # Can only gain Exp from fainted foes
        next if !b.fainted? || !b.boss
        pbDisplayPaused(_INTL("Each Pokémon in your party got Exp. Points!"))
        b.participants = []
        eachInTeam(0,0) do |pkmn,i|
          b.participants.push(i)
          pbGainExpOne(i,b,0,[],[])
        end
		b.boss = false
      end
    else
		# Go through each battler in turn to find the Pokémon that participated in
		# battle against it, and award those Pokémon Exp/EVs
		expAll = (GameData::Item.exists?(:EXPALL) && $PokemonBag.pbHasItem?(:EXPALL))
		p1 = pbParty(0)
		@battlers.each do |b|
		  next unless b && b.opposes?   # Can only gain Exp from fainted foes
		  next if b.participants.length==0
		  next unless b.fainted? || b.captured
		  # Count the number of participants
		  numPartic = 0
		  b.participants.each do |partic|
			next unless p1[partic] && p1[partic].able? && pbIsOwner?(0,partic)
			numPartic += 1
		  end
		  # Find which Pokémon have an Exp Share
		  expShare = []
		  if !expAll
			eachInTeam(0,0) do |pkmn,i|
			  next if !pkmn.able?
			  next if !pkmn.hasItem?(:EXPSHARE) && GameData::Item.try_get(@initialItems[0][i]) != :EXPSHARE
			  expShare.push(i)
			end
		  end
		  # Calculate EV and Exp gains for the participants
		  if numPartic>0 || expShare.length>0 || expAll
			# Gain EVs and Exp for participants
			eachInTeam(0,0) do |pkmn,i|
			  next if !pkmn.able?
			  next unless b.participants.include?(i) || expShare.include?(i)
			  pbGainEVsOne(i,b)
			  pbGainExpOne(i,b,numPartic,expShare,expAll)
			end
			# Gain EVs and Exp for all other Pokémon because of Exp All
			if expAll
			  showMessage = true
			  eachInTeam(0,0) do |pkmn,i|
				next if !pkmn.able?
				next if b.participants.include?(i) || expShare.include?(i)
				pbDisplayPaused(_INTL("Your party Pokémon in waiting also got Exp. Points!")) if showMessage
				showMessage = false
				pbGainEVsOne(i,b)
				pbGainExpOne(i,b,numPartic,expShare,expAll,false)
			  end
			end
		  end
		  # Clear the participants array
		  b.participants = []
		end
    end
  end
  
    def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level*defeatedBattler.pokemon.base_exp
    if expShare.length>0 && (isPartic || hasExpShare)
      if numPartic==0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a/(2*numPartic) if isPartic
        exp += a/(2*expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a/2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a/2
    end
    return if exp<=0
    # Pokémon gain more Exp from trainer battles
    exp = (exp*2.0).floor if trainerBattle?
	# Pokemon gain a parameterized multiplier amount of Exp from boss battles
	if $game_switches[95]
		exp = (exp * $game_variables[98]).floor
	end
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = (2*level+10.0)/(pkmn.level+level+10.0)
      levelAdjust = levelAdjust**5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp*1.7).floor
      else
        exp = (exp*1.5).floor
      end
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # Make sure Exp doesn't exceed the maximum
	level_cap = LEVEL_CAPS_USED ? $game_variables[26] : growth_rate.max_level
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
	expFinal = expFinal.clamp(0,growth_rate.minimum_exp_for_level(level_cap))
    expGained = expFinal-pkmn.exp
	curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if expGained == 0 and pkmn.level < level_cap
      pbDisplayPaused(_INTL("{1} gained 0 experience.",pkmn.name))
      return
    end
    # "Exp gained" message
    if showMessages
      if newLevel == level_cap
        if expGained != 0
          pbDisplayPaused(_INTL("{1} gained only {3} experience due to the level cap at level {2}.",pkmn.name,level_cap,expGained))
		end
      else
        if isOutsider
          pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!",pkmn.name,expGained))
        else
          pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
        end
      end
    end
    if newLevel<curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise RuntimeError.new(
         _INTL("{1}'s new level is less than its\r\ncurrent level, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
	if newLevel > level_cap
      raise RuntimeError.new(
         _INTL("{1}'s new level is greater than the level cap, which shouldn't happen.\r\n[Debug: {2}]",
         pkmn.name,debugInfo))
    end
    # Give Exp
    if pkmn.shadowPokemon?
      pkmn.exp += expGained
      return
    end
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp<expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler,levelMinExp,levelMaxExp,tempExp1,tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel>newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler.pbUpdate(false) if battler
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp",battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      pkmn.calc_stats
      battler.pbUpdate(false) if battler
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!",pkmn.name,curLevel))
      @scene.pbLevelUp(pkmn,battler,oldTotalHP,oldAttack,oldDefense,
                                    oldSpAtk,oldSpDef,oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMove(idxParty,m[1]) if m[0]==curLevel }
	  if battler && battler.pokemon
        battler.pokemon.changeHappiness("levelup")
      end
    end
  end
end

def pbSetLevelCap(newCap)
  return if !LEVEL_CAPS_USED
  $game_variables[26] = newCap
  pbMessage(_INTL("Level cap raised to {1}!\\me[Bug catching 3rd]\\wtnp[80]\1",newCap))
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
		cmdTrainer  = -1
		cmdSave     = -1
		cmdOption   = -1
		cmdPokegear = -1
		cmdLevelCap = -1
		cmdDebug    = -1
		cmdQuit     = -1
		cmdEndGame  = -1
		if $Trainer.has_pokedex && $Trainer.pokedex.accessible_dexes.length > 0
		  commands[cmdPokedex = commands.length] = _INTL("Pokédex")
		end
		commands[cmdPokemon = commands.length]   = _INTL("Pokémon") if $Trainer.party_count > 0
		commands[cmdBag = commands.length]       = _INTL("Bag") if !pbInBugContest?
		commands[cmdPokegear = commands.length]  = _INTL("Pokégear") if $Trainer.has_pokegear
		commands[cmdLevelCap = commands.length]  = _INTL("Level Cap") if (LEVEL_CAPS_USED && $game_variables[26] > 0 && $game_variables[26] < 100)
		commands[cmdTrainer = commands.length]   = $Trainer.name
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
		  elsif cmdPokemon>=0 && command==cmdPokemon
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
		  elsif cmdBag>=0 && command==cmdBag
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
		  elsif cmdPokegear>=0 && command==cmdPokegear
			pbPlayDecisionSE
			pbFadeOutIn {
			  scene = PokemonPokegear_Scene.new
			  screen = PokemonPokegearScreen.new(scene)
			  screen.pbStartScreen
			  @scene.pbRefresh
			}
		  elsif cmdLevelCap>=0 && command==cmdLevelCap
			cap = $game_variables[26]
			msgwindow = pbCreateMessageWindow
			pbMessageDisplay(msgwindow, _INTL("The current level cap is {1}.", cap))
			pbMessageDisplay(msgwindow, _INTL("Once at level {1}, your Pokémon cannot gain experience or have Candies used on them.", cap))
			pbMessageDisplay(msgwindow,"The level can be raised by defeating gym leaders.")
			pbDisposeMessageWindow(msgwindow)
		  elsif cmdTrainer>=0 && command==cmdTrainer
			pbPlayDecisionSE
			pbFadeOutIn {
			  scene = PokemonTrainerCard_Scene.new
			  screen = PokemonTrainerCardScreen.new(scene)
			  screen.pbStartScreen
			  @scene.pbRefresh
			}
		  elsif cmdQuit>=0 && command==cmdQuit
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
		  elsif cmdSave>=0 && command==cmdSave
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
		  elsif cmdOption>=0 && command==cmdOption
			pbPlayDecisionSE
			pbFadeOutIn {
			  scene = PokemonOption_Scene.new
			  screen = PokemonOptionScreen.new(scene)
			  screen.pbStartScreen
			  pbUpdateSceneMap
			  @scene.pbRefresh
			}
		  elsif cmdDebug>=0 && command==cmdDebug
			pbPlayDecisionSE
			pbFadeOutIn {
			  pbDebugMenu
			  @scene.pbRefresh
			}
		  elsif cmdEndGame>=0 && command==cmdEndGame
			@scene.pbHideMenu
			if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
			  scene = PokemonSave_Scene.new
			  screen = PokemonSaveScreen.new(scene)
			  if screen.pbSaveScreen
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


ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif LEVEL_CAPS_USED && (pkmn.level + 1) > $game_variables[26]
      scene.pbDisplay(_INTL("It won't have any effect due to the level cap at #{$game_variables[26]}."))
      next false
  end
  pbChangeLevel(pkmn,pkmn.level+1,scene)
  scene.pbHardRefresh
  next true
})


class Pokemon
	  # @return [Integer] the maximum HP of this Pokémon
	  def calcHP(base, level, sv)
		return 1 if base == 1   # For Shedinja
		pseudoLevel = 15.0+(level.to_f/2.0)
		return (((base.to_f * 2.0 + sv.to_f) * pseudoLevel / 100.0) + pseudoLevel + 10.0).floor
	  end

	  # @return [Integer] the specified stat of this Pokémon (not used for total HP)
	  def calcStat(base, level, sv)
		pseudoLevel = 15.0+(level.to_f/2.0)
		return ((((base.to_f * 2.0 + (sv.to_f / 4)) * pseudoLevel / 100.0) + 5.0)).floor
	  end
end

#===============================================================================
# Change a Pokémon's level
#===============================================================================
def pbChangeLevel(pkmn,newlevel,scene)
  newlevel = newlevel.clamp(1, GameData::GrowthRate.max_level)
  if pkmn.level==newlevel
    pbMessage(_INTL("{1}'s level remained unchanged.",pkmn.name))
  elsif pkmn.level>newlevel
    attackdiff  = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.level = newlevel
    pkmn.calc_stats
    scene.pbRefresh
    pbMessage(_INTL("{1} dropped to Lv. {2}!",pkmn.name,pkmn.level))
    attackdiff  = pkmn.attack-attackdiff
    defensediff = pkmn.defense-defensediff
    speeddiff   = pkmn.speed-speeddiff
    spatkdiff   = pkmn.spatk-spatkdiff
    spdefdiff   = pkmn.spdef-spdefdiff
    totalhpdiff = pkmn.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed))
  else
    attackdiff  = pkmn.attack
    defensediff = pkmn.defense
    speeddiff   = pkmn.speed
    spatkdiff   = pkmn.spatk
    spdefdiff   = pkmn.spdef
    totalhpdiff = pkmn.totalhp
    pkmn.level = newlevel
    pkmn.calc_stats
    scene.pbRefresh
    if scene.is_a?(PokemonPartyScreen)
      scene.pbDisplay(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    else
      pbMessage(_INTL("{1} grew to Lv. {2}!",pkmn.name,pkmn.level))
    end
    attackdiff  = pkmn.attack-attackdiff
    defensediff = pkmn.defense-defensediff
    speeddiff   = pkmn.speed-speeddiff
    spatkdiff   = pkmn.spatk-spatkdiff
    spdefdiff   = pkmn.spdef-spdefdiff
    totalhpdiff = pkmn.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff),scene)
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pkmn.totalhp,pkmn.attack,pkmn.defense,pkmn.spatk,pkmn.spdef,pkmn.speed),scene)
    # Learn new moves upon level up
    movelist = pkmn.getMoveList
    for i in movelist
      next if i[0]!=pkmn.level
      pbLearnMove(pkmn,i[1],true) { scene.pbUpdate }
    end
    # Check for evolution
    newspecies = pkmn.check_evolution_on_level_up
    if newspecies
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution
        evo.pbEndScreen
        scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
      }
    end
	pkmn.changeHappiness("vitamin")
  end
end
