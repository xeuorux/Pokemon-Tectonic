BattleHandlers::HealingAbility.add(:HEALER,
    proc { |ability,battler,battle|
      battler.eachAlly do |b|
        next if !b.hasAnyStatusNoTrigger
        battle.pbShowAbilitySplash(battler)
        b.pbCureStatus()
        battle.pbHideAbilitySplash(battler)
      end
    }
)