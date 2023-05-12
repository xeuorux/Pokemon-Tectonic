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