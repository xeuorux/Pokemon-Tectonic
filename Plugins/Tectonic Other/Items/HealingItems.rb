ItemHandlers::UseOnPokemon.add(:ICEHEAL,proc { |item,pkmn,scene|
    if pkmn.fainted? || pkmn.status != :FROZEN
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.heal_status
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was unchilled out.",pkmn.name))
    next true
  })
  
  ItemHandlers::UseOnPokemon.copy(:FULLHEAL,:STATUSHEAL)
  
  ItemHandlers::UseOnPokemon.add(:POTION,proc { |item,pkmn,scene|
    next pbHPItem(pkmn,40,scene)
  })
  
  ItemHandlers::UseOnPokemon.add(:SUPERPOTION,proc { |item,pkmn,scene|
    next pbHPItem(pkmn,80,scene)
  })
  
  ItemHandlers::UseOnPokemon.add(:HYPERPOTION,proc { |item,pkmn,scene|
    next pbHPItem(pkmn,120,scene)
  })