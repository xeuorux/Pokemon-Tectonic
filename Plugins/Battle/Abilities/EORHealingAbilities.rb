BattleHandlers::EORHealingAbility.add(:HEALER,
  proc { |ability,battler,battle|
    battler.eachAlly do |b|
      next if !b.hasAnyStatusNoTrigger
      battle.pbShowAbilitySplash(battler)
      b.pbCureStatus()
      battle.pbHideAbilitySplash(battler)
    end
  }
)


BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
  proc { |ability,battler,battle|
    next if !battler.hasAnyStatusNoTrigger
    battle.pbShowAbilitySplash(battler)
    b.pbCureStatus()
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
  proc { |ability,battler,battle|
    next if !battler.hasAnyStatusNoTrigger
    next if ![:Rain, :HeavyRain].include?(battle.pbWeather)
    battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    battle.pbHideAbilitySplash(battler)
  }
)