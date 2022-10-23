ItemHandlers::UseOnPokemon.add(:FLAMEORB,proc { |item,pkmn,scene|
    if pkmn.fainted? || pkmn.status != :NONE || [:STABILITY,:FAEVEIL].include?(pkmn.ability_id)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.status      = :BURN
    pkmn.statusCount = 0
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was burned.",pkmn.name))
  })
  
  ItemHandlers::UseOnPokemon.add(:FROSTORB,proc { |item,pkmn,scene|
    if pkmn.fainted? || pkmn.status != :NONE || [:STABILITY,:FAEVEIL].include?(pkmn.ability_id)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.status      = :FROSTBITE
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was frostbitten.",pkmn.name))
  })
  
  ItemHandlers::UseOnPokemon.add(:POISONORB,proc { |item,pkmn,scene|
    if pkmn.fainted? || pkmn.status != :NONE || [:STABILITY,:ENERGETIC].include?(pkmn.ability_id)
      scene.pbDisplay(_INTL("It won't have any effect."))
      next false
    end
    pkmn.status      = :POISON
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1} was poisoned.",pkmn.name))
  })