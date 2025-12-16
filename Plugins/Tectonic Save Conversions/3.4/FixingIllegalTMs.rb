SaveData.register_conversion(:tm_fixing_340) do
  game_version '3.4.0'
  display_title 'Fixing illegal TMs'
  to_all do |save_data|
    save_data[:bag].pbChangeItem(:TMDISSIPATION,:TMSHIVERDANCE)
    save_data[:bag].pbChangeItem(:TMCLOUDBREAK,:TMQUIVERDANCE)
    save_data[:bag].pbChangeItem(:TMAURASPHERE,:TMADRENALASH)
    save_data[:bag].pbChangeItem(:TMSCREECH,:TMBARETEETH)
    save_data[:bag].pbChangeItem(:TMCOSMICPOWER,:TMRAPIDSPIN)
  end
end
