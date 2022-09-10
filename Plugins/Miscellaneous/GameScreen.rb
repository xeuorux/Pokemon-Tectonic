class Game_Screen
    def start_shake(power, speed, duration)
        return if $PokemonSystem.screenshake != 0
        @shake_power    = power
        @shake_speed    = speed
        @shake_duration = duration
    end
end