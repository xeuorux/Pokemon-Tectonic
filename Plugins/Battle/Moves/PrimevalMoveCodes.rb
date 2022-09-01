module EmpoweredMove
	def empowered?; return true; end
	def isEmpowered?; return true; end
	
	def pbMoveFailed?(user,targets); return false; end
	def pbFailsAgainstTarget?(user,target); return false; end
	
	def transformType(user,type)
		user.pbChangeTypes(type)
		typeName = GameData::Type.get(type).name
		@battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
	end
end

# Empowered Heal Bell
class PokeBattle_Move_600 < PokeBattle_Move_019
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		super
		@battle.eachSameSideBattler(user) do |b|
			b.pbRecoverHP((b.totalhp/8.0).round)
		end
		transformType(user,:NORMAL)
	end
end

# Empowered Sunny Day
class PokeBattle_Move_601 < PokeBattle_Move_0FF
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.pbRaiseStatStage(:ATTACK,1,user)
		user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
		transformType(user,:FIRE)
	end
end

# Empowered Rain Dance
class PokeBattle_Move_602 < PokeBattle_Move_100
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::AquaRing] = true
		@battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
		@battle.pbAnimation(:AQUARING, user, [user])
		transformType(user,:WATER)
	end
end

# Empowered Leech Seed
class PokeBattle_Move_603 < PokeBattle_Move_0DC
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
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
			next if !b.pbCanLowerStatStage?(:SPEED,user,self)
			b.pbLowerStatStage(:SPEED,2,user)
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
		user.effects[PBEffects::WeightChange] += 1000
		transformType(user,:FIGHTING)
	end
end

# Empowered Spikes
class PokeBattle_Move_607 < PokeBattle_Move_103
	include EmpoweredMove

	def pbEffectGeneral(user)
		user.pbOpposingSide.effects[PBEffects::Spikes] = 3
		@battle.pbDisplay(_INTL("3 layers of spikes were scattered all around {1}'s feet!",
		   user.pbOpposingTeam(true)))
		transformType(user,:GROUND)
	end
end

# Empowered Tailwind
class PokeBattle_Move_608 < PokeBattle_Move_05B
  include EmpoweredMove

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::Tailwind] = 99999
	@battle.pbDisplay(_INTL("A permanent Tailwind blew from behind {1}!",user.pbTeam(true)))
	@battle.eachSameSideBattler(user) do |b|
		b.effects[PBEffects::ExtraTurns] = 1
		@battle.pbDisplay(_INTL("{1} gained an extra attack!",user.pbThis))
	end
	transformType(user,:FLYING)
  end
end

# Empowered Calm Mind
class PokeBattle_Move_609 < PokeBattle_Move_02C
	 include EmpoweredMove

	def pbEffectGeneral(user)
		GameData::Stat.each_battle { |s| user.stages[s.id] = 0 if user.stages[s.id] < 0 }
		@battle.pbDisplay(_INTL("{1}'s negative stat changes were eliminated!", user.pbThis))
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
		user.pbRaiseStatStage(:DEFENSE,1,user)
		user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
		transformType(user,:ROCK)
	end
end

# Empowered Curse
class PokeBattle_Move_612 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			@battle.pbDisplay(_INTL("{1} laid a curse on {2}!",user.pbThis,b.pbThis(true)))
			b.effects[PBEffects::Curse] = true
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
		target.effects[PBEffects::Torment] = true
		@battle.pbDisplay(_INTL("{1} was subjected to torment!",target.pbThis))
		target.pbItemStatusCureCheck
		target.pbLowerStatStage(:ATTACK,1,user)
		target.pbLowerStatStage(:SPECIAL_ATTACK,1,user)
	 end
end

# Empowered Laser Focus
class PokeBattle_Move_615 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		user.effects[PBEffects::EmpoweredLaserFocus] = true
		@battle.pbDisplay(_INTL("{1} concentrated with extreme intensity!",user.pbThis))
		transformType(user,:STEEL)
	end
end

# Empowered Moonlight
class PokeBattle_Move_616 < PokeBattle_Move
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)
		user.pbRecoverHP((user.totalhp/8.0).round)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
		
		user.attack,user.spatk = user.spatk,user.attack
		@battle.pbDisplay(_INTL("{1} switched its Attack and Sp. Atk!",user.pbThis))
		
		user.defense,user.spdef = user.spdef,user.defense
		@battle.pbDisplay(_INTL("{1} switched its Defense and Sp. Def!",user.pbThis))
		user.effects[PBEffects::EmpoweredMoonlight] = !user.effects[PBEffects::EmpoweredMoonlight]
		
		transformType(user,:FAIRY)
	end
end

# Empowered Poison Gas
class PokeBattle_Move_617 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next if !b.pbCanPoison?(user,true,self)
			b.pbPoison(user)
	    end
		transformType(user,:POISON)
	end
end

# Empowered Endure
class PokeBattle_Move_618 < PokeBattle_Move
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		@battle.pbDisplay(_INTL("{1} braced itself!",user.pbThis))
		@battle.pbDisplay(_INTL("It will endure the next 3 hits which would faint it!",user.pbThis))
		user.effects[PBEffects::EmpoweredEndure] = 3
		transformType(user,:NORMAL)
	end
end
	
# Empowered Ignite
class PokeBattle_Move_619 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next if !b.pbCanBurn?(user,true,self)
			b.pbBurn(user)
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
		# TO DO
		super
		transformType(user,:WATER)
	end
end

# Empowered Grassy Terrain
class PokeBattle_Move_621 < PokeBattle_Move_155
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.pbRaiseStatStage(:ATTACK,1,user)
		user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
		transformType(user,:GRASS)
	end
end

# Empowered Electric Terrain
class PokeBattle_Move_622 < PokeBattle_Move_154
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::Charge] = 2
    	@battle.pbDisplay(_INTL("{1} began charging power!",user.pbThis))
		@battle.pbAnimation(:CHARGE, user, [user])
		transformType(user,:ELECTRIC)
	end
end

# Empowered Psychic Terrain
class PokeBattle_Move_623 < PokeBattle_Move_173
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		battler.pbRaiseStatStage(:ACCURACY,3,battler)
		transformType(user,:PSYCHIC)
	end
end

# Empowered Fairy Terrain
class PokeBattle_Move_624 < PokeBattle_Move_156
	include EmpoweredMove
	
	def pbEffectGeneral(user)
		super
		
		@battle.eachSameSideBattler(user) do |b|
			b.pbRaiseStatStage(:ATTACK,1,user)
			b.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
			b.pbRaiseStatStage(:DEFENSE,1,user)
			b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
		end

		transformType(user,:FAIRY)
	end
end

# Empowered Heal Order
class PokeBattle_Move_625 < PokeBattle_Move
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)
		user.pbRecoverHP((user.totalhp/8.0).round)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
		@battle.pbDisplay(_INTL("{1} summons a helper!",user.pbThis))
		@battle.addAvatarBattler(:COMBEE,user.level)
		
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
		target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)

		transformType(user,:POISON)
	end
end

# Empowered Rock Polish
class PokeBattle_Move_627 < PokeBattle_Move_030
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::ExtraTurns] = 2

		@battle.pbDisplay(_INTL("{1} gained two extra moves per turn!",user.pbThis))

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

	def pbMoveFailed?(user,targets)
		if user.pbOpposingSide.effects[PBEffects::EmpoweredEmbargo]
		  @battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end
	
	def pbEffectGeneral(user)
		user.pbOpposingSide.effects[PBEffects::EmpoweredEmbargo] = true
		@battle.pbDisplay(_INTL("{1} and the rest of it's team can no longer use items!",
			user.pbOpposingTeam(true)))

		transformType(user,:DARK)
	end
end

# Empowered Chill
class PokeBattle_Move_630 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		@battle.eachOtherSideBattler(user) do |b|
			next if !b.pbCanFrostbite?(user,true,self)
			b.pbFrostbite(user)
	    end
		transformType(user,:ICE)
	end
end

# Empowered Destiny Bond
class PokeBattle_Move_631 < PokeBattle_Move
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::EmpoweredDestinyBond] = true

		@battle.pbDisplay(_INTL("Attacks against {1} will incur half recoil!",user.pbThis))

		transformType(user,:GHOST)
	end
end

# Empowered Shore Up
class PokeBattle_Move_632 < PokeBattle_Move
	include EmpoweredMove
	
	def healingMove?;       return true; end
	
	def pbEffectGeneral(user)

		# TODO

		user.pbRecoverHP((user.totalhp/8.0).round)
		@battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
		
		transformType(user,:GROUND)
	end
end

# Empowered Loom Over
class PokeBattle_Move_633 < PokeBattle_Move
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
		@battle.pbDisplay(_INTL("{1} sees everything!",user.pbThis))
		@battle.pbDisplay(_INTL("It will take 50% less attack damage for 3 turns!",user.pbThis))
		user.effects[PBEffects::EmpoweredDetect] = 3
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
class PokeBattle_Move_640 < PokeBattle_Move_007
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
  	def pbNumHits(user,targets); return 2;    end
end

# Empowered Slash
class PokeBattle_Move_643 < PokeBattle_Move_0A0
	include EmpoweredMove
end

# Primeval Brick Break
class PokeBattle_Move_644 < PokeBattle_TargetStatDownMove
	include EmpoweredMove

	def ignoresReflect?; return true; end

  	def pbEffectGeneral(user)
		if user.pbOpposingSide.effects[PBEffects::LightScreen]>0
		user.pbOpposingSide.effects[PBEffects::LightScreen] = 0
		@battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",user.pbOpposingTeam))
		end
		if user.pbOpposingSide.effects[PBEffects::Reflect]>0
		user.pbOpposingSide.effects[PBEffects::Reflect] = 0
		@battle.pbDisplay(_INTL("{1}'s Reflect wore off!",user.pbOpposingTeam))
		end
		if user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
		user.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
		@battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",user.pbOpposingTeam))
		end
	end

	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
		if user.pbOpposingSide.effects[PBEffects::LightScreen]>0 ||
		user.pbOpposingSide.effects[PBEffects::Reflect]>0 ||
		user.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
		hitNum = 1   # Wall-breaking anim
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

	def pbCritialOverride(user,target)
		return 1 if target.poisoned?
		return 0
	end
end

# Empowered Solar Beam
class PokeBattle_Move_646 < PokeBattle_Move_0C4
	include EmpoweredMove
end

# Empowered Power Gem
class PokeBattle_Move_647 < PokeBattle_Move_402
	include EmpoweredMove
end