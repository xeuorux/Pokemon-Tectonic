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