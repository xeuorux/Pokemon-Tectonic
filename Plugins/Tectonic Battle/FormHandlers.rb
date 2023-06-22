MultipleForms.register(:SILVALLY,{
  "getForm" => proc { |pkmn|
    next nil unless pkmn.hasAbility?(:RKSSYSTEM)
    next 0 unless pkmn.hasItem?(:MEMORYSET)
    next GameData::Type.get(pkmn.itemTypeChosen).id_number
  }
})

MultipleForms.register(:ARCEUS,{
  "getForm" => proc { |pkmn|
    next nil unless pkmn.hasAbility?(:MULTITYPE)
    next 0 unless pkmn.hasItem?(:PRISMATICPLATE)
    next GameData::Type.get(pkmn.itemTypeChosen).id_number
  }
})

MultipleForms.register(:AMPHAROS, {
    "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
        next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
    },
})

MultipleForms.register(:GARCHOMP, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  },
})

MultipleForms.register(:GYARADOS, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  },
})

MultipleForms.register(:LYCANROC, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.form == 1 && (pkmn.fainted? || endBattle)
  },
})

MultipleForms.register(:ZAMAZENTA,{
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:RUSTEDSHIELD)
    next 0
  }
})

MultipleForms.register(:ZACIAN,{
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:RUSTEDSWORD)
    next 0
  }
})

MultipleForms.register(:PUMPKABOO, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.fainted? || endBattle
  },
})

MultipleForms.register(:GOURGEIST, {
  "getFormOnLeavingBattle" => proc { |pkmn, _battle, _usedInBattle, endBattle|
      next 0 if pkmn.fainted? || endBattle
  },
})

MultipleForms.register(:SHAYMIN,{
  "getForm" => proc { |pkmn|
    next 0 if pkmn.fainted? || pkmn.frozen? || PBDayNight.isNight?
  }
})

MultipleForms.register(:URSHIFU,{
  "onSetForm" => proc { |pkmn, form, oldForm|
    form_moves = %i[WICKEDBLOW SURGINGSTRIKES]

    move_index = -1
    pkmn.moves.each_with_index do |move, i|
      next unless form_moves.any? { |m| m == move.id }
      move_index = i
      break
    end

    # Try learning that form's unique move
    new_move_id = form_moves[form - 1]
    if move_index >= 0
      # Knows another form's unique move; replace it
      old_move_name = pkmn.moves[move_index].name
      pkmn.moves[move_index].id = new_move_id
      new_move_name = pkmn.moves[move_index].name
      pbMessage(_INTL("1,\\wt[16] 2, and\\wt[16]...\\wt[16] ...\\wt[16] ... Ta-da!\\se[Battle ball drop]\1"))
      pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...\1", pkmn.name, old_move_name))
      pbMessage(_INTL("\\se[]{1} learned {2}!\\se[Pkmn move learnt]", pkmn.name, new_move_name))
    else
      # Just try to learn this form's unique move
      pbLearnMove(pkmn, new_move_id, true)
    end
  }
})