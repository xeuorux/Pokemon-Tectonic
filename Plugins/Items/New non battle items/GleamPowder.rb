class PokemonGlobalMetadata
  attr_accessor :next_shiny_guaranteed
end

ItemHandlers::UseFromBag.add(:GLEAMPOWDER,proc { |item|
  if pbConfirmMessageSerious(_INTL("Disperse the Gleam Powder?"))
    next 4
  else
    next 0
  end
})

ItemHandlers::UseInField.add(:GLEAMPOWDER,proc { |item|
  $PokemonGlobal.next_shiny_guaranteed = true
  pbMessage(_INTL("You disperse the Gleam Powder."))
  next 3
})

Events.onWildPokemonCreate += proc { |_sender,e|
  pokemon = e[0]
  if defined?($PokemonGlobal.next_shiny_guaranteed) && $PokemonGlobal.next_shiny_guaranteed
    pokemon.shiny = true
    $PokemonGlobal.next_shiny_guaranteed = false
    pbMessage(_INTL("The scent of the Gleam Powder pulls a shiny Pokemon towards you!"))
  end
}