SaveData.register_conversion(:events_resetter_conversion) do
  game_version '1.5.3'
  display_title 'Adding events reset tracker to pre 1.5.3 saves.'
  to_all do |save_data|
    save_data[:events_reset] = ResetTracker.new if !save_data.has_key?(:events_reset)
  end
end