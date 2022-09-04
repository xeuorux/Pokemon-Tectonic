class PokeBattle_Battler
	attr_accessor 	:boss
	attr_accessor 	:avatarPhase
	attr_accessor	:extraMovesPerTurn
	attr_reader 	:bossStatus
	attr_reader 	:bossStatusCount
	attr_accessor 	:primevalTimer
	attr_accessor	:indexesTargetedThisTurn
	attr_accessor	:dmgMult
	attr_accessor	:dmgResist
	
	def bossStatus=(value)
		@effects[PBEffects::Truant] = false if @bossStatus == :SLEEP && value != :SLEEP
		@bossStatus = value
		@bossStatusCount = 0 if value != :SLEEP
		@battle.scene.pbRefreshOne(@index)
	end
	
	def bossStatusCount=(value)
		@bossStatusCount = value
		@battle.scene.pbRefreshOne(@index)
	end
	
	def boss?
		return boss
	end
	
	def empowered?
		return @avatarPhase > 1
	end

	def extraMovesPerTurn
		val = @pokemon.extraMovesPerTurn || 0
		val += effects[PBEffects::ExtraTurns]
		return val
	end

	def extraMovesPerTurn=(val)
		@pokemon.extraMovesPerTurn = val
	end

	def resetExtraMovesPerTurn
		@pokemon.extraMovesPerTurn = GameData::Avatar.get(@species).num_turns - 1
	end

	def firstMoveThisTurn?
		return @battle.commandPhasesThisRound == 0
	end

	def lastMoveThisTurn?
		return @battle.commandPhasesThisRound == extraMovesPerTurn
	end

	def pbInitBlank
		@name           = ""
		@species        = 0
		@form           = 0
		@level          = 0
		@hp = @totalhp  = 0
		@type1 = @type2 = nil
		@ability_id     = nil
		@item_id        = nil
		@gender         = 0
		@attack = @defense = @spatk = @spdef = @speed = 0
		@status         = :NONE
		@statusCount    = 0
		@pokemon        = nil
		@pokemonIndex   = -1
		@participants   = []
		@moves          = []
		@iv             = {}
		GameData::Stat.each_main { |s| @iv[s.id] = 0 }
		@boss			= false
		@bossStatus		= :NONE
		@bossStatusCount = 0
		@empowered 		= false
		@primevalTimer	= 0
		@extraMovesPerTurn	= 0
		@indexesTargetedThisTurn	= []
		@dmgMult = 1
		@dmgResist = 0
	end
  
  # Used by Future Sight only, when Future Sight's user is no longer in battle.
  def pbInitDummyPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @totalhp      = pkmn.totalhp
	@hp           = pkmn.hp
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    # ability and item intentionally not copied across here
    @gender       = pkmn.gender
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
	@boss		  = pkmn.boss
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []
    # moves intentionally not copied across here
    @iv           = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
    @dummy        = true
	@dmgMult   = 1
	@dmgResist = 0
  end


  def pbInitPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @totalhp      = pkmn.totalhp
	@hp           = pkmn.hp
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @ability_id   = pkmn.ability_id
    @item_id      = pkmn.item_id
    @gender       = pkmn.gender
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
	@dmgMult	  = pkmn.dmgMult
	@dmgResist	  = pkmn.dmgResist
	@boss		  = pkmn.boss
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []   # Participants earn Exp. if this battler is defeated
    @moves        = []
    pkmn.moves.each_with_index do |m,i|
      @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,m)
    end
    @iv           = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
  end

	def pbInitEffects(batonPass)
		if batonPass
		  # These effects are passed on if Baton Pass is used, but they need to be
		  # reapplied
		  @effects[PBEffects::LaserFocus] = (@effects[PBEffects::LaserFocus]>0) ? 2 : 0
		  @effects[PBEffects::LockOn]     = (@effects[PBEffects::LockOn]>0) ? 2 : 0
		  if @effects[PBEffects::PowerTrick]
			@attack,@defense = @defense,@attack
		  end
		  # These effects are passed on if Baton Pass is used, but they need to be
		  # cancelled in certain circumstances anyway
		  @effects[PBEffects::Telekinesis] = 0 if isSpecies?(:GENGAR) && mega?
		  @effects[PBEffects::GastroAcid]  = false if unstoppableAbility?
		else
		  # These effects are not passed on if Baton Pass is used
		  @stages[:ATTACK]          = 0
		  @stages[:DEFENSE]         = 0
		  @stages[:SPEED]           = 0
		  @stages[:SPECIAL_ATTACK]  = 0
		  @stages[:SPECIAL_DEFENSE] = 0
		  @stages[:ACCURACY]        = 0
		  @stages[:EVASION]         = 0
		  @effects[PBEffects::AquaRing]          = false
		  @effects[PBEffects::Confusion]         = 0
		  @effects[PBEffects::ConfusionChance]   = 0
		  @effects[PBEffects::Curse]             = false
		  @effects[PBEffects::Embargo]           = 0
		  @effects[PBEffects::FocusEnergy]       = 0
		  @effects[PBEffects::GastroAcid]        = false
		  @effects[PBEffects::HealBlock]         = 0
		  @effects[PBEffects::Ingrain]           = false
		  @effects[PBEffects::LaserFocus]        = 0
		  @effects[PBEffects::LeechSeed]         = -1
		  @effects[PBEffects::LockOn]            = 0
		  @effects[PBEffects::LockOnPos]         = -1
		  @effects[PBEffects::MagnetRise]        = 0
		  @effects[PBEffects::PerishSong]        = 0
		  @effects[PBEffects::PerishSongUser]    = -1
		  @effects[PBEffects::PowerTrick]        = false
		  @effects[PBEffects::Substitute]        = 0
		  @effects[PBEffects::Telekinesis]       = 0
		  @effects[PBEffects::JawLock]           = false
		  @effects[PBEffects::JawLockUser]       = -1
		  @effects[PBEffects::NoRetreat]         = false
		  @effects[PBEffects::Charm]         	 = 0
		  @effects[PBEffects::CharmChance]   	 = 0
		end
		@fainted               = (@hp==0)
		@initialHP             = 0
		@lastAttacker          = []
		@lastFoeAttacker       = []
		@lastHPLost            = 0
		@lastHPLostFromFoe     = 0
		@tookDamage            = false
		@tookPhysicalHit       = false
		@lastMoveUsed          = nil
		@lastMoveUsedType      = nil
		@lastRegularMoveUsed   = nil
		@lastRegularMoveTarget = -1
		@lastRoundMoved        = -1
		@lastMoveFailed        = false
		@lastRoundMoveFailed   = false
		@movesUsed             = []
		@turnCount             = 0
		@avatarPhase		   = 1
		@primevalTimer		   = 0
		@extraMovesPerTurn	   = 0
		@indexesTargetedThisTurn   = []
		@effects[PBEffects::Attract]             = -1
		@battle.eachBattler do |b|   # Other battlers no longer attracted to self
		  b.effects[PBEffects::Attract] = -1 if b.effects[PBEffects::Attract]==@index
		end
		@effects[PBEffects::BanefulBunker]       = false
		@effects[PBEffects::BeakBlast]           = false
		@effects[PBEffects::Bide]                = 0
		@effects[PBEffects::BideDamage]          = 0
		@effects[PBEffects::BideTarget]          = -1
		@effects[PBEffects::BurnUp]              = false
		@effects[PBEffects::Charge]              = 0
		@effects[PBEffects::ChoiceBand]          = nil
		@effects[PBEffects::Counter]             = -1
		@effects[PBEffects::CounterTarget]       = -1
		@effects[PBEffects::Dancer]              = false
		@effects[PBEffects::DefenseCurl]         = false
		@effects[PBEffects::DestinyBond]         = false
		@effects[PBEffects::DestinyBondPrevious] = false
		@effects[PBEffects::DestinyBondTarget]   = -1
		@effects[PBEffects::Disable]             = 0
		@effects[PBEffects::DisableMove]         = nil
		@effects[PBEffects::Electrify]           = false
		@effects[PBEffects::Encore]              = 0
		@effects[PBEffects::EncoreMove]          = nil
		@effects[PBEffects::Endure]              = false
		@effects[PBEffects::FirstPledge]         = 0
		@effects[PBEffects::FlashFire]           = false
		@effects[PBEffects::Flinch]              = false
		@effects[PBEffects::FocusPunch]          = false
		@effects[PBEffects::FollowMe]            = 0
		@effects[PBEffects::Foresight]           = false
		@effects[PBEffects::FuryCutter]          = 0
		@effects[PBEffects::IceBall]          	 = 0
		@effects[PBEffects::RollOut]          = 0
		@effects[PBEffects::GemConsumed]         = nil
		@effects[PBEffects::Grudge]              = false
		@effects[PBEffects::HelpingHand]         = false
		@effects[PBEffects::HyperBeam]           = 0
		@effects[PBEffects::Illusion]            = nil
		if hasActiveAbility?(:ILLUSION)
		  idxLastParty = @battle.pbLastInTeam(@index)
		  if idxLastParty >= 0 && idxLastParty != @pokemonIndex
			@effects[PBEffects::Illusion]        = @battle.pbParty(@index)[idxLastParty]
		  end
		end
		@effects[PBEffects::Imprison]            = false
		@effects[PBEffects::Instruct]            = false
		@effects[PBEffects::Instructed]          = false
		@effects[PBEffects::KingsShield]         = false
		@battle.eachBattler do |b|   # Other battlers lose their lock-on against self
		  next if b.effects[PBEffects::LockOn]==0
		  next if b.effects[PBEffects::LockOnPos]!=@index
		  b.effects[PBEffects::LockOn]    = 0
		  b.effects[PBEffects::LockOnPos] = -1
		end
		@effects[PBEffects::MagicBounce]         = false
		@effects[PBEffects::MagicCoat]           = false
		@effects[PBEffects::MeanLook]            = -1
		@battle.eachBattler do |b|   # Other battlers no longer blocked by self
		  b.effects[PBEffects::MeanLook] = -1 if b.effects[PBEffects::MeanLook]==@index
		end
		@effects[PBEffects::MeFirst]             = false
		@effects[PBEffects::Metronome]           = 0
		@effects[PBEffects::MicleBerry]          = false
		@effects[PBEffects::Minimize]            = false
		@effects[PBEffects::MiracleEye]          = false
		@effects[PBEffects::MirrorCoat]          = -1
		@effects[PBEffects::MirrorCoatTarget]    = -1
		@effects[PBEffects::MoveNext]            = false
		@effects[PBEffects::MudSport]            = false
		@effects[PBEffects::Nightmare]           = false
		@effects[PBEffects::Outrage]             = 0
		@effects[PBEffects::ParentalBond]        = 0
		@effects[PBEffects::PickupItem]          = nil
		@effects[PBEffects::PickupUse]           = 0
		@effects[PBEffects::Pinch]               = false
		@effects[PBEffects::Powder]              = false
		@effects[PBEffects::Prankster]           = false
		@effects[PBEffects::PriorityAbility]     = false
		@effects[PBEffects::PriorityItem]        = false
		@effects[PBEffects::Protect]             = false
		@effects[PBEffects::ProtectRate]         = 1
		@effects[PBEffects::Pursuit]             = false
		@effects[PBEffects::Quash]               = 0
		@effects[PBEffects::Rage]                = false
		@effects[PBEffects::RagePowder]          = false
		@effects[PBEffects::Rollout]             = 0
		@effects[PBEffects::Roost]               = false
		@effects[PBEffects::SkyDrop]             = -1
		@battle.eachBattler do |b|   # Other battlers no longer Sky Dropped by self
		  b.effects[PBEffects::SkyDrop] = -1 if b.effects[PBEffects::SkyDrop]==@index
		end
		@effects[PBEffects::SlowStart]           = 0
		@effects[PBEffects::SmackDown]           = false
		@effects[PBEffects::Snatch]              = 0
		@effects[PBEffects::SpikyShield]         = false
		@effects[PBEffects::Spotlight]           = 0
		@effects[PBEffects::Stockpile]           = 0
		@effects[PBEffects::StockpileDef]        = 0
		@effects[PBEffects::StockpileSpDef]      = 0
		@effects[PBEffects::Taunt]               = 0
		@effects[PBEffects::ThroatChop]          = 0
		@effects[PBEffects::Torment]             = false
		@effects[PBEffects::Toxic]               = 0
		@effects[PBEffects::Transform]           = false
		@effects[PBEffects::TransformSpecies]    = 0
		@effects[PBEffects::Trapping]            = 0
		@effects[PBEffects::TrappingMove]        = nil
		@effects[PBEffects::TrappingUser]        = -1
		@battle.eachBattler do |b|   # Other battlers no longer trapped by self
		  next if b.effects[PBEffects::TrappingUser]!=@index
		  b.effects[PBEffects::Trapping]     = 0
		  b.effects[PBEffects::TrappingUser] = -1
		end
		@effects[PBEffects::Octolock]     = false
		@effects[PBEffects::OctolockUser] = -1
		@battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Octolock
		  next if !b.effects[PBEffects::Octolock]
		  next if b.effects[PBEffects::OctolockUser]!=@index
		  b.effects[PBEffects::Octolock]     = false
		  b.effects[PBEffects::OctolockUser] = -1
		end
		@battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Jawlock
		  next if !b.effects[PBEffects::JawLock]
		  next if b.effects[PBEffects::JawLockUser]!=@index
		  b.effects[PBEffects::JawLock]     = false
		  b.effects[PBEffects::JawLockUser] = -1
		end
		@effects[PBEffects::Truant]              = false
		@effects[PBEffects::TwoTurnAttack]       = nil
		@effects[PBEffects::Type3]               = nil
		@effects[PBEffects::Unburden]            = false
		@effects[PBEffects::Uproar]              = 0
		@effects[PBEffects::WaterSport]          = false
		@effects[PBEffects::WeightChange]        = 0
		@effects[PBEffects::Yawn]                = 0
		
		@effects[PBEffects::GorillaTactics]      = nil
		@effects[PBEffects::BallFetch]           = 0
		@effects[PBEffects::LashOut]             = false
		@effects[PBEffects::BurningJealousy]     = false
		@effects[PBEffects::Obstruct]            = false
		@effects[PBEffects::TarShot]             = false
		@effects[PBEffects::BlunderPolicy]       = false
		@effects[PBEffects::SwitchedAlly]        = -1
		
		@effects[PBEffects::FlinchedAlready]     = false
		@effects[PBEffects::Enlightened]		 = false
		@effects[PBEffects::ColdConversion]      = false
		@effects[PBEffects::CreepOut]		 	 = false
		@effects[PBEffects::LuckyStar]       	 = false
		@effects[PBEffects::Inured]       	 	 = false
		@effects[PBEffects::Gargantuan]			 = 0
		@effects[PBEffects::NerveBreak]   		 = false
		@effects[PBEffects::StunningCurl]		 = false
		@effects[PBEffects::RedHotRetreat]       = false
		@effects[PBEffects::VolleyStance]        = false
		@effects[PBEffects::OnDragonRide]    	 = false
		@effects[PBEffects::GivingDragonRideTo]  = -1
		@effects[PBEffects::ShimmeringHeat]		 = false
		@effects[PBEffects::FlareWitch]		 = false
		
		@effects[PBEffects::EmpoweredEndure]     = 0
		@effects[PBEffects::EmpoweredMoonlight]  = false
		@effects[PBEffects::EmpoweredLaserFocus] = false
		@effects[PBEffects::EmpoweredDestinyBond] = false
		@effects[PBEffects::ExtraTurns] = 0
		@effects[PBEffects::EmpoweredDetect]     = 0

		@battle.eachBattler do |b|   # Other battlers no longer giving a dragon ride to self
			next if b.effects[PBEffects::GivingDragonRideTo] != @index
			b.effects[PBEffects::GivingDragonRideTo]     	  = -1
		end
    end
end