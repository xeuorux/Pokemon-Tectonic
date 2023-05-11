BattleHandlers::WeatherExtenderItem.add(:DAMPROCK,
    proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Rain
    }
)

BattleHandlers::WeatherExtenderItem.add(:HEATROCK,
  proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Sun
  }
)

BattleHandlers::WeatherExtenderItem.add(:ICYROCK,
  proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Hail
  }
)

BattleHandlers::WeatherExtenderItem.add(:SMOOTHROCK,
  proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Sandstorm
  }
)

BattleHandlers::WeatherExtenderItem.add(:PINPOINTROCK,
  proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Eclipse
  }
)

BattleHandlers::WeatherExtenderItem.add(:MIRROREDROCK,
  proc { |item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Moonglow
  }
)