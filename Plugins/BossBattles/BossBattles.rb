Events.onWildPokemonCreate += proc {| sender, e |
  pkmn = e[0]
  
  # If this is a boss fight...
  if $game_switches[95]
    pkmn.boss = true
	
	#Setting the boss's move set
	if $game_variables[99].is_a?(Hash)
	  moves = $game_variables[99][pkmn.species]
	  pkmn.forget_all_moves()
      moves.each do |move|
        pkmn.learn_move(move)
      end
    elsif $game_variables[99].is_a?(Array)
      pkmn.forget_all_moves()
      $game_variables[99].each do |move|
        pkmn.learn_move(move)
      end
    end
	
	# Setting the boss's item
    if $game_variables[100]
		if $game_variables[100].is_a?(Hash)
			pkmn.item = $game_variables[100][pkmn.species]
		else
			pkmn.item = $game_variables[100]
		end
    end
	
	# Setting boss's ability
    if $game_variables[94]
		if $game_variables[94].is_a?(Hash)
			abilityIndex = $game_variables[94][pkmn.species]
			pkmn.ability = (pkmn.getAbilityList()[abilityIndex][0])
		else
			abilityIndex = $game_variables[94]
			pkmn.ability = (pkmn.getAbilityList()[abilityIndex][0])
		end
    else
      pkmn.ability = (pkmn.getAbilityList()[0][0])
    end
	
	pkmn.calc_stats()
  end
}

def scrubBossBattleSettings
  $game_variables[94] = nil
  $game_variables[95] = 1
  $game_variables[96] = 1
  $game_variables[97] = 1
  $game_variables[98] = 1
  $game_variables[99] = nil
  $game_variables[100] = nil
end

def pbPlayCrySpecies(species, form = 0, volume = 90, pitch = nil)
  GameData::Species.play_cry_from_species(species, form, volume, pitch)
end

module GameData
  class Species
	def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
	  species = pkmn.species if !species
	  species = GameData::Species.get(species).species   # Just to be sure it's a symbol
	  return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
	  if back
		ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  else
		ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  end
	  alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
	  if ret && alter_bitmap_function
		new_ret = ret.copy
		ret.dispose
		new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
		ret = new_ret
	  end
	  if ret && pkmn.boss
		new_ret = ret.copy
		bossified = createBossifiedBitmap(new_ret.bitmap)
		new_ret.bitmap = bossified
		ret.dispose
		ret = new_ret
	  end
	  return ret
	end
  end
end

def createBossifiedBitmap(bitmap)
  scaleFactor = 1 + $game_variables[97]/10.0
  copiedBitmap = Bitmap.new(bitmap.width*scaleFactor,bitmap.height*scaleFactor)
  for x in 0..copiedBitmap.width
    for y in 0..copiedBitmap.height
      color = bitmap.get_pixel(x/scaleFactor,y/scaleFactor)
      color.alpha   = [color.alpha,140].min
      color.red     = [color.red + 50,255].min
      color.blue    = [color.blue + 50,255].min
      copiedBitmap.set_pixel(x,y,color)
    end
  end
  return copiedBitmap
end


class Pokemon
	attr_accessor :boss
	# @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
	  def gender
		return 2 if boss
		if !@gender
		  gender_ratio = species_data.gender_ratio
		  case gender_ratio
		  when :AlwaysMale   then @gender = 0
		  when :AlwaysFemale then @gender = 1
		  when :Genderless   then @gender = 2
		  else
			female_chance = GameData::GenderRatio.get(gender_ratio).female_chance
			@gender = ((@personalID & 0xFF) < female_chance) ? 1 : 0
		  end
		end
		return @gender
	  end
end

class PokeBattle_Battler
	attr_accessor :boss
	

	def pbInitBlank
    @name           = ""
    @species        = 0
    @form           = 0
    @level          = 0
    @hp = @totalhp  = 0
    @type1 = @type2 = nil
    @ability_id     = nil
    @item_id        = nil
    @gender         = 0
    @attack = @defense = @spatk = @spdef = @speed = 0
    @status         = :NONE
    @statusCount    = 0
    @pokemon        = nil
    @pokemonIndex   = -1
    @participants   = []
    @moves          = []
    @iv             = {}
    GameData::Stat.each_main { |s| @iv[s.id] = 0 }
	@boss			= false
  end
  
  # Used by Future Sight only, when Future Sight's user is no longer in battle.
  def pbInitDummyPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @totalhp      = pkmn.totalhp
	@hp           = pkmn.hp
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    # ability and item intentionally not copied across here
    @gender       = pkmn.gender
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
	@boss		  = pkmn.boss
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []
    # moves intentionally not copied across here
    @iv           = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
    @dummy        = true
	
	
  end


  def pbInitPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @totalhp      = pkmn.totalhp
	@hp           = pkmn.hp
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @ability_id   = pkmn.ability_id
    @item_id      = pkmn.item_id
    @gender       = pkmn.gender
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
	@boss		  = pkmn.boss
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []   # Participants earn Exp. if this battler is defeated
    @moves        = []
    pkmn.moves.each_with_index do |m,i|
      @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,m)
    end
    @iv           = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
  end
	
	def shiny?
		return false if boss
		return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
		return @pokemon && @pokemon.shiny?
	end
end


BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if battle.wildBattle? && user.opposes? && !user.boss
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && !user.initialItem && b.initialItem==user.item
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

#===============================================================================
# User steals the target's item, if the user has none itself. (Covet, Thief)
# Items stolen from wild Pokémon are kept after the battle.
#===============================================================================
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't thieve, except if they are bosses
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? &&
       target.initialItem==target.item && !user.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
    user.pbHeldItemTriggerCheck
  end
end

class PokeBattle_Move_0EB < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} anchors itself!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} anchors itself with {2}!",target.pbThis,target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    if target.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",target.pbThis))
      return true
    end
    if !@battle.canRun
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @battle.wildBattle? && (target.level>user.level || target.boss?)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @battle.trainerBattle?
      canSwitch = false
      @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn,i|
        next if !@battle.pbCanSwitchLax?(target.index,i)
        canSwitch = true
        break
      end
      if !canSwitch
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end
end

class PokeBattle_Battle
	def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
		if $game_switches[95]
          pbDisplayPaused("Actually, it's a powerful projection!")
        end
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
           foeParty[1].name))
		if $game_switches[95]
          pbDisplayPaused("Actually, they're both powerful projections!")
        end
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
           foeParty[1].name,foeParty[2].name))
		if $game_switches[95]
          pbDisplayPaused("Actually, they're all powerful projections!")
        end
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        pbDisplayPaused(_INTL("You are challenged by {1}!",@opponent[0].full_name))
      when 2
        pbDisplayPaused(_INTL("You are challenged by {1} and {2}!",@opponent[0].full_name,
           @opponent[1].full_name))
      when 3
        pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
           @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
      end
    end
    # Send out Pokémon (opposing trainers first)
    for side in [1,0]
      next if side==1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side==0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t,i|
        next if side==0 && i==0   # The player's message is shown last
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!",t.full_name,@battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!",t.full_name,
             @battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!",t.full_name,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side==0
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!",@battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!",@battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts,true)
    end
  end


  #=============================================================================
  # Main battle loop
  #=============================================================================
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount+1}***")
      if @debug && @turnCount>=100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
	  
	  # Allow bosses to set various things about themselves
	  @battlers.each do |b|
		next if !b || b.fainted || !b.boss
		pbSetBossTurns(b)
		pbSetBossItem(b)
		pbSetBossForm(b)
	  end
	  
	  @commandPhasesThisRound = 0
	  
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision>0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision>0
	  
	  @commandPhasesThisRound = 1
	  
	  if $game_switches[95]
		  # Boss phases after main phases
		  extra = $game_variables[95] - 1
		  if extra > 0
			for i in 1..extra do
			  @battlers.each do |b|
				next if !b
				if b.boss
				  @lastRoundMoved = 0
				end
			  end
			  # Command phase
			  PBDebug.logonerr { pbExtraBossCommandPhase() }
			  break if @decision>0
			  
			  @commandPhasesThisRound += 1
			  
			  # Attack phase
			  PBDebug.logonerr { pbExtraBossAttackPhase() }
			  break if @decision>0
			end
		  end
	  end
	  
	  
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      @turnCount += 1
	  @commandPhasesThisRound = 0
    end
    pbEndOfBattle
  end
  
  def pbSetBossTurns(pkmn)
	if pkmn.species == :DIALGA
		healthRation = pkmn.hp / pkmn.totalhp
		if $game_variables[95] == 1 && healthRation < 0.66
			pbDisplay(_INTL("The projection of Dialga expands time on its side of the field!"))
			$game_variables[95] = 3
		elsif $game_variables[95] == 3 && healthRation < 0.33
			pbDisplay(_INTL("The projection of Dialga expands time even more! It's stretched to the max!"))
			$game_variables[95] = 4
		end
	elsif (pkmn.species == :KYOGRE || pkmn.species == :GROUDON)
		if  @turnCount % 3 == 0 && @turnCount > 0
			pbDisplay(_INTL("The projection is gathering energy for a massive attack!"))
			$game_variables[95] = 1
		else
			$game_variables[95] = 3
		end
	end
  end
  
  def pbSetBossItem(pkmn)
	if pkmn.species == :GENESECT && pkmn.turnCount == 0
		pbDisplay(_INTL("The projection of Genesect is analyzing your team for weaknesses..."))
		weakToElectric 	= 0
		weakToFire 		= 0
		weakToIce 		= 0
		weakToWater 	= 0
		maxValue = 0

		$Trainer.party.each do |b|
			next if !b
			type1 = b.type1
			type2 = nil
			type2 = b.type2 if b.type2 != b.type1
			weakToElectric += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ELECTRIC,type1,type2,nil))
			maxValue = weakToElectric if weakToElectric > maxValue
			weakToFire += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:FIRE,type1,type2,nil))
			maxValue = weakToElectric if weakToFire > maxValue
			weakToIce += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:ICE,type1,type2,nil))
			maxValue = weakToElectric if weakToIce > maxValue
			weakToWater += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:WATER,type1,type2,nil))
			maxValue = weakToElectric if weakToWater > maxValue
		end
		
		chosenItem = nil
		if maxValue > 0
			results = {SHOCKDRIVE: weakToElectric, BURNDRIVE: weakToFire, CHILLDRIVE: weakToIce, DOUSEDRIVE: weakToWater}
			results = results.sort_by{|k, v| v}.to_h
			results.delete_if{|k, v| v < maxValue}
			chosenItem = results.keys.sample
		end
		
		if !chosenItem
			pbDisplay(_INTL("The projection of Genesect can't find any!"))
		else
			pbDisplay(_INTL("The projection of Genesect loads a {1}!",GameData::Item.get(chosenItem).real_name))
			pkmn.item = chosenItem
		end
	end
  end
  
  def pbSetBossForm(pkmn)
	if (pkmn.species == :RAYQUAZA) && !pkmn.mega?
		pbMegaEvolve(pkmn.index)
	end
  end
  
  def pbExtraBossCommandPhase()
    @scene.pbBeginCommandPhase
    # Reset choices if commands can be shown
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    pbCommandPhaseLoop(false)
  end
  
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbExtraBossAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")   # Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    
	
	pbPriority.each do |b|
        next if b.fainted?
        next unless @choices[b.index][0]==:UseMove
        if b.boss
          b.pbProcessTurn(@choices[b.index])
        end
      end
  end
end

def pbPlayerPartyMaxLevel(countFainted = false)
  maxPlayerLevel = -100
  $Trainer.party.each do |pkmn|
    maxPlayerLevel = pkmn.level if pkmn.level > maxPlayerLevel && (!pkmn.fainted? || countFainted)
  end
  return maxPlayerLevel
end