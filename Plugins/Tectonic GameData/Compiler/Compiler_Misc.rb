module Compiler
	module_function

    def compile_signature_metadata
        signatureMoveInfo = getSignatureMoves()

        signatureMoveInfo.each do |moveID,signatureHolder|
        GameData::Move.get(moveID).signature_of = signatureHolder
        end

        signatureAbilityInfo = getSignatureAbilities()

        signatureAbilityInfo.each do |abilityID,signatureHolder|
        GameData::Ability.get(abilityID).signature_of = signatureHolder
        end

        # Save all data
        GameData::Move.save
        GameData::Ability.save
        Graphics.update
    end
end