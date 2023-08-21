SaveData.register_conversion(:tribal_bonuses) do
  game_version '1.11.0'
  display_title 'Adding Tribal Bonuses object to pre 1.11.0 saves.'
  to_all do |save_data|
    save_data[:tribal_bonuses] = TribalBonus.new if !save_data.has_key?(:tribal_bonuses)
  end
end