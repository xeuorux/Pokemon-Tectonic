ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  if pkmn.level>=GameData::GrowthRate.max_level || pkmn.shadowPokemon?
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  elsif LEVEL_CAPS_USED && (pkmn.level + 1) > $game_variables[26]
      scene.pbDisplay(_INTL("It won't have any effect due to the level cap at #{$game_variables[26]}."))
      next false
  end
  pbChangeLevel(pkmn,pkmn.level+1,scene)
  scene.pbHardRefresh
  next true
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,250,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,1000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,4000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,12000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,50000,item,scene)
})