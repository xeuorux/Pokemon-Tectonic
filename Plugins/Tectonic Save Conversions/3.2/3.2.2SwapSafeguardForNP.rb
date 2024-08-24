SaveData.register_conversion(:misc_fixes_v2) do
    game_version '3.2.2'
    display_title 'Swapping TM Safeguard for TM Natural Protection'
    to_all do |save_data|
        save_data[:bag].pbChangeItem(:TMSAFEGUARD,:TMNATURALPROTECTION)
    end
end