GameData::BattleEffect.register_effect(:Field,{
	:id => :AmuletCoin,
	:real_name => "AmuletCoin",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FairyLock,
	:real_name => "FairyLock",
	:type => :Integer,
	:ticks_down => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FusionBolt,
	:real_name => "FusionBolt",
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FusionFlare,
	:real_name => "FusionFlare",
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :Gravity,
	:real_name => "Gravity",
	:type => :Integer,
    :ticks_down => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("Gravity returned to normal!"))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :HappyHour,
	:real_name => "HappyHour",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :IonDeluge,
	:real_name => "IonDeluge",
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :MudSportField,
	:real_name => "MudSportField",
	:type => :Integer,
    :ticks_down => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The effects of Mud Sport have faded."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :PayDay,
	:real_name => "PayDay",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :WaterSportField,
	:real_name => "WaterSportField",
	:type => :Integer,
    :ticks_down => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The effects of Water Sport have faded."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :Fortune,
	:real_name => "Fortune",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :NeutralizingGas,
	:real_name => "NeutralizingGas",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :MagicRoom,
	:real_name => "MagicRoom",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{MAGIC_ROOM_DESCRIPTION} went away."))
		battle.pbPriority(true).each { |b| b.pbItemTerrainStatBoostCheck }
		battle.pbPriority(true).each { |b| b.pbItemFieldEffectCheck }
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :TrickRoom,
	:real_name => "TrickRoom",
    :type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{TRICK_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :WonderRoom,
	:real_name => "WonderRoom",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{WONDER_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :PuzzleRoom,
	:real_name => "PuzzleRoom",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{PUZZLE_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :OddRoom,
	:real_name => "OddRoom",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{ODD_ROOM_DESCRIPTION} went away."))
    },
})