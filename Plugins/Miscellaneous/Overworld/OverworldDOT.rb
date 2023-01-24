Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount % 8 == 0
    flashed = false
	  frontOfParty = $Trainer.first_able_pokemon
    $Trainer.able_party.each_with_index do |pokemon,index|
      if pokemon.status == :BURN && !pokemon.hasAbility?(:BURNHEAL)
        if !flashed
		      pbFlash(Color.new(255, 119, 0, 128), 4)
          flashed = true
        end
        pokemon.hp -= 2 if pokemon.hp>2 || Settings::POISON_FAINT_IN_FIELD
        if pokemon.hp <= 2 && !Settings::POISON_FAINT_IN_FIELD
          pokemon.status = :NONE
          pbMessage(_INTL("{1} survived the burn.\\nThe burn faded away!\1",pokemon.name))
          next
        elsif pokemon.hp <= 0
          pokemon.changeHappiness("faint")
          pokemon.status = :NONE
          pbMessage(_INTL("{1} fainted...",pokemon.name))
          if index == 0
            stowFollowerIfActive()
            refreshFollow()
          end
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
	    elsif pokemon.status == :POISON && !pokemon.hasAbility?(:POISONHEAL)
        if !flashed
          pbFlash(Color.new(255, 0, 119, 128), 4)
          flashed = true
        end
        pokemon.hp -= 2 if pokemon.hp>2 || Settings::POISON_FAINT_IN_FIELD
        if pokemon.hp <= 2 && !Settings::POISON_FAINT_IN_FIELD
          pokemon.status = :NONE
          pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!\1",pokemon.name))
          next
        elsif pokemon.hp <= 0
          pokemon.changeHappiness("faint")
          pokemon.status = :NONE
          pbMessage(_INTL("{1} fainted...",pokemon.name))
          if index == 0
            stowFollowerIfActive()
            refreshFollow()
          end
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      elsif pokemon.status == :FROSTBITE && !pokemon.hasAbility?(:FROSTHEAL)
        if !flashed
          pbFlash(Color.new(0, 119, 119, 128), 4)
          flashed = true
        end
        pokemon.hp -= 2 if pokemon.hp>2 || Settings::POISON_FAINT_IN_FIELD
        if pokemon.hp <= 2 && !Settings::POISON_FAINT_IN_FIELD
          pokemon.status = :NONE
          pbMessage(_INTL("{1} survived the frostbite.\\nThe frostbite faded away!\1",pokemon.name))
          next
        elsif pokemon.hp <= 0
          pokemon.changeHappiness("faint")
          pokemon.status = :NONE
          pbMessage(_INTL("{1} fainted...",pokemon.name))
          if index == 0
            stowFollowerIfActive()
            refreshFollow()
          end
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}

def pbCheckAllFainted
  if $Trainer.able_pokemon_count == 0
    pbMessage(_INTL("You have no more Pokémon that can fight!\1"))
    pbMessage(_INTL("You blacked out!"))
    pbBGMFade(1.0)
    pbBGSFade(1.0)
    blackOut
  end
end