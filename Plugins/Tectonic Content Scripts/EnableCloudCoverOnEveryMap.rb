# Enable the Cloud Cover graphics on any map
# Can be disabled on individual maps by creating a Parallel Process event
Events.onMapChange += proc { |_sender,_e|
    setGlobalSwitch(AUTO_CLOUDS_DISABLED_GLOBAl,false)
}