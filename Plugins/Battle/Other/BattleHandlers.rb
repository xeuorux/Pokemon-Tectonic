def pbBattleGem(user,type,move,mults,moveType)
  # Pledge moves never consume Gems
  return if move.is_a?(PokeBattle_PledgeMove)
  return if moveType != type
  user.effects[PBEffects::GemConsumed] = user.item_id
  mults[:base_damage_multiplier] *= 1.5
end