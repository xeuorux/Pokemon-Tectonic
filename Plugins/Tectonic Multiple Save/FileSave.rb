# Store save file after load save file
$current_save_file_name = nil

# Some methods for checking save file
module FileSave
    # Set name of folder
    DIR_SAVE_GAME = "Save Game"

    # Set name of file for saving:
    # Ex: Game1,Game2,etc
    FILENAME_SAVE_GAME = "Game"

    # Create dir
    def self.createDir(dir = DIR_SAVE_GAME)
        Dir.mkdir(dir) unless safeExists?(dir)
    end

    # Return location
    def self.location(dir = DIR_SAVE_GAME)
        createDir
        return "#{dir}"
    end

    # Array file
    def self.count(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
        return allSaveNames(dir, file, type).size
    end

    def self.allSaveNames(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
        createDir(dir)

        # If there exists a file from before multiple saves was implemented, rename it to be save '1'
        File.rename("#{dir}/#{file}.#{type}", "#{dir}/#{file}1.#{type}") if File.file?("#{dir}/#{file}.#{type}")

        return Dir.glob("#{dir}/#{file}*.#{type}")
    end

    def self.lastModifiedSaveName(_dir = DIR_SAVE_GAME, _file = FILENAME_SAVE_GAME, _type = "rxdata")
        saveNameArray = allSaveNames
        return nil if saveNameArray.size == 0

        lastModifiedSaveName = nil
        lastModifiedTime = 0
        saveNameArray.each do |saveName|
            File.open(saveName) do |file|
                fileLastModifiedTime = file.mtime.to_f
                if fileLastModifiedTime > lastModifiedTime
                    lastModifiedSaveName = saveName
                    lastModifiedTime = fileLastModifiedTime
                end
            end
        end
        return lastModifiedSaveName
    end

    # Rename
    def self.rename(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
        saveArray = allSaveNames
        return if saveArray.size <= 0

        name = []
        saveArray.each { |f| name << (File.basename(f, ".#{type}").gsub(/[^0-9]/, "")) }
        needtorewrite = false
        (0...saveArray.size).each do |i|
            needtorewrite = true if saveArray[i] != "#{dir}/#{file}#{name[i]}.#{type}"
        end
        if needtorewrite
            numbername = []
            name.each { |n| numbername << n.to_i }
            (0...numbername.size).each do |i|
                loop do
                    break if i == 0
                    diff = numbername.index(numbername[i])
                    break if diff == i
                    numbername[i] += 1
                end
                Dir.mkdir("#{dir}/#{numbername[i]}")
                File.rename("#{saveArray[i]}", "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}")
            end
            (0...name.size).each do |i|
                name2 = "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}"
                File.rename(name2, "#{dir}/#{file}#{numbername[i]}.#{type}")
                Dir.delete("#{dir}/#{numbername[i]}")
            end
        end

        saveArray.size.times do |i|
            num = 0
            namef = format("%d", i + 1)
            loop do
                break if File.file?("#{dir}/#{file}#{namef}.#{type}")
                num    += 1
                namef2  = format("%d", i + 1 + num)
                if File.file?("#{dir}/#{file}#{namef2}.#{type}")
                    File.rename("#{dir}/#{file}#{namef2}.#{type}",
"#{dir}/#{file}#{namef}.#{type}")
                end
            end
        end
    end

    # Save
    def self.name(n = nil, re = true, dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, _type = "rxdata")
        rename if re
        return "#{dir}/#{file}1.rxdata" if n.nil?
        unless n.is_a?(Numeric)
            p "Set number for file save"
            return
        end
        return "#{dir}/#{file}#{n}.rxdata"
    end

    # Old file save
    def self.title
        return System.game_title.gsub(/[^\w ]/, "_")
    end

    # Version 19
    def self.dirv19(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
        game_title = title
        return unless File.directory?(System.data_directory)
        old_file = System.data_directory + "/Game.rxdata"
        return unless File.file?(old_file)
        rename
        size = count
        File.move(old_file, "#{dir}/#{file}#{size + 1}.#{type}")
    end

    # Version 18
    def self.dirv18(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
        game_title = title
        home = ENV["HOME"] || ENV["HOMEPATH"]
        return if home.nil?
        old_location = File.join(home, "Saved Games", game_title)
        return unless File.directory?(old_location)
        old_file = File.join(old_location, "Game.rxdata")
        return unless File.file?(old_file)
        rename
        size = count
        File.move(old_file, "#{dir}/#{file}#{size + 1}.#{type}")
    end
end
