BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |ability, battler, _stat, battle, showMessages|
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY, :WHITESMOKE, :FULLMETALBODY, :STAINLESSSTEEL, :OPTIMIZEDALLOY)

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

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |ability, battler, stat, battle, showMessages|
      next false if stat != :ACCURACY
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |ability, battler, stat, battle, showMessages|
      next false if stat != :ATTACK && stat != :SPECIAL_ATTACK
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |ability, battler, stat, battle, showMessages|
      next false if stat != :DEFENSE && stat != :SPECIAL_DEFENSE
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:IMPERVIOUS,
  proc { |ability, battler, stat, battle, showMessages|
      next false if stat != :DEFENSE && stat != :SPECIAL_DEFENSE
      if showMessages
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
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