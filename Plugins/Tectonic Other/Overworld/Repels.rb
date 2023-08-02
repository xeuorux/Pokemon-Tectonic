Events.onStepTaken += proc {
    if $PokemonGlobal.repel > 0 && !$game_player.terrain_tag.ice   # Shouldn't count down if on ice
      $PokemonGlobal.repel -= 1
      if $PokemonGlobal.repel <= 0
        if $PokemonBag.pbHasItem?(:REPEL) ||
           $PokemonBag.pbHasItem?(:SUPERREPEL) ||
           $PokemonBag.pbHasItem?(:MAXREPEL)
          if pbConfirmMessage(_INTL("The repellent's effect wore off! Would you like to use another one?"))
            ret = nil
            pbFadeOutIn {
              scene = PokemonBag_Scene.new
              screen = PokemonBagScreen.new(scene,$PokemonBag)
              ret = screen.pbChooseItemScreen(Proc.new { |item|
                [:REPEL, :SUPERREPEL, :MAXREPEL].include?(item)
              })
            }
            pbUseItem($PokemonBag,ret) if ret
          end
        else
          pbMessage(_INTL("The repellent's effect wore off!"))
        end
      end
    end
  }