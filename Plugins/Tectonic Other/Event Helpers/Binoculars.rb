def binocularPreview(eventID)
    return unless playerFacingNorth?
    event = getEventByID(eventID)
    pbMessage(_INTL("You peer into the binoculars..."))
    controlledCameraPreview(event.x,event.y)
end