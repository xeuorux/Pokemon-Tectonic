BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
    proc { |ability,mods,user,target,move,type|
        mods[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
    }
)

BattleHandlers::AccuracyCalcUserAbility.add(:AQUASNEAK,
    proc { |ability,mods,user,target,move,type|
        mods[:base_accuracy] = 0 if user.turnCount <= 1
    }
)