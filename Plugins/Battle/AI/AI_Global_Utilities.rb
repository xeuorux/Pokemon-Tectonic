#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move,user,skill)
	ret = move.pbCalcType(user)
	return ret
end

def pbRoughStatCalc(atkStat,atkStage)
	stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
	stageDiv = PokeBattle_Battler::STAGE_DIVISORS
	return (atkStat.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
  end

def pbRoughStat(battler,stat,skill=100)
	castBattler = (battler.effects[PBEffects::Illusion] && battler.pbOwnedByPlayer?) ? battler.effects[PBEffects::Illusion] : battler
	return battler.pbSpeed if stat==:SPEED && !battler.effects[PBEffects::Illusion]
	
	stage = battler.stages[stat]+6
	value = 0
	case stat
	when :ATTACK          then value = castBattler.attack
	when :DEFENSE         then value = castBattler.defense
	when :SPECIAL_ATTACK  then value = castBattler.spatk
	when :SPECIAL_DEFENSE then value = castBattler.spdef
	when :SPEED           then value = castBattler.speed
	end
	return pbRoughStatCalc(value,stage)
end