class PokeBattle_Battle
	def chooseDexTarget(battler)
		idxTarget = @scene.pbChooseTarget(battler.index,GameData::Target.get(:UserOrOther),nil,true)
		return if idxTarget<0
		pokemonTargeted = @battlers[idxTarget].pokemon
		pokemonTargeted = @battlers[idxTarget].disguisedAs if @battlers[idxTarget].illusion?
		openSingleDexScreen(pokemonTargeted)
    end
end