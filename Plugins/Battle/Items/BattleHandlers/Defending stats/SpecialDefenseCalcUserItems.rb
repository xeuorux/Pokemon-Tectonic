BattleHandlers::SpecialDefenseCalcUserItem.add(:ASSAULTVEST,
  proc { |_item, _user, _battle, spDefMult|
      spDefMult *= 1.5
      next spDefMult
  }
)
