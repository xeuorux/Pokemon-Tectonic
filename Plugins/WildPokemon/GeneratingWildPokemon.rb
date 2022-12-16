#===============================================================================
#
#===============================================================================
# Creates and returns a Pokémon based on the given species and level.
# Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
# Pokérus, gender/nature forcing because of player's lead Pokémon).
def pbGenerateWildPokemon(species,level,ignoreCap = false)
  level = [getLevelCap(),level].min unless ignoreCap
  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  item = generateWildHeldItem(genwildpoke,$Trainer.first_pokemon.hasAbility?(:FRISK))
  genwildpoke.item = item
  # Shiny Charm makes shiny Pokémon more likely to generate
  if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
	  genwildpoke.shinyRerolls = 2
  else
	  genwildpoke.shinyRerolls = 1
  end
  # Trigger events that may alter the generated Pokémon further
  Events.onWildPokemonCreate.trigger(nil,genwildpoke)
  # Give it however many chances to be shiny
  genwildpoke.shinyRerolls.times do
      break if genwildpoke.shiny?
      genwildpoke.personalID = rand(2 ** 16) | rand(2 ** 16) << 16
	    genwildpoke.shiny = nil
  end
  #genwildpoke.shiny_variant = true if genwildpoke.shiny? && rand(4) < 1
  return genwildpoke
end

def generateWildHeldItem(pokemon,friskActive=false)
  item = nil
  items = pokemon.wildHoldItems
  chances = [50,5,1]
  itemrnd = rand(100)
  itemrnd = [itemrnd-20,0].max if friskActive
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