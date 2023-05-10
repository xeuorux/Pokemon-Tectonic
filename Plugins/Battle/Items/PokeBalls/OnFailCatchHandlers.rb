BallHandlers::OnFailCatch.add(:SLICEBALL, proc { |_ball, _battle, battler|
    battler.applyFractionalDamage(1/4.0)
})

BallHandlers::OnFailCatch.add(:LEECHBALL, proc { |_ball, _battle, battler|
    battler.applyLeeched if battler.canLeech?(nil, true)
})

BallHandlers::OnFailCatch.add(:POTIONBALL, proc { |_ball, _battle, battler|
    battler.applyFractionalHealing(1/4.0)
})

BallHandlers::OnFailCatch.add(:DISABLEBALL, proc { |_ball, _battle, battler|
    battler.applyEffect(:Disable,10) if battler.canBeDisabled?(true)
})