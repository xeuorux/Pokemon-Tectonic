#===============================================================================
#
#===============================================================================
# Creates and returns a Pokémon based on the given species and level.
# Applies wild Pokémon modifiers (wild held item, shiny chance modifiers,
# Pokérus, gender/nature forcing because of player's lead Pokémon).
def pbGenerateWildPokemon(species,level,isRoamer=false)
  genwildpoke = Pokemon.new(species,level)
  # Give the wild Pokémon a held item
  items = genwildpoke.wildHoldItems
  first_pkmn = $Trainer.first_pokemon
  chances = [50,5,1]
  itemrnd = rand(100)
  itemrnd = [itemrnd-20,0].max if first_pkmn.hasAbility?(:FRISK)
  if (items[0]==items[1] && items[1]==items[2]) || itemrnd<chances[0]
    genwildpoke.item = items[0]
  elsif itemrnd<(chances[0]+chances[1])
    genwildpoke.item = items[1]
  elsif itemrnd<(chances[0]+chances[1]+chances[2])
    genwildpoke.item = items[2]
  end
  # Shiny Charm makes shiny Pokémon more likely to generate
  if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
	genwildpoke.shinyRerolls = 3
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
  return genwildpoke
end

class Pokemon
	attr_accessor :shinyRerolls
end