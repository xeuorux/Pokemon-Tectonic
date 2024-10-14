ItemHandlers::UseOnPokemon.add(:GRACIDEA,proc { |item,pkmn,scene|
  unless pkmn.isSpecies?(:SHAYMIN)
    pbSceneDefaultDisplay(_INTL("It had no effect."),scene)
    next false
  end
  if pkmn.fainted?
    pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
    next false
  end
  formToSet = pkmn.form == 0 ? 1 : 0
  pkmn.setForm(formToSet) {
    scene&.pbRefresh
    pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
  }
  next true
})

ItemHandlers::UseOnPokemon.add(:REVEALGLASS,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:TORNADUS) &&
       !pkmn.isSpecies?(:THUNDURUS) &&
       !pkmn.isSpecies?(:LANDORUS)
      pbSceneDefaultDisplay(_INTL("It had no effect."),scene)
      next false
    end
    if pkmn.fainted?
      pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
      next false
    end
    newForm = (pkmn.form==0) ? 1 : 0
    pkmn.setForm(newForm) {
      scene&.pbRefresh
      pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:PRISONBOTTLE,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:HOOPA)
      pbSceneDefaultDisplay(_INTL("It had no effect."),scene)
      next false
    end
    if pkmn.fainted?
      pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
    end
    newForm = (pkmn.form==0) ? 1 : 0
    pkmn.setForm(newForm) {
      scene&.pbRefresh
      pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:DNASPLICERS,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:KYUREM)
      pbSceneDefaultDisplay(_INTL("It had no effect."),scene)
      next false
    end
    if pkmn.fainted?
      pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        pbSceneDefaultDisplay(_INTL("It cannot be fused with itself."),scene)
        next false
      elsif poke2.egg?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with an Egg."),scene)
        next false
      elsif poke2.fainted?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that fainted Pokémon."),scene)
        next false
      elsif !poke2.isSpecies?(:RESHIRAM) &&
            !poke2.isSpecies?(:ZEKROM)
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that Pokémon."),scene)
        next false
      end
      newForm = 0
      newForm = 1 if poke2.isSpecies?(:RESHIRAM)
      newForm = 2 if poke2.isSpecies?(:ZEKROM)
      pkmn.setForm(newForm) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene&.pbHardRefresh
        pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      pbSceneDefaultDisplay(_INTL("You have no room to separate the Pokémon."),scene)
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene&.pbHardRefresh
      pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:NSOLARIZER,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 2
      pbSceneDefaultDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        pbSceneDefaultDisplay(_INTL("It cannot be fused with itself."),scene)
        next false
      elsif poke2.egg?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with an Egg."),scene)
        next false
      elsif poke2.fainted?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that fainted Pokémon."),scene)
        next false
      elsif !poke2.isSpecies?(:SOLGALEO)
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that Pokémon."),scene)
        next false
      end
      pkmn.setForm(1) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene&.pbHardRefresh
        pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      pbSceneDefaultDisplay(_INTL("You have no room to separate the Pokémon."),scene)
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene&.pbHardRefresh
      pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
    }
    next true
  })
  
  ItemHandlers::UseOnPokemon.add(:NLUNARIZER,proc { |item,pkmn,scene|
    if !pkmn.isSpecies?(:NECROZMA) || pkmn.form == 1
      pbSceneDefaultDisplay(_INTL("It had no effect."))
      next false
    end
    if pkmn.fainted?
      pbSceneDefaultDisplay(_INTL("This can't be used on the fainted Pokémon."),scene)
      next false
    end
    # Fusing
    if pkmn.fused.nil?
      chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
      next false if chosen<0
      poke2 = $Trainer.party[chosen]
      if pkmn==poke2
        pbSceneDefaultDisplay(_INTL("It cannot be fused with itself."),scene)
        next false
      elsif poke2.egg?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with an Egg."),scene)
        next false
      elsif poke2.fainted?
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that fainted Pokémon."),scene)
        next false
      elsif !poke2.isSpecies?(:LUNALA)
        pbSceneDefaultDisplay(_INTL("It cannot be fused with that Pokémon."),scene)
        next false
      end
      pkmn.setForm(2) {
        pkmn.fused = poke2
        $Trainer.remove_pokemon_at_index(chosen)
        scene&.pbHardRefresh
        pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
      }
      next true
    end
    # Unfusing
    if $Trainer.party_full?
      pbSceneDefaultDisplay(_INTL("You have no room to separate the Pokémon."),scene)
      next false
    end
    pkmn.setForm(0) {
      $Trainer.party[$Trainer.party.length] = pkmn.fused
      pkmn.fused = nil
      scene&.pbHardRefresh
      pbSceneDefaultDisplay(_INTL("{1} changed Forme!",pkmn.name),scene)
    }
    next true
  })

ItemHandlers::UseOnPokemon.add(:REINSOFUNITY, proc { |item, pkmn, scene|
    unless pkmn.isSpecies?(:CALYREX)
        scene.pbDisplay(_INTL("It has no effect on Pokémon other than Calyrex."))
        next false
    end

    if pkmn.fainted?
        scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
        next false
    end
  
    # Fusing
    if pkmn.fused.nil?
        chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
        next false if chosen < 0
        other_pkmn = $Trainer.party[chosen]
        if pkmn == other_pkmn
            scene.pbDisplay(_INTL("It cannot be fused with itself."))
            next false
        elsif other_pkmn.egg?
            scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
            next false
        elsif other_pkmn.fainted?
            scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
            next false
        elsif !other_pkmn.isSpecies?(:GLASTRIER) &&
                !other_pkmn.isSpecies?(:SPECTRIER)
            scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
            next false
        end
        newForm = 0
        newForm = 1 if other_pkmn.isSpecies?(:GLASTRIER)
        newForm = 2 if other_pkmn.isSpecies?(:SPECTRIER)
        pkmn.setForm(newForm) {
            pkmn.fused = other_pkmn
            $Trainer.remove_pokemon_at_index(chosen)
            scene.pbHardRefresh
            scene.pbDisplay(_INTL("{1} changed Forme!", pkmn.name))
        }
        next true
    end

    # unfusing

    if $Trainer.party_full?
        scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
        next false
    end

    # Unfusing
    pkmn.setForm(0) {
        $Trainer.party[$Trainer.party.length] = pkmn.fused
        pkmn.fused = nil
        scene.pbHardRefresh
        scene.pbDisplay(_INTL("{1} changed Forme!", pkmn.name))
    }
    next true
})