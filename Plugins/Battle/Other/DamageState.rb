class PokeBattle_DamageState
	attr_accessor :iceface         # Ice Face ability used
	attr_accessor :displayedDamage
	attr_accessor :forced_critical
	attr_accessor :direDiversion
	attr_accessor :endureBerry
	attr_accessor :partiallyProtected
	attr_accessor :messagesPerHit

	def reset
		@initialHP          = 0
		@typeMod            = Effectiveness::INEFFECTIVE
		@unaffected         = false
		@protected          = false
		@magicCoat          = false
		@magicBounce        = false
		@totalHPLost        = 0
		@fainted            = false
		@messagesPerHit		= true
		resetPerHit
	  end

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
		@partiallyProtected	= false
	end
end