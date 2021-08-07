def pbRockSmashDynamite
  hasDynamite = PokemonBag.pbHasItem?(:DYNAMITESTICK)
  if !hasDynamite
    pbMessage(_INTL("It's a rugged rock, but some explosives might be able to destroy it."))
    return false
  end
  if pbConfirmMessageSerious(_INTL("This rock appears to be breakable. Would you like to use a Dynamite Stick?"))
    pbMessage(_INTL("{1} used the explosives!",$Trainer.name))
    $PokemonBag.pbDeleteItem(:DYNAMITESTICK,1)
    return true
  end
end