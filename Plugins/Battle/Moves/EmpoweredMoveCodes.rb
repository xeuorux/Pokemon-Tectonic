module EmpoweredMove
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
		@battle.eachSameSideBattler(user) do |b|
			b.pbRecoverHP(b.totalhp / 4)
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
class PokeBattle_Move_602 < PokeBattle_Move_102
	include EmpoweredMove

	def pbEffectGeneral(user)
		super
		user.effects[PBEffects::AquaRing] = true
		@battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
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
			next unless b.pbCanFreeze?(user,true,self)
			b.pbFreeze()
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
	@battle.numBossOnlyTurns += 1
	@battle.eachSameSideBattler(user) do |b|
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