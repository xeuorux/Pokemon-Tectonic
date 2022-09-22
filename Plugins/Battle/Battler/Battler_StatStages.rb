class PokeBattle_Battler
  # These are not yet used everywhere they should be. Do not modify and expect consistent results.
  STAGE_MULTIPLIERS = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
  STAGE_DIVISORS    = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]

	def pbRaiseStatStage(stat,increment,user,showAnim=true,ignoreContrary=false)
		# Contrary
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		  return pbLowerStatStage(stat,increment,user,showAnim,true)
		end
		# Perform the stat stage change
		increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
		return false if increment<=0
		# Stat up animation and message
		@battle.pbCommonAnimation("StatUp",self) if showAnim
		arrStatTexts = [
		   _INTL("{1}'s {2} rose{3}!",pbThis,GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
		   _INTL("{1}'s {2} rose{3}!",pbThis,GameData::Stat.get(stat).name,boss? ? "" : " sharply"),
		   _INTL("{1}'s {2} rose{3}!",pbThis,GameData::Stat.get(stat).name,boss? ? " greatly" : " drastically")]
		@battle.pbDisplay(arrStatTexts[[increment-1,2].min])
		# Trigger abilities upon stat gain
		if abilityActive?
		  BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
		end
		return true
	end

	def pbRaiseStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false)
		# Contrary
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
		  return pbLowerStatStageByCause(stat,increment,user,cause,showAnim,true)
		end
		# Perform the stat stage change
		increment = pbRaiseStatStageBasic(stat,increment,ignoreContrary)
		return false if increment<=0
		# Stat up animation and message
		@battle.pbCommonAnimation("StatUp",self) if showAnim
		if user.index==@index
		  arrStatTexts = [
			 _INTL("{1}'s {2}{4} raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
			 _INTL("{1}'s {2}{4} raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? "" : " sharply"),
			 _INTL("{1}'s {2}{4} raised its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? " greatly" : " drastically")]
		else
		  arrStatTexts = [
			 _INTL("{1}'s {2}{5} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
			 _INTL("{1}'s {2}{5} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? "" : " sharply"),
			 _INTL("{1}'s {2}{5} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? " greatly" : " drastically")]
		end
		@battle.pbDisplay(arrStatTexts[[increment-1,2].min])
		# Trigger abilities upon stat gain
		if abilityActive?
		  BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
		end
		return true
	end

  def pbCanLowerStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
    return false if fainted?
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
    end
    if !user || user.index!=@index   # Not self-inflicted
      if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user))
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis)) if showFailMsg
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
        return false
      end
      if abilityActive?
        return false if BattleHandlers.triggerStatLossImmunityAbility(
           self.ability,self,stat,@battle,showFailMsg) if !@battle.moldBreaker
        return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(
           self.ability,self,stat,@battle,showFailMsg)
      end
      if !@battle.moldBreaker
        eachAlly do |b|
          next if !b.abilityActive?
          return false if BattleHandlers.triggerStatLossImmunityAllyAbility(
             b.ability,b,self,stat,@battle,showFailMsg)
        end
      end
    elsif hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
      return false
    end
    # Check the stat stage
    if statStageAtMin?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis, GameData::Stat.get(stat).name)) if showFailMsg
      return false
    end
    return true
  end

	def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
		# Mirror Armor, only if not self inflicted
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
    # Stubborn
    if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
      return false
    end
		# Perform the stat stage change
		increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
		return false if increment<=0
		# Stat down animation and message
		@battle.pbCommonAnimation("StatDown",self) if showAnim
		arrStatTexts = [
		   _INTL("{1}'s {2}{3} fell!",pbThis,GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
		   _INTL("{1}'s {2}{3} fell!",pbThis,GameData::Stat.get(stat).name,boss? ? "" : " harshly"),
		   _INTL("{1}'s {2}{3} fell!",pbThis,GameData::Stat.get(stat).name,boss? ? " severely" : " badly")]
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
	  # Stubborn
    if hasActiveAbility?(:STUBBORN) && !@battle.moldBreaker
      return false
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2}{4} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
         _INTL("{1}'s {2}{4} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? "" : " harshly"),
         _INTL("{1}'s {2}{4} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name,boss? ? " severely" : " badly")]
    else
      arrStatTexts = [
         _INTL("{1}'s {2}{5} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? " slightly" : ""),
         _INTL("{1}'s {2}{5} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? "" : " harshly"),
         _INTL("{1}'s {2}{5} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name,boss? ? " severely" : " badly")]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	  @effects[PBEffects::LashOut] = true
    return true
  end
  
  
  def pbLowerAttackStatStageIntimidate(user)
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
    if hasActiveAbility?(:INNERFOCUS)
      @battle.pbShowAbilitySplash(self,true)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
              pbThis,abilityName,user.pbThis(true),user.abilityName))
      @battle.pbHideAbilitySplash(self)
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:ATTACK,1,user,false)
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
    return false if !pbCanLowerStatStage?(:ATTACK,user)
    return pbLowerStatStageByCause(:ATTACK,1,user,user.abilityName)
  end
  
  def pbLowerSpecialAttackStatStageFascinate(user)
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
    if hasActiveAbility?(:INNERFOCUS)
      @battle.pbShowAbilitySplash(self,true)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
              pbThis,abilityName,user.pbThis(true),user.abilityName))
      @battle.pbHideAbilitySplash(self)
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
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:SPECIAL_ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:SPECIAL_ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end
  
  def pbLowerSpeedStatStageFrustrate(user)
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
    if hasActiveAbility?(:INNERFOCUS)
      @battle.pbShowAbilitySplash(self,true)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
              pbThis,abilityName,user.pbThis(true),user.abilityName))
      @battle.pbHideAbilitySplash(self)
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPEED,1,user,false)
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
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:SPEED,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:SPEED,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:SPEED,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPEED,user)
    return pbLowerStatStageByCause(:SPEED,1,user,user.abilityName)
  end
  
	def statStagesUp?()
		return stages[:ATTACK] > 0 || stages[:DEFENSE] > 0 ||
				stages[:SPEED] > 0 || stages[:SPECIAL_ATTACK] > 0 ||
				stages[:SPECIAL_DEFENSE] > 0 || stages[:ACCURACY] > 0 ||
				stages[:EVASION] > 0
	end
  	

  def pbMinimizeStatStage(stat,user=nil,move=nil,ignoreContrary=false)
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			pbMaximizeStatStage(stat,user,move,true)
		elsif pbCanLowerStatStage?(stat,user,move,true,ignoreContrary)
			@stages[stat] = -6
			@battle.pbCommonAnimation("StatDown",self)
      statName = GameData::Stat.get(stat).real_name
			@battle.pbDisplay(_INTL("{1} minimized its {2}!",self.pbThis, statName))
		end
	end

	def pbMaximizeStatStage(stat,user=nil,move=nil,ignoreContrary=false)
		if hasActiveAbility?(:CONTRARY) && !ignoreContrary
			pbMinimizeStatStage(stat,user,move,true)
		elsif pbCanRaiseStatStage?(stat,user,move,true,ignoreContrary)
			@stages[stat] = 6
			@battle.pbCommonAnimation("StatUp",self)
      statName = GameData::Stat.get(stat).real_name
			@battle.pbDisplay(_INTL("{1} maximizes its {2}!",self.pbThis, statName))
		end
	end
end