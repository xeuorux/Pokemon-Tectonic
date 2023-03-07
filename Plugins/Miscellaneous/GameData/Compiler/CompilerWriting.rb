module Compiler
	module_function

  #=============================================================================
  # Save Pokémon data to PBS file
  #=============================================================================
  def write_pokemon
    File.open("PBS/pokemon.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form != 0
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", species.id_number))
        f.write(sprintf("Name = %s\r\n", species.real_name))
        f.write(sprintf("InternalName = %s\r\n", species.species))
        f.write(sprintf("Notes = %s\r\n", species.notes)) if !species.notes.nil? && !species.notes.blank?
        f.write(sprintf("Type1 = %s\r\n", species.type1))
        f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        stats_array = []
        evs_array = []
		    total = 0
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
		      total += species.base_stats[s.id]
        end
		    f.write(sprintf("# HP, Attack, Defense, Speed, Sp. Atk, Sp. Def\r\n", total))
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(",")))
		    f.write(sprintf("# Total = %s\r\n", total))
        f.write(sprintf("GenderRate = %s\r\n", species.gender_ratio))
        f.write(sprintf("GrowthRate = %s\r\n", species.growth_rate))
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp))
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(",")))
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate))
        f.write(sprintf("Happiness = %d\r\n", species.happiness))
        if species.abilities.length > 0
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        if species.tribes(true).length > 0
          f.write(sprintf("Tribes = %s\r\n", species.tribes(true).join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps))
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0))
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0))
        f.write(sprintf("Color = %s\r\n", species.color))
        f.write(sprintf("Shape = %s\r\n", species.shape))
        f.write(sprintf("Habitat = %s\r\n", species.habitat)) if species.habitat != :None
        f.write(sprintf("Kind = %s\r\n", species.real_category))
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != 0
        f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
        f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
        f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x))
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y))
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x))
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y))
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != 0
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x))
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size))
        if species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
        f.write(sprintf("Incense = %s\r\n", species.incense)) if species.incense
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save Pokémon forms data to PBS file
  #=============================================================================
  def write_pokemon_forms
    File.open("PBS/pokemonforms.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Species.each do |species|
        next if species.form == 0
        base_species = GameData::Species.get(species.species)
        pbSetWindowText(_INTL("Writing species {1}...", species.id_number))
        Graphics.update if species.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s,%d]\r\n", species.species, species.form))
        f.write(sprintf("FormName = %s\r\n", species.real_form_name)) if species.real_form_name && !species.real_form_name.empty?
        f.write(sprintf("Notes = %s\r\n", species.notes)) if !species.notes.nil? && !species.notes.blank?
        f.write(sprintf("PokedexForm = %d\r\n", species.pokedex_form)) if species.pokedex_form != species.form
        f.write(sprintf("MegaStone = %s\r\n", species.mega_stone)) if species.mega_stone
        f.write(sprintf("MegaMove = %s\r\n", species.mega_move)) if species.mega_move
        f.write(sprintf("UnmegaForm = %d\r\n", species.unmega_form)) if species.unmega_form != 0
        f.write(sprintf("MegaMessage = %d\r\n", species.mega_message)) if species.mega_message != 0
        if species.type1 != base_species.type1 || species.type2 != base_species.type2
          f.write(sprintf("Type1 = %s\r\n", species.type1))
          f.write(sprintf("Type2 = %s\r\n", species.type2)) if species.type2 != species.type1
        end
        stats_array = []
        evs_array = []
        GameData::Stat.each_main do |s|
          next if s.pbs_order < 0
          stats_array[s.pbs_order] = species.base_stats[s.id]
          evs_array[s.pbs_order] = species.evs[s.id]
        end
        f.write(sprintf("BaseStats = %s\r\n", stats_array.join(","))) if species.base_stats != base_species.base_stats
        f.write(sprintf("BaseEXP = %d\r\n", species.base_exp)) if species.base_exp != base_species.base_exp
        f.write(sprintf("EffortPoints = %s\r\n", evs_array.join(","))) if species.evs != base_species.evs
        f.write(sprintf("Rareness = %d\r\n", species.catch_rate)) if species.catch_rate != base_species.catch_rate
        f.write(sprintf("Happiness = %d\r\n", species.happiness)) if species.happiness != base_species.happiness
        if species.abilities.length > 0 && species.abilities != base_species.abilities
          f.write(sprintf("Abilities = %s\r\n", species.abilities.join(",")))
        end
        if species.hidden_abilities.length > 0 && species.hidden_abilities != base_species.hidden_abilities
          f.write(sprintf("HiddenAbility = %s\r\n", species.hidden_abilities.join(",")))
        end
        if species.moves.length > 0 && species.moves != base_species.moves
          f.write(sprintf("Moves = %s\r\n", species.moves.join(",")))
        end
        if species.tutor_moves.length > 0 && species.tutor_moves != base_species.tutor_moves
          f.write(sprintf("TutorMoves = %s\r\n", species.tutor_moves.join(",")))
        end
        if species.egg_moves.length > 0 && species.egg_moves != base_species.egg_moves
          f.write(sprintf("EggMoves = %s\r\n", species.egg_moves.join(",")))
        end
        if species.egg_groups.length > 0 && species.egg_groups != base_species.egg_groups
          f.write(sprintf("Compatibility = %s\r\n", species.egg_groups.join(",")))
        end
        f.write(sprintf("StepsToHatch = %d\r\n", species.hatch_steps)) if species.hatch_steps != base_species.hatch_steps
        f.write(sprintf("Height = %.1f\r\n", species.height / 10.0)) if species.height != base_species.height
        f.write(sprintf("Weight = %.1f\r\n", species.weight / 10.0)) if species.weight != base_species.weight
        f.write(sprintf("Color = %s\r\n", species.color)) if species.color != base_species.color
        f.write(sprintf("Shape = %s\r\n", species.shape)) if species.shape != base_species.shape
        if species.habitat != :None && species.habitat != base_species.habitat
          f.write(sprintf("Habitat = %s\r\n", species.habitat))
        end
        f.write(sprintf("Kind = %s\r\n", species.real_category)) if species.real_category != base_species.real_category
        f.write(sprintf("Pokedex = %s\r\n", species.real_pokedex_entry)) if species.real_pokedex_entry != base_species.real_pokedex_entry
        f.write(sprintf("Generation = %d\r\n", species.generation)) if species.generation != base_species.generation
        if species.wild_item_common != base_species.wild_item_common ||
           species.wild_item_uncommon != base_species.wild_item_uncommon ||
           species.wild_item_rare != base_species.wild_item_rare
          f.write(sprintf("WildItemCommon = %s\r\n", species.wild_item_common)) if species.wild_item_common
          f.write(sprintf("WildItemUncommon = %s\r\n", species.wild_item_uncommon)) if species.wild_item_uncommon
          f.write(sprintf("WildItemRare = %s\r\n", species.wild_item_rare)) if species.wild_item_rare
        end
        f.write(sprintf("BattlerPlayerX = %d\r\n", species.back_sprite_x)) if species.back_sprite_x != base_species.back_sprite_x
        f.write(sprintf("BattlerPlayerY = %d\r\n", species.back_sprite_y)) if species.back_sprite_y != base_species.back_sprite_y
        f.write(sprintf("BattlerEnemyX = %d\r\n", species.front_sprite_x)) if species.front_sprite_x != base_species.front_sprite_x
        f.write(sprintf("BattlerEnemyY = %d\r\n", species.front_sprite_y)) if species.front_sprite_y != base_species.front_sprite_y
        f.write(sprintf("BattlerAltitude = %d\r\n", species.front_sprite_altitude)) if species.front_sprite_altitude != base_species.front_sprite_altitude
        f.write(sprintf("BattlerShadowX = %d\r\n", species.shadow_x)) if species.shadow_x != base_species.shadow_x
        f.write(sprintf("BattlerShadowSize = %d\r\n", species.shadow_size)) if species.shadow_size != base_species.shadow_size
        if species.evolutions != base_species.evolutions && species.evolutions.any? { |evo| !evo[3] }
          f.write("Evolutions = ")
          need_comma = false
          species.evolutions.each do |evo|
            next if evo[3]   # Skip prevolution entries
            f.write(",") if need_comma
            need_comma = true
            evo_type_data = GameData::Evolution.get(evo[1])
            param_type = evo_type_data.parameter
            f.write(sprintf("%s,%s,", evo[0], evo_type_data.id.to_s))
            if !param_type.nil?
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                f.write(getConstantName(param_type, evo[2]))
              else
                f.write(evo[2].to_s)
              end
            end
          end
          f.write("\r\n")
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  def write_moves
    File.open("PBS/moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        break if m.id_number >= 2000
        write_move(f,m)
      end
    }
    File.open("PBS/other_moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next if m.id_number < 2000
        write_move(f,m)
      end
    }
    Graphics.update
  end

  def write_move(f, m)
    f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s,%s\r\n",
        m.id_number,
        csvQuote(m.id.to_s),
        csvQuote(m.real_name),
        csvQuote(m.function_code),
        m.base_damage,
        m.type.to_s,
        ["Physical", "Special", "Status"][m.category],
        m.accuracy,
        m.total_pp,
        m.effect_chance,
        m.target,
        m.priority,
        csvQuote(m.flags),
        csvQuoteAlways(m.real_description),
        m.animation_move.nil? ? "" : m.animation_move.to_s
      ))
  end
  
  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types
    File.open("PBS/trainertypes.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      GameData::TrainerType.each do |t|
        policiesString = ""
        if t.policies
          policiesString += "["
          t.policies.each_with_index do |policy_symbol,index|
            policiesString += policy_symbol.to_s
            policiesString += "," if index < t.policies.length - 1
          end
          policiesString += "]"
        end
	  
        f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s\r\n",
        t.id_number,
        csvQuote(t.id.to_s),
        csvQuote(t.real_name),
        t.base_money,
        csvQuote(t.battle_BGM),
        csvQuote(t.victory_ME),
        csvQuote(t.intro_ME),
        ["Male", "Female", "Mixed", "Wild"][t.gender],
        (t.skill_level == t.base_money) ? "" : t.skill_level.to_s,
        csvQuote(t.skill_code),
        policiesString
        ))
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_trainers
    File.open("PBS/trainers.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Trainer.each do |trainer|
        pbSetWindowText(_INTL("Writing trainer {1}...", trainer.id_number))
        Graphics.update if trainer.id_number % 50 == 0
        f.write("\#-------------------------------\r\n")
        if trainer.version > 0
          f.write(sprintf("[%s,%s,%d]\r\n", trainer.trainer_type, trainer.real_name, trainer.version))
        else
          f.write(sprintf("[%s,%s]\r\n", trainer.trainer_type, trainer.real_name))
        end
        if trainer.extendsVersion >= 0
          if !trainer.extendsClass.nil? && !trainer.extendsName.nil?
            f.write(sprintf("Extends = %s,%s,%s\r\n", trainer.extendsClass.to_s, trainer.extendsName.to_s, trainer.extendsVersion.to_s))
          else
            f.write(sprintf("ExtendsVersion = %s\r\n", trainer.extendsVersion.to_s))
          end
        end
        if !trainer.nameForHashing.nil?
          f.write(sprintf("NameForHashing = %s\r\n", trainer.nameForHashing.to_s))
        end
		    if trainer.policies && trainer.policies.length > 0
          policiesString = ""
          trainer.policies.each_with_index do |policy_symbol,index|
            policiesString += policy_symbol.to_s
            policiesString += "," if index < trainer.policies.length - 1
          end
          f.write(sprintf("Policies = %s\r\n", policiesString))
        end
        f.write(sprintf("Items = %s\r\n", trainer.items.join(","))) if trainer.items.length > 0
        trainer.pokemon.each do |pkmn|
          f.write(sprintf("Pokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          writePartyMember(f,pkmn)
        end
        trainer.removedPokemon.each do |pkmn|
          f.write(sprintf("RemovePokemon = %s,%d\r\n", pkmn[:species], pkmn[:level]))
          writePartyMember(f,pkmn)
        end
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  def writePartyMember(f,pkmn)
    f.write(sprintf("    Position = %s\r\n", pkmn[:assigned_position])) if !pkmn[:assigned_position].nil?
    f.write(sprintf("    Name = %s\r\n", pkmn[:name])) if pkmn[:name] && !pkmn[:name].empty?
    f.write(sprintf("    Form = %d\r\n", pkmn[:form])) if pkmn[:form] && pkmn[:form] > 0
    f.write(sprintf("    Gender = %s\r\n", (pkmn[:gender] == 1) ? "female" : "male")) if pkmn[:gender]
    f.write("    Shiny = yes\r\n") if pkmn[:shininess]
    f.write("    Shadow = yes\r\n") if pkmn[:shadowness]
    f.write(sprintf("    Moves = %s\r\n", pkmn[:moves].join(","))) if pkmn[:moves] && pkmn[:moves].length > 0
    f.write(sprintf("    Ability = %s\r\n", pkmn[:ability])) if pkmn[:ability]
    if pkmn[:ability_index]
      form = pkmn[:form] || 0
      sp_data = GameData::Species.get_species_form(pkmn[:species],form)
      abilityID = sp_data.abilities[pkmn[:ability_index]] || sp_data.abilities[0]
      abilityName = GameData::Ability.get(abilityID).real_name
      f.write(sprintf("    AbilityIndex = %d # %s\r\n", pkmn[:ability_index], abilityName))
    end
    f.write(sprintf("    Item = %s\r\n", pkmn[:item])) if pkmn[:item]
    f.write(sprintf("    Nature = %s\r\n", pkmn[:nature])) if pkmn[:nature]
    ivs_array = []
    evs_array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      ivs_array[s.pbs_order] = pkmn[:iv][s.id] if pkmn[:iv]
      evs_array[s.pbs_order] = pkmn[:ev][s.id] if pkmn[:ev]
    end
    f.write(sprintf("    IV = %s\r\n", ivs_array.join(","))) if pkmn[:iv]
    f.write(sprintf("    EV = %s\r\n", evs_array.join(","))) if pkmn[:ev]
    f.write(sprintf("    Happiness = %d\r\n", pkmn[:happiness])) if pkmn[:happiness]
    f.write(sprintf("    Ball = %s\r\n", pkmn[:poke_ball])) if pkmn[:poke_ball]
  end

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_avatars
    File.open("PBS/avatars.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Avatar.each do |avatar|
        pbSetWindowText(_INTL("Writing avatar {1}...", avatar.id_number))
        Graphics.update if avatar.id_number % 20 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", avatar.id))
        f.write(sprintf("Ability = %s\r\n", avatar.ability))
        f.write(sprintf("Moves1 = %s\r\n", avatar.moves1.join(",")))
        f.write(sprintf("Moves2 = %s\r\n", avatar.moves2.join(","))) if !avatar.moves2.nil? && avatar.num_phases >= 2
        f.write(sprintf("Moves3 = %s\r\n", avatar.moves3.join(","))) if !avatar.moves3.nil? && avatar.num_phases >= 3
        f.write(sprintf("Moves4 = %s\r\n", avatar.moves4.join(","))) if !avatar.moves4.nil? && avatar.num_phases >= 4
        f.write(sprintf("Moves5 = %s\r\n", avatar.moves5.join(","))) if !avatar.moves5.nil? && avatar.num_phases >= 5
        f.write(sprintf("Turns = %s\r\n", avatar.num_turns)) if avatar.num_turns != 2.0
        f.write(sprintf("HPMult = %s\r\n", avatar.hp_mult)) if avatar.num_turns != 4.0
        f.write(sprintf("HealthBars = %s\r\n", avatar.num_health_bars)) if avatar.num_health_bars != avatar.num_phases
        f.write(sprintf("Item = %s\r\n", avatar.item)) if !avatar.item.nil?
        f.write(sprintf("DMGMult = %s\r\n", avatar.dmg_mult)) if avatar.dmg_mult != 1.0
        f.write(sprintf("DMGResist = %s\r\n", avatar.dmg_resist)) if avatar.dmg_resist != 0.0
        f.write(sprintf("Form = %s\r\n", avatar.form)) if avatar.form != 0
        f.write(sprintf("Aggression = %s\r\n", avatar.aggression)) if avatar.aggression != PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end

  #=============================================================================
  # Save type data to PBS file
  #=============================================================================
  def write_types
    File.open("PBS/types.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each type in turn
      GameData::Type.each do |type|
        f.write("\#-------------------------------\r\n")
        f.write("[#{type.id_number}]\r\n")
        f.write("Name = #{type.real_name}\r\n")
        f.write("InternalName = #{type.id}\r\n")
        if type.color
          rgb = [type.color.red.to_i,type.color.green.to_i,type.color.blue.to_i]
          f.write("Color = #{rgb.join(",")}\r\n")
        end
        f.write("IsPseudoType = true\r\n") if type.pseudo_type
        f.write("IsSpecialType = true\r\n") if type.special?
        f.write("Weaknesses = #{type.weaknesses.join(",")}\r\n") if type.weaknesses.length > 0
        f.write("Resistances = #{type.resistances.join(",")}\r\n") if type.resistances.length > 0
        f.write("Immunities = #{type.immunities.join(",")}\r\n") if type.immunities.length > 0
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
    write_town_map
    write_connections
    write_phone
    write_types
    write_abilities
    write_moves
    write_items
    write_berry_plants
    write_pokemon
    write_pokemon_forms
    write_shadow_movesets
    write_regional_dexes
    write_ribbons
    write_encounters
    write_trainer_types
    write_trainers
    write_trainer_lists
    write_avatars
    write_metadata
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    File.open("PBS/items.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        GameData::Item.each do |i|
                break if i.id_number >= 2000
                write_item(f,i)
        end
    }
    File.open("PBS/other_items.txt", "wb") { |f|
        add_PBS_header_to_file(f)
        GameData::Item.each do |i|
            next if i.id_number < 2000
            write_item(f,i)
        end
    }
    Graphics.update
  end

  def write_item(f,i)
    move_name = (i.move) ? GameData::Move.get(i.move).id.to_s : ""
    sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d\r\n"
    sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d,%s\r\n" if move_name != ""
    f.write(sprintf(sprintf_text,
      i.id_number,
      csvQuote(i.id.to_s),
      csvQuote(i.real_name),
      csvQuote(i.real_name_plural),
      i.pocket,
      i.price,
      csvQuoteAlways(i.real_description),
      i.field_use,
      i.battle_use,
      i.type,
      csvQuote(move_name)
    ))
  end

  #=============================================================================
  # Save ability data to PBS file
  #=============================================================================
  def write_abilities
    File.open("PBS/abilities.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      abilityIndex = 0
      GameData::Ability.each do |a|
        if a.id_number >= 1000 && abilityIndex < 1000
          abilityIndex = 1000
        else
          abilityIndex += 1
        end
        f.write(sprintf("%d,%s,%s,%s\r\n",
          abilityIndex,
          csvQuote(a.id.to_s),
          csvQuote(a.real_name),
          csvQuoteAlways(a.real_description)
        ))
        
      end
    }
    Graphics.update
  end
end