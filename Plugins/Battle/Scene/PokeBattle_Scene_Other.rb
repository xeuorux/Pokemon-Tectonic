# Create the targeting category used for the Info button
GameData::Target.register({
  :id               => :UserOrOther,
  :id_number        => 500,
  :name             => _INTL("User Or Other"),
  :targets_foe      => true,
  :long_range       => true,
  :num_targets      => 1,
})

class PokeBattle_Battle
	def pbGoAfterInfo(battler)
		idxTarget = @scene.pbChooseTarget(battler.index,GameData::Target.get(:UserOrOther),nil,true)
		return if idxTarget<0
		pokemonTargeted = @battlers[idxTarget].pokemon
		pokemonTargeted = @battlers[idxTarget].disguisedAs if @battlers[idxTarget].illusion?
		openSingleDexScreen(pokemonTargeted)
    end
end