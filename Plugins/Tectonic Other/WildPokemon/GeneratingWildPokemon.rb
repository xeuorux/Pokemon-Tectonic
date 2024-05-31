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
  # Shiny Charm makes shiny Pokémon more likely to generate
  genwildpoke.shinyRerolls = 1
  $PokemonBag.pbQuantity(:SHINYCHARM).times do
    genwildpoke.shinyRerolls *= 2
  end
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke) unless skipAlterations
  # Give it however many chances to be shiny
  (genwildpoke.shinyRerolls - 1).times do
    break if genwildpoke.shiny?
    genwildpoke.regeneratePersonalID
    genwildpoke.shiny = nil
  end
  #genwildpoke.shiny_variant = true if genwildpoke.shiny? && rand(4) < 1
  return genwildpoke
end

WILD_ITEM_CHANCE_COMMON = 50
WILD_ITEM_CHANCE_UNCOMMON = 5
WILD_ITEM_CHANCE_RARE = 1

def generateWildHeldItem(pokemon,increasedChance=false)
  item = nil
  items = pokemon.wildHoldItems
  chances = [50,5,1]
  itemrnd = rand(100)
  itemrnd = [itemrnd-20,0].max if increasedChance
  if (items[0]==items[1] && items[1]==items[2]) || itemrnd<chances[0]
    item = items[0]
  elsif itemrnd<(chances[0]+chances[1])
    item = items[1]
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    item = items[2]
  end
  return item
end

class Pokemon
	attr_accessor :shinyRerolls
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