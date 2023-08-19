#===============================================================================
# Load various wild battle music
#===============================================================================
def pbGetWildBattleBGM(_wildParty) # wildParty is an array of Pokémon objects
    return $PokemonGlobal.nextBattleBGM.clone if $PokemonGlobal.nextBattleBGM
    ret = nil
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.wild_battle_BGM : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.wild_battle_BGM
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle wild")
    return ret
end

def pbGetWildVictoryME
    return $PokemonGlobal.nextBattleME.clone if $PokemonGlobal.nextBattleME
    ret = nil
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.wild_victory_ME : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.wild_victory_ME
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle victory")
    ret.name = "../../Audio/ME/" + ret.name
    return ret
end

def pbGetWildCaptureME
    return $PokemonGlobal.nextBattleCaptureME.clone if $PokemonGlobal.nextBattleCaptureME
    ret = nil
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.wild_capture_ME : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.wild_capture_ME
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle capture success")
    ret.name = "../../Audio/ME/" + ret.name
    return ret
end

#===============================================================================
# Load/play various trainer battle music
#===============================================================================
def pbPlayTrainerIntroME(trainer_type)
    trainer_type_data = GameData::TrainerType.get(trainer_type)
    return if nil_or_empty?(trainer_type_data.intro_ME)
    bgm = pbStringToAudioFile(trainer_type_data.intro_ME)
    pbMEPlay(bgm)
end

def pbGetTrainerBattleBGM(trainer) # can be a Player, NPCTrainer or an array of them
    return $PokemonGlobal.nextBattleBGM.clone if $PokemonGlobal.nextBattleBGM
    ret = nil
    music = nil
    trainerarray = trainer.is_a?(Array) ? trainer : [trainer]
    trainerarray.each do |t|
        trainer_type_data = GameData::TrainerType.get(t.trainer_type)
        music = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
    end
    ret = pbStringToAudioFile(music) if music && music != ""
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.trainer_battle_BGM : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.trainer_battle_BGM
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle trainer")
    return ret
end

def pbGetTrainerBattleBGMFromType(trainertype)
    return $PokemonGlobal.nextBattleBGM.clone if $PokemonGlobal.nextBattleBGM
    trainer_type_data = GameData::TrainerType.get(trainertype)
    ret = trainer_type_data.battle_BGM if trainer_type_data.battle_BGM
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.trainer_battle_BGM : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.trainer_battle_BGM
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle trainer")
    return ret
end

def pbGetTrainerVictoryME(trainer) # can be a Player, NPCTrainer or an array of them
    return $PokemonGlobal.nextBattleME.clone if $PokemonGlobal.nextBattleME
    music = nil
    trainerarray = trainer.is_a?(Array) ? trainer : [trainer]
    trainerarray.each do |t|
        trainer_type_data = GameData::TrainerType.get(t.trainer_type)
        music = trainer_type_data.victory_ME if trainer_type_data.victory_ME
    end
    ret = nil
    ret = pbStringToAudioFile(music) if music && music != ""
    unless ret
        # Check map metadata
        map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
        music = map_metadata ? map_metadata.trainer_victory_ME : nil
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    unless ret
        # Check global metadata
        music = GameData::Metadata.get.trainer_victory_ME
        ret = pbStringToAudioFile(music) if music && music != ""
    end
    ret ||= pbStringToAudioFile("Battle victory")
    ret.name = "../../Audio/ME/" + ret.name
    return ret
end
