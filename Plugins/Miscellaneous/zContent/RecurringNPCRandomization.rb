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

class NPCRandomization
    attr_reader :chosenNPC1
    attr_reader :chosenNPC2
    attr_reader :npc1Traitor
    attr_reader :npc2Traitor

    def initialize
        @chosenNPC1 = Random.rand(6) # Random number between 0 and 5 inclusive
        loop do
            @chosenNPC2 = Random.rand(6)
            break if @chosenNPC2 != @chosenNPC1
        end
        echoln("The chosen random NPC ids are: #{@chosenNPC1} and #{chosenNPC2}")
        @npc1Traitor = false
        @npc2Traitor = false
    end

    def wasNPCIdSelected?(npcID)
        return @chosenNPC1 == npcID || @chosenNPC2 == npcID
    end

    def traitorizeNPC(npcID)
        if @chosenNPC1 == npcID
            @npc1Traitor = true
        elsif @chosenNPC2 == npcID
            @npc2Traitor = true
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

# The ordering of the team versions in trainers.txt should be
# NPC team 0, NPC team 0 cursed, NPC team 1, NPC team 1 cursed, etc.
# [MASKEDVILLAIN,Crimson]
# [MASKEDVILLAIN2,Teal]
def randomNPCTrainerBattle(isRandom1)
    trainerVersion = isRandom1 ? $npc_randomization.chosenNPC1 : $npc_randomization.chosenNPC2
    trainerVersion *= 2
    if $PokemonGlobal.tarot_amulet_active
        trainerVersion += 1
    end

    trainerType = isRandom1 ? "MASKEDVILLAIN" : "MASKEDVILLAIN2"
    trainerName = isRandom1 ? "Crimson" : "Teal"

    return pbTrainerBattle(trainerType,"Masked Villain",nil, false, trainerVersion)
end

def fightVillainCrimson()
    randomNPCTrainerBattle(true)
end

def fightVillainTeal()
    randomNPCTrainerBattle(false)
end