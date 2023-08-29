ItemHandlers::UseOnPokemon.addIf(proc { |item| GameData::Item.get(item).is_evolution_stone? },
  proc { |item,pkmn,scene|
    newspecies = pkmn.check_evolution_on_use_item(item)
    if newspecies
      pbFadeOutInWithMusic {
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
        if scene.is_a?(PokemonPartyScreen)
          scene&.pbRefreshAnnotations(proc { |p| !p.check_evolution_on_use_item(item).nil? })
          scene&.pbRefresh
        end
      }
      next true
    end
    pbSceneDefaultDisplay(_INTL("It won't have any effect."),scene)
    next false
  }
)
