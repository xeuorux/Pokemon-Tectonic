#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  return ($Trainer.party_full? && $PokemonStorage.full?)
end

def pbNickname(pkmn)
  species_name = pkmn.speciesName
  if pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?", species_name))
    pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                   0, Pokemon::MAX_NAME_SIZE, "", pkmn)
  end
end

def pbStorePokemon(pkmn)
  if pbBoxesFull?
      pbMessage(_INTL("There's no more room for Pokémon!\1"))
      pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
      return
  end
  pkmn.record_first_moves
  if $Trainer.party_full?
      storingPokemon = pkmn
      if pbConfirmMessageSerious(_INTL("Would you like to add {1} to your party?", pkmn.name))
          pbMessage(_INTL("Choose which Pokemon will be sent back to the PC."))
          # if Y, select pokemon to store instead
          pbChoosePokemon(1, 3)
          chosen = $game_variables[1]
          # Didn't cancel
          if chosen != -1
              storingPokemon = $Trainer.party[chosen]

              promptToTakeItems(storingPokemon)

              $Trainer.party[chosen] = pkmn

              refreshFollow
          end
      end
      pbStorePokemonInPC(storingPokemon)
  else
      $Trainer.party[$Trainer.party.length] = pkmn
  end
end

def promptToTakeItems(pkmn)
  if pkmn.hasItem?
      if pkmn.hasMultipleItems?
          queryMessage = _INTL("{1} is holding multiple items. Take them before transferring?",
              pkmn.name)
      else
          queryMessage = _INTL("{1} is holding an {2}. Would you like to take it before transferring?",
              pkmn.name, getItemName(pkmn.firstItem))
      end
      
      pbTakeItemsFromPokemon(pkmn) if pbConfirmMessageSerious(queryMessage)
  end
end

def pbStorePokemonInPC(pkmn)
  oldcurbox = $PokemonStorage.currentBox
  storedbox = $PokemonStorage.pbStoreCaught(pkmn)
  curboxname = $PokemonStorage[oldcurbox].name
  boxname = $PokemonStorage[storedbox].name
  if storedbox != oldcurbox
      if $PokemonStorage[oldcurbox].isDonationBox?
        pbMessage(_INTL("Box \"{1}\" on the Pokémon Storage PC is a donation box.\1", curboxname))
      else
        pbMessage(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.\1", curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
  else
      pbMessage(_INTL("{1} was transferred to the Pokémon Storage PC.\1", pkmn.name))
      pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
  end
end

def pbNicknameAndStore(pkmn,nickname = true)
  if pbBoxesFull?
      pbMessage(_INTL("There's no more room for Pokémon!\1"))
      pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
      return
  end
  $Trainer.pokedex.set_seen(pkmn.species)
  $Trainer.pokedex.set_owned(pkmn.species)
  
  discoverPokemon(pkmn)

  # Increase the caught count for the global metadata
  incrementDexNavCounts(false) if defined?(incrementDexNavCounts)

  if $PokemonSystem.nicknaming_prompt == 0 && nickname
      pbNickname(pkmn)
  end

  pbStorePokemon(pkmn)

  evolutionButtonCheck(pkmn)
end

def discoverPokemon(pkmn)
  if pkmn.shiny?
    pbMessage(_INTL("Wow, the {1} is a different color from normal.", pkmn.name))
    pbMessage(_INTL("It's a <imp>shiny</imp> Pokémon!", pkmn.name))
  end

  pbMessage(_INTL("You check {1}, and discover that its ability is <imp>{2}</imp>!", pkmn.name, pkmn.ability.name))

  pkmn.items.each do |item|
      pbMessage(_INTL("The {1} is holding an {2}!", pkmn.name, getItemName(item)))
  end
end

#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemon(pkmn, level = 1)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pkmn = randomizeSpecies(pkmn, false, true)
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  return true
end

def pbAddPokemonSilent(pkmn, level = 1)
  return false if !pkmn || pbBoxesFull?
  pkmn = randomizeSpecies(pkmn, false, true)
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  if $Trainer.party_full?
    $PokemonStorage.pbStoreCaught(pkmn)
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
  return true
end

def pbAddPokemonFromTrade(pkmn)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pbNicknameAndStore(pkmn)
  return true
end

#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pkmn, level = 1, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  return true
end

def pbAddToPartySilent(pkmn, level = nil, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  # Set original trainer to a foreign one
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  # Set nickname
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  # Recalculate stats
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $Trainer.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $Trainer.name))
  end
  pbStorePokemon(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  return true
end

#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variable_ID)
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn.able?
    pbSet(variable_ID, i)
    return pkmn
  end
  pbSet(variable_ID, -1)
  return nil
end

#===============================================================================
# Return a level value based on Pokémon in a party
#===============================================================================
def pbBalancedLevel(party)
  return 1 if party.length == 0
  # Calculate the mean of all levels
  sum = 0
  party.each { |p| sum += p.level }
  return 1 if sum == 0
  mLevel = GameData::GrowthRate.max_level
  average = sum.to_f / party.length.to_f
  # Calculate the standard deviation
  varianceTimesN = 0
  party.each do |pkmn|
    deviation = pkmn.level - average
    varianceTimesN += deviation * deviation
  end
  # NOTE: This is the "population" standard deviation calculation, since no
  # sample is being taken.
  stdev = Math.sqrt(varianceTimesN / party.length)
  mean = 0
  weights = []
  # Skew weights according to standard deviation
  party.each do |pkmn|
    weight = pkmn.level.to_f / sum.to_f
    if weight < 0.5
      weight -= (stdev / mLevel.to_f)
      weight = 0.001 if weight <= 0.001
    else
      weight += (stdev / mLevel.to_f)
      weight = 0.999 if weight >= 0.999
    end
    weights.push(weight)
  end
  weightSum = 0
  weights.each { |w| weightSum += w }
  # Calculate the weighted mean, assigning each weight to each level's
  # contribution to the sum
  party.each_with_index { |pkmn, i| mean += pkmn.level * weights[i] }
  mean /= weightSum
  mean = mean.round
  mean = 1 if mean < 1
  # Add 2 to the mean to challenge the player
  mean += 2
  # Adjust level to maximum
  mean = mLevel if mean > mLevel
  return mean
end