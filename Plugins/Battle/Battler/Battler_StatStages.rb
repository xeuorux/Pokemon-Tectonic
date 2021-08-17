class PokeBattle_Battler
	def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
    # Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
	# Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} harshly fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} severely fell!",pbThis,GameData::Stat.get(stat).name)]
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
	# Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
	# Royal Scales
    if hasActiveAbility?(:ROYALSCALES) && !@battle.moldBreaker
      return false
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerSpecialAttackStatStageDazzle(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end
end