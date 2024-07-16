# # Defeated gym 1
# AchievementHandlers.registerGlobalSwitchAchievement(
#     :DEFEAT_GYM_1,
#     4,
# 	proc { |achievementID,switchID, value|
# 		next value
# 	}
# )

# # Achieved 8 badges
# AchievementHandlers.registerGlobalVariableAchievement(
#     :DEFEAT_ALL_GYMS,
#     27,
# 	proc { |achievementID,variableID, value|
# 		next value >= 8
# 	}
# )