$globalEffectIDCounter = 0

module GameData
    class BattleEffect
        attr_reader :id
        attr_reader :id_number
        attr_reader :real_name
        attr_reader :location # The locations are :Battler, :Side, :BothSides, :Position
        attr_reader :type # :Boolean, :Integer, :Position, :Type, :Pokemon, :Move, :Item, :Species
        attr_reader :default # Don't set this intentionally to nil, will be overwritten
        attr_reader :resets_eor # Resets to default value at the end of each turn
        
        # An array of other effects to disable at the same time as it
        # Be careful not to create loops with this
        attr_reader :connected_effects

        # Resets to default value when a battler starts their turn
        attr_reader :resets_battlers_sot

        # Resets to default value when a battler has no ability to continue acting this turn
        # Either when the move ends naturally or is interupted by various effects
        attr_reader :resets_battlers_eot 
        
        attr_reader :resets_on_cancel # Resets to default value if the battler's move is cancelled
        
        attr_reader :ticks_down # If it ticks down at end of round. Only used for integers
        attr_reader :tick_amount

        attr_reader :baton_passed

        # When battlers swap position, the effect changes value to point to the correct battler
        # Only used for :Position type effects
        attr_reader :swaps_with_battlers

        # When a new battler is initialized, other battlers effects which point to its index
        # Are reset to their default position
        # Only used for :Position type effects
        attr_reader :others_lose_track

        # When the effect is active on a battler, that battler is considered to be in a multi-turn attack
        attr_reader :multi_turn_tracker

        DATA = {}

        extend ClassMethods
        include InstanceMethods
    
        def self.load; end
        def self.save; end

        def self.register_effect(location,hash)
            hash[:location] = location
            register(hash)
        end
    
        def initialize(hash)
            @id                     = hash[:id]
            @id_number              = $globalEffectIDCounter
            $globalEffectIDCounter += 1
            @real_name              = hash[:real_name]
            @location               = hash[:location]
            @type                   = hash[:type] || :Boolean
            @default                = hash[:default]
            if @default.nil?
                case @type
                when :Boolean
                    @default = false
                when :Integer, :Species
                    @default = 0
                when :Position
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
            @expire_proc           = hash[:expire_proc]
            # Procs every end of round, only when ticked down with still turns remaining
            @remain_proc            = hash[:remain_proc]
            
            # If the effect needs custom logic to determing if it should be active or not
            # Instead of using the default values (i.e. Integers active above 0)
            @active_value_proc      = hash[:active_value_proc]

            if @eor_proc && (@expire_proc || @remain_proc)
                raise _INTL("Battle effect #{@id} defines both an End of Round proc and either an Expiration or Remaing proc.")
            end

            @baton_passed           = hash[:baton_passed] || false
            @swaps_with_battlers    = hash[:swaps_with_battlers] || false
            # For when the value has to be transformed when baton passed
            @pass_value_proc      = hash[:pass_value_proc]

            @resets_battlers_sot    = hash[:resets_battlers_sot]
            @resets_battlers_eot    = hash[:resets_battlers_eot] || false
            @resets_on_cancel       = hash[:resets_on_cancel] || false
            @multi_turn_tracker     = hash[:multi_turn_tracker] || false
        
            @others_lose_track      = hash[:others_lose_track] || false
        
            @connected_effects         = hash[:connected_effects] || false
        end

        # Method for determining if the effect is considered active
        def active_value?(value)
            case @type
            when :Boolean
                return value
            when :Integer, :Species
                return value > 0
            when :Position
                return value >= 0
            when :Type, :Pokemon, :Move, :Item
                return !value.nil?
            end
        end

        ### Methods dealing with the effect when a battler is initialized
        def initialize_battler(battle,battler)
            @initialize_proc.call(battle,battler) if @initialize_proc
        end

        ### Methods dealing with the effect being newly applied
        def apply_battler(battle,battler)
            value = battler.effects[@id]
            @apply_proc.call(battle,battler,value) if @apply_proc
        end

        def apply_position(battle,position)
            @apply_proc.call(battle,position) if @apply_proc
        end

        def apply_side(battle,side)
            @apply_proc.call(battle,side) if @apply_proc
        end

        def apply_both_sides(battle)
            @apply_proc.call(battle) if @apply_proc
        end

        ### Methods dealing with the effect remaining EOT
        def remain_battler(battle,battler)
            value = battler.effects[@id]
            @remain_proc.call(battle,battler,value) if @remain_proc
        end

        def remain_position(battle,position)
            @remain_proc.call(battle,position) if @remain_proc
        end

        def remain_side(battle,side)
            @remain_proc.call(battle,side) if @remain_proc
        end

        def remain_both_sides(battle)
            @remain_proc.call(battle) if @remain_proc
        end

        ### Methods dealing with the effect going away over time

        def expire_battler(battle,battler)
            @expire_proc.call(battle,battler) if @expire_proc
        end

        def expire_position(battle,position)
            @expire_proc.call(battle,position) if @expire_proc
        end

        def expire_side(battle,side)
            @expire_proc.call(battle,side) if @expire_proc
        end

        def expire_both_sides(battle)
            @expire_proc.call(battle) if @expire_proc
        end

        ### Methods dealing with the EOR effect regardless of if it expired this turn or not

        def eor_battler(battle,battler)
            value = battler.effects[@id]
            @eor_proc.call(battle,battler,value) if @eor_proc
        end

        def eor_position(battle,position)
            @eor_proc.call(battle,position) if @eor_proc
        end

        def eor_side(battle,side)
            @eor_proc.call(battle,side) if @eor_proc
        end

        def eor_both_sides(battle)
            @eor_proc.call(battle) if @eor_proc
        end

        ### Baton passing
        def baton_pass_value(battler,value)
            if @pass_value_proc
                return @pass_value_proc.call(battler,value)
            else
                return value
            end
        end

        def each_connected_effect
            @connected_effects.each do |otherEffect|
                otherEffectData = GameData::BattleEffect.get(effect)
                next if otherEffectData.nil?
                yield otherEffect, otherEffectData
            end
        end

        ### Iteration methods
        def self.each_battler_effect
            each() do |data|
                next if data.location != :Battler
                yield data
            end
        end

        def self.each_position_effect
            each() do |data|
                next if data.location != :Position
                yield data
            end
        end

        def self.each_side_effect
            each() do |data|
                next if data.location != :Side
                yield data
            end
        end

        def self.each_both_sides_effect
            each() do |data|
                next if data.location != :BothSides
                yield data
            end
        end
    end
end