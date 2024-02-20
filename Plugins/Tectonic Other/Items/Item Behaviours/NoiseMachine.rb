def useNoiseMachine()
    $PokemonGlobal.noise_machine_state = 0 if $PokemonGlobal.noise_machine_state.nil?
	$PokemonGlobal.noise_machine_state += 1
    $PokemonGlobal.noise_machine_state = 0 if $PokemonGlobal.noise_machine_state > 2
    case $PokemonGlobal.noise_machine_state
    when 0
        pbMessage(_INTL("The Noise Machine is now off."))
    when 1
        pbMessage(_INTL("The Noise Machine begins playing a high-pitched noise."))
        pbMessage(_INTL("Wild Pokémon are now repelled!"))
    when 2
        pbMessage(_INTL("The Noise Machine begins playing soothing sounds."))
        pbMessage(_INTL("Wild Pokémon are now drawn to you!"))
    end
	return true
end

ItemHandlers::UseFromBag.add(:NOISEMACHINE,proc { |item|
    useNoiseMachine
	next 1
})

ItemHandlers::ConfirmUseInField.add(:NOISEMACHINE,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:NOISEMACHINE,proc { |item|
	next useNoiseMachine
})