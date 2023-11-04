# SaveData.register_conversion(:rogue_mode_conversion) do
#   game_version '4.0.0'
#   display_title 'Adding RogueMode to pre 4.0.0 saves.'
#   to_all do |save_data|
#     save_data[:tectonic_rogue_mode] = TectonicRogueGameMode.new if !save_data.has_key?(:tectonic_rogue_mode)
#   end
# end