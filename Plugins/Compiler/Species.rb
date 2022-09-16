module GameData
    class Species
        attr_reader :notes

        def self.schema(compiling_forms = false)
            ret = {
              "FormName"          => [0, "q"],
              "Kind"              => [0, "s"],
              "Pokedex"           => [0, "q"],
              "Type1"             => [0, "e", :Type],
              "Type2"             => [0, "e", :Type],
              "BaseStats"         => [0, "vvvvvv"],
              "EffortPoints"      => [0, "uuuuuu"],
              "BaseEXP"           => [0, "v"],
              "Rareness"          => [0, "u"],
              "Happiness"         => [0, "u"],
              "Moves"             => [0, "*ue", nil, :Move],
              "TutorMoves"        => [0, "*e", :Move],
              "EggMoves"          => [0, "*e", :Move],
              "Abilities"         => [0, "*e", :Ability],
              "HiddenAbility"     => [0, "*e", :Ability],
              "WildItemCommon"    => [0, "e", :Item],
              "WildItemUncommon"  => [0, "e", :Item],
              "WildItemRare"      => [0, "e", :Item],
              "Compatibility"     => [0, "*e", :EggGroup],
              "StepsToHatch"      => [0, "v"],
              "Height"            => [0, "f"],
              "Weight"            => [0, "f"],
              "Color"             => [0, "e", :BodyColor],
              "Shape"             => [0, "y", :BodyShape],
              "Habitat"           => [0, "e", :Habitat],
              "Generation"        => [0, "i"],
              "BattlerPlayerX"    => [0, "i"],
              "BattlerPlayerY"    => [0, "i"],
              "BattlerEnemyX"     => [0, "i"],
              "BattlerEnemyY"     => [0, "i"],
              "BattlerAltitude"   => [0, "i"],
              "BattlerShadowX"    => [0, "i"],
              "BattlerShadowSize" => [0, "u"],
              "Notes"             => [0, "q"]
            }
            if compiling_forms
              ret["PokedexForm"]  = [0, "u"]
              ret["Evolutions"]   = [0, "*ees", :Species, :Evolution, nil]
              ret["MegaStone"]    = [0, "e", :Item]
              ret["MegaMove"]     = [0, "e", :Move]
              ret["UnmegaForm"]   = [0, "u"]
              ret["MegaMessage"]  = [0, "u"]
            else
              ret["InternalName"] = [0, "n"]
              ret["Name"]         = [0, "s"]
              ret["GrowthRate"]   = [0, "e", :GrowthRate]
              ret["GenderRate"]   = [0, "e", :GenderRatio]
              ret["Incense"]      = [0, "e", :Item]
              ret["Evolutions"]   = [0, "*ses", nil, :Evolution, nil]
            end
            return ret
        end

        def initialize(hash)
          @id                    = hash[:id]
          @id_number             = hash[:id_number]             || -1
          @species               = hash[:species]               || @id
          @form                  = hash[:form]                  || 0
          @real_name             = hash[:name]                  || "Unnamed"
          @real_form_name        = hash[:form_name]
          @real_category         = hash[:category]              || "???"
          @real_pokedex_entry    = hash[:pokedex_entry]         || "???"
          @pokedex_form          = hash[:pokedex_form]          || @form
          @type1                 = hash[:type1]                 || :NORMAL
          @type2                 = hash[:type2]                 || @type1
          @base_stats            = hash[:base_stats]            || {}
          @evs                   = hash[:evs]                   || {}
          GameData::Stat.each_main do |s|
            @base_stats[s.id] = 1 if !@base_stats[s.id] || @base_stats[s.id] <= 0
            @evs[s.id]        = 0 if !@evs[s.id] || @evs[s.id] < 0
          end
          @base_exp              = hash[:base_exp]              || 100
          @growth_rate           = hash[:growth_rate]           || :Medium
          @gender_ratio          = hash[:gender_ratio]          || :Female50Percent
          @catch_rate            = hash[:catch_rate]            || 255
          @happiness             = hash[:happiness]             || 70
          @moves                 = hash[:moves]                 || []
          @tutor_moves           = hash[:tutor_moves]           || []
          @egg_moves             = hash[:egg_moves]             || []
          @abilities             = hash[:abilities]             || []
          @hidden_abilities      = hash[:hidden_abilities]      || []
          @wild_item_common      = hash[:wild_item_common]
          @wild_item_uncommon    = hash[:wild_item_uncommon]
          @wild_item_rare        = hash[:wild_item_rare]
          @egg_groups            = hash[:egg_groups]            || [:Undiscovered]
          @hatch_steps           = hash[:hatch_steps]           || 1
          @incense               = hash[:incense]
          @evolutions            = hash[:evolutions]            || []
          @height                = hash[:height]                || 1
          @weight                = hash[:weight]                || 1
          @color                 = hash[:color]                 || :Red
          @shape                 = hash[:shape]                 || :Head
          @habitat               = hash[:habitat]               || :None
          @generation            = hash[:generation]            || 0
          @mega_stone            = hash[:mega_stone]
          @mega_move             = hash[:mega_move]
          @unmega_form           = hash[:unmega_form]           || 0
          @mega_message          = hash[:mega_message]          || 0
          @back_sprite_x         = hash[:back_sprite_x]         || 0
          @back_sprite_y         = hash[:back_sprite_y]         || 0
          @front_sprite_x        = hash[:front_sprite_x]        || 0
          @front_sprite_y        = hash[:front_sprite_y]        || 0
          @front_sprite_altitude = hash[:front_sprite_altitude] || 0
          @shadow_x              = hash[:shadow_x]              || 0
          @shadow_size           = hash[:shadow_size]           || 2
          @notes                 = hash[:notes]                 || ""
      end
  
      def notes
          return @notes
      end

      def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
        species = pkmn.species if !species
        species = GameData::Species.get(species).species   # Just to be sure it's a symbol
        return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
        if back
          ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
        else
          ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
        end
        
        if ret && pkmn.boss?
          filename = 'Graphics/Pokemon/Avatars/' + species.to_s
          filename += '_' + pkmn.form.to_s if pkmn.form != 0
          filename += '_back' if back
          ret = AnimatedBitmap.new(filename)
        elsif !pkmn.egg? && pkmn.shiny? && pkmn.shiny_variant # EXPERIMENTAL COLOR CHANGING
          ret = shiftSpeciesBitmapHue(ret,species)
        end
        
        alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
        if ret && !pkmn.boss? && alter_bitmap_function
          new_ret = ret.copy
          ret.dispose
          new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
          ret = new_ret
        end
        return ret
      end
  end
end