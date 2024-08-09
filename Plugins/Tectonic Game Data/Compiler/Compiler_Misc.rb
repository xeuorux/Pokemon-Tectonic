module Compiler
	module_function

    def compile_battle_metadata
        # Signature moves
        signatureMoveInfo = getSignatureMoves()

        signatureMoveInfo.each do |moveID,signatureHolder|
            GameData::Move.get(moveID).signature_of = signatureHolder
        end

        # Signature abilities
        signatureAbilityInfo = getSignatureAbilities()

        signatureAbilityInfo.each do |abilityID,signatureHolder|
            GameData::Ability.get(abilityID).signature_of = signatureHolder
        end

        # Move learning metadata
        levelUpLearnersPerMove = {}
        otherLearnersPerMove = {}
        GameData::Move.each do |moveData|
            next unless moveData.learnable?
            levelUpLearnersPerMove[moveData.id] = []
            otherLearnersPerMove[moveData.id] = []
        end
        GameData::Species.each do |speciesData|
            next unless speciesData.form == 0
            speciesData.moves.each do |learnset_entry|
                move_id = learnset_entry[1]
                level_learned = learnset_entry[0]
                levelUpLearnerEntry = [speciesData.id,level_learned]
                levelUpLearnersPerMove[move_id].push(levelUpLearnerEntry) unless levelUpLearnersPerMove[move_id].any? { |existingLearnerEntry|
                    existingLearnerEntry[0] == speciesData.id
                }
                
            end

            speciesData.learnable_moves.each do |moveID|
                otherLearnersPerMove[moveID].push(speciesData.id)
            end
        end

        levelUpLearnersPerMove.each do |moveID, levelUpLearnersForMove|
            GameData::Move.get(moveID).level_up_learners = levelUpLearnersForMove
        end

        otherLearnersPerMove.each do |moveID, otherLearnersPerMove|
            GameData::Move.get(moveID).other_learners = otherLearnersPerMove
        end

        # Save all data
        GameData::Move.save
        GameData::Ability.save
        Graphics.update
    end
end