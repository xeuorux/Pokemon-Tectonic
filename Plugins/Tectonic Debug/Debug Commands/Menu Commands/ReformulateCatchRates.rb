DebugMenuCommands.register("reformulatecatchrates", {
    "parent"      => "editorsmenu",
    "name"        => _INTL("Reformulate catch rates"),
    "description" => _INTL("Reformulates all catch rates. Don't use lightly."),
    "always_show" => true,
    "effect"      => proc {
      if pbConfirmMessage(_INTL("Are you sure you want to reformulate all catch rates?"))
        msgwindow = pbCreateMessageWindow
        pbMessageDisplay(msgwindow, _INTL("Reformulating all catch rates. Please wait."), false)
        Graphics.update
        
        totalDiff = 0
        numSpecies = 0
        GameData::Species.each do |sp|
            total = 0
            sp.base_stats.each_with_index do |stat, index|
              total += stat[1]
            end
        total = [[220,total].max,720].min
        newRarity = (8.8 * (250 - (250 * (total-220)/500)) ** 0.6) + 5
        if newRarity.is_a?(Complex)
          next
        end
        newRarity = newRarity.floor
        diff = (newRarity - sp.catch_rate)
        totalDiff += diff
        diff  = "+".concat(diff.to_s) if diff > 0
        numSpecies += 1
        pokeballRate = (PokeBattle_Battle.captureThresholdCalcInternals(:NONE,50,300,newRarity).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
        pokeballRate = (pokeballRate * 10000).floor / 100
        ultraballRate = (PokeBattle_Battle.captureThresholdCalcInternals(:NONE,50,300,newRarity * 2).to_f/CATCH_BASE_CHANCE.to_f ) ** 4
        ultraballRate = (ultraballRate * 10000).floor / 100
        end
        averageChange = totalDiff/numSpecies
        
        pbDisposeMessageWindow(msgwindow)
      end
    }
  })