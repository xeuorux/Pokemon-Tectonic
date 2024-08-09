SaveData.register_conversion(:set_flag_176_313) do
  game_version '3.1.3'
  display_title 'Setting flag 176 properly.'
  to_all do |save_data|
      globalSwitches = save_data[:switches]
      selfSwitches = save_data[:self_switches]

      globalSwitches[176] = selfSwitches[[258, 17, 'B']] # 176 is set if Yezera has been defeated in Whitebloom Town
  end
end