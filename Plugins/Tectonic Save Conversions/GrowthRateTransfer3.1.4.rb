SaveData.register_conversion(:growth_rate_fix_314) do
    game_version '3.1.4'
    display_title '3.1.4 growth rate fix'
    to_all do |save_data|
        mediumGrowthRate = GameData::GrowthRate.get(:Medium)

        eachPokemonInSave(save_data) do |pokemon,_location|
            pokemon.exp = mediumGrowthRate.minimum_exp_for_level(pokemon.level)
        end
    end
end