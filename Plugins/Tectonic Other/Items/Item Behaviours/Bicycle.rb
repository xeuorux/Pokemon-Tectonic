#===============================================================================
# UseText handlers
#===============================================================================
ItemHandlers::UseText.add(:BICYCLE,proc { |item|
    next ($PokemonGlobal.bicycle) ? _INTL("Walk") : _INTL("Use")
  })
  
  ItemHandlers::UseText.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

  ItemHandlers::UseFromBag.add(:BICYCLE,proc { |item|
    next (pbBikeCheck) ? 2 : 0
  })
  
  ItemHandlers::UseFromBag.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)

  ItemHandlers::UseInField.add(:BICYCLE,proc { |item|
    if pbBikeCheck
      if $PokemonGlobal.bicycle
        pbDismountBike
      else
        pbMountBike
      end
      next 1
    end
    next 0
  })
  
  ItemHandlers::UseInField.copy(:BICYCLE,:MACHBIKE,:ACROBIKE)