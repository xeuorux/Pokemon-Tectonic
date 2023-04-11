# Store save file after load save file
$storenamefilesave = nil

DIR_SCREENSHOTS = "Screenshots"

# Some methods for checking save file
module FileSave
	# Set name of folder
	DIR_SAVE_GAME = "Save Game"

	# Set name of file for saving:
	# Ex: Game1,Game2,etc
	FILENAME_SAVE_GAME = "Game"

	# Create dir
	def self.createDir(dir = DIR_SAVE_GAME)
		Dir.mkdir(dir) if !safeExists?(dir)
	end

	# Return location
	def self.location(dir = DIR_SAVE_GAME)
		self.createDir
		return "#{dir}"
	end
	
	# Array file
	def self.count(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
		return allSaveNames(dir,file,type).size
	end

	def self.allSaveNames(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
		self.createDir(dir)

		# If there exists a file from before multiple saves was implemented, rename it to be save '1'
		if File.file?("#{dir}/#{file}.#{type}")
			File.rename("#{dir}/#{file}.#{type}", "#{dir}/#{file}1.#{type}")
		end

		return Dir.glob("#{dir}/#{file}*.#{type}")
	end

	def self.lastModifiedSaveName(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
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
		saveArray = self.allSaveNames
		return if saveArray.size <= 0

		name = []
		saveArray.each { |f| name << ( File.basename(f, ".#{type}").gsub(/[^0-9]/, "") ) }
		needtorewrite = false
		(0...saveArray.size).each { |i|
			needtorewrite = true if saveArray[i]!="#{dir}/#{file}#{name[i]}.#{type}"
		}
		if needtorewrite
			numbername = []
			name.each { |n| numbername << n.to_i}
			(0...numbername.size).each { |i|
				loop do
					break if i==0
					diff = numbername.index(numbername[i])
					break if diff==i
					numbername[i] += 1
				end
				Dir.mkdir("#{dir}/#{numbername[i]}")
				File.rename("#{saveArray[i]}", "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}")
			}
			(0...name.size).each { |i|
				name2 = "#{dir}/#{numbername[i]}/#{file}#{numbername[i]}.#{type}"
				File.rename(name2, "#{dir}/#{file}#{numbername[i]}.#{type}")
				Dir.delete("#{dir}/#{numbername[i]}")
			}
		end

		saveArray.size.times { |i|
			num = 0
			namef = sprintf("%d", i + 1)
			loop do
				break if File.file?("#{dir}/#{file}#{namef}.#{type}")
				num    += 1
				namef2  = sprintf("%d", i + 1 + num)
				File.rename("#{dir}/#{file}#{namef2}.#{type}", "#{dir}/#{file}#{namef}.#{type}") if File.file?("#{dir}/#{file}#{namef2}.#{type}")
			end
		}
	end

	# Save
	def self.name(n = nil, re = true, dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
		self.rename if re
		return "#{dir}/#{file}1.rxdata" if n.nil?
		if !n.is_a?(Numeric)
			p "Set number for file save"
			return
		end
		return "#{dir}/#{file}#{n}.rxdata"
	end

	# Old file save
	def self.title
		return System.game_title.gsub(/[^\w ]/, '_')
	end

	# Version 19
	def self.dirv19(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
		game_title = self.title
		return if !File.directory?(System.data_directory)
		old_file = System.data_directory + '/Game.rxdata'
		return if !File.file?(old_file)
		self.rename
		size = self.count
		File.move(old_file, "#{dir}/#{file}#{size+1}.#{type}")
	end

	# Version 18
	def self.dirv18(dir = DIR_SAVE_GAME, file = FILENAME_SAVE_GAME, type = "rxdata")
		game_title = self.title
		home = ENV['HOME'] || ENV['HOMEPATH']
		return if home.nil?
		old_location = File.join(home, 'Saved Games', game_title)
		return if !File.directory?(old_location)
		old_file = File.join(old_location, 'Game.rxdata')
		return if !File.file?(old_file)
		self.rename
		size = self.count
    	File.move(old_file, "#{dir}/#{file}#{size+1}.#{type}")
	end
end

#-------------------------#
# Set for module SaveData #
#-------------------------#
module SaveData
	def self.delete_file(file = FILE_PATH)
		File.delete(file)
		File.delete(file + '.bak') if File.file?(file + '.bak')
  	end

	def self.move_old_windows_save
		FileSave.dirv19
		FileSave.dirv18
	end

	def self.changeFILEPATH(new = nil)
		return if new.nil?
		const_set(:FILE_PATH, new)
	end

	# Fetches save data from the given file. If it needed converting, resaves it.
	# @param file_path [String] path of the file to read from
	# @return [Hash] save data in Hash format
	# @raise (see .get_data_from_file)
	def self.read_from_file(file_path,convert=true)
		validate file_path => String
		save_data = get_data_from_file(file_path)
		save_data = to_hash_format(save_data) if save_data.is_a?(Array)
		if convert && !save_data.empty? && run_conversions(save_data)
			File.open(file_path, 'wb') { |file| Marshal.dump(save_data, file) }
		end
		return save_data
	end
end

#---------------------#
# Set 'set_up_system' #
#---------------------#
module Game
	def self.set_up_system
		SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
		SaveData.move_old_windows_save if System.platform[/Windows/]
		save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH) : {}
		if save_data.empty?
		  SaveData.initialize_bootup_values
		else
		  SaveData.load_bootup_values(save_data)
		end
		# Set resize factor
		pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
		# Set language (and choose language if there is no save file)
		if Settings::LANGUAGES.length >= 2 && $DEBUG
		  $PokemonSystem.language = pbChooseLanguage if save_data.empty?
		  pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
		end
	end
end

#--------------------#
# Set emergency save #
#--------------------#
def pbEmergencySave
	oldscene = $scene
	$scene = nil
	pbMessage(_INTL("The script is taking too long. The game will restart."))
	return if !$Trainer
	# It will store the last save file when you dont file save
	SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
	if SaveData.exists?
		File.open(SaveData::FILE_PATH, 'rb') do |r|
		  File.open(SaveData::FILE_PATH + '.bak', 'wb') do |w|
			while s = r.read(4096)
			  w.write s
			end
		  end
		end
	end
	if savingAllowed?
		if Game.save
			pbMessage(_INTL("\\se[]The game was saved.\\me[GUI save game]"))
		else
			pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
		end
	end
	pbMessage(_INTL("The previous save file has been backed up.\\wtnp[30]"))
	$scene = oldscene
end

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# Save                                                                         #
#------------------------------------------------------------------------------#
# Custom message
def pbCustomMessageForSave(message,commands,index,&block)
  return pbMessage(message,commands,index,&block)
end

# Save screen
class PokemonSaveScreen
	
	# Returns whether the player decided to quit the game
	def pbSaveScreen(quitting = false, deleting = true)
		if !savingAllowed?()
			showSaveBlockMessage()
			return
		end
		# Check for renaming
		FileSave.rename
		# Count save file
		count = FileSave.count
		# Start
		saveCommand = -1
		deleteCommand = -1
		quitCommand = -1
		cancelCommand = -1
		cmds = []
		cmds[saveCommand = cmds.length] = _INTL("Just Save")
		cmds[quitCommand = cmds.length] = _INTL("Save Quit") if quitting
		cmds[deleteCommand = cmds.length] = _INTL("Delete") if deleting
		cmds[cancelCommand = cmds.length] = _INTL("Cancel")
		saveChoice = pbCustomMessageForSave(_INTL("What do you want to do?"),cmds,cmds.length)
		return inGameSaveScreen(count) if quitCommand >= 0 && saveChoice == quitCommand
		inGameSaveScreen(count) if saveCommand >= 0 && saveChoice == saveCommand
		inGameDeleteScreen(count) if deleteCommand >= 0 && saveChoice == deleteCommand
		return false
	end
	
	def inGameSaveScreen(count)
		ret = false
		@scene.pbStartScreen
		commands = []
		cmdSaveCurrent 	= -1
		cmdSaveNew		= -1
		cmdSaveOld		= -1
		commands[cmdSaveCurrent = commands.length] = _INTL("Save current save file") if !$storenamefilesave.nil? && count>0
		commands[cmdSaveNew = commands.length] = _INTL("New Save File")
		commands[cmdSaveOld = commands.length] = _INTL("Old Save File")
		commands[commands.length] = _INTL("Cancel")
		saveTypeSelection = pbCustomMessageForSave(_INTL("What do you want to do?"),commands, ($storenamefilesave.nil? && count>0 ? 3 : 4 ))
		# New save file
		if cmdSaveNew >= 0 && saveTypeSelection == cmdSaveNew
			SaveData.changeFILEPATH(FileSave.name(count+1))
			if Game.save
				pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
				ret = true
			else
				pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
				ret = false
			end
			# Change the stored save file to what you just created
			$storenamefilesave = FileSave.name(count+1)
			SaveData.changeFILEPATH(!$storenamefilesave.nil? ? $storenamefilesave : FileSave.name)
		end
		# Old save file
		if cmdSaveOld >= 0 && saveTypeSelection == cmdSaveOld
			if count <= 0
				pbMessage(_INTL("No save file was found."))
			else
				pbFadeOutIn {
				  file = ScreenChooseFileSave.new(count)
				  file.movePanel
				  file.endScene
				  ret = file.staymenu
				}
			end
		end
		# Save over current
		if cmdSaveCurrent >=0 && saveTypeSelection == cmdSaveCurrent
			SaveData.changeFILEPATH($storenamefilesave)
			if Game.save
				pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
				ret = true
			else
				pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
				ret = false
			end
			SaveData.changeFILEPATH(!$storenamefilesave.nil? ? $storenamefilesave : FileSave.name)
		end
		@scene.pbEndScreen
		return ret
	end
	
	def inGameDeleteScreen(count)
		if count <= 0
			pbMessage(_INTL("No save file was found."))
			return false
		end
		commands = [_INTL("Delete One Save"),_INTL("Delete All Saves"),_INTL("Cancel")]
		deleteTypeSelection = pbCustomMessageForSave(_INTL("What do you want to do?"),commands,3)
		case deleteTypeSelection
		when 0
			pbFadeOutIn {
				file = ScreenChooseFileSave.new(count)
				file.movePanel(2)
				file.endScene
				Graphics.frame_reset if file.deletefile
			}
		when 1
			if pbConfirmMessageSerious(_INTL("Delete all saves?"))
				pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
				if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
					pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
					haserrorwhendelete = false
					count.times { |i|
						name = FileSave.name(i+1, false)
						begin
							SaveData.delete_file(name)
						rescue
							haserrorwhendelete = true
						end
					}
					pbMessage(_INTL("You have at least one file that cant delete and have error")) if haserrorwhendelete
					Graphics.frame_reset
					pbMessage(_INTL("The save file was deleted."))
				end
			end
		end
		# Return menu
		return false
	end
end

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# Load                                                                         #
#------------------------------------------------------------------------------#
class PokemonLoadScreen
	def initialize(scene)
		@scene = scene
	end

	def pbStartLoadScreen
		commands = []
		cmd_continue     = -1
		cmd_load_game	 = -1
		cmd_new_game     = -1
		cmd_debug        = -1
		cmd_website		 = -1
		cmd_survey		 = -1
		cmd_quit         = -1
		lastModifiedSaveName = FileSave.lastModifiedSaveName
		if FileSave.count > 0
			if !lastModifiedSaveName.nil?
				commands[cmd_continue = commands.length] = _INTL('Continue')
			end
			commands[cmd_load_game = commands.length] = _INTL('Load Game')
		end
		commands[cmd_new_game = commands.length]  = _INTL('New Game')
		commands[cmd_website = commands.length]   = _INTL('Website')
		commands[cmd_survey = commands.length]   = _INTL('Playtest Survey')
		commands[cmd_debug = commands.length]     = _INTL('Debug') if $DEBUG
		commands[cmd_quit = commands.length]      = _INTL('Quit Game')
		@scene.pbStartScene(commands, false, nil, 0, 0)
		@scene.pbStartScene2
		loop do
		  command = @scene.pbChoose(commands)
		  pbPlayDecisionSE if command != cmd_quit
		  case command
		  when cmd_continue
			$storenamefilesave = lastModifiedSaveName
			Game.set_up_system
			Game.load(SaveData.read_from_file(lastModifiedSaveName,true))
			@scene.pbEndScene
			return
		  when cmd_load_game
				pbFadeOutIn {
					file = ScreenChooseFileSave.new(FileSave.count)
					file.movePanel(1)
					@scene.pbEndScene if !file.staymenu
					file.endScene
					return if !file.staymenu
				}
		  when cmd_new_game
			@scene.pbEndScene
			Game.start_new
			return
		  when cmd_survey
			System.launch("https://forms.gle/49kb3i38AxMnD8RC7")
		  when cmd_website
			System.launch("https://www.tectonic-game.com/")
		  when cmd_debug
			pbFadeOutIn { pbDebugMenu(false) }
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

	def pbStartDeleteScreen
		@scene.pbStartDeleteScene
		@scene.pbStartScene2
		count = FileSave.count
		if count<0
			pbMessage(_INTL("No save file was found."))
		else
			msg = _INTL("What do you want to do?")
			cmds = [_INTL("Delete All File Save"),_INTL("Delete Only One File Save"),_INTL("Cancel")]
			cmd = pbCustomMessageForSave(msg,cmds,3)
			case cmd
			when 0
				if pbConfirmMessageSerious(_INTL("Delete all saves?"))
					pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
					if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
						pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
						haserrorwhendelete = false
						count.times { |i|
							name = FileSave.name(i+1, false)
							begin
								SaveData.delete_file(name)
							rescue
								haserrorwhendelete = true
							end
						}
						pbMessage(_INTL("You have at least one file that cant delete and have error")) if haserrorwhendelete
						Graphics.frame_reset
						pbMessage(_INTL("The save file was deleted."))
					end
				end
			when 1
				pbFadeOutIn {
				  file = ScreenChooseFileSave.new(count)
				  file.movePanel(2)
				  file.endScene
				  Graphics.frame_reset if file.deletefile
				}
			end
		end
		@scene.pbEndScene
		$scene = pbCallTitle
	end
end
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# Scene for save menu, load menu and delete menu                               #
#------------------------------------------------------------------------------#
class ScreenChooseFileSave
	attr_reader :staymenu
	attr_reader :deletefile
	
	def initialize(count)
		@sprites = {}
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		# Set value
		# Check quantity
		@count = count
		if @count<=0
			pbMessage("No save file was found.")
			return
		end
		# Check still menu
		@staymenu = false
		@deletefile = false
		# Check position
		@position = 0
		# Check position if count > 7
		@choose = 0
		# Set position of panel 'information'
		@posinfor = 0
		# Quantity of panel in information page
		@qinfor = 0
		# Check mystery gift
		@mysgif = false
	end
	
	# Set background (used "loadbg")
	def drawBg
		color = Color.new(248,248,248)
		addBackgroundOrColoredPlane(@sprites,"background","loadbg",color,@viewport)
	end

	#-------------------------------------------------------------------------------
	# Set Panel
	#-------------------------------------------------------------------------------
	# Draw panel
	def startPanel
		# Check and rename
		FileSave.rename
		# Start
		drawBg
		# Set bar
		num = (@count>7)? 7 : @count
		(0...num).each { |i|
				create_sprite("panel #{i}","loadPanels",@viewport)
				w = 384; h = 46 
				set_src_wh_sprite("panel #{i}",w,h)
				x = 16; y = 444
				set_src_xy_sprite("panel #{i}",x,y)
				x = 24*2; y = 16*2 + 48*i
				set_xy_sprite("panel #{i}",x,y) 
			}
		# Set choose bar
		create_sprite("choose panel","loadPanels",@viewport)
		w = 384; h = 46 
		set_src_wh_sprite("choose panel",w,h)
		x = 16; y = 444 + 46
		set_src_xy_sprite("choose panel",x,y)
		choosePanel(@choose)
		# Set text
		create_sprite_2("text",@viewport)
		textPanel
		pbFadeInAndShow(@sprites) { update }
	end
	
	def choosePanel(pos=0)
		x = 24*2; y = 16*2 + 48*pos
		set_xy_sprite("choose panel",x,y)
	end
	
	# Draw text panel
	BaseColor   = Color.new(252,252,252)
	ShadowColor = Color.new(0,0,0)
	def textPanel(font=nil)
		return if @count<=0
		bitmap = @sprites["text"].bitmap
		bitmap.clear
		if @count>0 && @count<7
		namesave = 0; endnum = @count
		else
		namesave = (@position>@count-7)? @count-7 : @position
		endnum = 7
		end
		textpos = []
		(0...endnum).each { |i| 
		saveIDThisSlot = namesave+1+i
		file = self.load_save_file(FileSave.name(saveIDThisSlot))
		trainer = file[:player]
		mapid = file[:map_factory].map.map_id
		mapname = pbGetMapNameFromId(mapid)
		mapname.gsub!(/\\PN/,trainer.name)
		string = _INTL("#{saveIDThisSlot}: #{trainer.name} / #{mapname}")
		x = 24*2 + 18; y = 16*2 + 5 + 48*i
		textpos<<[string,x,y,0,BaseColor,ShadowColor] 
		}
		(font.nil?)? pbSetSystemFont(bitmap) : bitmap.font.name = font
		pbDrawTextPositions(bitmap,textpos)
	end
  
	# Move panel
	# Type: 0: Save; 1: Load; 2: Delete
	def movePanel(type = 0)
		infor = false
		draw = true
		loadmenu = false

		@type = type
		loop do
		# Panel Page
		if !loadmenu
			if !infor
				if draw
					startPanel
					draw = false
				else
					# Update
					update_ingame
					if checkInput(Input::UP)
						@position -= 1
						@choose -= 1
						if @choose<0
							if @position<0
							@choose = (@count<7)? @count-1 : 6
							else
							@choose = 0
							end
						end
						@position = @count-1 if @position<0
						# Move choose panel
						choosePanel(@choose)
						# Draw text
						textPanel
						end
						if checkInput(Input::DOWN)
							@position += 1
							@choose += 1 if @position>@count-7
							(@choose = 0; @position = 0) if @position>=@count
							# Move choose panel
							choosePanel(@choose)
							# Draw text
							textPanel
						end
						if checkInput(Input::USE)
							dispose
							draw = true
							if self.fileLoad.empty?
								@choose = 0; @position = 0
								if FileSave.count==0
									pbMessage(_INTL('You dont have any save file. Restart game now.'))
									@staymenu = false
									$scene = pbCallTitle if @type == 1
									break
								end
							else
								infor = true
							end
						end
						if checkInput(Input::BACK)
							@staymenu = true if @type==1
						break
					end
				end
			# Information page
			else
				if draw
					self.fileLoad(true)
					startPanelInfor(@type)
					draw = false
				else
					# Update
					update_ingame
					# Load file
					loadmenu = true if @type==1
					if checkInput(Input::USE)
						# Save file
						case @type
						when 0
							SaveData.changeFILEPATH(FileSave.name(@position+1))
							if Game.save
								pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
								ret = true
							else
								pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
								ret = false
							end
							$storenamefilesave = FileSave.name(@position+1)
							SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
							break
						# Delete file
						when 2
							if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
								pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
								if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
									pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
									# Delete
									self.deleteFile
									@deletefile = true
								end
							end
							break
						end
					end
					if checkInput(Input::BACK)
						dispose
						draw = true
						infor = false
					end
				end
			end
		else
			# Update
			update_ingame
			# Start
			if @qinfor > 0
				if checkInput(Input::UP)
					@posinfor -= 1
					@posinfor = @qinfor if @posinfor<0
					choosePanelInfor
				end
				if checkInput(Input::DOWN)
					@posinfor += 1
					@posinfor = 0 if @posinfor>@qinfor
					choosePanelInfor
				end
			end
			if checkInput(Input::USE)
				# Set up system again
				$storenamefilesave = FileSave.name(@position+1)
				Game.set_up_system
				if @posinfor == 0
					Game.load(self.fileLoad(true))
					@staymenu = false
					break
				# Mystery Gift
				elsif @posinfor == 1 && @mysgif
					pbFadeOutIn { 
						pbDownloadMysteryGift(self.fileLoad(true)[:player]) 
						@posinfor = 0; @qinfor = 0; @mysgif = false
						dispose; draw = true; loadmenu=false; infor = false
					}
				# Language
				elsif Settings::LANGUAGES.length >= 2 && ( @posinfor==2 || (@posinfor==1 && !@mysgif)) && $DEBUG
					$PokemonSystem.language = pbChooseLanguage
					pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
					saveData = self.fileLoad(true)
					saveData[:pokemon_system] = $PokemonSystem
					File.open(FileSave.name(@position+1), 'wb') { |file| Marshal.dump(saveData, file) }
						@posinfor = 0; @qinfor = 0; @mysgif = false
						dispose; draw = true; loadmenu=false; infor = false
					end
				end
				if checkInput(Input::BACK)
					@posinfor = 0; @qinfor = 0; @mysgif = false
					dispose; draw = true; loadmenu = false; infor = false
				end
			end
		end
	end

	#-------------------------------------------------------------------------------
	# Set information
	#-------------------------------------------------------------------------------
	def startPanelInfor(type)
		# Draw background
		drawBg
		create_sprite("infor panel 0","loadPanels",@viewport)
		w = 408; h = 222
		set_src_wh_sprite("infor panel 0",w,h)
		x = 0; y = 0
		set_src_xy_sprite("infor panel 0",x,y)
		x = 24*2; y = 16*2
		set_xy_sprite("infor panel 0",x,y)
		drawInfor(type)
	end
	
	# Color
	TEXTCOLOR             = Color.new(232,232,232)
	TEXTSHADOWCOLOR       = Color.new(136,136,136)
	NAMETEXTCOLOR         = Color.new(61,139,48)
	NAMETEXTSHADOWCOLOR   = Color.new(31,71,24)
	
	# Draw information (text)
	def drawInfor(type,font=nil)
		# Set trainer
		saveData = self.fileLoad
		trainer = saveData[:player]
		# Set mystery gift and language
		if type==1
			mystery = trainer.mystery_gift_unlocked
			@mysgif = mystery
			@qinfor+=1 if mystery
			@qinfor+=1 if Settings::LANGUAGES.length>=2
			(0...@qinfor).each { |i|
				create_sprite("panel load #{i}","loadPanels",@viewport)
				w = 384; h = 46 
				set_src_wh_sprite("panel load #{i}",w,h)
				x = 16; y = 444
				set_src_xy_sprite("panel load #{i}",x,y)
				x = 24*2 + 8; y = 16*2 + 48*i + 112*2
				set_xy_sprite("panel load #{i}",x,y) 
			} if @qinfor>0
		end
		# Move panel (information)
		create_sprite("infor panel 1","loadPanels",@viewport)
		w = 408; h = 222
		set_src_wh_sprite("infor panel 1",w,h)
		x = 0; y = 222
		set_src_xy_sprite("infor panel 1",x,y)
		x = 24*2; y = 16*2
		set_xy_sprite("infor panel 1",x,y)
		# Set
		create_sprite_2("text",@viewport)
		framecount = saveData[:frame_count]
		totalsec = (framecount || 0) / Graphics.frame_rate
		bitmap = @sprites["text"].bitmap
		textpos = []
		# Text of trainer
		x = 24 * 2; y = 16 * 2
		title = (type==0)? "Save" : (type==1)?  "Load" : "Delete"
		textpos << [_INTL("#{title}"),16*2+x,5*2+y,0,TEXTCOLOR,TEXTSHADOWCOLOR]
		textpos << [_INTL("Badges:"),16*2+x,56*2+y,0,TEXTCOLOR,TEXTSHADOWCOLOR]
		textpos << [trainer.badge_count.to_s,103*2+x,56*2+y,1,TEXTCOLOR,TEXTSHADOWCOLOR]
		textpos << [_INTL("Version:"),16*2+x,72*2+y,0,TEXTCOLOR,TEXTSHADOWCOLOR]
		textpos << [saveData[:game_version],103*2+x,72*2+y,1,TEXTCOLOR,TEXTSHADOWCOLOR]
		textpos << [_INTL("Time:"),16*2+x,88*2+y,0,TEXTCOLOR,TEXTSHADOWCOLOR]
		hour = totalsec / 60 / 60
		min  = totalsec / 60 % 60
		if hour > 0
			textpos<<[_INTL("{1}h {2}m",hour,min),103*2+x,88*2+y,1,TEXTCOLOR,TEXTSHADOWCOLOR]
		else
			textpos<<[_INTL("{1}m",min),103*2+x,88*2+y,1,TEXTCOLOR,TEXTSHADOWCOLOR]
		end
		textpos << [trainer.name,56*2+x,32*2+y,0,NAMETEXTCOLOR,NAMETEXTSHADOWCOLOR]
		mapid = saveData[:map_factory].map.map_id
		mapname = pbGetMapNameFromId(mapid)
		mapname.gsub!(/\\PN/,trainer.name)
		textpos << [mapname,193*2+x,5*2+y,1,TEXTCOLOR,TEXTSHADOWCOLOR]
		# Load menu
		if type == 1
			# Mystery gift / Language
			string = []
			string<<_INTL("Mystery Gift") if mystery
			string<<_INTL("Language") if Settings::LANGUAGES.length>=2
			if @qinfor>0
				(0...@qinfor).each { |i|
				str = string[i]
				x1 = x + 36 + 8
				y1 = y + 5 + 112*2 + 48*i
				textpos<<[str,x1,y1,0,TEXTCOLOR,TEXTSHADOWCOLOR]
				}
			end
		end
		# Set text
		if font.nil?
			pbSetSystemFont(bitmap)
		else
			bitmap.font.name = font
		end
		pbDrawTextPositions(bitmap,textpos)

		# Set trainer (draw)
		if !trainer || !trainer.party
			# Fade
			pbFadeInAndShow(@sprites) { update }
			return
		else
			meta = GameData::Metadata.get_player(trainer.character_ID)
			if meta
				filename = pbGetPlayerCharset(meta,1,trainer,true)
				@sprites["player"] = TrainerWalkingCharSprite.new(filename,@viewport)
				charwidth  = @sprites["player"].bitmap.width
				charheight = @sprites["player"].bitmap.height
				@sprites["player"].x        = 56*2-charwidth/8
				@sprites["player"].y        = 56*2-charheight/8
				@sprites["player"].src_rect = Rect.new(0,0,charwidth/4,charheight/4)
			end
			for i in 0...trainer.party.length
				@sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i],@viewport)
				@sprites["party#{i}"].setOffset(PictureOrigin::Center)
				@sprites["party#{i}"].x = (167+33*(i%2))*2
				@sprites["party#{i}"].y = (56+25*(i/2))*2
				@sprites["party#{i}"].z = 99999
			end
			# Fade
			pbFadeInAndShow(@sprites) { update }
		end
	end
	
	def choosePanelInfor
		if @posinfor==0
		w = 408; h = 222
		set_src_wh_sprite("infor panel 1",w,h)
		x = 0; y = 222
		set_src_xy_sprite("infor panel 1",x,y)
		x = 24*2; y = 16*2
		set_xy_sprite("infor panel 1",x,y)
		else
		w = 384; h = 46
		set_src_wh_sprite("infor panel 1",w,h)
		x = 16; y = 490
		set_src_xy_sprite("infor panel 1",x,y)
		x = 24*2 + 8
		y = 16*2 + 48*(@posinfor-1) + 112*2
		set_xy_sprite("infor panel 1",x,y)
		end
	end
	#-------------------------------------------------------------------------------
	# Delete
	#-------------------------------------------------------------------------------
	def deleteFile
			savefile = FileSave.name(@position+1, false)
			begin
		SaveData.delete_file(savefile)
		pbMessage(_INTL('The saved data was deleted.'))
		rescue SystemCallError
		pbMessage(_INTL('All saved data could not be deleted.'))
		end
	end
	#-------------------------------------------------------------------------------
	#  Load File
	#-------------------------------------------------------------------------------
	def load_save_file(file_path,convert=false)
		save_data = SaveData.read_from_file(file_path,convert)
		return save_data
	end

	# Called if all save data is invalid.
	# Prompts the player to delete the save files.
	def prompt_save_deletion
		pbMessage(_INTL('Cant load this save file'))
		pbMessage(_INTL('The save file is corrupt, or is incompatible with this game.'))
		exit unless pbConfirmMessageSerious(_INTL('Do you want to delete this save file?'))
		self.deleteFile
		$game_system   = Game_System.new
		$PokemonSystem = PokemonSystem.new
	end

	def fileLoad(convert=false)
		return load_save_file(FileSave.name(@position+1),convert)
	end

	#-------------------------------------------------------------------------------
	# Set SE for input
	#-------------------------------------------------------------------------------
	def checkInput(name)
		if Input.trigger?(name)
			(name==Input::BACK)? pbPlayCloseMenuSE : pbPlayDecisionSE
			return true
		end
		return false
	end
	#-------------------------------------------------------------------------------
	# Set bitmap
	#-------------------------------------------------------------------------------
	# Image
	def create_sprite(spritename,filename,vp,dir="Pictures")
		@sprites["#{spritename}"] = Sprite.new(vp)
		@sprites["#{spritename}"].bitmap = Bitmap.new("Graphics/#{dir}/#{filename}")
	end

	# Set x, y
	def set_xy_sprite(spritename,x,y)
		@sprites["#{spritename}"].x = x
		@sprites["#{spritename}"].y = y
	end

	# Set src
	def set_src_wh_sprite(spritename,w,h)
		@sprites["#{spritename}"].src_rect.width = w
		@sprites["#{spritename}"].src_rect.height = h
	end

	def set_src_xy_sprite(spritename,x,y)
		@sprites["#{spritename}"].src_rect.x = x
		@sprites["#{spritename}"].src_rect.y = y
	end
	
	#-------------------------------------------------------------------------------
	# Text
	#-------------------------------------------------------------------------------
	# Draw
	def create_sprite_2(spritename,vp)
		@sprites["#{spritename}"] = Sprite.new(vp)
		@sprites["#{spritename}"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
		@sprites["#{spritename}"].bitmap.clear
	end
	#-------------------------------------------------------------------------------
	def dispose
		pbDisposeSpriteHash(@sprites)
	end

	def update
		pbUpdateSpriteHash(@sprites)
	end

	def update_ingame
		Graphics.update
		Input.update
		pbUpdateSpriteHash(@sprites)
	end

	def endScene
		dispose
		@viewport.dispose
	end
end