class PokemonTrainerCard_Scene
    def pbDrawTrainerCardFront
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      baseColor   = Color.new(72,72,72)
      shadowColor = Color.new(160,160,160)
      totalsec = Graphics.frame_count / Graphics.frame_rate
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
      $PokemonGlobal.startTime = Time.now if !$PokemonGlobal.startTime
      starttime = _INTL("{1} {2}, {3}",
         pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
         $PokemonGlobal.startTime.day,
         $PokemonGlobal.startTime.year)
      textPositions = [
         [_INTL("Name"),34,58,0,baseColor,shadowColor],
         [$Trainer.name,302,58,1,baseColor,shadowColor],
         [_INTL("ID No."),332,58,0,baseColor,shadowColor],
         [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
         [_INTL("Money"),34,106,0,baseColor,shadowColor],
         [_INTL("${1}",$Trainer.money.to_s_formatted),302,106,1,baseColor,shadowColor],
         [_INTL("Pokédex"),34,154,0,baseColor,shadowColor],
         [sprintf("%d/%d",$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count),302,154,1,baseColor,shadowColor],
         [_INTL("Time"),34,202,0,baseColor,shadowColor],
         [time,302,202,1,baseColor,shadowColor],
         [_INTL("Started"),34,250,0,baseColor,shadowColor],
         [starttime,302,250,1,baseColor,shadowColor]
      ]
      pbDrawTextPositions(overlay,textPositions)
      x = 72
      region = pbGetCurrentRegion(0) # Get the current region
      imagePositions = []
      for i in 0...8
        if $Trainer.badges[i+region*8]
          imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges",x,310,i*32,region*32,32,32])
        end
        x += 48
      end
      pbDrawImagePositions(overlay,imagePositions)
    end
end