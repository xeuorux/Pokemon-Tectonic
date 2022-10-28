GameData::Evolution.register({
    :id            => :TradeSpecies,
    :parameter     => :Species,
    :on_trade_proc => proc { |pkmn, parameter, other_pkmn|
      next pkmn.species == parameter && !other_pkmn.hasItem?(:EVERSTONE) && !other_pkmn.hasItem?(:EVIOLITE)
    }
  })