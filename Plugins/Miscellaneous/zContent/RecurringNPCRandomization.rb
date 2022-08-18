SaveData.register(:npc_randomization) do
	ensure_class :NPCRandomization
	save_value { $npc_randomization }
	load_value { |value| $npc_randomization = value }
	new_game_value { NPCRandomization.new }
end

class NPCRandomization
    attr_reader :chosenNPC1
    attr_reader :chosenNPC2
    attr_reader :npc1Expelled
    attr_reader :npc2Expelled

    def initialize
        @chosenNPC1 = Random.rand(6) # Random number between 0 and 5 inclusive
        loop do
            @chosenNPC2 = Random.rand(6)
            break if @chosenNPC2 != @chosenNPC1
        end
        echoln("The chosen random NPC ids are: #{@chosenNPC1} and #{chosenNPC2}")
        @npc1Expelled = false
        @npc2Expelled = false
    end

    def wasNPCIdSelected?(npcID)
        return @chosenNPC1 == npcID || @chosenNPC2 == npcID
    end

    def expelNPC(npcID)
        if @chosenNPC1 == npcID
            @npc1Expelled = true
        elsif @chosenNPC2 == npcID
            @npc2Expelled = true
        else
            pbMessage(_INTL("The submitted NPC ID could not be expelled as it was not randomly selected on this playthrough: #{npcID}"))
            pbMessage(_INTL("This is a recoverable error. Please alert a programmer."))
        end
    end
end

# The ordering of the team versions in trainers.txt should be
# NPC team 1, NPC team 1 cursed, NPC team 2, NPC team 2 cursed, etc.
# [MASKEDVILLAIN,Crimson]
# [MASKEDVILLAIN2,Teal]
def randomNPCTrainerBattle(trainerClass,trainerIDs,isRandom1)
    trainerVersion = isRandom1 ? $npc_randomization.chosenNPC1 : $npc_randomization.chosenNPC2
    trainerVersion *= 2
    if $PokemonGlobal.tarot_amulet_active
        trainerVersion += 1
    end

    trainerType = isRandom1 ? "MASKEDVILLAIN" : "MASKEDVILLAIN2"
    trainerName = isRandom1 ? "Crimson" : "Teal"

    return pbTrainerBattle(trainerType,"Masked Villain",nil, false, trainerVersion)
end

def pbTrainerBattleCursed(nonCursedInfoArray, cursedInfoArray)
	if $PokemonGlobal.tarot_amulet_active
		id = cursedInfoArray[2] || 0
		return pbTrainerBattle(cursedInfoArray[0], cursedInfoArray[1], nil, false, id)
	else
		id = nonCursedInfoArray[2] || 0
		return pbTrainerBattle(nonCursedInfoArray[0], nonCursedInfoArray[1], nil, false, id)
	end
end