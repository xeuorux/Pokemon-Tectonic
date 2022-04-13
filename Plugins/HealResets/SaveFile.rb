SaveData.register(:events_reset) do
	ensure_class :ResetTracker
	save_value { $reset_tracker }
	load_value { |value| $reset_tracker = value }
	new_game_value { ResetTracker.new }
end

SaveData.register_conversion(:events_resetter_conversion) do
  game_version '1.5.3'
  display_title 'Adding events reset tracker to pre 1.5.3 saves.'
  to_all do |save_data|
    save_data[:events_reset] = ResetTracker.new if !save_data.has_key?(:events_reset)
  end
end