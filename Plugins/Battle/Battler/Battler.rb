class PokeBattle_Battler
	def takesSandstormDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL,:STOUT])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	  end

	def takesHailDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:ICE) || pbHasType?(:STEEL) || pbHasType?(:GHOST)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK,:STOUT,:SNOWWARNING])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	end
	
	def shiny?
		return false if boss?
		return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
		return @pokemon && @pokemon.shiny?
	end
	
  # Returns the active types of this Pokémon. The array should not include the
  # same type more than once, and should not include any invalid type numbers
  # (e.g. -1).
  def pbTypes(withType3=false)
    ret = [@type1]
    ret.push(@type2) if @type2!=@type1
    # Burn Up erases the Fire-type.
    ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
	# Cold Conversion erases the Ice-type.
    ret.delete(:ICE) if @effects[PBEffects::ColdConversion]
    # Roost erases the Flying-type. If there are no types left, adds the Normal-
    # type.
    if @effects[PBEffects::Roost]
      ret.delete(:FLYING)
      ret.push(:NORMAL) if ret.length == 0
    end
    # Add the third type specially.
    if withType3 && @effects[PBEffects::Type3]
      ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
    end
    return ret
  end
  
  # NOTE: Do not create any held item which affects whether a Pokémon's ability
  #       is active. The ability Klutz affects whether a Pokémon's item is
  #       active, and the code for the two combined would cause an infinite loop
  #       (regardless of whether any Pokémon actualy has either the ability or
  #       the item - the code existing is enough to cause the loop).
  def abilityActive?(ignore_fainted = false)
    return false if fainted? && !ignore_fainted
	return false if @battle.field.effects[PBEffects::NeutralizingGas]
    return false if @effects[PBEffects::GastroAcid]
    return true
  end
  
  # Applies to both losing self's ability (i.e. being replaced by another) and
  # having self's ability be negated.
  def unstoppableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
#      :FLOWERGIFT,                                        # This can be stopped
#      :FORECAST,                                          # This can be stopped
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :ICEFACE,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
      :GULPMISSILE,
      :ASONEICE,
      :ASONEGHOST
    ]
    return ability_blacklist.include?(abil.id)
  end
  
  # Applies to gaining the ability.
  def ungainableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :FLOWERGIFT,
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      # Appearance-changing abilities
      :ILLUSION,
      :IMPOSTER,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
	  :NEUTRALIZINGGAS,
	  :HUNGERSWITCH
    ]
    return ability_blacklist.include?(abil.id)
  end
  
  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
	permanent = false # Items respawn after battle always!!
    @effects[PBEffects::ChoiceBand] = nil
    @effects[PBEffects::Unburden]   = true if self.item
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
	@battle.scene.pbRefresh()
  end
  
  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbSpeed
    return 1 if fainted?
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = @stages[:SPEED] + 6
    speed = @speed*stageMul[stage]/stageDiv[stage]
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = BattleHandlers.triggerSpeedCalcAbility(self.ability,self,speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = BattleHandlers.triggerSpeedCalcItem(self.item,self,speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
    # Paralysis
    if (status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)) || status == :FROZEN
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    return [(speed*speedMult).round,1].max
  end
end