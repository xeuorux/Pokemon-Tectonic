BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |_ability, battler, _stat, battle, showMessages|
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY, :WHITESMOKE, :STUBBORN, :FULLMETALBODY, :METALCOVER)

BattleHandlers::StatLossImmunityAbility.add(:ANCIENTSCALES,
  proc { |_ability, battler, _stat, battle, showMessages|
      next false unless @battle.pbWeather == :Eclipse
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |_ability, battler, _stat, battle, showMessages|
      next false unless battler.pbHasType?(:GRASS)
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |_ability, battler, stat, battle, showMessages|
      next false if stat != :ACCURACY
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |_ability, battler, stat, battle, showMessages|
      next false if stat != :ATTACK && stat != :SPECIAL_ATTACK
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |_ability, battler, stat, battle, showMessages|
      next false if stat != :DEFENSE && stat != :SPECIAL_DEFENSE
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:IMPERVIOUS,
  proc { |_ability, battler, stat, battle, showMessages|
      next false if stat != :DEFENSE && stat != :SPECIAL_DEFENSE
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)


BattleHandlers::StatLossImmunityAbility.add(:JUGGERNAUT,
  proc { |_ability, battler, stat, battle, showMessages|
      next false if stat != :SPEED
      if showMessages
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!", battler.pbThis, GameData::Stat.get(stat).name))
          battle.pbHideAbilitySplash(battler)
      end
      next true
  }
)
