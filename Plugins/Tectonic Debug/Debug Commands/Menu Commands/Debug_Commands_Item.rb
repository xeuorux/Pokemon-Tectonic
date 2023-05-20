  DebugMenuCommands.register("additem", {
    "parent"      => "itemsmenu",
    "name"        => _INTL("Add Item"),
    "description" => _INTL("Choose an item and a quantity of it to add to the Bag."),
    "effect"      => proc {
      pbListScreenBlock(_INTL("ADD ITEM"), ItemLister.new) { |button, item|
        if button == Input::USE && item
          params = ChooseNumberParams.new
          params.setRange(1, Settings::BAG_MAX_PER_SLOT)
          params.setInitialValue(1)
          params.setCancelValue(0)
          qty = pbMessageChooseNumber(_INTL("Add how many {1}?",
             GameData::Item.get(item).name_plural), params)
          if qty > 0
            $PokemonBag.pbStoreItem(item, qty)
            pbMessage(_INTL("Gave {1}x {2}.", qty, GameData::Item.get(item).name))
          end
        end
      }
    }
  })

  DebugMenuCommands.register("fillbag", {
    "parent"      => "itemsmenu",
    "name"        => _INTL("Fill Bag"),
    "description" => _INTL("Add a certain number of every item to the Bag."),
    "effect"      => proc {
      params = ChooseNumberParams.new
      params.setRange(1, Settings::BAG_MAX_PER_SLOT)
      params.setInitialValue(1)
      params.setCancelValue(0)
      qty = pbMessageChooseNumber(_INTL("Choose the number of items."), params)
      if qty > 0
        GameData::Item.each { |i|
            next unless i.legal?
            $PokemonBag.pbStoreItem(i.id, qty)
        }
        pbMessage(_INTL("The Bag was filled with {1} of each item.", qty))
      end
    }
  })

  DebugMenuCommands.register("emptybag", {
    "parent"      => "itemsmenu",
    "name"        => _INTL("Empty Bag"),
    "description" => _INTL("Remove all items from the Bag."),
    "effect"      => proc {
      $PokemonBag.clear
      pbMessage(_INTL("The Bag was cleared."))
    }
  })

  DebugMenuCommands.register("fixpockets", {
    "parent"      => "itemsmenu",
    "name"        => _INTL("Fix item pockets"),
    "description" => _INTL("Remove all items from the bag, then put them back in, to reset pocket location"),
    "effect"      => proc {
      pbMessage("Fixing item pockets.")
      $PokemonBag.reassignPockets()
      pbMessage("All items reassigned.")
    }
  })