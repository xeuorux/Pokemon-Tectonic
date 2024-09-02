ItemHandlers::UseOnPokemon.add(:POTION, proc { |_item, pkmn, scene|
  next pbHPItem(pkmn, 40, scene, true)
})

ItemHandlers::UseOnPokemon.add(:SUPERPOTION, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, 80, scene, true)
})

ItemHandlers::UseOnPokemon.add(:HYPERPOTION, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, 120, scene, true)
})

ItemHandlers::UseOnPokemon.add(:MAXPOTION, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, pkmn.totalhp - pkmn.hp, scene, true)
})

ItemHandlers::UseOnPokemon.add(:BERRYJUICE, proc { |_item, pkmn, scene|
  next pbHPItem(pkmn, 20, scene)
})

ItemHandlers::UseOnPokemon.add(:FRESHWATER, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, 50, scene)
})

ItemHandlers::UseOnPokemon.add(:SODAPOP, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:LEMONADE, proc { |_item, pkmn, scene|
    next pbHPItem(pkmn, 150, scene)
})

ItemHandlers::UseOnPokemon.add(:FULLHEAL, proc { |_item, pkmn, scene|
    if pkmn.fainted? || pkmn.status == :NONE
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    pkmn.heal_status
    scene&.pbRefresh
    pbSceneDefaultDisplay(_INTL("{1} became healthy.", pkmn.name), scene)
    next true
})

ItemHandlers::UseOnPokemon.copy(:FULLHEAL,
   :LAVACOOKIE, :OLDGATEAU, :CASTELIACONE, :LUMIOSEGALETTE, :SHALOURSABLE,
   :BIGMALASADA, :RAGECANDYBAR, :STATUSHEAL)

ItemHandlers::UseOnPokemon.add(:FULLRESTORE, proc { |_item, pkmn, scene|
    if pkmn.hp == pkmn.totalhp && pkmn.status == :NONE
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    hpgain = pbItemRestoreHP(pkmn, pkmn.totalhp - pkmn.hp)
    pkmn.heal_status
    scene&.pbRefresh
    if hpgain > 0
        pbSceneDefaultDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpgain), scene)
    else
        pbSceneDefaultDisplay(_INTL("{1} became healthy.", pkmn.name), scene)
    end
    next true
})

ItemHandlers::UseOnPokemon.add(:MOOMOOMILK, proc { |_item, pkmn, scene|
  if pkmn.fainted?
    pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
    next false
  end
  if pkmn.hp == pkmn.totalhp && pkmn.status == :NONE
      pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
      next false
  end
  hpgain = pbItemRestoreHP(pkmn, pkmn.totalhp - pkmn.hp)
  pkmn.heal_status
  scene&.pbRefresh
  if hpgain > 0
      pbSceneDefaultDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpgain), scene)
  else
      pbSceneDefaultDisplay(_INTL("{1} became healthy.", pkmn.name), scene)
  end
  next true
})

ItemHandlers::UseOnPokemon.add(:REVIVE, proc { |_item, pkmn, scene|
    unless pkmn.fainted?
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    pkmn.hp = (pkmn.totalhp / 2).floor
    pkmn.hp = 1 if pkmn.hp <= 0
    pkmn.heal_status
    scene&.pbRefresh
    pbSceneDefaultDisplay(_INTL("{1}'s HP was restored.", pkmn.name), scene)
    next true
})

ItemHandlers::UseOnPokemon.add(:MAXREVIVE, proc { |_item, pkmn, scene|
    unless pkmn.fainted?
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    pkmn.heal_HP
    pkmn.heal_status
    scene&.pbRefresh
    pbSceneDefaultDisplay(_INTL("{1}'s HP was restored.", pkmn.name), scene)
    next true
})

ItemHandlers::UseInField.add(:SACREDASH, proc { |_item|
    if $Trainer.pokemon_count == 0
        pbMessage(_INTL("There is no Pokémon."))
        next 0
    end
    canrevive = false
    for i in $Trainer.pokemon_party
        next unless i.fainted?
        canrevive = true
        break
    end
    unless canrevive
        pbMessage(_INTL("It won't have any effect."))
        next 0
    end
    revived = 0
    pbFadeOutIn do
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $Trainer.party)
        screen.pbStartScene(_INTL("Using item..."), false)
        for i in 0...$Trainer.party.length
            next unless $Trainer.party[i].fainted?
            revived += 1
            $Trainer.party[i].heal
            screen.pbRefreshSingle(i)
            screen.pbDisplay(_INTL("{1}'s HP was restored.", $Trainer.party[i].name))
        end
        screen.pbDisplay(_INTL("It won't have any effect.")) if revived == 0
        screen.pbEndScene
    end
    next (revived == 0) ? 0 : 3
})

ItemHandlers::UseOnPokemon.add(:SWEETHEART, proc { |_item, pkmn, scene|
    if pkmn.hp == pkmn.totalhp || pkmn.fainted?
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    hpGain = pbItemRestoreHP(pkmn, 40)
    scene&.pbRefresh
    pbSceneDefaultDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpGain), scene)
    pbSceneDefaultDisplay(_INTL("{1} really enjoyed the chocolate!", pkmn.name), scene)
    pkmn.changeHappiness("sweetheart")
    next true
})

ItemHandlers::UseOnPokemon.add(:VANILLATULUMBA, proc { |item, pkmn, scene|
    level_cap = LEVEL_CAPS_USED ? getLevelCap : growth_rate.max_level
    if pkmn.fainted? || (pkmn.hp == pkmn.totalhp && pkmn.level >= level_cap)
        pbSceneDefaultDisplay(_INTL("It won't have any effect."), scene)
        next false
    end
    
    if pkmn.hp < pkmn.totalhp
        hpGain = pbItemRestoreHP(pkmn, 100)
        scene&.pbRefresh
        pbSceneDefaultDisplay(_INTL("{1}'s HP was restored by {2} points.", pkmn.name, hpGain), scene)
    end

    pbEXPAdditionItem(pkmn, 4000, item, scene, true) unless pkmn.level >= level_cap
    
    next true
})
