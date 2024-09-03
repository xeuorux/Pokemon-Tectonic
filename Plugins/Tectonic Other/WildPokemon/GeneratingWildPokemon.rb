#===============================================================================
#
#===============================================================================
# Creates and returns a Pokémon based on the given species and level.
# Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
# Pokérus, gender/nature forcing because of player's lead Pokémon).
def pbGenerateWildPokemon(species,level,ignoreCap = false,skipAlterations = false)
  # Reduce the given level below the current level cap
  unless ignoreCap
    levelCap = getLevelCap
    until level <= levelCap
      level -= 5
    end
  end
  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  item = generateWildHeldItem(genwildpoke,herdingActive?)
  genwildpoke.giveItem(item) if item
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke) unless skipAlterations
  return genwildpoke
end

WILD_ITEM_CHANCE_COMMON = 35
WILD_ITEM_CHANCE_UNCOMMON = 10
WILD_ITEM_CHANCE_RARE = 2

def generateWildHeldItem(pokemon,increasedChance=false)
  if pokemon.is_a?(Symbol)
    itemsWithRarities = GameData::Species.get(pokemon).wildHeldItemsWithRarities
  else
    itemsWithRarities = pokemon.wildHeldItemsWithRarities
  end
  
  return nil if itemsWithRarities.empty?

  itemRoll = rand(100)
  itemRoll -= 20 if increasedChance
  itemRoll = 0 if itemRoll < 0

  totalRarity = 0
  itemsWithRarities.each do |item, rarity|
    totalRarity += rarity
    next unless itemRoll < totalRarity
    return item
  end

  return nil
end

def runItemGenerationTest(pokemon,increasedChance=false,testCount = 10000)
  echoln("Generating a test for wild held items generated for #{pokemon}")

  itemCounts = {}
  testCount.times do
    itemGenerated = generateWildHeldItem(pokemon,increasedChance)
    next unless itemGenerated
    if itemCounts.key?(itemGenerated)
      itemCounts[itemGenerated] += 1
    else
      itemCounts[itemGenerated] = 0
    end
  end

  itemCounts.each do |item, count|
    echoln("Item #{item} was generated #{count} times, which is #{(100 * count / testCount.to_f).round(1)} percent of the time")
  end
end

def RIGT(pokemon,increasedChance=false,testCount = 1000)
  runItemGenerationTest(pokemon,increasedChance,testCount)
end

def herdingActive?
  $Trainer.party.each do |partyMember|
    next unless partyMember
    return true if partyMember.hasAbility?(:HERDING)
  end
  return false
end

def testShinyChances
  shinyTimes = 0
  totalTimes = 200_000
  totalTimes.times do
    shinyTimes += 1 if pbGenerateWildPokemon(:MSINISTEA,8,false,true).shiny?
  end
  percentage = (100 * shinyTimes / totalTimes.to_f).to_s
  pbMessage(_INTL("Trial complete."))
  echoln("Out of #{totalTimes.to_s} trials, a level 8 sinistea was shiny #{shinyTimes} times or #{percentage} percent of the time")
end

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end
}

# Used by fishing rods and Headbutt/Rock Smash/Sweet Scent to generate a wild
# Pokémon (or two) for a triggered wild encounter.
def pbEncounter(enc_type)
    $PokemonTemp.encounterType = enc_type
    encounter1 = $PokemonEncounters.choose_wild_pokemon(enc_type)
    encounter1 = EncounterModifier.trigger(encounter1)
    return false if !encounter1
    if $PokemonEncounters.have_double_wild_battle?
        encounter2 = $PokemonEncounters.choose_wild_pokemon(enc_type)
        encounter2 = EncounterModifier.trigger(encounter2)
        return false if !encounter2
        pbDoubleWildBattle(encounter1[0], encounter1[1], encounter2[0], encounter2[1])
    else
        pbWildBattle(encounter1[0], encounter1[1])
    end
        $PokemonTemp.encounterType = nil
    $PokemonTemp.forceSingleBattle = false
    EncounterModifier.triggerEncounterEnd
    return true
end