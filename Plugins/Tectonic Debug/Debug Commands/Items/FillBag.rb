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