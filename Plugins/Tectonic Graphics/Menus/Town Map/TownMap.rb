def getDisplayedPositionOfGameMap(gameMapID)
  mapInfos = pbLoadMapInfos
  displayedPosition = nil
  while gameMapID >= 1 && displayedPosition.nil?
    map_metadata = GameData::MapMetadata.try_get(gameMapID)
    if map_metadata.nil? || map_metadata.town_map_position.nil?
      gameMapID = mapInfos[gameMapID].parent_id
    else
      displayedPosition = map_metadata.town_map_position
    end
  end
  return displayedPosition
end

#===============================================================================
#
#===============================================================================
def pbShowMap(region=-1,wallmap=true)
  pbFadeOutIn {
    scene = PokemonRegionMap_Scene.new(region,wallmap)
    screen = PokemonRegionMapScreen.new(scene)
    screen.pbStartScreen
  }
end