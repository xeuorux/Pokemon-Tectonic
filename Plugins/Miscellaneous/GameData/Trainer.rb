module GameData
	class Trainer
		attr_reader :policies
		attr_reader :extendsClass
		attr_reader :extendsName
		attr_reader :extendsVersion
		attr_reader :removedPokemon
		attr_reader :nameForHashing
	
		SCHEMA = {
		  "Items"        => [:items,         "*e", :Item],
		  "LoseText"     => [:lose_text,     "s"],
		  "Policies"	 => [:policies,		 "*e", :Policy],
		  "Pokemon"      => [:pokemon,       "ev", :Species],   # Species, level
		  "RemovePokemon"=> [:removed_pokemon,       "ev", :Species],   # Species, level
		  "Form"         => [:form,          "u"],
		  "Name"         => [:name,          "s"],
		  "NameForHashing"   => [:name_for_hashing,   "s"],
		  "Moves"        => [:moves,         "*e", :Move],
		  "Ability"      => [:ability,       "s"],
		  "AbilityIndex" => [:ability_index, "u"],
		  "Item"         => [:item,          "e", :Item],
		  "Gender"       => [:gender,        "e", { "M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
													"F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1 }],
		  "Nature"       => [:nature,        "e", :Nature],
		  "IV"           => [:iv,            "uUUUUU"],
		  "EV"           => [:ev,            "uUUUUU"],
		  "Happiness"    => [:happiness,     "u"],
		  "Shiny"        => [:shininess,     "b"],
		  "Shadow"       => [:shadowness,    "b"],
		  "Ball"         => [:poke_ball,     "s"],
		  "ExtendsVersion" => [:extends_version, "u"],
		  "Extends"		 => [:extends,		 "esu", :TrainerType],
		  "Position"	 => [:assigned_position, "u"],
		}
		
		def initialize(hash)
		  @id             = hash[:id]
		  @id_number      = hash[:id_number]
		  @trainer_type   = hash[:trainer_type]
		  @real_name      = hash[:name]         || "Unnamed"
		  @nameForHashing = hash[:name_for_hashing]
		  @version        = hash[:version]      || 0
		  @items          = hash[:items]        || []
		  @real_lose_text = hash[:lose_text]    || "..."
		  @pokemon        = hash[:pokemon]      || []
		  @pokemon.each do |pkmn|
			GameData::Stat.each_main do |s|
			  pkmn[:iv][s.id] ||= 0 if pkmn[:iv]
			  pkmn[:ev][s.id] ||= 0 if pkmn[:ev]
			end
		  end
		  @removedPokemon = hash[:removed_pokemon] || []
		  @policies		  = hash[:policies]		|| []
		  @extendsClass	  = hash[:extends_class]
		  @extendsName	  = hash[:extends_name]
		  @extendsVersion = hash[:extends_version] || -1
		end
	
		# Creates a battle-ready version of a trainer's data.
		# @return [Array] all information about a trainer in a usable form
		def to_trainer
			parentTrainer = nil
			parentTrainerData = nil
			extending = false
			if @extendsVersion > -1
				parentTrainerData = GameData::Trainer.get(@extendsClass || @trainer_type, @extendsName || @real_name, @extendsVersion)
				parentTrainer = parentTrainerData.to_trainer
				extending = true if !parentTrainer.nil?
				#echoln("Trainer #{@id.to_s} is extending trainer #{parentTrainerData.id.to_s}")
			end

			# Determine trainer's name
			tr_name = self.name
			Settings::RIVAL_NAMES.each do |rival|
				next if rival[0] != @trainer_type || !$game_variables[rival[1]].is_a?(String)
				tr_name = $game_variables[rival[1]]
				break
			end
			
			# Create trainer object
			trainer = NPCTrainer.new(tr_name, @trainer_type, @nameForHashing)
			trainer.id         = $Trainer.make_foreign_ID
			trainer.items      = @items.clone
			trainer.lose_text  = @lose_text
			trainer.policies   = @policies.clone
			trainer.policies.concat(GameData::TrainerType.get(@trainer_type).policies)

			if extending
				trainer.items.concat(parentTrainer.items.clone)
				trainer.lose_text = parentTrainer.lose_text if @lose_text.nil? || @lose_text == "..."
				trainer.policies.concat(parentTrainer.policies.clone)
			end

			trainer.policies.uniq!

			# Add pokemon from a parent trainer entry's party, if inheriting
			if extending
				parentTrainer.party.each do |parentPartyMember|
					# Determine if this pokemon was marked for removal in the child trainer entry
					hasRemoveMatch = false
					@removedPokemon.each do |removed_member|
						removedSpecies = GameData::Species.get(removed_member[:species]).species
						next if parentPartyMember.species != removedSpecies
						removedLevel = removed_member[:level]
						removedName = removed_member[:name] || removedSpecies.name
						if parentPartyMember.level == removedLevel
							hasRemoveMatch = true
							break
						elsif removedName == parentPartyMember.name
							hasRemoveMatch = true
							break
						end
					end
					
					trainer.party.push(parentPartyMember.clone) if !hasRemoveMatch
				end
			end

			# Create each Pokémon owned by the trainer
			@pokemon.each do |pkmn_data|
				species = GameData::Species.get(pkmn_data[:species]).species
				level = pkmn_data[:level]

				nickname = nil
				nickname = pkmn_data[:name] if pkmn_data[:name] && !pkmn_data[:name].empty?

				pkmn = nil
				matchedOnNickname = false
				if extending
					trainer.party.each do |existingPokemon|
						next if existingPokemon.species != species
						if existingPokemon.level == level
							pkmn = existingPokemon
							break
						elsif !nickname.nil? && nickname == existingPokemon.name
							pkmn = existingPokemon
							pkmn.level = level
							break
						end
					end
				end

				if pkmn.nil?
					pkmn = Pokemon.new(species, level, trainer, false)
					trainer.party.push(pkmn)
				else
					#echoln("Pokemon #{pkmn.name} in entry #{@id.to_s} inherits from entry #{parentTrainerData.id.to_s}")
				end

				# Set Pokémon's properties if defined
				pkmn.name = nickname if !nickname.nil?

				pkmn.assignedPosition = pkmn_data[:assigned_position] || Settings::MAX_PARTY_SIZE

				if !pkmn_data[:form].nil?
					pkmn.forced_form = pkmn_data[:form] if MultipleForms.hasFunction?(species, "getForm")
					pkmn.form_simple = pkmn_data[:form]
				end

				pkmn.item = pkmn_data[:item] if !pkmn_data[:item].nil?

				if pkmn_data[:moves] && pkmn_data[:moves].length > 0
					pkmn.forget_all_moves
					pkmn_data[:moves].each { |move| pkmn.learn_move(move) }
				end

				if pkmn.moves.length == 0
					pkmn.reset_moves([pkmn.level,50].min,true)
				end

				if !pkmn_data[:ability].nil? || !pkmn_data[:ability_index].nil?
					pkmn.ability = pkmn_data[:ability]
					pkmn.ability_index = pkmn_data[:ability_index]
				end
				
				pkmn.gender = pkmn_data[:gender] || ((trainer.male?) ? 0 : 1)
				pkmn.shiny = (pkmn_data[:shininess]) ? true : false if !pkmn_data[:shininess].nil?

				pkmn.nature = 0

				GameData::Stat.each_main do |s|
					pkmn.iv[s.id] = 0
					if pkmn_data[:ev]
						pkmn.ev[s.id] = pkmn_data[:ev][s.id]
					else
						pkmn.ev[s.id] = 8
					end
				end

				pkmn.happiness = pkmn_data[:happiness] if !pkmn_data[:happiness].nil?

				if pkmn_data[:shadowness]
					pkmn.makeShadow
					pkmn.update_shadow_moves(true)
					pkmn.shiny = false
				end

				pkmn.poke_ball = pkmn_data[:poke_ball] if !pkmn_data[:poke_ball].nil?

				pkmn.calc_stats
			end

			if extending && trainer.party.length > Settings::MAX_PARTY_SIZE
				raise _INTL("Error when trying to contruct trainer #{@id.to_s} as an extension of trainer #{trainer.id.to_s}. The resultant party is larger than the maximum party size!")
			end

			trainer.party.sort! { |memberA,memberB|
				if memberA.assignedPosition == memberB.assignedPosition
					next 1
				end
				next memberA.assignedPosition <=> memberB.assignedPosition
			}

			#echoln(trainer.party.to_s)

			return trainer
		end
	end
end

class Pokemon
	attr_accessor :assignedPosition

	def reset_moves(assignedLevel=-1,forceSignatures=false)
		if assignedLevel == -1
			assignedLevel = self.level
		end
		# Find all level-up moves that self could have learned
		moveset = self.getMoveList
		knowable_moves = []
		signature_moves = []
		moveset.each { |m| 
			moveID = m[1]
			moveData = GameData::Move.get(moveID)
			# Forces signature moves if they're learnable by the pokemon's level
			if moveData.is_signature? && forceSignatures && m[0] <= self.level
				signature_moves.push(moveID)
			# Allows other moves only if they're learnable by the given level (which is still usually the pokemon's level)
			elsif m[0] <= assignedLevel
				knowable_moves.push(moveID)
			end
		}
		# Remove duplicates (retaining the latest copy of each move)
		knowable_moves = knowable_moves.concat(signature_moves)
		knowable_moves = knowable_moves.reverse
		knowable_moves |= []
		knowable_moves = knowable_moves.reverse
		# Add all moves
		@moves.clear
		first_move_index = knowable_moves.length - MAX_MOVES
		first_move_index = 0 if first_move_index < 0
		for i in first_move_index...knowable_moves.length
			@moves.push(Pokemon::Move.new(knowable_moves[i]))
		end
	end
end

class Trainer
	attr_reader   :nameForHashing

	def wild?;           return GameData::TrainerType.get(@trainer_type).wild?;     end
end

class NPCTrainer < Trainer
	attr_accessor :policies
	attr_accessor :policyStates

	def initialize(name, trainer_type, nameForHashing = nil)
		super(name, trainer_type)
		@items     = []
		@lose_text = nil
		@policies  = []
		@policyStates = {}
		@nameForHashing = nameForHashing || name
	end
end
