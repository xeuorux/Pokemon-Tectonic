
SaveData.register_conversion(:global_switch_refactor_3_0_0) do
  game_version '3.0.0'
  display_title 'Setting global switches based on self-switches.'
  to_all do |save_data|
    globalSwitches = save_data[:switches]
    globalVariables = save_data[:variables]
    selfSwitches = save_data[:self_switches]
    itemBag = save_data[:bag]

    globalSwitches[ZAIN_2_BADGES_PHONECALL_GLOBAL] = selfSwitches[[56,29,'B']]
    globalSwitches[ZAIN_3_BADGES_PHONECALL_GLOBAL] = selfSwitches[[301,49,'B']]
    globalSwitches[151] = selfSwitches[[165,33,'D']] # unlock spirit atoll
    globalSwitches[69] = selfSwitches[[258,17,'B']] # defeated whitebloom yezera
  end
end
