def pbRegisterPartner(tr_type, tr_name, tr_id = 0)
    tr_type = GameData::TrainerType.get(tr_type).id
    pbCancelVehicles
    trainer = pbLoadTrainer(tr_type, tr_name, tr_id)
    Events.onTrainerPartyLoad.trigger(nil, trainer)
    for i in trainer.party
      i.owner = Pokemon::Owner.new_from_trainer(trainer)
      i.calc_stats
    end
    $PokemonGlobal.partner = [tr_type, tr_name, trainer.id, trainer.party, trainer.flags]
  end
  
  def pbDeregisterPartner
    $PokemonGlobal.partner = nil
  end
  