module Settings
  GAME_VERSION = "2.3.0"

  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL        = 71
  GAIN_EXP_FOR_CAPTURE = false
  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD       = true
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD =  false
  
  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = true

  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regionaldexes.txt". The last name is for the National Dex and is added
  # onto the end of this array (remember that you don't need to use it). This
  # array's order is also the order of $Trainer.pokedex.unlocked_dexes, which
  # records which Dexes have been unlocked (the first is unlocked by default).
  # If an entry is just a name, then the region map shown in the Area page while
  # viewing that Dex list will be the region map of the region the player is
  # currently in. The National Dex entry should always behave like this.
  # If an entry is of the form [name, number], then the number is a region
  # number. That region's map will appear in the Area page while viewing that
  # Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      _INTL("National Pokédex")
    ]
  end
  # Whether all forms of a given species will be immediately available to view
  # in the Pokédex so long as that species has been seen at all (true), or
  # whether each form needs to be seen specifically before that form appears in
  # the Pokédex (false).
  DEX_SHOWS_ALL_FORMS = true
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  DEXES_WITH_OFFSETS  = []
  
  # A set of arrays, each containing the details of a roaming Pokémon. The
  # information within each array is as follows:
  #   * Species.
  #   * Level.
  #   * Game Switch; the Pokémon roams while this is ON.
  #   * Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
  #     4=surfing/fishing). See the bottom of PField_RoamingPokemon for lists.
  #   * Name of BGM to play for that encounter (optional).
  #   * Roaming areas specifically for this Pokémon (optional).
  ROAMING_SPECIES = []
  
  # A set of arrays, each containing the details of a wild encounter that can
  # only occur via using the Poké Radar. The information within each array is as
  # follows:
  #   * Map ID on which this encounter can occur.
  #   * Probability that this encounter will occur (as a percentage).
  #   * Species.
  #   * Minimum possible level.
  #   * Maximum possible level (optional).
  POKE_RADAR_ENCOUNTERS = []
  
  NUM_STORAGE_BOXES = 40

  REGION_MAP_EXTRAS = [
    [0, 51, 0, 0, "Abyssal Cave", false],
    [0, 52, 0, 0, "Volcanic Shore", false],
    [0, 55, 0, 0, "Guardian Island", false]
  ]

  # The names of each pocket of the Bag. Ignore the first entry ("").
  def self.bag_pocket_names
    return ["",
      _INTL("Items"),
      _INTL("Medicine"),
      _INTL("Poké Balls"),
      _INTL("TMs"),
      _INTL("Held Items"),
      _INTL("Sell Items"),
      _INTL("Battle Items"),
      _INTL("Key Items")
    ]
  end

  # Available speech frames. These are graphic files in "Graphics/Windowskins/".
  SPEECH_WINDOWSKINS = [
    "speech1",
    "speech2",
    "speech3",
    "speech4",
    "speech5",
    "speech6",
    "speech7",
    "speech8",
    "speech9",
    "speech10",
    "speech11",
    "speech12",
    "speech13",
    "speech14",
    "speech15",
    "speech16",
    "speech17",
    "speech18",
    "speech19",
    "speech20",
    "speech21"
  ]

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "choice1",
    "choice2",
    "choice3",
    "choice4",
    "choice5",
    "choice6",
    "choice7",
    "choice8",
    "choice9",
    "choice10",
    "choice11",
    "choice12",
    "choice13",
    "choice14",
    "choice15",
    "choice16",
    "choice17",
    "choice18",
    "choice19",
    "choice20",
    "choice21",
    "choice22",
    "choice23",
    "choice24",
    "choice5",
    "choice26",
    "choice27",
    "choice28"
  ]

  LANGUAGES = [
    ["English", "english.dat"],
    ["Español (Incompleto)", "spanish.dat"]
  ]
end