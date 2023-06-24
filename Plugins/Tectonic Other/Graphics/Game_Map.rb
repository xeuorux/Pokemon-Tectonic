def tile_ID_from_coordinates(x, y)
    return x * PokemonTilesetScene::TILES_PER_AUTOTILE if y == 0   # Autotile
    return PokemonTilesetScene::TILESET_START_ID + (y - 1) * PokemonTilesetScene::TILES_PER_ROW + x
end

def coordinates_from_tild_ID (tileID)
    return [tileID / PokemonTilesetScene::TILES_PER_AUTOTILE, 0] if tileID < PokemonTilesetScene::TILESET_START_ID
    x = (tileID - PokemonTilesetScene::TILESET_START_ID) % PokemonTilesetScene::TILES_PER_ROW
    y = (tileID - PokemonTilesetScene::TILESET_START_ID) / PokemonTilesetScene::TILES_PER_ROW + 1
    return [x,y]
end

class Game_Map
    def tileset_id;     return @map.tileset_id;     end
    def bgm;            return @map.bgm;            end

    def getTileIDForEventAtCoordinate(event, x, y)
        coordinateX, coordinateY = coordinates_from_tild_ID(event.tile_id)
        newCoordinateX = coordinateX + (x - event.x)
        newCoordinateY = coordinateY + (y - event.y)
        return tile_ID_from_coordinates(newCoordinateX, newCoordinateY)
    end

    def passable?(x, y, d, self_event = nil)
        if !$game_temp.player_transferring && pbGetFollowerDependentEvent && self_event != $game_player
            dependent = pbGetFollowerDependentEvent
            return false if self_event != dependent && dependent.x == x && dependent.y == y
        end
        return false unless valid?(x, y)
        bit = (1 << (d / 2 - 1)) & 0x0f
        for event in events.values
          next if event.tile_id <= 0
          next if event == self_event
          next unless event.at_coordinate?(x, y)
          next if event.through
          tileID = getTileIDForEventAtCoordinate(event, x, y)
          terrainTag = GameData::TerrainTag.try_get(@terrain_tags[tileID])
          next if terrainTag.ignore_passability
          return true if terrainTag.ignore_passability
          return false if self_event && self_event != $game_player &&
            self_event.name[/trippable/] && terrainTag.id == :TripWire
          return true if terrainTag.ice
          return true if terrainTag.ledge
          return true if terrainTag.can_surf
          return true if terrainTag.bridge
          passage = @passages[tileID]
          return false if passage & bit != 0
          return false if passage & 0x0f == 0x0f
          return true if @priorities[tileID] == 0 && !event.name[/passablemult/]
        end
        return playerPassable?(x, y, d, self_event) if self_event == $game_player
        # All other events
        newx = x
        newy = y
        case d
        when 1
          newx -= 1
          newy += 1
        when 2
          newy += 1
        when 3
          newx += 1
          newy += 1
        when 4
          newx -= 1
        when 6
          newx += 1
        when 7
          newx -= 1
          newy -= 1
        when 8
          newy -= 1
        when 9
          newx += 1
          newy -= 1
        end
        return false if !valid?(newx, newy)
        for i in [2, 1, 0]
          tile_id = data[x, y, i]
          terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
          # If already on water, only allow movement to another water tile
          if self_event != nil && terrain.can_surf_freely
            for j in [2, 1, 0]
              facing_tile_id = data[newx, newy, j]
              return false if facing_tile_id == nil
              facing_terrain = GameData::TerrainTag.try_get(@terrain_tags[facing_tile_id])
              if facing_terrain.id != :None && !facing_terrain.ignore_passability
                return facing_terrain.can_surf_freely
              end
            end
            return false
          # Can't walk onto ice
          elsif terrain.ice
            return false
          elsif self_event != nil && self_event.x == x && self_event.y == y
            # Can't walk onto ledges
            for j in [2, 1, 0]
              facing_tile_id = data[newx, newy, j]
              return false if facing_tile_id == nil
              facing_terrain = GameData::TerrainTag.try_get(@terrain_tags[facing_tile_id])
              return false if facing_terrain.ledge
              break if facing_terrain.id != :None && !facing_terrain.ignore_passability
            end
          end
          # Regular passability checks
          if !terrain || !terrain.ignore_passability
            passage = @passages[tile_id]
            return false if passage & bit != 0 || passage & 0x0f == 0x0f
            return true if @priorities[tile_id] == 0
          end
        end
        return true
    end

    def passableStrict?(x, y, d, self_event = nil)
      return false if !valid?(x, y)
      for event in events.values
        next if event == self_event || event.tile_id <= 0 || event.through
        next unless event.at_coordinate?(x, y)
        tileID = getTileIDForEventAtCoordinate(event, x, y)
        terrainTag = GameData::TerrainTag.try_get(@terrain_tags[tileID])
        return true if terrainTag.ignore_passability
        return true if terrainTag.ice
        return true if terrainTag.ledge
        return true if terrainTag.can_surf
        return true if terrainTag.bridge
        return false if @passages[tileID] & 0x0f != 0
        return true if @priorities[tileID] == 0
      end
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        terrainTag = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
        return true if terrainTag.ignore_passability
        return true if terrainTag.ice
        return true if terrainTag.ledge
        return true if terrainTag.can_surf
        return true if terrainTag.bridge
        return false if @passages[tile_id] & 0x0f != 0
        return true if @priorities[tile_id] == 0
      end
      return true
    end

    def terrain_tag(x,y,countBridge=false)
      if valid?(x, y)
        for i in [2, 1, 0]
          tile_id = data[x, y, i]
          terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
          next if terrain.id == :None || terrain.ignore_passability
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
      end
      return GameData::TerrainTag.get(:None)
    end

    def encounter_terrain_tag(x,y,countBridge=false)
      if valid?(x, y)
        for i in [2, 1, 0]
          tile_id = data[x, y, i]
          terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
          next unless terrain.encounter_tile
          next if !countBridge && terrain.bridge && $PokemonGlobal.bridge == 0
          return terrain
        end
      end
      return GameData::TerrainTag.get(:None)
    end
  end