DebugMenuCommands.register("addfalsemetadata", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Add false metadata"),
  "description" => _INTL("For the important first 3 entries of map metadata, add false where there is nil."),
  "effect"      => proc {
    GameData::MapMetadata.each do |map_metadata|
      metadata_hash = {
        :id                   => map_metadata.id,
        :outdoor_map          => map_metadata.outdoor_map,
        :announce_location    => map_metadata.announce_location,
        :can_bicycle          => map_metadata.can_bicycle,
        :always_bicycle       => map_metadata.always_bicycle,
        :teleport_destination => map_metadata.teleport_destination,
        :weather              => map_metadata.weather,
        :town_map_position    => map_metadata.town_map_position,
        :dive_map_id          => map_metadata.dive_map_id,
        :dark_map             => map_metadata.dark_map,
        :safari_map           => map_metadata.safari_map,
        :snap_edges           => map_metadata.snap_edges,
        :random_dungeon       => map_metadata.random_dungeon,
        :battle_background    => map_metadata.battle_background,
        :wild_battle_BGM      => map_metadata.wild_battle_BGM,
        :trainer_battle_BGM   => map_metadata.trainer_battle_BGM,
        :wild_victory_ME      => map_metadata.wild_victory_ME,
        :trainer_victory_ME   => map_metadata.trainer_victory_ME,
        :wild_capture_ME      => map_metadata.wild_capture_ME,
        :town_map_size        => map_metadata.town_map_size,
        :battle_environment   => map_metadata.battle_environment
      }
      metadata_hash[:outdoor_map] = false if metadata_hash[:outdoor_map].nil?
      metadata_hash[:announce_location] = false if metadata_hash[:announce_location].nil?
      metadata_hash[:can_bicycle] = false if metadata_hash[:can_bicycle].nil?
      # Add metadata's data to records
      GameData::MapMetadata.register(metadata_hash)
      GameData::MapMetadata.save
    end
    Compiler.write_metadata
  }
})