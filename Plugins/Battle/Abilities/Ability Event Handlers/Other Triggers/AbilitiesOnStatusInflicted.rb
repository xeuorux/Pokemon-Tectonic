BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
    proc { |ability,battler,user,status|
      next if !user || user.index==battler.index
      next if !user.pbCanSynchronizeStatus?(status, battler)
      case status
      when :POISON
          battler.battle.pbShowAbilitySplash(battler)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}! {4}!",battler.pbThis,battler.abilityName,user.pbThis(true),POISONED_EXPLANATION)
          end
          user.pbPoison(nil,msg,(battler.getStatusCount(:POISON)>0))
          battler.battle.pbHideAbilitySplash(battler)
      when :BURN
          battler.battle.pbShowAbilitySplash(battler)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} burned {3}! {4}!",battler.pbThis,battler.abilityName,user.pbThis(true),BURNED_EXPLANATION)
          end
          user.pbBurn(nil,msg)
          battler.battle.pbHideAbilitySplash(battler)
      when :PARALYSIS
          battler.battle.pbShowAbilitySplash(battler)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} numbed {3}! {4}!",
               battler.pbThis,battler.abilityName,user.pbThis(true),NUMBED_EXPLANATION)
          end
          user.pbParalyze(nil,msg)
          battler.battle.pbHideAbilitySplash(battler)
        when :FROZEN
          battler.battle.pbShowAbilitySplash(battler)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} chilled {3}! {4}}",
               battler.pbThis,battler.abilityName,user.pbThis(true),CHILLED_EXPLANATION)
          end
          user.pbFreeze(nil,msg)
          battler.battle.pbHideAbilitySplash(battler)
       when :FROSTBITE
          battler.battle.pbShowAbilitySplash(battler)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} frostbit {3}! {4}}!",
               battler.pbThis,battler.abilityName,user.pbThis(true),FROSTBITE_EXPLANATION)
          end
          user.pbFrostbite(nil,msg)
          battler.battle.pbHideAbilitySplash(battler)
      end
    }
  )