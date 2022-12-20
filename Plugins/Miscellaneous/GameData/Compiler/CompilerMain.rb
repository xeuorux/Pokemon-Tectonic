module Compiler
	module_function

    def self.load_all
        echoln("Loading all game data.")
        Type.load
        Ability.load
        Move.load
        Item.load
        BerryPlant.load
        Species.load
        SpeciesOld.load
        Ribbon.load
        Encounter.load
        TrainerType.load
        Trainer.load
        Metadata.load
        MapMetadata.load
        Policy.load
        Avatar.load
    end
        
    def main
        return if !$DEBUG
        begin
        dataFiles = [
            "berry_plants.dat",
            "encounters.dat",
            "form2species.dat",
            "items.dat",
            "map_connections.dat",
            "metadata.dat",
            "moves.dat",
            "phone.dat",
            "regional_dexes.dat",
            "ribbons.dat",
            "shadow_movesets.dat",
            "species.dat",
            "species_eggmoves.dat",
            "species_evolutions.dat",
            "species_metrics.dat",
            "species_movesets.dat",
            "species_old.dat",
            "tm.dat",
            "town_map.dat",
            "trainer_lists.dat",
            "trainer_types.dat",
            "trainers.dat",
            "types.dat",
            "policies.dat",
            "avatars.dat"
        ]
        textFiles = [
            "abilities.txt",
            "berryplants.txt",
            "connections.txt",
            "encounters.txt",
            "items.txt",
            "metadata.txt",
            "moves.txt",
            "phone.txt",
            "pokemon.txt",
                "pokemon_old.txt",
            "pokemonforms.txt",
            "regionaldexes.txt",
            "ribbons.txt",
            "shadowmoves.txt",
            "townmap.txt",
            "trainerlists.txt",
            "trainers.txt",
            "trainertypes.txt",
            "types.txt",
                "policies.txt",
                "avatars.txt"
        ]
        latestDataTime = 0
        latestTextTime = 0
        mustCompile = false
        # Should recompile if new maps were imported
        mustCompile |= import_new_maps
        # If no PBS file, create one and fill it, then recompile
        if !safeIsDirectory?("PBS")
            Dir.mkdir("PBS") rescue nil
            write_all
            mustCompile = true
        end

        # Check data files and PBS files, and recompile if any PBS file was edited
        # more recently than the data files were last created
        dataFiles.each do |filename|
            next if !safeExists?("Data/" + filename)
            begin
            File.open("Data/#{filename}") { |file|
                latestDataTime = [latestDataTime, file.mtime.to_i].max
            }
            rescue SystemCallError
            mustCompile = true
            end
        end
        textFiles.each do |filename|
            next if !safeExists?("PBS/" + filename)
            begin
            File.open("PBS/#{filename}") { |file|
                latestTextTime = [latestTextTime, file.mtime.to_i].max
            }
            rescue SystemCallError
            end
        end
        MessageTypes.loadMessageFile("Data/messages.dat")

        # Should recompile if holding Ctrl
        Input.update
        mustCompile = true if Input.press?(Input::CTRL) || ARGV.include?("compile")
        
        # Delete old data files in preparation for recompiling
        if mustCompile
            for i in 0...dataFiles.length
            begin
                File.delete("Data/#{dataFiles[i]}") if safeExists?("Data/#{dataFiles[i]}")
                rescue SystemCallError
            end
            end
        end
        # Recompile all data
        compile_all(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
        rescue Exception
        e = $!
        raise e if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
        pbPrintException(e)
        for i in 0...dataFiles.length
            begin
            File.delete("Data/#{dataFiles[i]}")
            rescue SystemCallError
            end
        end
        raise Reset.new if e.is_a?(Hangup)
        loop do
            Graphics.update
        end
        end
    end
end