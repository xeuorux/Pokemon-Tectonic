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

    def unlockAchievement(achievementID)
        @achievementsEarned.push(achievementID)
        storeAchievements
        showAchievement(achievementID)
    end

    def showAchievement(achievementID)
        name = achievementID.to_s
        name.gsub!(":","")
        name.gsub!("_"," ")
        name.gsub(/\w+/) do |word|
            word.capitalize
        end
        label = _INTL("Achievement Unlocked:\r\n{1}",name)
        $scene.spriteset.addUserSprite(LocationWindow.new(label,Graphics.frame_rate * 4))
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
end

def isAchievementUnlocked?(achievementID)
    return $AchievementsTracker.isAchievementUnlocked?(achievementID)
end

def unlockAchievement(achievementID)
    $AchievementsTracker.unlockAchievement(achievementID)
end

def dumpAchievements
    $AchievementsTracker.dumpAchievements
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