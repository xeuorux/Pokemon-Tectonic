class PokeBattle_Battle
  #=============================================================================
  # Running from battle
  #=============================================================================
  def pbCanRun?(idxBattler)
    return false if trainerBattle? || bossBattle? # Boss battle
    battler = @battlers[idxBattler]
    return false if !@canRun && !battler.opposes?
    #return true if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
    return true if battler.abilityActive? &&
                   BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
    return true if battler.itemActive? &&
                   BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
    return false if battler.effects[PBEffects::Trapping]>0 ||
                    battler.effects[PBEffects::MeanLook]>=0 ||
                    battler.effects[PBEffects::Ingrain] ||
                    battler.effects[PBEffects::JawLock] ||
                    battler.effects[PBEffects::OctolockUser]>=0 ||
                    battler.effects[PBEffects::NoRetreat] ||
                    @field.effects[PBEffects::FairyLock]>0
    eachOtherSideBattler(idxBattler) do |b|
      return false if b.abilityActive? &&
                      BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
      return false if b.itemActive? &&
                      BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
    end
    return true
  end
	
  # Return values:
  # -1: Failed fleeing
  #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
  #  1: Succeeded at fleeing, battle will end
  # duringBattle is true for replacing a fainted Pokémon during the End Of Round
  # phase, and false for choosing the Run command.
  def pbRun(idxBattler,duringBattle=false)
    battler = @battlers[idxBattler]
    if battler.opposes?
      return 0 if trainerBattle?
      @choices[idxBattler][0] = :Run
      @choices[idxBattler][1] = 0
      @choices[idxBattler][2] = nil
      return -1
    end
    # Fleeing from trainer battles or boss battles
    if trainerBattle? || $game_switches[95]
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision = 2
          return 1
        end
      elsif pbDisplayConfirmSerious(_INTL("Would you like to forfeit the match and quit now?"))
        pbSEPlay("Battle flee")
        if @internalBattle
          @decision = 2
        else
          @decision = 3
        end
        return 1
      end
      return 0
    end
    # Fleeing from wild battles
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("You got away safely!"))
      @decision = 3
      return 1
    end
    if !@canRun
      pbDisplayPaused(_INTL("You can't escape!"))
      return 0
    end
    if !duringBattle
=begin
      if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("Your Pokémon uses its ghostly powers to escape!"))
        @decision = 3
        return 1
      end
=end
      # Abilities that guarantee escape
      if battler.abilityActive?
        if BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
          pbShowAbilitySplash(battler,true)
          pbHideAbilitySplash(battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("You got away safely!"))
          @decision = 3
          return 1
        end
      end
      # Held items that guarantee escape
      if battler.itemActive?
        if BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("{1} fled using its {2}!",
             battler.pbThis,battler.itemName))
          @decision = 3
          return 1
        end
      end
	  if battler.effects[PBEffects::JawLock]
		  @battlers.each do |b|
			if (battler.effects[PBEffects::JawLockUser] == b.index) && !b.fainted?
			  partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
			  return false
			end
		  end
      end
      # Other certain trapping effects
      if battler.effects[PBEffects::Trapping]>0 ||
         battler.effects[PBEffects::MeanLook]>=0 ||
         battler.effects[PBEffects::Ingrain] ||
         @field.effects[PBEffects::FairyLock]>0
        pbDisplayPaused(_INTL("You can't escape!"))
        return 0
      end
      # Trapping abilities/items
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.abilityName))
          return 0
        end
      end
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.itemActive?
        if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.itemName))
          return 0
        end
      end
    end

	levelPlayer = 1
    if levelPlayer<@battlers[idxBattler].level
      levelPlayer = @battlers[idxBattler].level
    end
    @battlers[idxBattler].eachAlly do |a|
     levelPlayer = a.level if levelPlayer<a.level
    end

    levelEnemy = 1
	anyOwned = false
    eachOtherSideBattler(idxBattler) do |b|
      levelEnemy = b.level if b.level > levelEnemy
	  anyOwned = true if b.owned?
    end

    rate = 140
    rate += 10 * [levelPlayer-levelEnemy,0].max
    rate += @runCommand*20
	rate += 50 if anyOwned
        
    if rate>=250 || @battleAI.pbAIRandom(250)<rate
      pbSEPlay("Battle flee")
      case rate
      when 0..130; pbDisplayPaused(_INTL("Miraculously, you found a way out!"))
      when 131..170; pbDisplayPaused(_INTL("It was hard work, but you managed to escape!"))
      when 171..210; pbDisplayPaused(_INTL("With a bit of luck you made your retreat!"))
      when 211..250; pbDisplayPaused(_INTL("You got away safely!"))
      when 251..10000; pbDisplayPaused(_INTL("You fled easily!"))
      end
      @decision = 3
      return 1
    end
    case rate
    when 0..130; pbDisplayPaused(_INTL("You're locked in place by fear!"))
    when 131..170; pbDisplayPaused(_INTL("You don't see a way out!"))
    when 171..210; pbDisplayPaused(_INTL("You couldn't get away!"))
    when 211..250; pbDisplayPaused(_INTL("The wild Pokémon narrowly blocks your escape!"))
    end
    return -1
  end
end