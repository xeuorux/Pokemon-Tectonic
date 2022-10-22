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
        battler.pbCureStatus()
        battle.pbHideAbilitySplash(battler)
    }
)

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