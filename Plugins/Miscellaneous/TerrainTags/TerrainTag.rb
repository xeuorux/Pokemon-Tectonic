module GameData
    class TerrainTag
      attr_reader :slows
      attr_reader :rock_climbable
      attr_reader :push_direction
    
      def initialize(hash)
        @id                     = hash[:id]
        @id_number              = hash[:id_number]
        @real_name              = hash[:id].to_s                || "Unnamed"
        @can_surf               = hash[:can_surf]               || false
        @waterfall              = hash[:waterfall]              || false
        @waterfall_crest        = hash[:waterfall_crest]        || false
        @can_fish               = hash[:can_fish]               || false
        @can_dive               = hash[:can_dive]               || false
        @deep_bush              = hash[:deep_bush]              || false
        @shows_grass_rustle     = hash[:shows_grass_rustle]     || false
        @land_wild_encounters   = hash[:land_wild_encounters]   || false
        @double_wild_encounters = hash[:double_wild_encounters] || false
        @battle_environment     = hash[:battle_environment]
        @ledge                  = hash[:ledge]                  || false
        @ice                    = hash[:ice]                    || false
        @bridge                 = hash[:bridge]                 || false
        @shows_reflections      = hash[:shows_reflections]      || false
        @must_walk              = hash[:must_walk]              || false
        @ignore_passability     = hash[:ignore_passability]     || false
        @slows     			        = hash[:slows]     			        || false
        @rock_climbable		      = hash[:rock_climbable]		      || false
        @push_direction         = hash[:push_direction]
      end
    end
  end