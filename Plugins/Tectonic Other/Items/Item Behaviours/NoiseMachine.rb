def useNoiseMachine()
    $PokemonGlobal.noise_machine_state = 0 if $PokemonGlobal.noise_machine_state.nil?
    commands = []
    commands.push(_INTL("Off"))
    commands.push(_INTL("Harsh Noise"))
    commands.push(_INTL("Soothing Sounds"))
    commands.push(_INTL("Cancel"))
    choice = pbMessage(_INTL("Place the Noise Machine on which setting?"),commands,commands.length)
    case choice
    when 0
        pbMessage(_INTL("The Noise Machine is now off."))
    when 1
        pbMessage(_INTL("The Noise Machine begins playing a high-pitched noise."))
        pbMessage(_INTL("Wild Pokémon are now repelled!"))
    when 2
        pbMessage(_INTL("The Noise Machine begins playing soothing sounds."))
        pbMessage(_INTL("Wild Pokémon are now drawn to you!"))
    else
        return false
    end
    $PokemonGlobal.noise_machine_state = choice
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