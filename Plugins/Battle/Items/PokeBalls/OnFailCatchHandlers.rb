BallHandlers::OnFailCatch.add(:SLICEBALL, proc { |_ball, _battle, battler|
    battler.applyFractionalDamage(1/4.0)
})