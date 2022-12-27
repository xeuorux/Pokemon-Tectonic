GameData::BattleEffect.register_effect(:Battler,{
	:id => :AquaRing,
	:real_name => "Aqua Ring",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		next if !battler.canHeal?
		fraction = 1.0/8.0
		fraction *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("The ring of water restored {1}'s HP!",battler.pbThis(true))
		battler.applyFractionalHealing(fraction,customMessage: healMessage)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Attract,
	:real_name => "Attract",
	:type => :Position,
	:others_lose_track => true,
	:is_mental => true,
	:swaps_with_battlers => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} fell in love!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BeakBlast,
	:real_name => "Beak Blast",
	:resets_battlers_eot => true,
	:resets_battlers_sot => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbCommonAnimation("BeakBlast",battler)
		battle.pbDisplay(_INTL("{1} started heating up its beak!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Bide,
	:real_name => "Bide Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
	:sub_effects => [:BideDamage, :BideTarget],
	:apply_proc => Proc.new { |battle, battler, value|
		battler.disableEffect(:BideDamage)
		battler.disableEffect(:BideTarget)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BideDamage,
	:real_name => "Bide Damage",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BideTarget,
	:real_name => "Bide Target",
	:type => :Position,
	:info_displayed => false,
	:swaps_with_battlers => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BurnUp,
	:real_name => "Burnt Up",
	:info_displayed => false,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} burned itself out!",battler.pbThis))
        battle.scene.pbRefresh()
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DryHeat,
	:real_name => "Dried Out",
	:info_displayed => false,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} was dried out!",battler.pbThis))
        battle.scene.pbRefresh()
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Charge,
	:real_name => "Charged",
	:type => :Integer,
	:ticks_down => true,
	:resets_battlers_eot => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} began charging power!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ChoiceBand,
	:real_name => "Choice Locked",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Confusion,
	:real_name => "Confusion Turns",
	:type => :Integer,
	:baton_passed => true,
	:is_mental => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbCommonAnimation('Confusion', battler)
		battle.pbDisplay(_INTL("{1} became confused! It will hit itself with its own Attack!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
	},
	:sub_effects => [:ConfusionChance],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Counter,
	:real_name => "Counter Damage",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CounterTarget,
	:real_name => "Counter Target",
	:type => :Position,
	:resets_eor => true,
	:info_displayed => false,
	:swaps_with_battlers => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Curse,
	:real_name => "Cursed",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} is cursed!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		if battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is afflicted by the curse!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Dancer,
	:real_name => "Dancer",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DefenseCurl,
	:real_name => "Curled Up",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBond,
	:real_name => "Destiny Bond",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBondPrevious,
	:real_name => "Destiny Bond Previous",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBondTarget,
	:real_name => "Destiny Bond Target",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Disable,
	:real_name => "Disable Turns",
	:type => :Integer,
	:ticks_down => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battler.applyEffect(:DisableMove, battler.lastRegularMoveUsed)
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
	},
	:is_mental => true,
	:sub_effects => [:DisableMove],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DisableMove,
	:real_name => "Disabled Move",
	:type => :Move,
	:apply_proc => Proc.new { |battle, battler, value|
		moveName = GameData::Move.get(value).name
		battle.pbDisplay(_INTL("{1}'s {2} was disabled!",battler.pbThis,moveName))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Electrify,
	:real_name => "Electrify",
	:resets_eor	=> true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1}'s moves have been electrified!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Embargo,
	:real_name => "Embargoed",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} can't use items anymore!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
		battler.pbItemTerrainStatBoostCheck
	    battler.pbItemFieldEffectCheck
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Encore,
	:real_name => "Encore Turns",
	:type => :Integer,
	:is_mental => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battler.applyEffect(:EncoreMove,battler.lastRegularMoveUsed)
		battle.pbDisplay(_INTL("{1} received an encore!",battler.pbThis))
		battle.pbDisplay(_INTL("It will repeat its move for the next #{value-1} turns!"))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		next if battler.fainted?
		idxEncoreMove = battler.pbEncoredMoveIndex
		if idxEncoreMove < 0 || battler.moves[idxEncoreMove].pp == 0
			battler.disableEffect(:EncoreMove)
		else
			battler.tickDownAndProc(:Encore)
		end
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis))
	},
	:sub_effects => [:EncoreMove],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EncoreMove,
	:real_name => "Must Use",
	:type => :Move,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Endure,
	:real_name => "Endure",
	:resets_eor	=> true,
})

# Stores a move code
GameData::BattleEffect.register_effect(:Battler,{
	:id => :FirstPledge,
	:real_name => "First Pledge",
	:type => :Integer,
	:default => 0,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlashFire,
	:real_name => "Fired Up",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",battler.pbThis(true)))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Flinch,
	:real_name => "Flinch",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FocusEnergy,
	:real_name => "Crit Chance Up",
	:type => :Integer,
	:maximum => 6,
	:baton_passed => true,
	:critical_rate_buff => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FocusPunch,
	:real_name => "Focus Punch",
	:resets_eor	=> true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbCommonAnimation("FocusPunch",battler)
      	battle.pbDisplay(_INTL("{1} is tightening its focus!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FollowMe,
	:real_name => "Follow Me",
	:type => :Integer,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became the center of attention!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Foresight,
	:real_name => "Identified",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was identified!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GastroAcid,
	:real_name => "Ability Surpressed",
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next false if battler.unstoppableAbility?
		next value
	},
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",battler.pbThis))
		battler.disableEffect(:Truant)
		battler.pbOnAbilityChanged(battler.ability)
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GemConsumed,
	:real_name => "Gem Consumed",
	:type => :Item,
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Grudge,
	:real_name => "Grudge",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HealBlock,
	:real_name => "Healing Blocked",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:is_mental => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was prevented from healing!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} Heal Block wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HelpingHand,
	:real_name => "Helping Hand",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HyperBeam,
	:real_name => "Recharging",
	:type => :Integer,
	:ticks_down => true,
	:multi_turn_tracker => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battler.currentMove = battler.lastMoveUsed
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Illusion,
	:real_name => "Illusion",
	:type => :Pokemon,
	:initialize_proc => Proc.new { |battle,battler|
		if battler.hasActiveAbility?(:ILLUSION)
			idxLastParty = battle.pbLastInTeam(battler.index)
			if idxLastParty >= 0 && idxLastParty != battler.pokemonIndex
				toDisguiseAs = battle.pbParty(battler.index)[idxLastParty]
				battler.applyEffect(:Illusion,toDisguiseAs)
			end
		end
	},
	:disable_proc => Proc.new { |battle,battler|
		battle.pbDisplay(_INTL("{1}'s illusion wore off!",battler.pbThis))
	},
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Imprison,
	:real_name => "Moves Imprisoned",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1}'s shared moves were sealed!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Ingrain,
	:real_name => "Ingrained",
	:baton_passed => true,
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} firmly planted its roots! It can't be moved!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		next if !battler.canHeal?
		ratio = 1.0 / 8.0
		ratio *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("{1} absorbed nutrients with its roots!",battler.pbThis)
		battler.applyFractionalHealing(ratio, customMessage: healMessage)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Instruct,
	:real_name => "Instruct",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Instructed,
	:real_name => "Instructed",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LaserFocus,
	:real_name => "Laser Focus Turns",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:critical_rate_buff => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 2 if value > 0
		next 0
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LeechSeed,
	:real_name => "Seeded",
	:type => :Position,
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was seeded!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} shed Leech Seed!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		next if !battler.takesIndirectDamage?
		recipient = battle.battlers[value]
		next if !recipient || recipient.fainted?
		battle.pbCommonAnimation("LeechSeed",recipient,battler)
		oldHPRecipient = recipient.hp
		hpLost = battler.applyFractionalDamage(1.0/8.0,false)
		recipient.pbRecoverHPFromDrain(hpLost,battler)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LockOn,
	:real_name => "Locked On",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 2 if value > 0
		next 0
	},
	:sub_effects => [:LockOnPos],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LockOnPos,
	:real_name => "Locked On To",
	:type => :Position,
	:baton_passed => true,
	:disable_effecs_on_other_exit => [:LockOn],
	:swaps_with_battlers => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagicBounce,
	:real_name => "Magic Bounce",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagicCoat,
	:real_name => "Magic Coat",
	:resets_eor	=> true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was shrouded with Magic Coat!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagnetRise,
	:real_name => "Magnet Risen",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MeanLook,
	:real_name => "Cannot Escape",
	:type => :Position,
	:trapping => true,
	:others_lose_track => true,
	:swaps_with_battlers => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} can no longer escape!", battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MeFirst,
	:real_name => "Me First",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Metronome,
	:real_name => "Metronome Count",
	:type => :Integer,
	:maximum => 5,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MicleBerry,
	:real_name => "Micle Berry",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Minimize,
	:real_name => "Minimized",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became very small!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MiracleEye,
	:real_name => "Miracle Eye",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was identified!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorCoat,
	:real_name => "Mirror Coat Damage",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorCoatTarget,
	:real_name => "Mirror Coat Target",
	:type => :Position,
	:resets_eor => true,
	:swaps_with_battlers => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MoveNext,
	:real_name => "Will Move Next",
	:resets_battlers_sot => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battler.disableEffect(:Quash)
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MudSport,
	:real_name => "Electric Resistant",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Nightmare,
	:real_name => "Nightmared",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} began having a nightmare!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		if !battler.asleep?
			battler.effects[:Nightmare] = false
		elsif battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is locked in a nightmare!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Outrage,
	:real_name => "Rampage Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battler.currentMove = battler.lastMoveUsed
	},
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} spun down from its attack.",battler.pbThis))
		battler.currentMove = nil
		echoln("RAMPAGE EXPIRE PROC")
	},
	:remain_proc => Proc.new { |battle, battler,value|
		battle.pbDisplay(_INTL("{1} continues to rampage!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ParentalBond,
	:real_name => "Parental Bond",
	:type => :Integer,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PerishSong,
	:real_name => "Perish Song Turns",
	:type => :Integer,
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} heard the Perish Song! It will faint in {2} turns!",battler.pbThis,value))
	},
	:expire_proc => Proc.new { |battle, battler|
		battler.pbReduceHP(battler.hp)
		battler.pbFaint if battler.fainted?
	},
	:sub_effects => [:PerishSongUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PerishSongUser,
	:real_name => "Perish Singer",
	:type => :Position,
	:baton_passed => true,
	:disable_effecs_on_other_exit => [:PerishSong],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PickupItem,
	:real_name => "Pickup Item",
	:type => :Item,
	:sub_effects => [:PickupUse],
	:info_displayed => false,
})

# I don't really understand this one
GameData::BattleEffect.register_effect(:Battler,{
	:id => :PickupUse,
	:real_name => "Pickup Use",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Pinch,
	:real_name => "Pinch",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Powder,
	:real_name => "Powder",
	:resets_eor	=> true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} is covered in powder!",battler.pbThis))
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PowerTrick,
	:real_name => "Power Tricked",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battler.attack,battler.defense = battler.defense,battler.attack
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Prankster,
	:real_name => "Prankster",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PriorityAbility,
	:real_name => "Priority Ability",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PriorityItem,
	:real_name => "Priority Item",
	:resets_eor	=> true,
	:info_displayed => false,
})


GameData::BattleEffect.register_effect(:Battler,{
	:id => :Pursuit,
	:real_name => "Pursuit",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Quash,
	:real_name => "Quash",
	:type => :Integer,
	:resets_battlers_sot => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battler.disableEffect(:MoveNext)
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Rage,
	:real_name => "Rage",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RagePowder,
	:real_name => "Rage Powder",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Roost,
	:real_name => "Roosting",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ShellTrap,
	:real_name => "Shell Trap",
	:resets_battlers_eot => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbCommonAnimation("ShellTrap",battler)
      	battle.pbDisplay(_INTL("{1} set a shell trap!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SkyDrop,
	:real_name => "Sky Drop",
	:type => :Position,
	:others_lose_track => true,
	:swaps_with_battlers => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SlowStart,
	:real_name => "Slow Start Turns",
	:type => :Integer,
	:ticks_down => true,
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} finally got its act together!",battler.pbThis))
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SmackDown,
	:real_name => "Smacked Down",
	:apply_proc => Proc.new { |battle,battler,value|
		if battler.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce. NOTE: Not Sky Drop.
			battler.disableEffect(:TwoTurnAttack)
			battle.pbClearChoice(battler.index) if !battler.movedThisRound?
		end
		battler.disableEffect(:MagnetRise)
		battler.disableEffect(:Telekinesis)
		battle.pbDisplay(_INTL("{1} fell straight down!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Snatch,
	:real_name => "Snatch",
	:type => :Integer,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} waits for a move to steal!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Spotlight,
	:real_name => "Spotlight",
	:type => :Integer,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became the center of attention!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Stockpile,
	:real_name => "Stockpile Charges",
	:type => :Integer,
	:maximum => 3,
	:increment_proc => Proc.new { | battle, battler, value, increment|
		battle.pbDisplay(_INTL("{1} stockpiled {2}!",battler.pbThis,value))
		battler.incrementEffect(:StockpileDef)
		battler.incrementEffect(:StockpileSpDef)
	},
	:disable_proc => Proc.new { |battle, battler|
		statArray = []
		if battler.effectActive?(:StockpileDef)
			statArray.push(:DEFENSE)
			statArray.push(battler.countEffect(:StockpileDef))
		end
		if battler.effectActive?(:StockpileSpDef)
			statArray.push(:SPECIAL_DEFENSE)
			statArray.push(battler.countEffect(:StockpileSpDef))
		end

		battler.pbLowerMultipleStatStages(statArray, battler)
	},
	:sub_effects => [:StockpileDef,:StockpileSpDef]
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StockpileDef,
	:real_name => "Stockpile Def",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StockpileSpDef,
	:real_name => "Stockpile Sp Def",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Substitute,
	:real_name => "Substitute Health",
	:type => :Integer,
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplaySlower(_INTL("{1} put up a substitute!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Taunt,
	:real_name => "Taunted Turns",
	:type => :Integer,
	:ticks_down => true,
	:is_mental => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} fell for the taunt!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} taunt wore off.",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Telekinesis,
	:real_name => "Telekinesis Turns",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 0 if battler.isSpecies?(:GENGAR) && battler.mega?
		next value
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ThroatChop,
	:real_name => "Throat Injured Turns",
	:type => :Integer,
	:ticks_down => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} can't use sound-based moves for the next #{value-1} turns!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Torment,
	:real_name => "Tormented",
	:is_mental => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was subjected to torment!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Transform,
	:real_name => "Transformed",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TransformSpecies,
	:real_name => "Transformed Into",
	:type => :Species,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Trapping,
	:real_name => "Trapping Turns",
	:type => :Integer,
	:ticks_down => true,
	:trapping => true,
	:swaps_with_battlers => true,
	:disable_proc => Proc.new { |battle,battler|
		moveName = battler.getMoveData(:TrappingMove).name
        battle.pbDisplay(_INTL("{1} was freed from {2}!",battler.pbThis,moveName))
	},
	:remain_proc => Proc.new { |battle,battler,value|
		moveName = battler.getMoveData(:TrappingMove).name
		case battler.effects[:TrappingMove]
        when :BIND,:VINEBIND            then battle.pbCommonAnimation("Bind", battler)
        when :CLAMP,:SLAMSHUT           then battle.pbCommonAnimation("Clamp", battler)
        when :FIRESPIN,:CRIMSONSTORM    then battle.pbCommonAnimation("FireSpin", battler)
        when :MAGMASTORM                then battle.pbCommonAnimation("MagmaStorm", battler)
        when :SANDTOMB,:SANDVORTEX      then battle.pbCommonAnimation("SandTomb", battler)
        when :INFESTATION               then battle.pbCommonAnimation("Infestation", battler)
	    when :SNAPTRAP 	                then battle.pbCommonAnimation("SnapTrap",battler)
        when :THUNDERCAGE               then battle.pbCommonAnimation("ThunderCage",battler)
		when :WHIRLPOOL,:MAELSTROM      then battle.pbCommonAnimation("Whirlpool",battler)
		when :BEARHUG					then battle.pbCommonAnimation("BearHug",battler)
        else                            battle.pbCommonAnimation("Wrap", battler)
        end
        if battler.takesIndirectDamage?
          fraction = 1.0/8.0
          fraction *= 2 if battler.getBattlerPointsTo(:TrappingUser).hasActiveItem?(:BINDINGBAND)
          battle.pbDisplay(_INTL("{1} is hurt by {2}!",battler.pbThis,moveName))
          battler.applyFractionalDamage(fraction)
        end
	},
	:sub_effects => [:TrappingMove,:TrappingUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TrappingMove,
	:real_name => "Trapping Move",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TrappingUser,
	:real_name => "Trapped By",
	:type => :Position,
	:disable_effecs_on_other_exit => [:Trapping],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Truant,
	:real_name => "Slacking Off",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TwoTurnAttack,
	:real_name => "Two Turn Attack",
	:type => :Move,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Type3,
	:real_name => "Type 3",
	:type => :Type,
	:info_displayed => false,
	:apply_proc => Proc.new { |battle,battler,value|
		typeName = GameData::Type.get(value).name
		battle.pbDisplay(_INTL("{1} gainted the {2} type!",battler.pbThis,typeName))
		battle.scene.pbRefresh()
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ItemLost,
	:real_name => "Item Lost",
	:info_displayed => false,
	:apply_proc => Proc.new { |battle,battler,value|
		if battler.hasActiveAbility?(:UNBURDEN)
			battle.pbShowAbilitySplash(battler)
			battle.pbDisplay(_INTL("{1} is unburdened of its item. Its Speed doubled!",battler.pbThis))
			battle.pbHideAbilitySplash(battler)
		end
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Uproar,
	:real_name => "Uproar Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:ticks_down => true,
	:multi_turn_tracker => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} caused an uproar!",battler.pbThis))
		battle.pbPriority(true).each do |b|
			next if b.fainted?
			next if b.hasActiveAbility?(:SOUNDPROOF)
			b.pbCureStatus(true,:SLEEP)
		end
	},
	:remain_proc => Proc.new { |battle, battler,value|
		battle.pbDisplay(_INTL("{1} is making an uproar!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} calmed down.",battler.pbThis))
		battler.currentMove = nil
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :WaterSport,
	:real_name => "Fire Resistant",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :WeightChange,
	:real_name => "Weight Changed",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Refurbished,
	:real_name => "Weight Halved",
	:type => :Integer,
	:maximum => 10,
	:increment_proc => Proc.new { | battle, battler, value, increment|
		battle.pbDisplay(_INTL("{1} shed half its weight!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Yawn,
	:real_name => "Drowsy",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle, battler|
		if battler.canSleepYawn?
			PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
			battler.applySleep
		end
	},
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became drowsy!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GorillaTactics,
	:real_name => "Choice Locking",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BallFetch,
	:real_name => "BallFetch",
	:type => :Item,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StatsDropped,
	:real_name => "Stats Dropped",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BurningJealousy,
	:real_name => "Burning Jealousy",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :JawLock,
	:real_name => "Jaw Lock",
	:baton_passed => true,
	:trapping => true,
	:disable_proc => Proc.new { |battle, battler|
		# Disable jaw lock on all other battlers who were locked with this
		battle.eachBattler do |b|
			if b.pointsAt?(:JawLockUser,battler)
				b.disableEffect(:JawLock)
				b.disableEffect(:JawLockUser)
			end
		end
	},
	:sub_effects => [:JawLockUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :JawLockUser,
	:real_name => "Jaw Locker",
	:info_displayed => false,
	:type => :Position,
	:baton_passed => true,
	:disable_effecs_on_other_exit => [:JawLock],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TarShot,
	:real_name => "Covered In Tar",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became weaker to fire!", battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Octolock,
	:real_name => "Octolocked",
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} is trapped by the tentacle hold!", battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		octouser = battle.battlers[battler.effects[:OctolockUser]]
		battler.pbLowerMultipleStatStages([:DEFENSE,1,:SPECIAL_DEFENSE,1],octouser)
	},
	:sub_effects => [:OctolockUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :OctolockUser,
	:real_name => "Octolocked By",
	:type => :Position,
	:disable_effecs_on_other_exit => [:Octolock],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BlunderPolicy,
	:real_name => "Blunder Policy",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SwitchedAlly,
	:real_name => "Switched Ally",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Sentry,
	:real_name => "Sentry",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Assist,
	:real_name => "Assisting",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ConfusionChance,
	:real_name => "Confusion Chance",
	:type => :Integer,
	:baton_passed => true,
	:info_displayed => false,
	:active_value_proc => proc { |value|
		next value != 0
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlinchedAlready,
	:real_name => "Flinch Immune",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Enlightened,
	:real_name => "Ignores Added Effects",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ColdConversion,
	:real_name => "Cold Converted",
	:info_displayed => false,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} lost its cold!",battler.pbThis))
        battle.scene.pbRefresh()
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CreepOut,
	:real_name => "Weak to Bug",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} is now afraid of Bug-type moves!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LuckyStar,
	:real_name => "Added Crit Chance",
	:critical_rate_buff => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} is blessed by the lucky star!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Charm,
	:real_name => "Charm Turns",
	:type => :Integer,
	:baton_passed => true,
	:is_mental => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.battle.pbAnimation(:LUCKYCHANT, battler, nil)
		battle.pbDisplay(_INTL("{1} became charmed! It will hit itself with its own Sp. Atk!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis))
	},
	:sub_effects => [:CharmChance],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CharmChance,
	:real_name => "Charm Chance",
	:type => :Integer,
	:baton_passed => true,
	:info_displayed => false,
	:active_value_proc => proc { |value|
		next value != 0
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Inured,
	:real_name => "No Weaknesses",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} shed its weaknesses!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :NoRetreat,
	:real_name => "No Retreat!!",
	:baton_passed => true,
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} is committed to the battle! It can't escape!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :NerveBreak,
	:real_name => "Healing Reversed",
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1}'s nerves are strained!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FuryCutter,
	:real_name => "Fury Cutter Count",
	:type => :Integer,
	:maximum => 4,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
	:snowballing_move_counter => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :IceBall,
	:real_name => "Ice Ball Count",
	:type => :Integer,
	:maximum => 4,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
	:snowballing_move_counter => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RollOut,
	:real_name => "Roll Out Count",
	:type => :Integer,
	:maximum => 4,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
	:snowballing_move_counter => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HeartRhythm,
	:real_name => "Heart Rhythm Count",
	:type => :Integer,
	:maximum => 4,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
	:snowballing_move_counter => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StunningCurl,
	:real_name => "Stunning Curl",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RootShelter,
	:real_name => "Root Shelter",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ExtraTurns,
	:real_name => "Extra Turns",
	:type => :Integer,
	:apply_proc => Proc.new { |battle, battler, value|
		if value == 1
			battle.pbDisplay(_INTL("{1} gained an extra attack!",battler.pbThis))
		else
			battle.pbDisplay(_INTL("{1} gained {2} extra attacks!",battler.pbThis, value))
		end
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredMoonlight,
	:real_name => "Stats Swapped Around",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredEndure,
	:real_name => "Enduring Turns",
	:type => :Integer,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} braced itself!",battler.pbThis))
		battle.pbDisplay(_INTL("It will endure the next #{value} hits which would faint it!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredLaserFocus,
	:real_name => "Laser Focus",
	:critical_rate_buff => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} concentrated with extreme intensity!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredDestinyBond,
	:real_name => "Empowered Bond",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("Attacks against {1} will incur half recoil!",battler.pbThis(true)))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :VolleyStance,
	:real_name => "Volley Stance",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} prepares to begin the bombardment!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GivingDragonRideTo,
	:real_name => "Carrying",
	:type => :Position,
	:others_lose_track => true,
	:trapping => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :OnDragonRide,
	:real_name => "Riding Dragon",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ShimmeringHeat,
	:real_name => "Shimmering Heat",
	:resets_eor	=> true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} is obscured by the shimmering haze!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlareWitch,
	:real_name => "Flare Witch",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} breaks open its witch powers!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredDetect,
	:real_name => "Halving Damage Turns",
	:type => :Integer,
	:ticks_down => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} sees everything!",battler.pbThis))
		battle.pbDisplay(_INTL("It's protected from half of all attack damage for #{value} turns!",battler.pbThis))
	},
	:disable_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1}'s Primeval Detect wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Echo,
	:real_name => "Echo",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredShoreUp,
	:real_name => "Eroding",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} began eroding!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		battler.pbLowerMultipleStatStages([:DEFENSE,1,:SPECIAL_DEFENSE,1],battler)
		battler.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],battler)
		battler.pbItemStatRestoreCheck
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredFlowState,
	:real_name => "Total Focus",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} entered a state of total focus!",battler.pbThis))
		battle.pbDisplay(_INTL("Its stats can't be lowered!",battler.pbThis))
	},
})

#######################################################
# Protection effects
#######################################################

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ProtectFailure,
	:real_name => "Protect Will Fail",
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Protect,
	:real_name => "Protect",
	:resets_eor	=> true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :KingsShield,
	:real_name => "King's Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.tryLowerStat(:ATTACK, user, increment: 1) if move.physicalMove?
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Obstruct,
	:real_name => "Obstruct",
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.tryLowerStat(:DEFENSE,user, increment: 2) if move.physicalMove?
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BanefulBunker,
	:real_name => "Baneful Bunker",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.applyPoison(target) if move.physicalMove? && user.canPoison?(target, false)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RedHotRetreat,
	:real_name => "Red-Hot Retreat",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.applyBurn(target) if move.specialMove? && user.canBurn?(target, false)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SpikyShield,
	:real_name => "Spiky Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			if move.physicalMove?
				battle.pbDisplay(_INTL('{1} was hurt!', user.pbThis))
				user.applyFractionalDamage(1.0 / 8.0)
			end
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorShield,
	:real_name => "Mirror Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			if move.specialMove?
				battle.pbDisplay(_INTL('{1} was hurt!', user.pbThis))
				user.applyFractionalDamage(1.0 / 8.0)
			end
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :VolatileToxin,
	:real_name => "Volatile Toxin",
	:apply_proc => Proc.new { |battle, battler, value|
	battle.pbDisplay(_INTL("The next Ground-type attack against {1} will deal double damage!",battler.pbThis(true)))
	},
})