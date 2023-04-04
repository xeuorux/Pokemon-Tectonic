class PokemonGlobalMetadata
	attr_accessor :caughtCountsPerMap
	attr_accessor :expJAR
	attr_accessor :teamHealerCurrentUses
	attr_accessor :teamHealerMaxUses
	attr_accessor :teamHealerUpgrades
	attr_accessor :tarot_amulet_active
	attr_accessor :stored_search
	
	def initialize
    # Movement
    @bicycle              = false
    @surfing              = false
    @diving               = false
    @sliding              = false
    @fishing              = false
    # Player data
    @startTime            = Time.now
    @stepcount            = 0
    @pcItemStorage        = nil
    @phoneNumbers         = []
    @phoneTime            = 0
    @partner              = nil
    @creditsPlayed        = false
    # Pokédex
    numRegions            = pbLoadRegionalDexes.length
    @pokedexDex           = (numRegions==0) ? -1 : 0
    @pokedexIndex         = []
    @pokedexMode          = 0
    for i in 0...numRegions+1     # National Dex isn't a region, but is included
      @pokedexIndex[i]    = 0
    end
    # Day Care
    @daycare              = [[nil,0],[nil,0]]
    @daycareEgg           = false
    @daycareEggSteps      = 0
    # Special battle modes
    @safariState          = nil
    @bugContestState      = nil
    @challenge            = nil
    @lastbattle           = nil
    # Events
    @eventvars            = {}
    # Affecting the map
    @bridge               = 0
    @repel                = 0
    @flashused            = false
    @encounter_version    = 0
    # Map transfers
    @healingSpot          = nil
    @escapePoint          = []
    @pokecenterMapId      = -1
    @pokecenterX          = -1
    @pokecenterY          = -1
    @pokecenterDirection  = -1
    # Movement history
    @visitedMaps          = []
    @mapTrail             = []
    # Counters
    @happinessSteps       = 0
    @pokerusTime          = nil
    # Save file
    @safesave             = false
    @expJAR				  = 0
    @caughtCountsPerMap	  = {}
    @teamHealerUpgrades   = 0
    @teamHealerMaxUses	  = 1
    @teamHealerCurrentUses= 1
    @tarot_amulet_active  = false
    @stored_search		  = nil
  end
end