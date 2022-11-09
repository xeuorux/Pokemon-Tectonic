class PokeBattle_AI
	def beginAITester(user)
		count = 0
		@battle.eachBattler do |b|
			count += 1
		end
		if count > 2
			@battle.scene.pbDisplay("Auto tests not programmed to run in battles with more than 2 pokemon!")
			return
		end
		@battle.scene.pbDisplay("Beginning AI auto tests...")
		@battle.scene.pbUpdate
		testAllMoveScores(user)
	end

	def testAllMoveScores(user,show_analysis=false)
		scores = []
		target = []
		GameData::Move.each { |move|    # Get any one move
			next if move.zMove? || move.empoweredMove?
			score = 0
			begin
				moveObject = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(move.id))
				target = user.pbFindTargets([nil,nil,nil,-1],moveObject,user)
				newChoice = pbEvaluateMoveTrainer(user,moveObject,100)
				if newChoice
					score = newChoice[0]
					target = newChoice[1]
					targetName = target >= 0 ? @battle.battlers[target].name : "nothing"
					scores.push([move,targetName,score]) if show_analysis
				end
			rescue
				echoln("Exception encountered while evaluating move #{move.real_name} (#{move.function_code})\n")
			end
		}
		printAnalysis(scores) if show_analysis
	end
	
	def printAnalysis(scores)
		scores.sort_by!{ |score| -score[2]}
		echoln("The best five moves in this situation:\n")
		for i in 0..4
			entry = scores[i]
			echoln("#{i+1}: #{entry[0].id} #{entry[0].function_code} (targeting #{entry[1]}) -- #{entry[2]} \n")
		end
		echoln("The five worst non-zero moves in this situation:\n")
		for i in 0..4
			entry = scores[scores.length-(5-i)]
			echoln("#{i+1}: #{entry[0].id} #{entry[0].function_code} (targeting #{entry[1]}) -- #{entry[2]} \n")
		end
	end
end