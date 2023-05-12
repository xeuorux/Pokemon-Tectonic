BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability, battler|
      next unless battler.hasStatusNoTrigger(:POISON)
      battler.battle.pbShowAbilitySplash(battler, ability)
      battler.pbCureStatus(true, :POISON)
      battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability, battler|
      next unless battler.hasStatusNoTrigger(:SLEEP)
      battler.battle.pbShowAbilitySplash(battler, ability)
      battler.pbCureStatus(true, :SLEEP)
      battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA, :VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability, battler|
      next unless battler.hasStatusNoTrigger(:SLEEP)
      battler.battle.pbShowAbilitySplash(battler, ability)
      battler.pbCureStatus(true, :NUMB)
      battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability, battler|
      next unless battler.hasStatusNoTrigger(:BURN)
      battler.battle.pbShowAbilitySplash(battler, ability)
      battler.pbCureStatus(true, :BURN)
      battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL, :WATERBUBBLE)

BattleHandlers::StatusCureAbility.add(:MENTALBLOCK,
  proc { |ability, battler|
      battle = battler.battle

      activate = false
      battler.eachEffect(true) do |_effect, _value, data|
          next unless data.is_mental?
          activate = true
          break
      end
      activate = true if battler.dizzy?

      if activate
          battle.pbShowAbilitySplash(battler, ability)
          # Disable all mental effects
          battler.eachEffect(true) do |effect, _value, data|
              next unless data.is_mental?
              battler.disableEffect(effect)
          end
          battler.pbCureStatus(true, :DIZZY) if battler.dizzy?
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::StatusCureAbility.add(:ENERGETIC,
  proc { |ability, battler|
      if battler.hasStatusNoTrigger(:POISON)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :POISON)
          battler.battle.pbHideAbilitySplash(battler)
      end
      if battler.hasStatusNoTrigger(:NUMB)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :NUMB)
          battler.battle.pbHideAbilitySplash(battler)
      end
      if battler.hasStatusNoTrigger(:FROZEN)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :FROZEN)
          battler.battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::StatusCureAbility.add(:STABILITY,
  proc { |ability, battler|
      if battler.hasStatusNoTrigger(:POISON)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :POISON)
          battler.battle.pbHideAbilitySplash(battler)
      end
      if battler.hasStatusNoTrigger(:BURN)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :BURN)
          battler.battle.pbHideAbilitySplash(battler)
      end
      if battler.hasStatusNoTrigger(:FROSTBITE)
          battler.battle.pbShowAbilitySplash(battler, ability)
          battler.pbCureStatus(true, :FROSTBITE)
          battler.battle.pbHideAbilitySplash(battler)
      end
  }
)


BattleHandlers::StatusCureAbility.add(:SEASURVIVOR,
    proc { |ability, battler|
        if battler.hasStatusNoTrigger(:BURN)
            battler.battle.pbShowAbilitySplash(battler, ability)
            battler.pbCureStatus(true, :BURN)
            battler.battle.pbHideAbilitySplash(battler)
        end
        if battler.hasStatusNoTrigger(:FROSTBITE)
            battler.battle.pbShowAbilitySplash(battler, ability)
            battler.pbCureStatus(true, :FROSTBITE)
            battler.battle.pbHideAbilitySplash(battler)
        end
    }
  )
  