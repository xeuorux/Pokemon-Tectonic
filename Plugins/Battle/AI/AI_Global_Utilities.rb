#=============================================================================
# Get approximate properties for a battler
#=============================================================================
def pbRoughType(move,user)
	ret = move.pbCalcType(user)
	return ret
end