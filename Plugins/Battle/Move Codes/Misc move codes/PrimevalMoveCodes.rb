module EmpoweredMove
	def pbMoveFailed?(user,targets); return false; end
	def pbFailsAgainstTarget?(user,target); return false; end

	# There must be 2 turns without using a primeval attack to then be able to use it again
	def turnsBetweenUses(); return 2; end
	
	def transformType(user,type)
		user.pbChangeTypes(type)
		typeName = GameData::Type.get(type).name
		@battle.pbAnimation(:CONVERSION, user, [user])
		user.pokemon.bossType = type
		@battle.scene.pbChangePokemon(user.index,user.pokemon)
		@battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
	end
end

# Empowered Heal Bell
class PokeBattle_Move_600 < PokeBattle_Move_019
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		# Double supers here is intentional
		super
		super
		@battle.eachSameSideBattler(user) do |b|
			healAmount = b.totalhp/2.0
			healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE if b.boss?
			b.pbRecoverHP(healAmount)
		end
		transformType(user,:NORMAL)
	end
end

# Empowered Sunny Day
class PokeBattle_Move_601 < PokeBattle_Move_0FF
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],user,move: self)
		transformType(user,:FIRE)
	end
end

# Empowered Rain Dance
class PokeBattle_Move_602 < PokeBattle_Move_100
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.pbAnimation(:AQUARING, user, [user])
		user.applyEffect(:AquaRing)
		transformType(user,:WATER)
	end
end

# Empowered Leech Seed
class PokeBattle_Move_603 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			b.applyLeeched(user) if b.canLeech?(user,true,self)
	    end
		transformType(user,:GRASS)
	end
end

# Empowered Lightning Dance
class PokeBattle_Move_604 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:SPECIAL_ATTACK,2,:SPEED,2]
	end
	
	def pbEffectGeneral(user)
		super
		transformType(user,:ELECTRIC)
	end
end 

# Empowered Hail
class PokeBattle_Move_605 < PokeBattle_Move_102
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			b.tryLowerStat(:SPEED,user, increment: 2, move: self)
	    end
		transformType(user,:ICE)
	end
end

# Empowered Bulk Up
class PokeBattle_Move_606 < PokeBattle_Move_024
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.pbDisplay(_INTL("{1} gained a massive amount of mass!",user.pbThis))
		user.incrementEffect(:WeightChange, 1000)
		transformType(user,:FIGHTING)
	end
end

# Empowered Spikes
class PokeBattle_Move_607 < PokeBattle_Move_103
	include EmpoweredMove

	def pbEffectGeneral(user)
		# Apply up to the maximum number of layers
		increment = GameData::BattleEffect.get(:Spikes).maximum - user.pbOpposingSide.countEffect(:Spikes)
		if increment > 0
			user.pbOpposingSide.incrementEffect(:Spikes,increment)
		end
		transformType(user,:GROUND)
	end
end

# Empowered Tailwind
class PokeBattle_Move_608 < PokeBattle_Move_05B
  include EmpoweredMove

  def pbEffectGeneral(user)
    user.pbOwnSide.applyEffect(:Tailwind,999)
	@battle.eachSameSideBattler(user) do |b|
		b.applyEffect(:ExtraTurns,1)
	end
	transformType(user,:FLYING)
  end
end

# Empowered Calm Mind
class PokeBattle_Move_609 < PokeBattle_Move_02C
	 include EmpoweredMove

	def pbEffectGeneral(user)
		user.tryRaiseStat(:ACCURACY,user,increment: 3, move: self)
		super
		transformType(user,:PSYCHIC)
	end
end

# Empowered String Shot
class PokeBattle_Move_610 < PokeBattle_TargetMultiStatDownMove
	include EmpoweredMove

	def initialize(battle,move)
		super
		@statDown = [:SPEED,2,:ATTACK,2,:SPECIAL_ATTACK,2]
	end
	
	def pbEffectGeneral(user)
		transformType(user,:BUG)
	end
end

# Empowered Sandstorm
class PokeBattle_Move_611 < PokeBattle_Move_101
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.pbRaiseMultipleStatStages([:DEFENSE,1,:SPECIAL_DEFENSE,1],user,move:self)
		transformType(user,:ROCK)
	end
end

# Empowered Curse
class PokeBattle_Move_612 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			b.applyEffect(:Curse)
	    end
		transformType(user,:GHOST)
	end
end

# Empowered Dragon Dance
class PokeBattle_Move_613 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:ATTACK,2,:SPEED,2]
	end
	
	def pbEffectGeneral(user)
		super
		transformType(user,:DRAGON)
	end
end

# Empowered Torment
class PokeBattle_Move_614 < PokeBattle_Move_0B7
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		transformType(user,:DARK)
	end
	
	def pbEffectAgainstTarget(user,target)
		target.applyEffect(:Torment)
		target.pbLowerMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],user,move: self)
	 end
end

# Empowered Laser Focus
class PokeBattle_Move_615 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		user.applyEffect(:EmpoweredLaserFocus)
		transformType(user,:STEEL)
	end
end

# Empowered Moonlight
class PokeBattle_Move_616 < PokeBattle_HalfHealingMove
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.attack,user.spatk = user.spatk,user.attack
		@battle.pbDisplay(_INTL("{1} switched its Attack and Sp. Atk!",user.pbThis))
		
		user.defense,user.spdef = user.spdef,user.defense
		@battle.pbDisplay(_INTL("{1} switched its Defense and Sp. Def!",user.pbThis))
		user.effects[:EmpoweredMoonlight] = !user.effects[:EmpoweredMoonlight]
		
		transformType(user,:FAIRY)
	end
end

# Empowered Poison Gas
class PokeBattle_Move_617 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next if !b.canPoison?(user,true,self)
			b.applyPoison(user)
	    end
		transformType(user,:POISON)
	end
end

# Empowered Endure
class PokeBattle_Move_618 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.applyEffect(:EmpoweredEndure,3)
		transformType(user,:NORMAL)
	end
end
	
# Empowered Ignite
class PokeBattle_Move_619 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			b.applyBurn(user) if b.canBurn?(user,true,self)
	    end
		transformType(user,:FIRE)
	end
end

# Empowered Flow State
class PokeBattle_Move_620 < PokeBattle_MultiStatUpMove
	include EmpoweredMove
	
	def initialize(battle,move)
		super
		@statUp = [:ATTACK,1,:SPECIAL_DEFENSE,1]
	end
	
	def pbEffectGeneral(user)
		super

		user.applyEffect(:EmpoweredFlowState)

		transformType(user,:WATER)
	end
end

# Empowered Grassy Terrain
class PokeBattle_Move_621 < PokeBattle_Move_155
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],user,move: self)
		transformType(user,:GRASS)
	end
end

# Empowered Electric Terrain
class PokeBattle_Move_622 < PokeBattle_Move_154
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.pbAnimation(:CHARGE, user, [user])
		user.applyEffect(:Charge,2)
		transformType(user,:ELECTRIC)
	end
end

# Empowered Psychic Terrain
class PokeBattle_Move_623 < PokeBattle_Move_173
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		GameData::Stat.each_battle { |s| user.stages[s.id] = 0 if user.stages[s.id] < 0 }
		@battle.pbDisplay(_INTL("{1}'s negative stat changes were eliminated!", user.pbThis))
		transformType(user,:PSYCHIC)
	end
end

# Empowered Fairy Terrain
class PokeBattle_Move_624 < PokeBattle_Move_156
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		
		@battle.eachSameSideBattler(user) do |b|
			b.pbRaiseMultipleStatStages([:DEFENSE,1,:SPECIAL_DEFENSE,1],user,move: self)
		end

		transformType(user,:FAIRY)
	end
end

# Empowered Heal Order
class PokeBattle_Move_625 < PokeBattle_HalfHealingMove
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)
		super

		if @battle.pbSideSize(user.index) < 3
			@battle.pbDisplay(_INTL("{1} summons a helper!",user.pbThis))
			@battle.addAvatarBattler(:COMBEE,user.level,user.index % 2)
		end
		
		transformType(user,:BUG)
	end
end

# Empowered Gastro Acid
class PokeBattle_Move_626 < PokeBattle_Move_068
	include EmpoweredMove
	
	def pbFailsAgainstTarget?(user,target)
	  if target.unstoppableAbility? && !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
		@battle.pbDisplay(_INTL("But it failed!"))
		return true
	  end
	  return false
	end
  
	def pbEffectAgainstTarget(user,target)
		super
		target.tryLowerStat(:SPECIAL_DEFENSE,user,move: self)

		transformType(user,:POISON)
	end
end

# Empowered Rock Polish
class PokeBattle_Move_627 < PokeBattle_Move_030
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.applyEffect(:ExtraTurns,2)
		transformType(user,:ROCK)
	end
end

# Empowered Whirlwind
class PokeBattle_Move_628 < PokeBattle_Move_0EB
	include EmpoweredMove

	def pbEffectGeneral(user)
		transformType(user,:FLYING)
	end
end

# Empowered Embargo
class PokeBattle_Move_629 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		user.pbOpposingSide.applyEffect(:EmpoweredEmbargo) unless user.pbOpposingSide.effectActive?(:EmpoweredEmbargo) 
		transformType(user,:DARK)
	end
end

# Empowered Chill
class PokeBattle_Move_630 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			b.applyFrostbite(user) if b.canFrostbite?(user,true,self)
	    end
		transformType(user,:ICE)
	end
end

# Empowered Destiny Bond
class PokeBattle_Move_631 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.applyEffect(:EmpoweredDestinyBond)
		transformType(user,:GHOST)
	end
end

# Empowered Shore Up
class PokeBattle_Move_632 < PokeBattle_HalfHealingMove
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		user.applyEffect(:EmpoweredShoreUp)
		
		transformType(user,:GROUND)
	end
end

# Empowered Loom Over
class PokeBattle_Move_633 < PokeBattle_Move_522
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super

		transformType(user,:DRAGON)
	end
end

# Empowered Detect
class PokeBattle_Move_634 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.applyEffect(:EmpoweredDetect,3)
		transformType(user,:FIGHTING)
	end
end

########################################################
### DAMAGING MOVES
########################################################

# Empowered Meteor Mash
class PokeBattle_Move_636 < PokeBattle_Move_01C
	include EmpoweredMove
end

# Empowered Ice Beam
class PokeBattle_Move_637 < PokeBattle_Move_51B
	include EmpoweredMove
end

# Empowered Rock Tomb
class PokeBattle_Move_638 < PokeBattle_Move_04D
	include EmpoweredMove
end

# Empowered Ancient Power
class PokeBattle_Move_639 < PokeBattle_Move_02D
	include EmpoweredMove
end

# Empowered Thunderbolt
class PokeBattle_Move_640 < PokeBattle_NumbMove
	include EmpoweredMove
end

# Empowered Flareblitz
class PokeBattle_Move_641 < PokeBattle_Move_0FB
	include EmpoweredMove
end

# Empowered Metal Claw
class PokeBattle_Move_642 < PokeBattle_Move_01C
	include EmpoweredMove

	def multiHitMove?;           return true; end
  	def pbNumHits(user,targets,checkingForAI=false); return 2;    end
end

# Empowered Slash
class PokeBattle_Move_643 < PokeBattle_Move_0A0
	include EmpoweredMove
end

# Empowered Brick Break
class PokeBattle_Move_644 < PokeBattle_TargetStatDownMove
	include EmpoweredMove

	def ignoresReflect?; return true; end

  	def pbEffectGeneral(user)
		user.pbOpposingSide.eachEffect(true) do |effect,value,data|
			user.pbOpposingSide.disableEffect(effect) if data.is_screen?
		end
	end

	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
		user.pbOpposingSide.eachEffect(true) do |effect,value,data|
			# Wall-breaking anim
			hitNum = 1 if data.is_screen?
		end
		super
	end

	def initialize(battle,move)
	  super
	  @statDown = [:DEFENSE,3]
	end
end

# Empowered Cross Poison
class PokeBattle_Move_645 < PokeBattle_Move
	include EmpoweredMove

	def pbCriticalOverride(user,target)
		return 1 if target.poisoned?
		return 0
	end
end

# Empowered Solar Beam
class PokeBattle_Move_646 < PokeBattle_Move_0C4
	include EmpoweredMove
end

# Empowered Power Gem
class PokeBattle_Move_647 < PokeBattle_Move_401
	include EmpoweredMove
end

# Empowered Bullet Seed
class PokeBattle_Move_648 < PokeBattle_Move_17C
	include EmpoweredMove

	def pbRepeatHit?(hitNum = 0)
		return hitNum < 5
	end
	
	def turnsBetweenUses(); return 3; end
end

########################################################
### Specific avatar only moves
########################################################

#===============================================================================
# Targets struck lose their flinch immunity. Only usable by the Avatar of Rayquaza (Stratosphere Scream)
#===============================================================================
class PokeBattle_Move_700 < PokeBattle_StatDownMove
    def ignoresSubstitute?(user); return true; end
  
    def pbMoveFailed?(user,targets)
      if !user.countsAs?(:RAYQUAZA) || !user.boss?
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis(true)))
        return true
      end
      return false
    end

	def pbEffectAfterAllHits(user,target)
		return if target.fainted?
		return if target.damageState.unaffected
		if target.effectActive?(:FlinchedAlready)
			target.disableEffect(:FlinchedAlready)
			@battle.pbDisplay(_INTL("#{target.pbThis} is newly afraid. It can be flinched again!"))
		end
	end
end