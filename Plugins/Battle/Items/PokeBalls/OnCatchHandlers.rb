BallHandlers::OnCatch.add(:HEALBALL, proc { |_ball, _battle, pkmn|
    pkmn.heal
})

BallHandlers::OnCatch.add(:FRIENDBALL, proc { |_ball, _battle, pkmn|
    pkmn.happiness = 200
})
