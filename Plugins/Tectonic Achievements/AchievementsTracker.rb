class AchievementsTracker
    def self.achievementsFilePath
        return System.data_directory + "/Achievements.dat"
    end

    def initialize
        @achievementsEarned = []
    end

    def isAchievementUnlocked?(achievementID)
        return @achievementsEarned.include?(achievementID)
    end

    def unlockAchievement(achievementID,ignoreAlreadyUnlocked = false)
        pbMessage(_INTL("Invalid Achievement #{achievementID}.")) unless GameData::Achievement.try_get(achievementID)

        if isAchievementUnlocked?(achievementID) && !ignoreAlreadyUnlocked
            echoln(_INTL("Achievement {1} is already unlocked! Cannot unlock again.",achievementID))
            return
        end
        @achievementsEarned.push(achievementID)
        storeAchievements
        echoln(_INTL("Unlocking achievement {1}.",achievementID))
        notifyAchievement(achievementID)
    end

    def notifyAchievement(achievementID)
        pbMessage(_INTL("Invalid Achievement #{achievement_id}.")) unless GameData::Achievement.try_get(achievementID)
        showAchievementPopup(GameData::Achievement.get(achievementID).name)
    end

    def showAchievementPopup(name)
        label = _INTL("Achievement Unlocked:\\n\\c[2]{1}",name)

        pbWait(10)
        pbMessage(_INTL("\\cl\\l[2]\\op\\wu<ac>{1}</ac>\\wtnp[{2}]", label, achievementsPopupDuration))
    end

    def storeAchievements
        File.open(AchievementsTracker.achievementsFilePath, 'wb') { |file| Marshal.dump($AchievementsTracker, file) }
    end

    def dumpAchievements
        echoln("List of unlocked achievements:")

        if @achievementsEarned.empty?
            echoln("None")
        else
            @achievementsEarned.each do |achievementID|
                echoln(achievementID.to_s)
            end
        end
    end

    def clearAchievements
        @achievementsEarned.clear
        storeAchievements
        pbMessage(_INTL("Achievements cleared."))
    end
end

def achievementsPopupDuration
	dur = 80
	dur -= 5 * $PokemonSystem.textspeed
	return dur
end

def isAchievementUnlocked?(achievementID)
    return $AchievementsTracker.isAchievementUnlocked?(achievementID)
end

def unlockAchievement(achievementID,ignoreAlreadyUnlocked = false)
    $AchievementsTracker.unlockAchievement(achievementID,ignoreAlreadyUnlocked)
end

def dumpAchievements
    $AchievementsTracker.dumpAchievements
end

def clearAchievements
    $AchievementsTracker.clearAchievements
end

def SAP(text)
    $AchievementsTracker.showAchievementPopup(text)
end

# Run on game start
if File.directory?(System.data_directory)
    if File.file?(AchievementsTracker.achievementsFilePath)
        File.open(AchievementsTracker.achievementsFilePath) do |file|
            $AchievementsTracker = Marshal.load(file)
        end
        echoln("Loaded the existing Achievements Tracker data file.")
    else
        $AchievementsTracker = AchievementsTracker.new
        $AchievementsTracker.storeAchievements
        echoln("Creating a new Achievements Tracker.")
    end
else
    raise _INTL("Could not create game achievements file.")
end