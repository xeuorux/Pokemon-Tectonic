DebugMenuCommands.register("analyzecrossmapswitching", {
  "parent"      => "unrealtime",
  "name"        => _INTL("Set time to hour"),
  "description" => _INTL("Set the unreal time to the next instance of some hour on the 24-hour clock."),
  "effect"      => proc { |sprites, viewport|
	params = ChooseNumberParams.new
	params.setMaxDigits(2)
	params.setDefaultValue(0)
	params.setRange(1, 24)
	chosenHour = pbChooseNumber(nil, params) 
	UnrealTime.advance_to(chosenHour - 1, 0, 0)
	pbMessage("Advancing the unreal time system to hour #{chosenHour}")
  }}
)
