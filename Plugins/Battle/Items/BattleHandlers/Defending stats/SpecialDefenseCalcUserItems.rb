BattleHandlers::SpecialDefenseCalcUserItem.add(:ASSAULTVEST,
  proc { |item,user,battle,spDefMult|
    spDefMult *= 1.5
    next spDefMult
  }
)