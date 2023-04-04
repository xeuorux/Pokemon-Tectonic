class Game_Event < Game_Character
	attr_reader   :event
	attr_accessor :direction_fix
end

class PokemonStorage
  BASICWALLPAPERQTY = 14
  
  def allWallpapers
    return [
       # Basic wallpapers
       _INTL("Forest"),_INTL("City"),_INTL("Desert"),_INTL("Savanna"),
       _INTL("Crag"),_INTL("Volcano"),_INTL("Snow"),_INTL("Cave"),
       _INTL("Beach"),_INTL("Seafloor"),_INTL("River"),_INTL("Sky"),
       _INTL("Machine"),_INTL("Simple")
    ]
  end
end

class Game_Temp
  def setup_sames=(value)
    @setup_sames = value
  end

  def setup_sames
    @setup_sames = false if @setup_sames.nil?
    return @setup_sames
  end
end