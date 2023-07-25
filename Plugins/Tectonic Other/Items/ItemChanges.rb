ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc { |item,pkmn,scene|
    unless pkmn.isSpecies?(:SHAYMIN)
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
      next false
    end
    formToSet = pkmn.form == 0 ? 1 : 0
    pkmn.setForm(formToSet) {
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })