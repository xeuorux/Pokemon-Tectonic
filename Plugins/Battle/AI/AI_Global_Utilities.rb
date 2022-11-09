#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move,user,skill)
	ret = move.pbCalcType(user)
	return ret
end