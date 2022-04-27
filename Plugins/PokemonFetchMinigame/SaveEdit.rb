# SaveData.register(:fetching_minigame) do
# 	ensure_class :PokemonFetchingMinigame
# 	save_value { $fetching_minigame }
# 	load_value { |value| $fetching_minigame = value }
# 	new_game_value { PokemonFetchingMinigame.new }
# end

# SaveData.register_conversion(:fetching_minigame) do
#   game_version '1.6.2'
#   display_title 'Adding Catching Minigame to pre 1.6.2 saves.'
#   to_all do |save_data|
#     save_data[:fetching_minigame] = PokemonFetchingMinigame.new if !save_data.has_key?(:fetching_minigame)
#   end
# end