class Pokemon
	TRAITS =
	[
	"Persistent",
	"Patient",
	"Rogueish",
	"Inviting",
	"Shy",
	"Friendly",
	"Acquisitive",
	"Sweettooth",
	"Alluring",
	"Collector",
	"Resilient",
	"Boastful",
	"Partier",
	"Studious",
	"Ambitious",
	"Adorable",
	"Territorial",
	"Speedy",
	"Cowardly",
	"Greedy",
	"Eager",
	"Selfless",
	"Lucky"
	]

	def trait1
		return nil if happiness < 50
		return TRAITS[@personalID % TRAITS.length]
	end
	  
	def trait2
	    return nil if happiness < 150
		gen = (@personalID/TRAITS.length).floor % TRAITS.length
		gen += (@personalID % (TRAITS.length-1)) if TRAITS[gen] == trait1
		return TRAITS[gen]
	end
	  
	def trait3
		return nil if happiness < 220
		gen = (@personalID/(TRAITS.length * TRAITS.length)).floor % TRAITS.length
		gen += (@personalID % (TRAITS.length-1)) if TRAITS[gen] == trait1
		gen += (@personalID % (TRAITS.length-2)) if TRAITS[gen] == trait2
		return TRAITS[gen]
	end
end

class PokemonSummary_Scene
	  def drawPageTwo
		overlay = @sprites["overlay"].bitmap
		memo = ""
		
		# Traits
		if !@pokemon.shadowPokemon? || @pokemon.heartStage>3
		  memo += _INTL("<c3=F83820,E09890>Traits:<c3=404040,B0B0B0>\n")
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}\n",@pokemon.trait1 || "Unknown",@pokemon.trait1 ? "FF" : "77")
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}\n",@pokemon.trait2 || "Unknown",@pokemon.trait2 ? "FF" : "77")
		  memo += _INTL("<c3=404040{2},B0B0B0>{1}\n",@pokemon.trait3 || "Unknown",@pokemon.trait3 ? "FF" : "77")
		  memo += _INTL("\n")
		end

		# Write date received
		if @pokemon.timeReceived
		  date  = @pokemon.timeReceived.day
		  month = pbGetMonthName(@pokemon.timeReceived.mon)
		  year  = @pokemon.timeReceived.year
		  memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
		end
		# Write map name Pokémon was received on
		mapname = pbGetMapNameFromId(@pokemon.obtain_map)
		mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
		mapname = _INTL("Faraway place") if !mapname || mapname==""
		memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
		# Write how Pokémon was obtained
		mettext = [_INTL("Met at Lv. {1}.",@pokemon.obtain_level),
				   _INTL("Egg received."),
				   _INTL("Traded at Lv. {1}.",@pokemon.obtain_level),
				   "",
				   _INTL("Had a fateful encounter at Lv. {1}.",@pokemon.obtain_level)
				  ][@pokemon.obtain_method]
		memo += sprintf("<c3=404040,B0B0B0>%s\n",mettext) if mettext && mettext!=""
		
		# If Pokémon was hatched, write when and where it hatched
		if @pokemon.obtain_method == 1
		  if @pokemon.timeEggHatched
			date  = @pokemon.timeEggHatched.day
			month = pbGetMonthName(@pokemon.timeEggHatched.mon)
			year  = @pokemon.timeEggHatched.year
			memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n",date,month,year)
		  end
		  mapname = pbGetMapNameFromId(@pokemon.hatched_map)
		  mapname = _INTL("Faraway place") if !mapname || mapname==""
		  memo += sprintf("<c3=F83820,E09890>%s\n",mapname)
		  memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
		else
		  memo += "\n"   # Empty line
		end
		
		# Write all text
		drawFormattedTextEx(overlay,232,82,268,memo)
	  end
end