SaveData.register(:npc_randomization) do
	ensure_class :NPCRandomization
	save_value { $npc_randomization }
	load_value { |value| $npc_randomization = value }
	new_game_value { NPCRandomization.new }
end

# Recurring NPC IDs
# Imogene - 0
# Alessa - 1
# Skylar - 2
# Keoni - 3
# Eifion - 4
# Candy - 5

RECURRING_NPC_COUNT = 6

NPC1_TRAITOR_SWITCH = 57
NPC2_TRAITOR_SWITCH = 58

class NPCRandomization
    attr_reader :chosenNPC1
    attr_reader :chosenNPC2
    attr_reader :npc1Traitor
    attr_reader :npc2Traitor

    def initialize
        @chosenNPC1 = Random.rand(RECURRING_NPC_COUNT) # Random number between 0 and 5 inclusive
        loop do
            @chosenNPC2 = Random.rand(RECURRING_NPC_COUNT)
            break if @chosenNPC2 != @chosenNPC1
        end
        echoln("The chosen random NPC ids are: #{@chosenNPC1} and #{chosenNPC2}")
        $game_switches[NPC1_TRAITOR_SWITCH] = false
        $game_switches[NPC2_TRAITOR_SWITCH] = false
    end

    def chosenNPC1=(value)
        if !$DEBUG
            debugErrorMessage()
        end
        if value == @chosenNPC2
            pbMessage(_INTL("Cannot set the chosen NPC1 to be the same as the chosen NPC2."))
            return
        end
        @chosenNPC1 = (value)
    end

    def chosenNPC2=(value)
        if !$DEBUG
            debugErrorMessage()
        end
        if value == @chosenNPC1
            pbMessage(_INTL("Cannot set the chosen NPC2 to be the same as the chosen NPC1."))
            return
        end
        @chosenNPC2 = (value)
    end

    def debugErrorMessage()
        raise _INTL("Error: should not be able to change which NPC's have been chosen for randomization outside of debug mode.")
    end

    def wasNPCIdSelected?(npcID)
        return @chosenNPC1 == npcID || @chosenNPC2 == npcID
    end

    #for villain meeting 1
    def wasNPCIdSelected1?(npcID)
        return @chosenNPC1 == npcID
    end

    #for villain meeting 2
    def wasNPCIdSelected2?(npcID)
        return @chosenNPC2 == npcID
    end

    def traitorizeNPC(npcID)
        if @chosenNPC1 == npcID
            $game_switches[NPC1_TRAITOR_SWITCH] = true
            $game_switches[65] = true # Make Crimson dissapear from Sweetrock Harbor
            $game_map.need_refresh = true
        elsif @chosenNPC2 == npcID
            $game_switches[NPC2_TRAITOR_SWITCH] = true
            $game_map.need_refresh = true
        else
            pbMessage(_INTL("The submitted NPC ID could not be made traitor as it was not randomly selected on this playthrough: #{npcID}"))
            pbMessage(_INTL("This is a recoverable error. Please alert a programmer."))
        end
    end
end

def wasNPCIdSelected?(npcID)
    return $npc_randomization.wasNPCIdSelected?(npcID)
end

def traitorizeNPC(npcID)
    $npc_randomization.traitorizeNPC(npcID)
end

#for villain meeting 1
def wasNPCIdSelected1?(npcID)
    return $npc_randomization.wasNPCIdSelected1?(npcID)
end

#for villain meeting 2
def wasNPCIdSelected2?(npcID)
    return $npc_randomization.wasNPCIdSelected2?(npcID)
end

# The ordering of the team versions in trainers.txt should be
# NPC team 0, NPC team 0 cursed, NPC team 1, NPC team 1 cursed, etc.
# [MASKEDVILLAIN,Crimson]
# [MASKEDVILLAIN2,Teal]
def randomNPCTrainerBattle(isRandom1,fightSection=0)
    trainerVersion = isRandom1 ? $npc_randomization.chosenNPC1 : $npc_randomization.chosenNPC2
    doubleBattle = trainerVersion == 0
    trainerVersion *= 2
    if $PokemonGlobal.tarot_amulet_active
        trainerVersion += 1
    end
    trainerVersion += fightSection * RECURRING_NPC_COUNT * 2

    trainerType = isRandom1 ? "MASKEDVILLAIN" : "MASKEDVILLAIN2"
    trainerName = isRandom1 ? "Crimson" : "Teal"

    if doubleBattle
        setBattleRule("double")
        trainerType += "_DOUBLE"
    end

    return pbTrainerBattle(trainerType,trainerName,nil, false, trainerVersion)
end

def fightVillainCrimson(fightSection=0)
    randomNPCTrainerBattle(true,fightSection)
end

def fightVillainTeal(fightSection=0)
    randomNPCTrainerBattle(false,fightSection)
end

DebugMenuCommands.register("setnpcchosen1", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Set NPC1 Chosen"),
  "description" => _INTL("Set which NPC was chosen for NPC Randomization slot 1"),
  "effect"      => proc {
    params = ChooseNumberParams.new
    maxVal = 5
    params.setRange(0, maxVal)
    params.setInitialValue($npc_randomization.chosenNPC1)
    params.setCancelValue(-1)
    chosenNumber = pbMessageChooseNumber(
       _INTL("Choose which NPC ID you would like to have be the selected one.", maxVal), params)
    if chosenNumber >= 0
        $npc_randomization.chosenNPC1 = chosenNumber
    end
  }
})

DebugMenuCommands.register("setnpcchosen2", {
  "parent"      => "fieldmenu",
  "name"        => _INTL("Set NPC2 Chosen"),
  "description" => _INTL("Set which NPC was chosen for NPC Randomization slot 2"),
  "effect"      => proc {
    params = ChooseNumberParams.new
    maxVal = 5
    params.setRange(0, maxVal)
    params.setInitialValue($npc_randomization.chosenNPC2)
    params.setCancelValue(-1)
    chosenNumber = pbMessageChooseNumber(
       _INTL("Choose which NPC ID you would like to have be the selected one.", maxVal), params)
    if chosenNumber >= 0
        $npc_randomization.chosenNPC2 = chosenNumber
    end
  }
})