def styleValueMult(level)
  return (2.0 + level.to_f / 50.0)
end

# @return [Integer] the maximum HP of this Pokémon
def calcHPGlobal(base, level, sv, stylish = false)
	return 1 if base == 1   # For Shedinja
	pseudoLevel = 15.0+(level.to_f/2.0)
  stylishMult = stylish ? 2.0 : 1.0
	return (((base.to_f * 2.0 + sv.to_f * styleValueMult(level) * stylishMult) * pseudoLevel / 100.0) + pseudoLevel + 10.0).floor
end

# @return [Integer] the specified stat of this Pokémon (not used for total HP)
def calcStatGlobal(base, level, sv, stylish = false)
	pseudoLevel = 15.0+(level.to_f/2.0)
  stylishMult = stylish ? 2.0 : 1.0
	return ((((base.to_f * 2.0 + sv.to_f * styleValueMult(level) * stylishMult) * pseudoLevel / 100.0) + 5.0)).floor
end