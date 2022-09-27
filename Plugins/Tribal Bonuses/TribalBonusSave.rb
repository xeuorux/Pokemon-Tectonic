SaveData.register(:tribal_bonuses) do
	ensure_class :TribalBonus
	save_value { $Tribal_Bonuses }
	load_value { |value| $Tribal_Bonuses = value }
	new_game_value { TribalBonus.new }
end