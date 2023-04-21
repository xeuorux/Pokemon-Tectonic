class PokeBattle_DamageState
	attr_accessor :initialHP
	attr_accessor :typeMod         # Type effectiveness
	attr_accessor :unaffected
	attr_accessor :messagesPerHit  # Whether to show a message with each hit
	attr_accessor :protected
	attr_accessor :partiallyProtected # Would have been protected, but attacker is a boss
	attr_accessor :magicCoat
	attr_accessor :magicBounce
	attr_accessor :totalHPLost     # Like hpLost, but cumulative over all hits
	attr_accessor :displayedDamage # The damage to display above the hit battler
	attr_accessor :fainted         # Whether battler was knocked out by the move
  
	attr_accessor :missed          # Whether the move failed the accuracy check
	attr_accessor :calcDamage      # Calculated damage
	attr_accessor :hpLost          # HP lost by opponent, inc. HP lost by a substitute
	attr_accessor :critical        # Critical hit flag
	attr_accessor :forced_critical # The critical hit was forced (e.g. by Merciless)
	attr_accessor :substitute      # Whether a substitute took the damage
	attr_accessor :focusBand       # Focus Band used
	attr_accessor :focusSash       # Focus Sash used
	attr_accessor :sturdy          # Sturdy ability used
	attr_accessor :dangerSense     # Danger Sense ability used
	attr_accessor :disguise        # Disguise ability used
	attr_accessor :endured         # Damage was endured
	attr_accessor :berryWeakened   # Whether a type-resisting berry was used
	attr_accessor :iceface         # Ice Face ability activated
	attr_accessor :direDiversion   # Dire Diversion ability activated
	attr_accessor :endureBerry	   # Cass Berry activated
	attr_accessor :feastWeakened   # Whether a type-resisting feast was used (wont be consumed)
	attr_accessor :fear			   # The hit caused fear in the pokemon

	def initialize; reset; end

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
		@partiallyProtected	= false
		@fear				= false
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
		@dangerSense		= false
		@disguise      		= false
		@endured       		= false
		@berryWeakened 		= nil
		@feastWeakened		= nil
		@iceface       		= false
		@forced_critical	= false
		@direDiversion		= false
		@endureBerry		= false
	end
end