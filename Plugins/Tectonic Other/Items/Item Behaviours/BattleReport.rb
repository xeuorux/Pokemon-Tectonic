ItemHandlers::UseFromBag.add(:BATTLEREPORT,proc { |item|
  if !levelCapMaxed?
    increaseLevelCap(5)
    next 3
  else
    pbMessage(_INTL("You are too skilled to learn any more from a battle report."))
    next 0
  end
})