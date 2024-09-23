OMINOUS_EGG_STAGE_VAR = 42
TRAINERS_PERFECTED_GLOBAL_VAR = 79

GlobalStateHandlers::GlobalVariableChanged.add(TRAINERS_PERFECTED_GLOBAL_VAR,
    proc { |variableID, value|
        if pbHasItem?(:OMINOUSEGG)
            checkForOminousEggRewards
        end
    }
)

def receiveOminousEgg
    pbReceiveItem(:OMINOUSEGG)
    setGlobalVariable(OMINOUS_EGG_STAGE_VAR,0)
    checkForOminousEggRewards
end

def checkForOminousEggRewards
    stage = getGlobalVariable(OMINOUS_EGG_STAGE_VAR)
    value = getGlobalVariable(TRAINERS_PERFECTED_GLOBAL_VAR)
    rewards = []

    if value >= 20 && stage == 0
        rewards.push(:LIFEORB)
        incrementGlobalVar(OMINOUS_EGG_STAGE_VAR)
    end

    if value >= 40 && stage == 1
        rewards.push(:MASTERBALL)
        incrementGlobalVar(OMINOUS_EGG_STAGE_VAR)
    end

    if value >= 60 && stage == 2
        rewards.push(:RELICSTATUE)
        incrementGlobalVar(OMINOUS_EGG_STAGE_VAR)
    end

    if value >= 80 && stage == 3
        rewards.push(:SHINYCHARM)
        incrementGlobalVar(OMINOUS_EGG_STAGE_VAR)
    end

    unless rewards.empty?
        playOminousEggCutscene

        rewards.each do |item|
            pbReceiveItem(item)
        end
    end
end

def playOminousEggCutscene
    pbWait(20)
    pbMessage(_INTL("\\i[OMINOUSEGG]...you hear whispers from the Ominous Egg."))
    pbWait(20)
    case getGlobalVariable(OMINOUS_EGG_STAGE_VAR)
    when 1
        pbMessage(_INTL("\\i[OMINOUSEGG]...sacrifice..."))
    when 2
        pbMessage(_INTL("\\i[OMINOUSEGG]...urge to dominate..."))
    when 3
        pbMessage(_INTL("\\i[OMINOUSEGG]...to stand above others..."))
    when 4
        pbMessage(_INTL("\\i[OMINOUSEGG]...nothing can hide from you..."))
    end
end