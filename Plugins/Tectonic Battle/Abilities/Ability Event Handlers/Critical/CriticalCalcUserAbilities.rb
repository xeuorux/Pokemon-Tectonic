BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability, _user, _target, _move, c|
      next c + 2
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability, user, _target, _move, c|
      next c + user.steps[:SPEED]
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:RAZORSEDGE,
  proc { |ability, _user, _target, move, c|
      next c + 1 if move.bladeMove?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:NIGHTVISION,
  proc { |ability, user, _target, _move, c|
      next c + 1 if user.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SANDDRILLING,
  proc { |ability, user, _target, _move, c|
      next c + 1 if user.battle.pbWeather == :Sandstorm
  }
)