module Compiler
    module_function

    #=============================================================================
    # Compile Battle Tower and other Cups trainers/Pokémon
    #=============================================================================
    def compile_trainer_lists(path = "PBS/trainerlists.txt")
        btTrainersRequiredTypes = {
        "Trainers"   => [0, "s"],
        "Pokemon"    => [1, "s"],
        "Challenges" => [2, "*s"]
        }
        if !safeExists?(path)
        File.open(path, "wb") { |f|
            f.write(0xEF.chr)
            f.write(0xBB.chr)
            f.write(0xBF.chr)
            f.write("[DefaultTrainerList]\r\n")
            f.write("Trainers = bttrainers.txt\r\n")
            f.write("Pokemon = btpokemon.txt\r\n")
        }
        end
        sections = []
        MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,[])
        MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,[])
        MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,[])
        File.open(path, "rb") { |f|
        FileLineData.file = path
        pbEachFileSectionEx(f) { |section,name|
            next if name!="DefaultTrainerList" && name!="TrainerList"
            rsection = []
            for key in section.keys
            FileLineData.setSection(name,key,section[key])
            schema = btTrainersRequiredTypes[key]
            next if key=="Challenges" && name=="DefaultTrainerList"
            next if !schema
            record = pbGetCsvRecord(section[key],0,schema)
            rsection[schema[0]] = record
            end
            if !rsection[0]
            raise _INTL("No trainer data file given in section {1}.\r\n{2}",name,FileLineData.linereport)
            end
            if !rsection[1]
            raise _INTL("No trainer data file given in section {1}.\r\n{2}",name,FileLineData.linereport)
            end
            rsection[3] = rsection[0]
            rsection[4] = rsection[1]
            rsection[5] = (name=="DefaultTrainerList")
            if safeExists?("PBS/"+rsection[0])
            rsection[0] = compile_battle_tower_trainers("PBS/"+rsection[0])
            else
            rsection[0] = []
            end
            if safeExists?("PBS/"+rsection[1])
            filename = "PBS/"+rsection[1]
            rsection[1] = []
            pbCompilerEachCommentedLine(filename) { |line,_lineno|
                rsection[1].push(PBPokemon.fromInspected(line))
            }
            else
            rsection[1] = []
            end
            rsection[2] = [] if !rsection[2]
            while rsection[2].include?("")
            rsection[2].delete("")
            end
            rsection[2].compact!
            sections.push(rsection)
        }
        }
        save_data(sections,"Data/trainer_lists.dat")
    end

    def compile_battle_tower_trainers(filename)
        sections = []
        requiredtypes = {
        "Type"          => [0, "e", :TrainerType],
        "Name"          => [1, "s"],
        "BeginSpeech"   => [2, "s"],
        "EndSpeechWin"  => [3, "s"],
        "EndSpeechLose" => [4, "s"],
        "PokemonNos"    => [5, "*u"]
        }
        trainernames  = []
        beginspeech   = []
        endspeechwin  = []
        endspeechlose = []
        if safeExists?(filename)
        File.open(filename,"rb") { |f|
            FileLineData.file = filename
            pbEachFileSectionEx(f) { |section,name|
            rsection = []
            for key in section.keys
                FileLineData.setSection(name,key,section[key])
                schema = requiredtypes[key]
                next if !schema
                record = pbGetCsvRecord(section[key],0,schema)
                rsection[schema[0]] = record
            end
            trainernames.push(rsection[1])
            beginspeech.push(rsection[2])
            endspeechwin.push(rsection[3])
            endspeechlose.push(rsection[4])
            sections.push(rsection)
            }
        }
        end
        MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,trainernames)
        MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,beginspeech)
        MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,endspeechwin)
        MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,endspeechlose)
        return sections
    end
  
    #=============================================================================
    # Save trainer list data to PBS file
    #=============================================================================
    def write_trainer_lists
      trainerlists = load_data("Data/trainer_lists.dat") rescue nil
      return if !trainerlists
      File.open("PBS/trainerlists.txt","wb") { |f|
        add_PBS_header_to_file(f)
        for tr in trainerlists
          f.write("\#-------------------------------\r\n")
          f.write(((tr[5]) ? "[DefaultTrainerList]" : "[TrainerList]")+"\r\n")
          f.write("Trainers = "+tr[3]+"\r\n")
          f.write("Pokemon = "+tr[4]+"\r\n")
          f.write("Challenges = "+tr[2].join(",")+"\r\n") if !tr[5]
          write_battle_tower_trainers(tr[0],"PBS/"+tr[3])
          write_battle_tower_pokemon(tr[1],"PBS/"+tr[4])
        end
      }
      Graphics.update
    end

      #=============================================================================
  # Save Battle Tower trainer data to PBS file
  #=============================================================================
  def write_battle_tower_trainers(bttrainers, filename)
    return if !bttrainers || !filename
    btTrainersRequiredTypes = {
      "Type"          => [0, "e", nil],   # Specifies a trainer
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"]
    }
    File.open(filename,"wb") { |f|
      add_PBS_header_to_file(f)
      for i in 0...bttrainers.length
        next if !bttrainers[i]
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%03d]\r\n",i))
        for key in btTrainersRequiredTypes.keys
          schema = btTrainersRequiredTypes[key]
          record = bttrainers[i][schema[0]]
          next if record==nil
          f.write(sprintf("%s = ",key))
          if key=="Type"
            f.write(record.to_s)
          elsif key=="PokemonNos"
            f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
          else
            pbWriteCsvRecord(record,f,schema)
          end
          f.write(sprintf("\r\n"))
        end
      end
    }
    Graphics.update
  end

  #=============================================================================
  # Save Battle Tower Pokémon data to PBS file
  #=============================================================================
  def write_battle_tower_pokemon(btpokemon,filename)
    return if !btpokemon || !filename
    species = {}
    moves   = {}
    items   = {}
    natures = {}
    evs = {
      :HP              => "HP",
      :ATTACK          => "ATK",
      :DEFENSE         => "DEF",
      :SPECIAL_ATTACK  => "SA",
      :SPECIAL_DEFENSE => "SD",
      :SPEED           => "SPD"
    }
    File.open(filename,"wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      for i in 0...btpokemon.length
        Graphics.update if i % 500 == 0
        pkmn = btpokemon[i]
        c1 = (species[pkmn.species]) ? species[pkmn.species] : (species[pkmn.species] = GameData::Species.get(pkmn.species).species.to_s)
        c2 = (items[pkmn.firstItem]) ? items[pkmn.firstItem] : (items[pkmn.firstItem] = GameData::Item.get(pkmn.firstItem).id.to_s)
        c3 = (natures[pkmn.nature]) ? natures[pkmn.nature] : (natures[pkmn.nature] = GameData::Nature.get(pkmn.nature).id.to_s)
        evlist = ""
        pkmn.ev.each_with_index do |stat, i|
          evlist += "," if i > 0
          evlist += evs[stat]
        end
        c4 = c5 = c6 = c7 = ""
        [pkmn.move1, pkmn.move2, pkmn.move3, pkmn.move4].each_with_index do |move, i|
          next if !move
          text = (moves[move]) ? moves[move] : (moves[move] = GameData::Move.get(move).id.to_s)
          case i
          when 0 then c4 = text
          when 1 then c5 = text
          when 2 then c6 = text
          when 3 then c7 = text
          end
        end
        f.write("#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}\r\n")
      end
    }
    Graphics.update
  end
end