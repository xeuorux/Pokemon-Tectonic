# Burn party Pokémon
Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount%4==0 && Settings::POISON_IN_FIELD
    flashed = false
    for i in $Trainer.able_party
      if i.status == :BURN && !i.hasAbility?(:WATERVEIL)
        if !flashed
          $game_screen.start_flash(Color.new(255,119,0,128), 4)
          flashed = true
        end
        i.hp -= 1 if i.hp>1 || Settings::POISON_FAINT_IN_FIELD
        if i.hp==1 && !Settings::POISON_FAINT_IN_FIELD
          i.status = :NONE
          pbMessage(_INTL("{1} survived the burn.\\nThe burn was healed!\1",i.name))
          next
        elsif i.hp==0
          i.changeHappiness("faint")
          i.status = :NONE
          pbMessage(_INTL("{1} fainted...",i.name))
		  refreshFollow()
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}