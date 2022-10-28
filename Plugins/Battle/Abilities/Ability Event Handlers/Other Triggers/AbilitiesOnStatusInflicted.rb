BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
    proc { |ability,battler,user,status|
      next if !user || user.index==battler.index
      next if !user.pbCanSynchronizeStatus?(status, battler)
      case status
      when :POISON
          battler.battle.pbShowAbilitySplash(battler)
          user.pbPoison(battler,nil,(battler.getStatusCount(:POISON)>0))
          battler.battle.pbHideAbilitySplash(battler)
      when :BURN
          battler.battle.pbShowAbilitySplash(battler)
          user.pbBurn(battler)
          battler.battle.pbHideAbilitySplash(battler)
      when :PARALYSIS
          battler.battle.pbShowAbilitySplash(battler)
          user.pbParalyze(battler)
          battler.battle.pbHideAbilitySplash(battler)
        when :FROZEN
          battler.battle.pbShowAbilitySplash(battler)
          user.pbFreeze(battler)
          battler.battle.pbHideAbilitySplash(battler)
       when :FROSTBITE
          battler.battle.pbShowAbilitySplash(battler)
          user.pbFrostbite(battler)
          battler.battle.pbHideAbilitySplash(battler)
      end
    }
  )