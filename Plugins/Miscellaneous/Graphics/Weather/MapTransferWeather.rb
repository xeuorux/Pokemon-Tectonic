#===============================================================================
# Checks when moving between maps
#===============================================================================
# Clears the weather of the old map, if the old map has defined weather and the
# new map either has the same name as the old map or doesn't have defined
# weather.
Events.onMapChanging += proc { |_sender, e|
  new_map_ID = e[0]
  next if new_map_ID == 0
  old_map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  #next if !old_map_metadata || !old_map_metadata.weather
  map_infos = pbLoadMapInfos
  if $game_map.name == map_infos[new_map_ID].name
    new_map_metadata = GameData::MapMetadata.try_get(new_map_ID)
    next if new_map_metadata && new_map_metadata.weather
  end
  $game_screen.weather(:None, 0, 0)
}