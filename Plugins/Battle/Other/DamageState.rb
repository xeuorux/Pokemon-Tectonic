class PokeBattle_DamageState
	attr_accessor :iceface         # Ice Face ability used
	attr_accessor :displayedDamage
	attr_accessor :forced_critical
	attr_accessor :direDiversion
	attr_accessor :endureBerry

	def resetPerHit
		@missed        		= false
		@calcDamage    		= 0
		@hpLost       	 	= 0
		@displayedDamage 	= 0
		@critical      		= false
		@substitute    		= false
		@focusBand     		= false
		@focusSash     		= false
		@sturdy        		= false
		@disguise      		= false
		@endured       		= false
		@berryWeakened 		= false
		@iceface       		= false
		@forced_critical	= false
		@direDiversion		= false
		@endureBerry		= false
	end
end