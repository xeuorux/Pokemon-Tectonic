module GameData
    def self.load_all
        echoln("Loading all game data.")
        Type.load
        Ability.load
        Move.load
        Item.load
        BerryPlant.load
        Species.load
        SpeciesOld.load
        Ribbon.load
        Encounter.load
        TrainerType.load
        Trainer.load
        Metadata.load
        MapMetadata.load
        Policy.load
        echoln("Loading avatar data")
        Avatar.load
    end
end