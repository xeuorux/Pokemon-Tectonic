GameData::BattleEffect.register_effect(:Field,{
	:id => :AmuletCoin,
	:real_name => "Amulet Coin",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FairyLock,
	:real_name => "Fairy Lock",
	:type => :Integer,
	:ticks_down => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FusionBolt,
	:real_name => "Fusion Bolt",
	:resets_eor => true,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :FusionFlare,
	:real_name => "Fusion Flare",
	:resets_eor => true,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :Gravity,
	:real_name => "Gravity Turns",
	:type => :Integer,
    :ticks_down => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("Gravity returned to normal!"))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :HappyHour,
	:real_name => "Happy Hour",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :IonDeluge,
	:real_name => "Ion Deluge",
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :MudSportField,
	:real_name => "Mud Sport Turns",
	:type => :Integer,
    :ticks_down => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The effects of Mud Sport have faded."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :PayDay,
	:real_name => "Money Dropped",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :WaterSportField,
	:real_name => "Water Sport Turns",
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
	:real_name => "Neutralizing Gas",
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :MagicRoom,
	:real_name => "Magic Room Turns",
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
	:real_name => "Trick Room Turns",
    :type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{TRICK_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :WonderRoom,
	:real_name => "Wonder Room Turns",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{WONDER_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :PuzzleRoom,
	:real_name => "Puzzle Room Turns",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{PUZZLE_ROOM_DESCRIPTION} went away."))
    },
})

GameData::BattleEffect.register_effect(:Field,{
	:id => :OddRoom,
	:real_name => "Odd Room Turns",
	:type => :Integer,
    :ticks_down => true,
	:is_room => true,
    :expire_proc => Proc.new { |battle,battler|
        battle.pbDisplay(_INTL("The #{ODD_ROOM_DESCRIPTION} went away."))
    },
})