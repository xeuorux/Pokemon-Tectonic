$globalEffectIDCounter = 0

module GameData
	class BattleEffect
		attr_reader :id, :id_number, :real_name, :resets_eor, :tick_amount, :baton_passed

		# The locations are :Battler, :Side, :Field, :Position
		attr_reader :location
		
		# The types are :Boolean, :Integer, :Position, :Type, :Pokemon, :Move, :Item, :Species, :PartyPosition
		# If the type isn't included in an effect definition, its assumed to be a boolean
		attr_reader :type
		
		# Don't set the default to nil, will be overwritten
		attr_reader :default

		# The maximum value attainable by the effect before moves and abilities dont increment it anymore
		# Only used for Integers
		attr_reader :maximum

		# Whether or not the effect should be displayed on the battle info menu
		attr_reader :info_displayed

		# An array of other effects to disable at the same time as it
		# Be careful not to create loops with this
		attr_reader :sub_effects

		# Resets to default value when a battler starts their turn (sot = "start of turn")
		attr_reader :resets_battlers_sot

		# Resets to default value when a battler has no ability to continue acting this turn
		# Either when the move ends naturally or is interupted by various effects
		# (eot = "end of turn")
		attr_reader :resets_battlers_eot

		# Resets to default value if the battler's move is cancelled
		attr_reader :resets_on_cancel

		# If it ticks down at end of round. Only used for integers
		attr_reader :ticks_down

		# When battlers swap position, the effect changes value to point to the correct battler
		# Only used for :Position type effects
		attr_reader :swaps_with_battlers

		# When a new battler is initialized, other battlers effects which point to its index
		# Are reset to their default position
		# Only used for :Position type effects
		attr_reader :others_lose_track

		# When the effect is active on a battler, that battler is considered to be in a multi-turn attack
		attr_reader :multi_turn_tracker

		# Is an effect that makes the pokemon invulnerable
		# Marked so that moves like Feint can know to remove it
		attr_reader :protection_effect

		# Bespoke information for type applying spikes
		attr_reader :type_applying_hazard

		# Whether its swapped by the move Court Change
		# Defaults to true
		attr_reader :court_changed

		def court_changed?
			return @court_changed
		end

		# Is a "screen" like reflect
		attr_reader :is_screen

		def is_screen?
			return @is_screen
		end

		# Trick Room, etc
		attr_reader :is_room

		def is_room?
			return @is_room
		end

		# Spikes, etc.
		attr_reader :is_hazard

		def is_hazard?
			return @is_hazard
		end

		# Cursed by Mental Herb or similar
		attr_reader :is_mental

		def is_mental?
			return @is_mental
		end

		def is_status_hazard?
			return !@type_applying_hazard.nil?
		end

		def has_apply_proc?
			return !@apply_proc.nil?
		end

		def has_eor_proc?
			return !@eor_proc.nil?
		end

		def has_remain_proc?
			return !@remain_proc.nil?
		end

		def has_expire_proc?
			return !@expire_proc.nil?
		end
		
		DATA = {}

		extend ClassMethods
		include InstanceMethods

		def self.load; end
		def self.save; end

		def self.register_effect(location, hash)
			hash[:location] = location
			register(hash)
		end

		def initialize(hash)
			@id = hash[:id]
			@id_number              = $globalEffectIDCounter
			$globalEffectIDCounter += 1
			@real_name              = hash[:real_name]
			@location               = hash[:location]
			@type                   = hash[:type] || :Boolean
			@default                = hash[:default]
			@maximum				= hash[:maximum]
			@info_displayed			= hash[:info_displayed] || true
			if @default.nil?
				case @type
				when :Boolean
					@default = false
				when :Integer, :Species
					@default = 0
				when :Position, :PartyPosition
					@default = -1
				end
			end
			# For applying other effects or changes alongside this effect
			# Called also when baton passing
			@apply_proc             = hash[:activated_proc]

			@resets_eor             = hash[:resets_eor] || false
			@ticks_down             = hash[:ticks_down] || false
			@tick_amount            = hash[:tick_amount] || 1

			# Procs when the battler is initialized
			@initialize_proc        = hash[:initialize_proc]

			# Procs every round when active.
			@eor_proc               = hash[:eor_proc]

			# Procs every end of round, only when ticking down to 0
			@expire_proc 			= hash[:expire_proc]
			# Procs every end of round, only when ticked down with still turns remaining
			@remain_proc            = hash[:remain_proc]

			# Procs every end of round, only when ticked down with still turns remaining
			@remain_proc            = hash[:remain_proc]

			# Procs whenever the event value is incremented (for integers)
			@increment_proc			= hash[:increment_proc]

			raise _INTL("Battle effect #{@id} defines an increment proc when its not an integer.") if @increment_proc && @type != :Integer

			# If the effect needs custom logic to determing if it should be active or not
			# Instead of using the default values (i.e. Integers active above 0)
			@active_value_proc      = hash[:active_value_proc]

			raise _INTL("Battle effect #{@id} defines both an End of Round proc and either an Expiration or Remaing proc.") if @eor_proc && (@expire_proc || @remain_proc)

			@baton_passed           = hash[:baton_passed] || false
			@swaps_with_battlers    = hash[:swaps_with_battlers] || false
			# For when the value has to be transformed when baton passed
			@pass_value_proc = hash[:pass_value_proc]

			@resets_battlers_sot    = hash[:resets_battlers_sot]
			@resets_battlers_eot    = hash[:resets_battlers_eot] || false
			@resets_on_cancel       = hash[:resets_on_cancel] || false
			@multi_turn_tracker     = hash[:multi_turn_tracker] || false

			@others_lose_track      = hash[:others_lose_track] || false

			@sub_effects = hash[:sub_effects] || false

			@protection_effect = hash[:protection_effect] || false
			@court_changed		= hash[:court_changed] || true

			@type_applying_hazard = hash[:type_applying_hazard]
			
			@is_room			= hash[:is_room] || false
			@is_screen			= hash[:is_screen] || false
			@is_hazard			= hash[:is_hazard] || false
			@is_mental			= hash[:is_mental] || false
		end

		# Method for determining if the effect is considered active
		def active_value?(value)
			active = false

			if @active_value_proc
				active = @active_value_proc.call(value)
			else
				case @type
				when :Boolean
					active = value
				when :Integer, :Species
					active = value > 0
				when :Position
					active = value >= 0
				when :Type, :Pokemon, :Move, :Item
					active = !value.nil?
				end
			end

			each_sub_effect do |sub_effect, sub_data|
				sub_active = sub_data.active_value?(@effects[sub_effect])
				if sub_active != active
					raise _INTL("Sub-Effect #{sub_data.real_name} of effect #{@real_name} has mismatched activity status")
				end
			end
			return active
		end

		def valid_value?(value)
			case @type
			when :Boolean
				return [true, false].include?(value)
			when :Integer
				return value.is_a?(Integer)
			when :Species
				return value.nil? || GameData::Species.exists?(value)
			when :Position
				return true # TODO
			when :Type
				return value.nil? || GameData::Type.exists?(value)
			when :Pokemon
				return value.nil? || value.is_a?(Pokemon)
			when :Move
				return value.nil? || GameData::Move.exists?(value)
			when :Item
				return value.nil? || GameData::Item.exists?(value)
			end
		end

		def value_to_string(value)
			case @type
			when :Boolean, :Integer
				return value.to_s
			when :Species
				return GameData::Species.get(value).real_name
			when :Position
				return "#{@battle.battlers[value].name}'s Spot"
			when :Type
				return GameData::Type.get(value).real_name
			when :Pokemon
				return "ERROR"
			when :Move
				return GameData::Move.get(value).real_name
			when :Item
				return GameData::Item.get(value).real_name
			end
			return ""
		end

		### Methods dealing with the effect when a battler is initialized
		def initialize_battler(battle, battler)
			@initialize_proc.call(battle, battler) if @initialize_proc
		end

		### Methods dealing with the effect being newly applied
		def apply_battler(battle, battler)
			value = battler.effects[@id]
			@apply_proc.call(battle, battler, value) if @apply_proc
		end

		def apply_position(battle, index)
			position = battle.positions[index]
			battler = battle.battlers[index]
			return if battler.nil? || battler.fainted?
			@apply_proc.call(battle, index, position, battler) if @apply_proc
		end

		def apply_side(battle, side)
			teamName = battle.battlers[side.index].pbTeam
			@apply_proc.call(battle, side, teamName) if @apply_proc
		end

		def apply_field(battle)
			@apply_proc.call(battle) if @apply_proc
		end

		### Methods dealing with the effect remaining EOT
		def remain_battler(battle, battler)
			value = battler.effects[@id]
			@remain_proc.call(battle, battler, value) if @remain_proc
		end

		def remain_position(battle, index)
			position = battle.positions[index]
			battler = battle.battlers[index]
			return if battler.nil? || battler.fainted?
			@remain_proc.call(battle, index, position, battler) if @remain_proc
		end

		def remain_side(battle, side)
			teamName = battle.battlers[side.index].pbTeam
			@remain_proc.call(battle, side, teamName) if @remain_proc
		end

		def remain_field(battle)
			@remain_proc.call(battle) if @remain_proc
		end

		### Methods dealing with the effect going away after ticking down
		def expire_battler(battle, battler)
			@expire_proc.call(battle, battler) if @expire_proc
		end

		def expire_position(battle, index)
			position = battle.positions[index]
			battler = battle.battlers[index]
			return if battler.nil? || battler.fainted?
			@expire_proc.call(battle, index, position, battler) if @expire_proc
		end

		def expire_side(battle, side)
			teamName = battle.battlers[side.index].pbTeam
			@expire_proc.call(battle, side, teamName) if @expire_proc
		end

		def expire_field(battle)
			@expire_proc.call(battle) if @expire_proc
		end

		### Methods dealing with effects at the end of each round
		def eor_battler(battle, battler)
			value = battler.effects[@id]
			@eor_proc.call(battle, battler, value) if @eor_proc
		end

		def eor_position(battle, index)
			position = battle.positions[index]
			battler = battle.battlers[index]
			return if battler.nil? || battler.fainted?
			value = battler.effects[@id]
			@eor_proc.call(battle, index, position, battler, value) if @eor_proc
		end

		def eor_side(battle, side)
			teamName = battle.battlers[side.index].pbTeam
			value = battler.effects[@id]
			@eor_proc.call(battle, side, teamName, value) if @eor_proc
		end

		def eor_field(battle)
			value = battler.effects[@id]
			@eor_proc.call(battle, value) if @eor_proc
		end

		### Methods dealing with the effect being incremented (call afterwards)
		def increment_battler(battle, battler, increment)
			newValue = battler.effects[@id]
			@increment_proc.call(battle, battler, newValue, increment) if @increment_proc
		end

		def increment_position(battle, index, increment)
			position = battle.positions[index]
			battler = battle.battlers[index]
			return if battler.nil? || battler.fainted?
			newValue = battler.effects[@id]
			@increment_proc.call(battle, index, position, battler, newValue, increment) if @increment_proc
		end

		def increment_side(battle, side, increment)
			teamName = battle.battlers[side.index].pbTeam
			newValue = battler.effects[@id]
			@increment_proc.call(battle, side, teamName, newValue, increment) if @increment_proc
		end

		def increment_field(battle, increment)
			newValue = battler.effects[@id]
			@increment_proc.call(battle, newValue, increment) if @increment_proc
		end

		### Baton passing
		def baton_pass_value(battler, value)
			if @pass_value_proc
				return @pass_value_proc.call(battler, value)
			else
				return value
			end
		end

		def each_sub_effect
			@sub_effects.each do |otherEffect|
				otherEffectData = GameData::BattleEffect.get(effect)
				yield otherEffect, otherEffectData
			end
		end

		### Iteration methods
		def self.each_battler_effect
			each do |data|
				next if data.location != :Battler
				yield data
			end
		end

		def self.each_position_effect
			each do |data|
				next if data.location != :Position
				yield data
			end
		end

		def self.each_side_effect
			each do |data|
				next if data.location != :Side
				yield data
			end
		end

		def self.each_field_effect
			each do |data|
				next if data.location != :Field
				yield data
			end
		end
	end
end
