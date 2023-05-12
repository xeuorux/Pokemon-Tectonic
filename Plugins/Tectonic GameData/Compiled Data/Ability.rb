module Compiler
    module_function

    #=============================================================================
    # Compile ability data
    #=============================================================================
    def compile_abilities
        GameData::Ability::DATA.clear
        ability_names        = []
        ability_descriptions = []
        idBase = 0
        ["PBS/abilities.txt", "PBS/abilities_new.txt", "PBS/abilities_primeval.txt",
         "PBS/abilities_cut.txt",].each do |path|
            idNumber = idBase
            cutAbility = path == "PBS/abilities_cut.txt"
            primevalAbility = path == "PBS/abilities_primeval.txt"
            newAbility = ["PBS/abilities_new.txt", "PBS/abilities_primeval.txt"].include?(path)
            pbCompilerEachPreppedLine(path) do |line, line_no|
                idNumber += 1
                line = pbGetCsvRecord(line, line_no, [0, "vnss"])
                ability_number = idNumber
                ability_symbol = line[1].to_sym
                if GameData::Ability::DATA[ability_number]
                    raise _INTL("Ability ID number '{1}' is used twice.\r\n{2}", ability_number,
FileLineData.linereport)
                elsif GameData::Ability::DATA[ability_symbol]
                    raise _INTL("Ability ID '{1}' is used twice.\r\n{2}", ability_symbol, FileLineData.linereport)
                end
                # Construct ability hash
                ability_hash = {
                  :id           => ability_symbol,
                  :id_number    => ability_number,
                  :name         => line[2],
                  :description  => line[3],
                  :cut          => cutAbility,
                  :tectonic_new => newAbility,
                  :primeval     => primevalAbility,
                }
                # Add ability's data to records
                GameData::Ability.register(ability_hash)
                ability_names[ability_number]        = ability_hash[:name]
                ability_descriptions[ability_number] = ability_hash[:description]
            end
            idBase += 1000
        end
        # Save all data
        GameData::Ability.save
        MessageTypes.setMessages(MessageTypes::Abilities, ability_names)
        MessageTypes.setMessages(MessageTypes::AbilityDescs, ability_descriptions)
        Graphics.update
    end

    #=============================================================================
    # Save ability data to PBS file
    #=============================================================================
    def write_abilities
        File.open("PBS/abilities.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each do |a|
                next if a.cut || a.primeval || a.tectonic_new
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_new.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each do |a|
                next unless a.tectonic_new && !a.primeval
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_cut.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each do |a|
                next unless a.cut
                write_ability(f, a)
            end
        end
        File.open("PBS/abilities_primeval.txt", "wb") do |f|
            add_PBS_header_to_file(f)
            GameData::Ability.each do |a|
                next unless a.primeval
                write_ability(f, a)
            end
        end
        Graphics.update
    end

    def write_ability(f, a)
        f.write(format("%d,%s,%s,%s\r\n",
          a.id_number,
          csvQuote(a.id.to_s),
          csvQuote(a.real_name),
          csvQuoteAlways(a.real_description)
        ))
    end
end

module GameData
    class Ability
        SUN_ABILITIES = %i[DROUGHT INNERLIGHT CHLOROPHYLL SOLARPOWER LEAFGUARD FLOWERGIFT MIDNIGHTSUN
                           HARVEST SUNCHASER HEATSAVOR BLINDINGLIGHT SOLARCELL SUSTAINABLE FINESUGAR REFRESHMENTS
                           HEATVEIL OXYGENATION DESOLATELAND]

        RAIN_ABILITIES = %i[DRIZZLE STORMBRINGER SWIFTSWIM RAINDISH HYDRATION TIDALFORCE STORMFRONT
                            DREARYCLOUDS DRYSKIN RAINPRISM STRIKETWICE AQUAPROPULSION OVERWHELM ARCCONDUCTOR
                            PRIMORDIALSEA]

        SAND_ABILITIES = %i[SANDSTREAM SANDBURST SANDRUSH SANDSHROUD DESERTSPIRIT SANDDRILLING SANDDEMON
                            IRONSTORM SANDSTRENGTH SANDPOWER CRAGTERROR DESERTSCAVENGER]

        HAIL_ABILITIES = %i[SNOWWARNING FROSTSCATTER ICEBODY SNOWSHROUD BLIZZBOXER SLUSHRUSH ICEFACE
                            BITTERCOLD ECTOPARTICLES ICEQUEEN ETERNALWINTER TAIGATRECKER ICEMIRROR WINTERINSULATION
                            POLARHUNTER WINTERWISDOM]

        ECLIPSE_ABILITIES = %i[HARBINGER SUNEATER APPREHENSIVE TOTALGRASP EXTREMOPHILE WORLDQUAKE RESONANCE
                               DISTRESSING SHAKYCODE MYTHICSCALES SHATTERING STARSALIGN WARPINGEFFECT TOLLDANGER
                               DRAMATICLIGHTING CALAMITY ANARCHIC MENDINGTONES PEARLSEEKER HEAVENSCROWN]

        MOONGLOW_ABILITIES = %i[MOONGAZE LUNARLOYALTY LUNATIC MYSTICTAP ASTRALBODY NIGHTLIGHT NIGHTLIFE
                                MALICIOUSGLOW NIGHTVISION MOONLIGHTER LUNARCLEANSING NIGHTSTALKER WEREWOLF
                                FULLMOONBLADE MOONBUBBLE MIDNIGHTTOIL MOONBASKING NIGHTOWL]

        GENERAL_WEATHER_ABILITIES = %i[STOUT TERRITORIAL NESTING]

        MULTI_ITEM_ABILITIES = %i[BERRYBUNCH HERBALIST FASHIONABLE ALLTHATGLITTERS STICKYFINGERS KLUMSYKINESIS]

        FLINCH_IMMUNITY_ABILITIES = %i[INNERFOCUS JUGGERNAUT MENTALBLOCK]

        UNCOPYABLE_ABILITIES = %i[TRACE RECEIVER POWEROFALCHEMY OVERACTING]

        HAZARD_IMMUNITY_ABILITIES = %i[AQUASNEAK NINJUTSU DANGERSENSE HYPERSPEED]

        attr_reader :signature_of, :cut, :primeval, :tectonic_new
        attr_reader :id
        attr_reader :id_number
        attr_reader :real_name
        attr_reader :real_description

        DATA = {}
        DATA_FILENAME = "abilities.dat"

        extend ClassMethods
        include InstanceMethods

        def initialize(hash)
            @id               = hash[:id]
            @id_number        = hash[:id_number]    || -1
            @real_name        = hash[:name]         || "Unnamed"
            @real_description = hash[:description]  || "???"
            @cut              = hash[:cut]          || false
            @primeval         = hash[:primeval]     || false
            @tectonic_new     = hash[:tectonic_new] || false
        end

        # @return [String] the translated name of this ability
        def name
            return pbGetMessage(MessageTypes::Abilities, @id_number)
        end

        # @return [String] the translated description of this ability
        def description
            return pbGetMessage(MessageTypes::AbilityDescs, @id_number)
        end

        # The highest evolution of a line
        def signature_of=(val)
            @signature_of = val
        end
  
        def is_signature?()
            return !@signature_of.nil?
        end

        def legal?(isBoss = false)
            return false if @cut
            return false if @primeval && !isBoss
            return true
        end
    end
end
