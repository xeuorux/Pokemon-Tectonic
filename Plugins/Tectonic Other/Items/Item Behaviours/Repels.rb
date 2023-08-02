def pbRepel(item,steps)
    if $PokemonGlobal.repel>0
      pbMessage(_INTL("But a repellent's effect still lingers from earlier."))
      return 0
    end
    pbUseItemMessage(item)
    $PokemonGlobal.repel = steps
    return 3
  end
  
  ItemHandlers::UseInField.add(:REPEL,proc { |item|
    next pbRepel(item,100)
  })
  
  ItemHandlers::UseInField.add(:SUPERREPEL,proc { |item|
    next pbRepel(item,200)
  })
  
  ItemHandlers::UseInField.add(:MAXREPEL,proc { |item|
    next pbRepel(item,250)
  })