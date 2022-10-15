LEVEL_CAPS_USED = true

class PokeBattle_Battle
  #=============================================================================
  # Gaining Experience
  #=============================================================================
  def pbGainExp
	  hasExpJAR = (GameData::Item.exists?(:EXPEZDISPENSER) && $PokemonBag.pbHasItem?(:EXPEZDISPENSER))
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
	  if bossBattle?
      @battlers.each do |b|
        next if !b || !b.opposes?   # Can only gain Exp from fainted foes
        next if !b.fainted? || !b.boss
        pbDisplayPaused(_INTL("Each Pokémon in your party got Exp. Points!"))
        b.participants = []
        eachInTeam(0,0) do |pkmn,i|
          b.participants.push(i)
          pbGainExpOne(i,b,0,[],[],hasExpJAR)
        end
        b.boss = false
      end
    elsif wildBattle?
      return
    else
      # Go through each battler in turn to find the Pokémon that participated in
      # battle against it, and award those Pokémon Exp
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
        # Calculate Exp gains for the participants
        if numPartic>0 || expShare.length>0 || expAll
        # Gain Exp for participants
        eachInTeam(0,0) do |pkmn,i|
          next if !pkmn.able?
          next unless b.participants.include?(i) || expShare.include?(i)
          pbGainExpOne(i,b,numPartic,expShare,expAll,hasExpJAR)
        end
        # Gain Exp for all other Pokémon because of Exp All
        if expAll
          showMessage = true
          eachInTeam(0,0) do |pkmn,i|
          next if !pkmn.able?
          next if b.participants.include?(i) || expShare.include?(i)
          pbDisplayPaused(_INTL("Your party Pokémon in waiting also got Exp. Points!")) if showMessage
          showMessage = false
          pbGainExpOne(i,b,numPartic,expShare,expAll,hasExpJAR,false)
          end
        end
        end
        # Clear the participants array
        b.participants = []
      end
    end
  end
  
  def pbGainExpOne(idxParty,defeatedBattler,numPartic,expShare,expAll,hasExpJAR,showMessages=true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining exp from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp>=growth_rate.maximum_exp
      pkmn.calc_stats
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
    if trainerBattle?
      exp = exp * 1.5
      if $PokemonBag.pbHasItem?(:PERFORMANCEANALYZER2)
        exp = exp * 1.25
      elsif $PokemonBag.pbHasItem?(:PERFORMANCEANALYZER)
        exp = exp * 1.2
      end
      exp = exp.floor
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
    # Increase Exp gain based on battling streak
    pkmn.battlingStreak = 0 if pkmn.battlingStreak.nil?
    if pkmn.onHotStreak?
      #pbDisplayPaused(_INTL("{1} benefits from its Hot Streak!",pkmn.name))
      exp = (exp * 1.3).floor
    end
    # Modify Exp gain based on pkmn's held item
    i = BattleHandlers.triggerExpGainModifierItem(pkmn.item,pkmn,exp)
    if i < 0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # If EXP in this battle is capped, store all XP instead of granting it
    if @expCapped
      @expStored += (exp * 0.7).floor
      return
    end
    # Make sure Exp doesn't exceed the maximum
    level_cap = LEVEL_CAPS_USED ? $game_variables[26] : growth_rate.max_level
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expLeftovers = expFinal.clamp(0,growth_rate.minimum_exp_for_level(level_cap))
    # Calculates if there is excess exp and if it can be stored
    if (expFinal > expLeftovers) && hasExpJAR
      expLeftovers = expFinal.clamp(0,growth_rate.minimum_exp_for_level(level_cap+1))
    else
      expLeftovers = 0
    end
  	expFinal = expFinal.clamp(0,growth_rate.minimum_exp_for_level(level_cap))
    expGained = expFinal-pkmn.exp
	  expLeftovers = expLeftovers-pkmn.exp
    expLeftovers = (expLeftovers * 0.7).floor
	  @expStored += expLeftovers if expLeftovers > 0
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
          pbDisplayPaused(_INTL("{1} gained only {3} Exp. Points due to the level cap at level {2}.",pkmn.name,level_cap,expGained))
		    end
      else
        if !pkmn.onHotStreak?
          pbDisplayPaused(_INTL("{1} got {2} Exp. Points!",pkmn.name,expGained))
        else
          pbDisplayPaused(_INTL("{1} got a Hot Streak boosted {2} Exp. Points!",pkmn.name,expGained))
        end
      end
    end
    if newLevel < curLevel
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
      if curLevel > newLevel
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
	  $PokemonGlobal.expJAR = 0 if $PokemonGlobal.expJAR.nil?
	  $PokemonGlobal.expJAR += expLeftovers if (expLeftovers > 0 && hasExpJAR)
  end
end

def styleValueMult(level)
  return (2.0 + level.to_f / 50.0)
end

# @return [Integer] the maximum HP of this Pokémon
def calcHPGlobal(base, level, sv, stylish = false)
	return 1 if base == 1   # For Shedinja
	pseudoLevel = 15.0+(level.to_f/2.0)
  stylishMult = stylish ? 2.0 : 1.0
	return (((base.to_f * 2.0 + sv.to_f * styleValueMult(level) * stylishMult) * pseudoLevel / 100.0) + pseudoLevel + 10.0).floor
end

# @return [Integer] the specified stat of this Pokémon (not used for total HP)
def calcStatGlobal(base, level, sv, stylish = false)
	pseudoLevel = 15.0+(level.to_f/2.0)
  stylishMult = stylish ? 2.0 : 1.0
	return ((((base.to_f * 2.0 + sv.to_f * styleValueMult(level) * stylishMult) * pseudoLevel / 100.0) + 5.0)).floor
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
      pbLearnMove(pkmn,i[1],true)
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