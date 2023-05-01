DEFAULT_BOSS_TURNS = 2
DEFAULT_BOSS_HP_MULT = 6.0
DEFAULT_BOSS_DAMAGE_MULT = 1.0
AVATAR_OVERKILL_RESISTANCE = 0.75
AVATAR_DILUTED_STATUS_CONDITIONS = false
AVATAR_DILUTED_EFFECTIVENESS = false
AVATAR_DILUTED_STAT_STEPS = false
PRIMEVAL_MOVES_RESET_DEBUFFS = true

AVATARS_REGULAR_ATTACKS_PIERCE_PROTECT = true
AVATARS_REGULAR_ATTACKS_PIERCE_IMMUNITIES = false
AVATARS_TELEGRAPH_REGULAR_ATTACKS = false
AVATARS_FEAR_NOT_FAINT = true
HEALING_RATIO_ON_FEAR_REMOVED = 0

# Avatar AI
AVATARS_RANDOMLY_PRIORITIZE_FAINTING = false
AVATARS_DIVERSIFY_TARGETING_BETWEEN_ROUNDS = false
AVATARS_DISLIKE_REPEATING_SAME_MOVE = false
AVATARS_START_WITH_STAB = false
AVATARS_PRIORITIZE_SAME_TURN_TARGETS = false
AVATARS_CANT_CHANGE_TARGETING = false
AVATARS_CALCULATE_DAMAGE_DEALT = true
AVATAR_DAMAGE_SCORE_MAX = 100

module GameData
	class Avatar
		attr_reader :id
		attr_reader :id_number
		attr_reader :num_turns
		attr_reader :species
		attr_reader :form
		attr_reader :moves1
		attr_reader :moves2
		attr_reader :moves3
		attr_reader :moves4
		attr_reader :moves5
		attr_reader :post_prime_moves
		attr_reader :abilities
		attr_reader :item
		attr_reader :hp_mult
		attr_reader :dmg_mult
		attr_reader :dmg_resist
		attr_reader :num_phases
		attr_reader :num_health_bars
		attr_reader :aggression
	
		DATA = {}
		DATA_FILENAME = "avatars.dat"

		SCHEMA = {
		  "Turns"         		=> [:turns,          	"u"],
		  "Form"         		=> [:form,          	"U"],
		  "Moves1"        		=> [:moves1,         	"*e", :Move],
		  "Moves2"      		=> [:moves2,			"*E", :Move],
		  "Moves3"      		=> [:moves3,			"*E", :Move],
		  "Moves4"      		=> [:moves4,			"*E", :Move],
		  "Moves5"      		=> [:moves5,			"*E", :Move],
		  "Ability"      		=> [:abilities,       	"*e", :Ability],
		  "Item"         		=> [:item,          	"e", :Item],
		  "HPMult"				=> [:hp_mult,			"f"],
		  "DMGMult"				=> [:dmg_mult,			"F"],
		  "DMGResist"			=> [:dmg_resist,		"F"],
		  "HealthBars"			=> [:health_bars,		"U"],
		  "Aggression"			=> [:aggression,		"U"],
		}

		extend ClassMethods
		include InstanceMethods
		
		def initialize(hash)
		  @id               = hash[:id]
		  @id_number        = hash[:id_number]
		  @num_turns        = hash[:turns] || DEFAULT_BOSS_TURNS
		  @species			= @id.to_s.split('_')[0].to_sym
		  @form             = hash[:form] || 0
		  @moves1        	= hash[:moves1]
		  @moves2 			= hash[:moves2] || []
		  @moves3 			= hash[:moves3] || []
		  @moves4 			= hash[:moves4] || []
		  @moves5 			= hash[:moves5] || []
		  @abilities        = hash[:abilities]
		  @item             = hash[:item]
		  @hp_mult			= hash[:hp_mult] || DEFAULT_BOSS_HP_MULT
		  @dmg_mult 		= hash[:dmg_mult] || DEFAULT_BOSS_DAMAGE_MULT
		  @dmg_resist		= hash[:dmg_resist] || 0
		  @aggression		= hash[:aggression] || PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION

		  raise _INTL("The Avatar definition for #{@id} has no first moves defined!") if @moves1.nil?

		  @num_phases = 1
		  if @moves2.length > 0
			@num_phases += 1
			if @moves3.length > 0
				@num_phases += 1
				if @moves4.length > 0
					@num_phases += 1
					if @moves5.length > 0
						@num_phases += 1
					end
				end
			end
		  end

		  @num_health_bars = hash[:health_bars] || @num_phases

		  @abilities.each do |abilityID|
			next unless abilityID
            next if GameData::Ability.get(abilityID).legal?(true)
            raise _INTL("Cut ability #{abilityID} is assigned to avatar #{@id}!")
		  end
		end

		def second_status?
			return @num_health_bars > 1
		end

		def arrayOfMoveSets
			return [@moves1,@moves2,@moves3,@moves4,@moves5]
		end

		def getListOfPhaseTypes
			phaseTypes = [nil]
			arrayOfMoveSets.each do |moveSet|
				moveSet.each do |move|
					moveData = GameData::Move.get(move)

					if moveData.empoweredMove? && moveData.category == 2
						phaseTypes.push(moveData.type)
					end
				end
			end

			return phaseTypes
		end

		def getTypeForPhase(index)
			return getListOfPhaseTypes[]
		end

		def self.get_from_species_form(speciesForm)
			if DATA.has_key?(speciesForm)
				return self.get(speciesForm)
			else
				species = speciesForm.to_s.split('_')[0].to_sym
				return self.get(species)
			end
		end

		def self.get_from_pokemon(pokemon)
			avatar_data = nil
			if pokemon.form != 0
				speciesFormSymbol = (pokemon.species.to_s + "_" + pokemon.form.to_s).to_sym
				avatar_data = GameData::Avatar.get_from_species_form(speciesFormSymbol)
			else
				avatar_data = GameData::Avatar.get(pokemon.species.to_sym)
			end
			return avatar_data
		end
	end
end