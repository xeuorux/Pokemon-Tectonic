module Effectiveness

	module_function

	def hyper_effective?(value)
		return value > NORMAL_EFFECTIVE * 2
	end

	def hyper_effective_type?(attack_type,defend_type1=nil,defend_type2=nil,defend_type3=nil)
		return attack_type > NORMAL_EFFECTIVE * 2 if !defend_type1
		value = calculate(attack_type, target_type1, target_type2, target_type3)
		return hyper_effective?(value)
	end

	def barely_effective?(value)
		return value < NORMAL_EFFECTIVE / 2 && value > INEFFECTIVE
	end

	def barely_effective_type?(attack_type,defend_type1=nil,defend_type2=nil,defend_type3=nil)
		return attack_type < NORMAL_EFFECTIVE / 2 && attack_type > INEFFECTIVE if !defend_type1
		value = calculate(attack_type, target_type1, target_type2, target_type3)
		return barely_effective?(value)
	end

	def modify_boss_effectiveness(effectiveness, user, target)
		return effectiveness
		#return (1.0 + effectiveness) / 2.0 if target.boss? || user.boss?
	end
end