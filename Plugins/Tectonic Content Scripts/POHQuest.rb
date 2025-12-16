PLAYER_OWNED_HOUSE_QUEST_GLOBAL_VAR = 46

def incrementPOHQuestStage(fade = false)
  if fade
    fadeVarIncrement(PLAYER_OWNED_HOUSE_QUEST_GLOBAL_VAR)
  else
    incrementGlobalVar(PLAYER_OWNED_HOUSE_QUEST_GLOBAL_VAR)
  end
end