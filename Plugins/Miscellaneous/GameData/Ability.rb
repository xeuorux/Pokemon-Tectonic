module GameData
    class Ability
        SUN_ABILITIES = %i[DROUGHT INNERLIGHT CHLOROPHYLL SOLARPOWER LEAFGUARD FLOWERGIFT MIDNIGHTSUN
                        HARVEST SUNCHASER HEATSAVOR BLINDINGLIGHT SOLARCELL ROAST FINESUGAR REFRESHMENTS
                        HEATVEIL
        ]

        RAIN_ABILITIES = %i[DRIZZLE STORMBRINGER SWIFTSWIM RAINDISH HYDRATION TIDALFORCE STORMFRONTRAINPRISM
                          DREARYCLOUDS DRYSKIN RAINPRISM
        ]

        SAND_ABILITIES = %i[SANDSTREAM SANDBURST SANDFORCE SANDRUSH SANDSHROUD DESERTSPIRIT
                          SHRAPNELSTORM HARSHHUNTER
        ]

        HAIL_ABILITIES = %i[SNOWWARNING FROSTSCATTER ICEBODY SNOWSHROUD BLIZZBOXER SLUSHRUSH ICEFACE
                          BITTERCOLD ECTOPARTICLES
        ]

        attr_reader :signature_of

        # The highest evolution of a line
        def signature_of=(val)
          @signature_of = val
        end

        def is_signature?()
          return !@signature_of.nil?
        end

        def is_primeval?
          return @id.to_s[/PRIMEVAL/]
        end
    end
  end