class Pokemon
	attr_accessor :hpMult
	attr_accessor :dmgMult
  attr_accessor :dmgResist
	attr_accessor :battlingStreak
  attr_accessor :extraMovesPerTurn
	
  # Creates a new Pokémon object.
  # @param species [Symbol, String, Integer] Pokémon species
  # @param level [Integer] Pokémon level
  # @param owner [Owner, Player, NPCTrainer] Pokémon owner (the player by default)
  # @param withMoves [TrueClass, FalseClass] whether the Pokémon should have moves
  # @param rechech_form [TrueClass, FalseClass] whether to auto-check the form
  def initialize(species, level, owner = $Trainer, withMoves = true, recheck_form = true)
    species_data = GameData::Species.get(species)
    @species          = species_data.species
    @form             = species_data.form
    @forced_form      = nil
    @time_form_set    = nil
    self.level        = level
    @steps_to_hatch   = 0
    heal_status
    @gender           = nil
    @shiny            = nil
    @ability_index    = nil
    @ability          = nil
    @nature           = nil
    @nature_for_stats = nil
    @item             = nil
    @mail             = nil
    @moves            = []
    reset_moves if withMoves
    @first_moves      = []
    @ribbons          = []
    @cool             = 0
    @beauty           = 0
    @cute             = 0
    @smart            = 0
    @tough            = 0
    @sheen            = 0
    @pokerus          = 0
    @name             = nil
    @happiness        = species_data.happiness
    @poke_ball        = :POKEBALL
    @markings         = 0
    @iv               = {}
    @ivMaxed          = {}
    @ev               = {}
    GameData::Stat.each_main do |s|
      @iv[s.id]       = 0
      @ev[s.id]       = DEFAULT_STYLE_VALUE
    end
    if owner.is_a?(Owner)
      @owner = owner
    elsif owner.is_a?(Player) || owner.is_a?(NPCTrainer)
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, '', 2, 2)
    end
    @obtain_method    = 0   # Met
    @obtain_method    = 4 if $game_switches && $game_switches[Settings::FATEFUL_ENCOUNTER_SWITCH]
    @obtain_map       = ($game_map) ? $game_map.map_id : 0
    @obtain_text      = nil
    @obtain_level     = level
    @hatched_map      = 0
    @timeReceived     = Time.now.to_i
    @timeEggHatched   = nil
    @fused            = nil
    @personalID       = rand(2 ** 16) | rand(2 ** 16) << 16
    @hp               = 1
    @totalhp          = 1
    @hpMult		        = 1
  	@dmgMult		      = 1
    @dmgResist        = 0
    @extraMovesPerTurn = 0
	  @battlingStreak	  = 0
    calc_stats
    if @form == 0 && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end
  
  def onHotStreak?()
	  return @battlingStreak >= 2
  end
  
  def nature
    @nature = GameData::Nature.get(0).id # ALWAYS RETURN NEUTRAL
    return GameData::Nature.try_get(@nature)
  end
  
  # Recalculates this Pokémon's stats.
  def calc_stats
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    # Calculate stats
    stats = {}
    stylish = ability_id == :STYLISH
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHPGlobal(base_stats[s.id], this_level, @ev[s.id],stylish)
        stats[s.id] *= hpMult
      elsif (s.id == :ATTACK) || (s.id == :SPECIAL_ATTACK)
        stats[s.id] = calcStatGlobal(base_stats[s.id], this_level, @ev[s.id],stylish)
      else
        stats[s.id] = calcStatGlobal(base_stats[s.id], this_level, @ev[s.id],stylish)
      end
    end
    hpDiff = @totalhp - @hp
    @totalhp = stats[:HP]
    @hp      = (fainted? ? 0 : (@totalhp - hpDiff))
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end

  # The core method that performs evolution checks. Needs a block given to it,
  # which will provide either a GameData::Species ID (the species to evolve
  # into) or nil (keep checking).
  # @return [Symbol, nil] the ID of the species to evolve into
  def check_evolution_internal
    return nil if egg? || shadowPokemon?
    return nil if hasItem?(:EVERSTONE)
    return nil if hasItem?(:EVIOLITE)
    return nil if hasAbility?(:BATTLEBOND)
    species_data.get_evolutions(true).each do |evo|   # [new_species, method, parameter, boolean]
      next if evo[3]   # Prevolution
      ret = yield self, evo[0], evo[1], evo[2]   # pkmn, new_species, method, parameter
      return ret if ret
    end
    return nil
  end
end