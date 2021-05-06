BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status != :FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} unchilled it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)