ItemHandlers::CanUseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item,pokemon,battler,move,firstAction,battle,scene,showMessages|
    if battle.pbPlayer.party_full? && $PokemonStorage.full?
      pbSceneDefaultDisplay(_INTL("There is no room left in the PC!"),scene) if showMessages
      next false
    end
    # NOTE: Using a Poké Ball consumes all your actions for the round. The code
    #       below is one half of making this happen; the other half is in def
    #       pbItemUsesAllActions?.
    if !firstAction
      pbSceneDefaultDisplay(_INTL("It's impossible to aim without being focused!"),scene) if showMessages
      next false
    end
    if battler.semiInvulnerable?
      pbSceneDefaultDisplay(_INTL("It's no good! It's impossible to aim at a Pokémon that's not in sight!"),scene) if showMessages
      next false
    end
    # NOTE: The code below stops you from throwing a Poké Ball if there is more
    #       than one unfainted opposing Pokémon. (Snag Balls can be thrown in
    #       this case, but only in trainer battles, and the trainer will deflect
    #       them if they are trying to catch a non-Shadow Pokémon.)
    # if battle.pbOpposingBattlerCount>1
    #   if battle.pbOpposingBattlerCount==2
    #     pbSceneDefaultDisplay(_INTL("It's no good! It's impossible to aim when there are two Pokémon!"),scene) if showMessages
    #   else
    #     pbSceneDefaultDisplay(_INTL("It's no good! It's impossible to aim when there are more than one Pokémon!"),scene) if showMessages
    #   end
    #   next false
    # end
    next true
  }
)

ItemHandlers::UseInBattle.addIf(proc { |item| GameData::Item.get(item).is_poke_ball? },   # Poké Balls
  proc { |item,battler,battle|
    next battle.pbThrowPokeBall(battler.index,item)
  }
)