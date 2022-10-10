# Gather soot from soot grass
Events.onStepTakenFieldMovement += proc { |_sender,e|
    event = e[0]   # Get the event affected by field movement
    thistile = $MapFactory.getRealTilePos(event.map.map_id,event.x,event.y)
    map = $MapFactory.getMap(thistile[0])
    for i in [2, 1, 0]
      tile_id = map.data[thistile[1],thistile[2],i]
      next if tile_id == nil
      next if GameData::TerrainTag.try_get(map.terrain_tags[tile_id]).id != :SootGrass
      if event == $game_player && GameData::Item.exists?(:SOOTSACK)
        $Trainer.soot += 1 if $PokemonBag.pbHasItem?(:SOOTSACK)
      end
      break
    end
  }