MultipleForms.register(:AMPHAROS,{
    "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
      next 0
    }
})

MultipleForms.register(:GARCHOMP,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})