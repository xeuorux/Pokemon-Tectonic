LEVEL_CAPS_USED = true

class Pokemon
	attr_accessor :hpMult
	attr_accessor :scaleFactor
	attr_accessor :dmgMult
	attr_accessor :battlingStreak
	
  # Creates a new Pokémon object.
  # @param species [Symbol, String, Integer] Pokémon species
  # @param level [Integer] Pokémon level
  # @param owner [Owner, Player, NPCTrainer] Pokémon owner (the player by default)
  # @param withMoves [TrueClass, FalseClass] whether the Pokémon should have moves
  # @param rechech_form [TrueClass, FalseClass] whether to auto-check the form
  def initialize(species, level, owner = $Trainer, withMoves = true, recheck_form = true)
    species_data = GameData::Species.get(species)
    @species          = species_data.species
    @form             = species_data.form
    @forced_form      = nil
    @time_form_set    = nil
    self.level        = level
    @steps_to_hatch   = 0
    heal_status
    @gender           = nil
    @shiny            = nil
    @ability_index    = nil
    @ability          = nil
    @nature           = nil
    @nature_for_stats = nil
    @item             = nil
    @mail             = nil
    @moves            = []
    reset_moves if withMoves
    @first_moves      = []
    @ribbons          = []
    @cool             = 0
    @beauty           = 0
    @cute             = 0
    @smart            = 0
    @tough            = 0
    @sheen            = 0
    @pokerus          = 0
    @name             = nil
    @happiness        = species_data.happiness
    @poke_ball        = :POKEBALL
    @markings         = 0
    @iv               = {}
    @ivMaxed          = {}
    @ev               = {}
    GameData::Stat.each_main do |s|
      @iv[s.id]       = 0
      @ev[s.id]       = DEFAULT_STYLE_VALUE
    end
    if owner.is_a?(Owner)
      @owner = owner
    elsif owner.is_a?(Player) || owner.is_a?(NPCTrainer)
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, '', 2, 2)
    end
    @obtain_method    = 0   # Met
    @obtain_method    = 4 if $game_switches && $game_switches[Settings::FATEFUL_ENCOUNTER_SWITCH]
    @obtain_map       = ($game_map) ? $game_map.map_id : 0
    @obtain_text      = nil
    @obtain_level     = level
    @hatched_map      = 0
    @timeReceived     = pbGetTimeNow.to_i
    @timeEggHatched   = nil
    @fused            = nil
    @personalID       = rand(2 ** 16) | rand(2 ** 16) << 16
    @hp               = 1
    @totalhp          = 1
	  @hpMult			  = 1
	  @scaleFactor	  = 1
  	@dmgMult		  = 1
	  @battlingStreak	  = 0
    calc_stats
    if @form == 0 && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end
  
  def onHotStreak?()
	return @battlingStreak >= 2
  end
  
  def nature
    @nature = GameData::Nature.get(0).id # ALWAYS RETURN NEUTRAL
    return GameData::Nature.try_get(@nature)
  end
  
  # Recalculates this Pokémon's stats.
  def calc_stats
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    # Calculate stats
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHPGlobal(base_stats[s.id], this_level, @ev[s.id])
        if boss
          stats[s.id] *= hpMult
        end
      elsif (s.id == :ATTACK) || (s.id == :SPECIAL_ATTACK)
        stats[s.id] = calcStatGlobal(base_stats[s.id], this_level, @ev[s.id])
        if boss
          stats[s.id] *= dmgMult
        end
      else
        stats[s.id] = calcStatGlobal(base_stats[s.id], this_level, @ev[s.id])
      end
    end
    hpDiff = @totalhp - @hp
    @totalhp = stats[:HP]
    @hp      = (fainted? ? 0 : (@totalhp - hpDiff))
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end
end

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
    exp = (exp*1.8).floor if trainerBattle?
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
    if i<0
      i = BattleHandlers.triggerExpGainModifierItem(@initialItems[0][idxParty],pkmn,exp)
    end
    exp = i if i>=0
    # If EXP in this battle is capped, store all XP instead of granting it
    if @expCapped
      @expStored += exp
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
	 #pbDisplayPaused(_INTL("{1} exp was put into the EXP-EZ Dispenser.",expLeftovers)) if expLeftovers > 0
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
	  $PokemonGlobal.expJAR = 0 if $PokemonGlobal.expJAR.nil?
	  $PokemonGlobal.expJAR += expLeftovers if (expLeftovers > 0 && hasExpJAR)
  end
end

LEVEL_CAP_VAR = 26

def pbIncreaseLevelCap(increase)
	return if !LEVEL_CAPS_USED
	pbSetLevelCap($game_variables[LEVEL_CAP_VAR] + increase)
end

def pbSetLevelCap(newCap)
	return if !LEVEL_CAPS_USED
	$game_variables[LEVEL_CAP_VAR] = newCap
	pbMessage(_INTL("\\wmLevel cap raised to {1}!\\me[Bug catching 3rd]\\wtnp[80]\1",newCap))
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


# @return [Integer] the maximum HP of this Pokémon
def calcHPGlobal(base, level, sv)
	return 1 if base == 1   # For Shedinja
	pseudoLevel = 15.0+(level.to_f/2.0)
	return (((base.to_f * 2.0 + sv.to_f * 2) * pseudoLevel / 100.0) + pseudoLevel + 10.0).floor
end

# @return [Integer] the specified stat of this Pokémon (not used for total HP)
def calcStatGlobal(base, level, sv)
	pseudoLevel = 15.0+(level.to_f/2.0)
	return ((((base.to_f * 2.0 + sv.to_f * 2) * pseudoLevel / 100.0) + 5.0)).floor
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