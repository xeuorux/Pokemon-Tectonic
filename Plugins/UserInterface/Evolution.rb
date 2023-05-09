class PokemonEvolutionScene
    def self.pbDuplicatePokemon(pkmn, new_species)
      new_pkmn = pkmn.clone
      new_pkmn.species   = new_species
      new_pkmn.name      = nil
      new_pkmn.markings  = 0
      new_pkmn.poke_ball = :POKEBALL
      new_pkmn.removeItems
      new_pkmn.clearAllRibbons
      new_pkmn.calc_stats
      new_pkmn.heal
      # Add duplicate Pokémon to party
      $Trainer.party.push(new_pkmn)
      # See and own duplicate Pokémon
      $Trainer.pokedex.register(new_pkmn)
      $Trainer.pokedex.set_owned(new_species)
    end
end