GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightCounter,
	:real_name => "FutureSightCounter",
	:type => :Integer,
	:ticks_down => true,
    :connected_effects => [:FutureSightMove, :FutureSightUserPartyIndex, :FutureSightUserIndex],
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
	:real_name => "FutureSightMove",
	:type => :Move,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserIndex,
	:real_name => "FutureSightUserIndex",
	:type => :Position,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserPartyIndex,
	:real_name => "FutureSightUserPartyIndex",
	:type => :PartyPosition,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :HealingWish,
	:real_name => "HealingWish",
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :LunarDance,
	:real_name => "LunarDance",
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :Wish,
	:real_name => "Wish",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,index,position,battler|
		if battler.canHeal?
			wishMaker = battle.pbThisEx(index,position.effects[PBEffects::WishMaker])
			healingMessage = _INTL("{1}'s wish came true!",wishMaker)
			battler.pbRecoverHP(pos.effects[PBEffects::WishAmount],true,true,true,healingMessage)
		end
	},
	:connected_effects => [:WishAmount,:WishMaker],
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :WishAmount,
	:real_name => "WishAmount",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :WishMaker,
	:real_name => "WishMaker",
	:type => :PartyPosition,
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :Refuge,
	:real_name => "Refuge",
	:connected_effects => [:RefugeMaker],
})

GameData::BattleEffect.register_effect(:Position,{
	:id => :RefugeMaker,
	:real_name => "RefugeMaker",
	:type => :PartyPosition,
})