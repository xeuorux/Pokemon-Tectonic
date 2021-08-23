class Game_System
	def se_play(se)
		se = RPG::AudioFile.new(se) if se.is_a?(String)
		if se!=nil && se.name!="" && FileTest.audio_exist?("Audio/SE/"+se.name)
		  vol = se.volume
		  vol *= $PokemonSystem.sevolume/100.0
		  vol = vol.to_i
		  Audio.se_play("Audio/SE/"+se.name,vol,se.pitch || 100)
		end
	end
end