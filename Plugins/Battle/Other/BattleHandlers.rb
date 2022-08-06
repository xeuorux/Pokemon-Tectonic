def pbBattleGem(user,type,move,mults,moveType)
  # Pledge moves never consume Gems
  return if move.is_a?(PokeBattle_PledgeMove)
  return if moveType != type
  user.effects[PBEffects::GemConsumed] = user.item_id
  mults[:base_damage_multiplier] *= 1.5
end

def terrainSetAbility(terrain,battler,battle,ignorePrimal=false)
  return if battle.field.terrain == terrain
  battle.pbShowAbilitySplash(battler)
  if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
  end
  battle.pbStartTerrain(battler, terrain)
  # NOTE: The ability splash is hidden again in def pbStartTerrain.
end