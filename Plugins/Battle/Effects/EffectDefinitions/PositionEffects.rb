GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightCounter,
	:real_name => "Turns Till Move",
	:type => :Integer,
	:ticks_down => true,
    :sub_effects => [:FutureSightMove, :FutureSightUserPartyIndex, :FutureSightUserIndex],
	:expire_proc => Proc.new { |battle,index,position,battler|
		userIndex = position.effects[:FutureSightUserIndex]
		partyIndex = position.effects[:FutureSightUserPartyIndex]
		move = position.effects[:FutureSightMove]
		moveUser = nil
		battle.eachBattler do |b|
		  next if b.opposes?(userIndex)
		  next if b.pokemonIndex != partyIndex
		  moveUser = b
		  break
		end
		# Target is the user
		next if moveUser && moveUser.index == battler.index
		# User isn't in battle, get it from the party
		if moveUser.nil?
		  party = battle.pbParty(userIndex)
		  pkmn = party[partyIndex]
		  if pkmn && pkmn.able?
			moveUser = PokeBattle_Battler.new(battle,userIndex)
			moveUser.pbInitDummyPokemon(pkmn,partyIndex)
		  end
		end
		next if moveUser.nil?   # User is fainted
		moveName = GameData::Move.get(move).name
		pbDisplay(_INTL("{1} took the {2} attack!",battler.pbThis,moveName))
		# NOTE: Future Sight failing against the target here doesn't count towards
		#       Stomping Tantrum.
		userLastMoveFailed = moveUser.lastMoveFailed
		battle.futureSight = true
		moveUser.pbUseMoveSimple(move,index)
		battle.futureSight = false
		moveUser.lastMoveFailed = userLastMoveFailed
		battler.pbFaint if battler.fainted?
	}
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightMove,
	:real_name => "Incoming Move",
	:type => :Move,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserIndex,
	:real_name => "Foretold Move User Index",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserPartyIndex,
	:real_name => "Foretold Move User Party Index",
	:type => :PartyPosition,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :HealingWish,
	:real_name => "Healing Wish",
	:entry_proc => Proc.new { |battle,index,position,battler|
		battle.pbCommonAnimation("HealingWish",battler)
		healingMessage = _INTL("The healing wish came true for {1}!",battler.pbThis(true))
		battler.pbRecoverHP(battler.totalhp,true,true,true,healingMessage)
		battler.pbCureStatus(false)
		position.disableEffect(:HealingWish)
	},
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :LunarDance,
	:real_name => "Lunar Dance",
	:entry_proc => Proc.new { |battle,index,position,battler|
		battle.pbCommonAnimation("LunarDance",battler)
		healingMessage = _INTL("The healing wish came true for {1}!",battler.pbThis(true))
		battler.pbRecoverHP(battler.totalhp,true,true,true,healingMessage)
		battler.pbCureStatus(false)
		battler.eachMove { |m| m.pp = m.total_pp }
		position.disableEffect(:LunarDance)
	},
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :Wish,
	:real_name => "Turns Till Wish",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,index,position,battler|
		if battler.canHeal?
			wishMaker = battle.pbThisEx(index,position.effects[:WishMaker])
			healingMessage = _INTL("{1}'s wish came true!",wishMaker)
			battler.pbRecoverHP(pos.effects[:WishAmount],true,true,true,healingMessage)
		end
	},
	:sub_effects => [:WishAmount,:WishMaker],
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :WishAmount,
	:real_name => "Wish Heal Amount",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :WishMaker,
	:real_name => "Wish Maker",
	:type => :PartyPosition,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :Refuge,
	:real_name => "Refuge",
	:type => :PartyPosition,
	:entry_proc => Proc.new { |battle,index,position,battler|
		battle.pbCommonAnimation("HealingWish",battler)
		refugeMaker = battle.pbThisEx(battler.index,position.effects[:Refuge])
		battle.pbDisplay(_INTL("{1}'s refuge comforts {2}!",refugeMaker,battler.pbThis(true)))
		battler.pbCureStatus(false)
		position.disableEffect(:Refuge)
	},
})