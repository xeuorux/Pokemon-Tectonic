def pbGetPlayerCharset(meta,charset,trainer=nil,force=false)
    trainer = $Trainer if !trainer
    outfit = (trainer) ? trainer.outfit : 0
    if $game_player && $game_player.charsetData && !force
      return nil if $game_player.charsetData[0] == $Trainer.character_ID &&
                    $game_player.charsetData[1] == charset &&
                    $game_player.charsetData[2] == outfit
    end
    $game_player.charsetData = [$Trainer.character_ID,charset,outfit] if $game_player
    ret = meta[charset]
    ret = meta[1] if nil_or_empty?(ret)
    if pbResolveBitmap("Graphics/Characters/"+ret+"_"+outfit.to_s)
      ret = ret+"_"+outfit.to_s
    end
    return ret
  end
  
def pbUpdateVehicle
    meta = GameData::Metadata.get_player($Trainer.character_ID)
    if meta
    charset = 1                                 # Regular graphic
    if $PokemonGlobal.diving;     charset = 5   # Diving graphic
    elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
    elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
    end
    newCharName = pbGetPlayerCharset(meta,charset)
    $game_player.character_name = newCharName if newCharName
    end
end

def pbCancelVehicles(destination=nil)
    $PokemonTemp.dependentEvents.refresh_sprite(false) if destination.nil?
    $PokemonGlobal.surfing = false
    $PokemonGlobal.diving  = false
    $PokemonGlobal.bicycle = false if !destination || !pbCanUseBike?(destination)
    pbUpdateVehicle
end

def pbCanUseBike?(map_id)
    map_metadata = GameData::MapMetadata.try_get(map_id)
    return false if !map_metadata
    return true if map_metadata.always_bicycle
    val = map_metadata.can_bicycle || map_metadata.outdoor_map
    return (val) ? true : false
end

def pbMountBike
    return if $PokemonGlobal.bicycle
    $PokemonGlobal.bicycle = true
    pbUpdateVehicle
    bike_bgm = GameData::Metadata.get.bicycle_BGM
    pbCueBGM(bike_bgm, 0.5) if bike_bgm
    pbPokeRadarCancel
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    bike_anim = !(map_metadata && map_metadata.always_bicycle)
    $PokemonTemp.dependentEvents.refresh_sprite(bike_anim)
end

def pbDismountBike
    return if !$PokemonGlobal.bicycle
    $PokemonGlobal.bicycle = false
    pbUpdateVehicle
    $game_map.autoplayAsCue
    $PokemonTemp.dependentEvents.refresh_sprite(true)
end
  