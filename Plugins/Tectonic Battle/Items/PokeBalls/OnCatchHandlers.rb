BallHandlers::OnCatch.add(:HEALBALL, proc { |_ball, _battle, pkmn|
    pkmn.heal
})

BallHandlers::OnCatch.add(:FRIENDBALL, proc { |_ball, _battle, pkmn|
    pkmn.happiness = 200
})

BallHandlers::OnCatch.add(:RADIANTBALL, proc { |_ball, _battle, pkmn|
    pkmn.shiny = true
})