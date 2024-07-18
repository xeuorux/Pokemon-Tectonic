def binocularPreview(eventID)
    return unless playerFacingNorth?
    event = getEventByID(eventID)
    pbMessage(_INTL("You peer into the binoculars..."))
    timedCameraPreview(event.x,event.y,6,true)
end