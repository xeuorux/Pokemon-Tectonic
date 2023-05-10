#===============================================================================
#
#===============================================================================
# Creates and returns a Pokémon based on the given species and level.
# Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
# Pokérus, gender/nature forcing because of player's lead Pokémon).
def pbGenerateWildPokemon(species,level,ignoreCap = false,skipAlterations = false)
  level = [getLevelCap(),level].min unless ignoreCap
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