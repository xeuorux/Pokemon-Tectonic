ItemHandlers::UseFromBag.add(:BATTLEREPORT,proc { |item|
  if pbConfirmMessageSerious(_INTL("Read the battle report?"))
    if !levelCapMaxed?
      increaseLevelCap(5)
    else
      pbMessage(_INTL("You are too skilled to learn any more from a battle report."))
      next 0
    end
    next 3
  else
    next 0
  end
})