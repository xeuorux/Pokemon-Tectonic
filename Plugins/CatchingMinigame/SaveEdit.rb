SaveData.register(:catching_minigame) do
	ensure_class :CatchingMinigame
	save_value { $catching_minigame }
	load_value { |value| $catching_minigame = value }
	new_game_value { CatchingMinigame.new }
end

SaveData.register_conversion(:catching_minigame_data_add) do
  game_version '1.5.2'
  display_title 'Adding Catching Minigame to pre 1.5.2 saves.'
  to_all do |save_data|
    save_data[:catching_minigame] = CatchingMinigame.new if !save_data.has_key?(:catching_minigame)
  end
end