MultipleForms.register(:AMPHAROS,{
    "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
    }
})

MultipleForms.register(:GARCHOMP,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  }
})

MultipleForms.register(:GYARADOS,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  }
})