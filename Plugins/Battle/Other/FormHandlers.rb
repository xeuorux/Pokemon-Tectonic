MultipleForms.register(:SHAYMIN,{
  "getForm" => proc { |pkmn|
    next 0 if pkmn.fainted? || pkmn.frozen? || PBDayNight.isNight?
  }
})