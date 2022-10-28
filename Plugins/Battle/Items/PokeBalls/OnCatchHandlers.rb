BallHandlers::OnCatch.add(:HEALBALL,proc { |ball,battle,pkmn|
    pkmn.heal
})
  
BallHandlers::OnCatch.add(:FRIENDBALL,proc { |ball,battle,pkmn|
    pkmn.happiness = 200
})