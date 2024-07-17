#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
    def initialize(scene)
        @scene = scene
    end

    # @param file_path [String] file to load save data from
    # @return [Hash] save data
    def load_save_file(file_path)
        save_data = SaveData.read_from_file(file_path)
        unless SaveData.valid?(save_data)
            if File.file?(file_path + ".bak")
                pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
                save_data = load_save_file(file_path + ".bak")
            else
                prompt_save_deletion
                return {}
            end
        end
        return save_data
    end

    # Called if all save data is invalid.
    # Prompts the player to delete the save files.
    def prompt_save_deletion
        pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
        exit unless pbConfirmMessageSerious(
            _INTL("Do you want to delete the save file and start anew?")
        )
        delete_save_data
        $game_system   = Game_System.new
        $PokemonSystem = PokemonSystem.new
    end

    def pbStartDeleteScreen
        @scene.pbStartDeleteScene
        @scene.pbStartScene2
        count = FileSave.count
        if count < 0
            pbMessage(_INTL("No save file was found."))
        else
            msg = _INTL("What do you want to do?")
            cmds = [_INTL("Delete All File Save"), _INTL("Delete Only One File Save"), _INTL("Cancel")]
            cmd = pbCustomMessageForSave(msg, cmds, 3)
            case cmd
            when 0
                if pbConfirmMessageSerious(_INTL("Delete all saves?"))
                    pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
                    if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
                        pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
                        haserrorwhendelete = false
                        count.times do |i|
                            name = FileSave.name(i + 1, false)
                            begin
                                SaveData.delete_file(name)
                            rescue StandardError
                                haserrorwhendelete = true
                            end
                        end
                        if haserrorwhendelete
                            pbMessage(_INTL("You have at least one file that cant delete and have error"))
                        end
                        Graphics.frame_reset
                        pbMessage(_INTL("The save file was deleted."))
                    end
                end
            when 1
                pbFadeOutIn do
                    file = ScreenChooseFileSave.new(count)
                    file.movePanel(2)
                    file.endScene
                    Graphics.frame_reset if file.deletefile
                end
            end
        end
        @scene.pbEndScene
        $scene = pbCallTitle
    end

    def delete_save_data
        SaveData.delete_file
        pbMessage(_INTL("The saved data was deleted."))
    rescue SystemCallError
        pbMessage(_INTL("All saved data could not be deleted."))
    end

    def pbStartLoadScreen
        commands = []
        cmd_continue        = -1
        cmd_load_game       = -1
        cmd_new_game        = -1
        cmd_achievements    = -1
        cmd_debug           = -1
        cmd_website         = -1
        cmd_survey          = -1
        cmd_quit            = -1
        lastModifiedSaveName = FileSave.lastModifiedSaveName
        if FileSave.count > 0
            commands[cmd_continue = commands.length]    = _INTL("Continue") unless lastModifiedSaveName.nil?
            commands[cmd_load_game = commands.length]   = _INTL("Load Game")
        end
        commands[cmd_new_game = commands.length]        = _INTL("New Game")
        commands[cmd_achievements = commands.length]    = _INTL("Achievements")
        commands[cmd_website = commands.length]         = _INTL("Website")
        commands[cmd_survey = commands.length]          = _INTL("Playtest Survey")
        commands[cmd_quit = commands.length]            = _INTL("Quit Game")
        @scene.pbStartScene(commands, false, nil, 0, 0)
        @scene.pbStartScene2
        loop do
            command = @scene.pbChoose(commands)
            pbPlayDecisionSE if command != cmd_quit
            case command
            when cmd_continue
                $current_save_file_name = lastModifiedSaveName
                Game.set_up_system
                Game.load(SaveData.read_from_file(lastModifiedSaveName, true))
                @scene.pbEndScene
                return
            when cmd_load_game
                pbFadeOutIn do
                    file = ScreenChooseFileSave.new(FileSave.count)
                    file.movePanel(1)
                    @scene.pbEndScene unless file.staymenu
                    file.endScene
                    return unless file.staymenu
                end
            when cmd_new_game
                @scene.pbEndScene
                Game.start_new
                return
            when cmd_achievements
                pbFadeOutIn do
                    achievementsListScene = AchievementsListScene.new
                    screen = AchievementsListScreen.new(achievementsListScene)
                    screen.pbStartScreen
                end
            when cmd_survey
                System.launch("https://forms.gle/49kb3i38AxMnD8RC7")
            when cmd_website
                System.launch("https://www.tectonic-game.com/")
            when cmd_quit
                pbPlayCloseMenuSE
                @scene.pbEndScene
                $scene = nil
                return
            else
                pbPlayBuzzerSE
            end
        end
    end
end
