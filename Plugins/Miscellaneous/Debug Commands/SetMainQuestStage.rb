DebugMenuCommands.register("setmainqueststage", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Stage"),
  "description" => _INTL("Set which Main Quest Stage the player is considered to be on."),
  "effect"      => proc {
    commands = []
    MAIN_QUEST_STAGES.each_with_index do |key_value_pair, index|
      name = MainQuestTracker.getNiceNameForStageSymbol(key_value_pair[0])
      commands.push(_INTL("{1}: {2}", index, name))
    end
    stageCmd = pbShowCommands(nil, commands, -1)
    if stageCmd >= 0
      $main_quest_tracker.setMainQuestStage(stageCmd)
      pbMessage("Changed the player's main quest stage to #{MainQuestTracker.getNiceNameForStageSymbol(MAIN_QUEST_STAGES.keys[stageCmd])}.")
    end
  }
})