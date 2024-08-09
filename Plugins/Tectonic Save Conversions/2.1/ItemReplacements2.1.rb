SaveData.register_conversion(:replace_memories_21) do
  game_version '2.1.0'
  display_title 'Replacing Memories with a single memory disc item'
  to_all do |save_data|
    bag = save_data[:bag]
    memories = [:FIGHTINGMEMORY,
      :FLYINGMEMORY,
      :POISONMEMORY,
      :GROUNDMEMORY,
      :ROCKMEMORY,
      :BUGMEMORY,
      :GHOSTMEMORY,
      :STEELMEMORY,
      :FIREMEMORY,
      :WATERMEMORY,
      :GRASSMEMORY,
      :ELECTRICMEMORY,
      :PSYCHICMEMORY,
      :ICEMEMORY,
      :DRAGONMEMORY,
      :DARKMEMORY,
      :FAIRYMEMORY
    ]
    hasAnyMemory = false
    memories.each do |memoryID|
      if bag.pbHasItem?(memoryID)
        bag.pbDeleteItem(memoryID)
        hasAnyMemory = true
      end
    end
    
    bag.pbStoreItem(:MEMORYSET, 1, false) if hasAnyMemory
  end
end

SaveData.register_conversion(:reimbursing_terrain_tms_21) do
  game_version '2.1.0'
  display_title 'Reimbursing player for purchased terrain TMs'
  to_all do |save_data|
    bag = save_data[:bag]

    terrainTMs = %i[TM88 TM89 TM90 TM91]
    terrainTMs.each do |tmID|
      if bag.pbHasItem?(tmID)
        bag.pbDeleteItem(tmID)
        save_data[:player].money += 5000
      end
    end
  end
end

