BattleHandlers::WeatherExtenderItem.add(:DAMPROCK,
    proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Rain
    }
)

BattleHandlers::WeatherExtenderItem.add(:HEATROCK,
  proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Sun
  }
)

BattleHandlers::WeatherExtenderItem.add(:ICYROCK,
  proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Hail
  }
)

BattleHandlers::WeatherExtenderItem.add(:SMOOTHROCK,
  proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Sandstorm
  }
)

BattleHandlers::WeatherExtenderItem.add(:PINPOINTROCK,
  proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Eclipse
  }
)

BattleHandlers::WeatherExtenderItem.add(:MIRROREDROCK,
  proc { |_item, weather, duration, _battler, _battle|
      next duration * 2 if weather == :Moonglow
  }
)