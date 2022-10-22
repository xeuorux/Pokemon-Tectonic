BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
    proc { |ability,battler,battle|
      next if !battler.hasAnyStatusNoTrigger
      battle.pbShowAbilitySplash(battler)
      battler.pbCureStatus(true,:POISON)
      battler.pbCureStatus(true,:BURN)
      battler.pbCureStatus(true,:PARALYSIS)
      battler.pbCureStatus(true,:FROZEN)
      battler.pbCureStatus(true,:FROSTBITE)
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