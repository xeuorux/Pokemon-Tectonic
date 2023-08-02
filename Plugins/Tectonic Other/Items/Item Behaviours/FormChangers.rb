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

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:TORNADUS) &&
       !pkmn.isSpecies?(:THUNDURUS) &&
       !pkmn.isSpecies?(:LANDORUS)
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
      next false
    end
    newForm = (pkmn.form==0) ? 1 : 0
    pkmn.setForm(newForm) {
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:HOOPA)
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    end
    newForm = (pkmn.form==0) ? 1 : 0
    pkmn.setForm(newForm) {
      scene.pbRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:KYUREM)
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        scene.pbDisplay(_INTL("It cannot be fused with itself."))
        next false
      elsif poke2.egg?
        scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
        next false
      elsif poke2.fainted?
        scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
        next false
      elsif !poke2.isSpecies?(:RESHIRAM) &&
            !poke2.isSpecies?(:ZEKROM)
        scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
        next false
      end
      newForm = 0
      newForm = 1 if poke2.isSpecies?(:RESHIRAM)
      newForm = 2 if poke2.isSpecies?(:ZEKROM)
      pkmn.setForm(newForm) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:NSOLARIZER,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 2
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        scene.pbDisplay(_INTL("It cannot be fused with itself."))
        next false
      elsif poke2.egg?
        scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
        next false
      elsif poke2.fainted?
        scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
        next false
      elsif !poke2.isSpecies?(:SOLGALEO)
        scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
        next false
      end
      pkmn.setForm(1) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:NLUNARIZER,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 1
      scene.pbDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        scene.pbDisplay(_INTL("It cannot be fused with itself."))
        next false
      elsif poke2.egg?
        scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
        next false
      elsif poke2.fainted?
        scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
        next false
      elsif !poke2.isSpecies?(:LUNALA)
        scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
        next false
      end
      pkmn.setForm(2) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  })