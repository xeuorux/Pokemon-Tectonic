def pbCloudRandomEncounter(chance = 20)
    return unless get_self().moving? || $game_player.moving?
    return unless rand(100) < chance
    if $PokemonEncounters.encounter_triggered?(:Cloud, $PokemonGlobal.repel > 0, true)
      pbEncounter(:Cloud)
    end
end