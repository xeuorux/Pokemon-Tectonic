ItemHandlers::UseOnPokemon.add(:RARECANDY,proc { |item,pkmn,scene|
  pbLevelGivingItem(pkmn, item, scene)
})


def pbLevelGivingItem(pkmn, item, scene)
  if pkmn.level >= GameData::GrowthRate.max_level
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif LEVEL_CAPS_USED && (pkmn.level + 1) > getLevelCap
      scene.pbDisplay(_INTL("It won't have any effect due to the level cap at #{getLevelCap}."))
      return false
  end

  # Ask the player how many they'd like to apply
  level_cap = LEVEL_CAPS_USED ? getLevelCap : growth_rate.max_level
  maxLevelIncrease = level_cap - pkmn.level
  maximum = [maxLevelIncrease, $PokemonBag.pbQuantity(item)].min # Max items which can be used
  if maximum > 1
      params = ChooseNumberParams.new
      params.setRange(1, maximum)
      params.setInitialValue(1)
      params.setCancelValue(0)
      question = _INTL("How many {1} do you want to use?", GameData::Item.get(item).name_plural)
      qty = pbMessageChooseNumber(question, params)
  else
      qty = 1
  end

  return false if qty < 1

  $PokemonBag.pbDeleteItem(item, qty - 1)
  pbChangeLevel(pkmn,pkmn.level + qty,scene)
  scene.pbHardRefresh

  return true
end

ItemHandlers::UseOnPokemon.copy(:RARECANDY,:VANILLATULUMBA)

ItemHandlers::UseOnPokemon.add(:EXPCANDYXS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,250,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYS,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,1000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYM,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,4000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,12000,item,scene)
})

ItemHandlers::UseOnPokemon.add(:EXPCANDYXL,proc { |item,pkmn,scene|
  pbEXPAdditionItem(pkmn,50000,item,scene)
})