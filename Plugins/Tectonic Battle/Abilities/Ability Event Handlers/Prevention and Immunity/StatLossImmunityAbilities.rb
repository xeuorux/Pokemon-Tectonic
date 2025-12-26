BattleHandlers::LoadDataDependentAbilityHandlers += proc {
  GameData::Ability.getByFlag("OtherStatDropImmunity").each do |abilityID|
    BattleHandlers::StatLossImmunityAbility.add(abilityID,
      proc { |ability, battler, _stat, battle, showMessages|
          if showMessages
              battle.pbShowAbilitySplash(battler, ability)
              battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
              battle.pbHideAbilitySplash(battler)
          end
          next true
      }
    )
  end
}

BattleHandlers::StatLossImmunityAbility.add(:PLOTARMOR,
  proc { |ability, battler, _stat, battle, showMessages|
      next false unless battle.eclipsed?
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunitySelfAbility.add(:PLOTARMOR,
  proc { |ability, battler, _stat, battle, showMessages|
      next false unless battle.eclipsed?
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:STONESYMBOL,
  proc { |ability, battler, _stat, battle, showMessages|
      next false unless battle.sandy?
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunitySelfAbility.add(:STONESYMBOL,
  proc { |ability, battler, _stat, battle, showMessages|
      next false unless battle.sandy?
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |ability, battler, _stat, battle, showMessages|
      next false unless battler.pbHasType?(:GRASS)
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:RUNNINGFREE,
  proc { |ability, battler, stat, battle, showMessages|
      next false unless stat == :SPEED
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunitySelfAbility.add(:RUNNINGFREE,
  proc { |ability, battler, stat, battle, showMessages|
      next false unless stat == :SPEED
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)