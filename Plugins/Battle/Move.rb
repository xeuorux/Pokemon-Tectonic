class PokeBattle_Move
  #=============================================================================
  # Animate the damage dealt, including lowering the HP
  #=============================================================================
  # Animate being damaged and losing HP (by a move)
  def pbAnimateHitAndHPLost(user,targets)
    # Animate allies first, then foes
    animArray = []
    for side in 0...2   # side here means "allies first, then foes"
      targets.each do |b|
        next if b.damageState.unaffected || b.damageState.hpLost==0
        next if (side==0 && b.opposes?(user)) || (side==1 && !b.opposes?(user))
        oldHP = b.hp+b.damageState.hpLost
        PBDebug.log("[Move damage] #{b.pbThis} lost #{b.damageState.hpLost} HP (#{oldHP}=>#{b.hp})")
        effectiveness = 0
        if Effectiveness.resistant?(b.damageState.typeMod);          effectiveness = 1
        elsif Effectiveness.super_effective?(b.damageState.typeMod); effectiveness = 2
        end
		effectiveness = -1 if Effectiveness.ineffective?(b.damageState.typeMod)
        effectiveness = 4 if Effectiveness.hyper_effective?(b.damageState.typeMod)
        animArray.push([b,oldHP,effectiveness])
      end
      if animArray.length>0
        @battle.scene.pbHitAndHPLossAnimation(animArray)
        animArray.clear
      end
    end
  end
  
  #=============================================================================
  # Weaken the damage dealt (doesn't actually change a battler's HP)
  #=============================================================================
  def pbCheckDamageAbsorption(user,target)
    # Substitute will take the damage
    if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user) &&
       (!user || user.index!=target.index)
      target.damageState.substitute = true
      return
    end
    # Disguise will take the damage
    if !@battle.moldBreaker && target.isSpecies?(:MIMIKYU) &&
       target.form==0 && target.ability == :DISGUISE
      target.damageState.disguise = true
      return
    end
	# Ice Face will take the damage
    if !@battle.moldBreaker && target.species == :EISCUE &&
       target.form==0 && target.ability == :ICEFACE && physicalMove?
      target.damageState.iceface = true
      return
    end
  end
  
  def pbReduceDamage(user,target)
    damage = target.damageState.calcDamage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage>target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
      return
    end
    # Disguise takes the damage
    return if target.damageState.disguise
	# Ice Face takes the damage
    return if target.damageState.iceface
    # Target takes the damage
    if damage>=target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user,target)
        damage -= 1
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
      elsif damage==target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp==target.totalhp
          target.damageState.focusSash = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100)<10
          target.damageState.focusBand = true
          damage -= 1
        end
      end
    end
    damage = 0 if damage<0
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
  end

  #=============================================================================
  # Messages upon being hit
  #=============================================================================
  def pbEffectivenessMessage(user,target,numTargets=1)
    return if target.damageState.disguise
	return if target.damageState.iceface
	if Effectiveness.hyper_effective?(target.damageState.typeMod)
	  if numTargets>1
        @battle.pbDisplay(_INTL("It's hyper effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's hyper effective!"))
      end
    elsif Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
  end
  
  def pbHitEffectivenessMessages(user,target,numTargets=1)
    return if target.damageState.disguise
	return if target.damageState.iceface
    if target.damageState.substitute
      @battle.pbDisplay(_INTL("The substitute took damage for {1}!",target.pbThis(true)))
    end
    if target.damageState.critical
      if numTargets>1
        @battle.pbDisplay(_INTL("A critical hit on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("A critical hit!"))
      end
    end
    # Effectiveness message, for moves with 1 hit
    if !multiHitMove? && user.effects[PBEffects::ParentalBond]==0
      pbEffectivenessMessage(user,target,numTargets)
    end
    if target.damageState.substitute && target.effects[PBEffects::Substitute]==0
      target.effects[PBEffects::Substitute] = 0
      @battle.pbDisplay(_INTL("{1}'s substitute faded!",target.pbThis))
    end
  end
  
  def pbEndureKOMessage(target)
    if target.damageState.disguise
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
      else
        @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1}'s disguise was busted!",target.pbThis))
	elsif target.damageState.iceface
      @battle.pbShowAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1} transformed!",target.pbThis))
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
    elsif target.damageState.sturdy
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.focusSash
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",target.pbThis))
      target.pbConsumeItem
    elsif target.damageState.focusBand
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",target.pbThis))
    end
  end
end
