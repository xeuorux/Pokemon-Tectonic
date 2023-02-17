MultipleForms.register(:SILVALLY,{
  "getForm" => proc { |pkmn|
    next nil unless pkmn.hasAbility?(:RKSSYSTEM)
    next 0 unless pkmn.hasItem?(:MEMORYSET)
    next GameData::Type.get(pkmn.itemTypeChosen).id_number
  }
})

MultipleForms.register(:ARCEUS,{
  "getForm" => proc { |pkmn|
    next nil unless pkmn.hasAbility?(:MULTITYPE)
    next 0 unless pkmn.hasItem?(:PRISMATICPLATE)
    next GameData::Type.get(pkmn.itemTypeChosen).id_number
  }
})

MultipleForms.register(:AMPHAROS, {
    "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
        next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
    },
})

MultipleForms.register(:GARCHOMP, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  },
})

MultipleForms.register(:GYARADOS, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  },
})

MultipleForms.register(:PUMPKABOO, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.fainted? || endBattle
  },
})

MultipleForms.register(:GOURGEIST, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.fainted? || endBattle
  },
})
