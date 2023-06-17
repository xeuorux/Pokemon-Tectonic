def pbRockSmashDynamite
  hasDynamite = PokemonBag.pbHasItem?(:DYNAMITESTICK)
  if !hasDynamite
    pbMessage(_INTL("It's a rugged rock, but some explosives might be able to destroy it."))
    return false
  end
  if pbConfirmMessageSerious(_INTL("An explodeable rock. Use a Dynamite Stick? You have #{pbQuantity(:DYNAMITESTICK)}."))
    pbMessage(_INTL("{1} used the explosives!",$Trainer.name))
    $PokemonBag.pbDeleteItem(:DYNAMITESTICK,1)
    return true
  end
end

def explodeRock
	pbSEPlay("Explosion7",120,150)
	pbMoveRoute(get_self,[
		PBMoveRoute::Wait,2,
		PBMoveRoute::TurnLeft,
		PBMoveRoute::Wait,2,
		PBMoveRoute::TurnRight,
		PBMoveRoute::Wait,2,
		PBMoveRoute::TurnUp,
		PBMoveRoute::Wait,2
	])
	pbWait(Graphics.frame_rate*4/10)
	setMySwitch('A',true)
end