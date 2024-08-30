# NOTE: If adding a new target, you will need to add code in several places to
#       make them work properly:
#         - def pbFindTargets
#         - def pbMoveCanTarget?
#         - def pbCreateTargetTexts
#         - def pbFirstTarget
#         - def pbTargetsMultiple?
module GameData
  class Target
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :num_targets        # 0, 1 or 2 (meaning 2+)
      attr_reader :targets_foe        # Is able to target one or more foes
      attr_reader :targets_user       # Is able to target the user
      attr_reader :targets_ally       # Is able to target the user's ally
      attr_reader :targets_all        # Crafty Shield can't protect from these moves
      attr_reader :affects_foe_side   # Pressure also affects these moves
      attr_reader :long_range         # Hits non-adjacent targets

      DATA = {}

      extend ClassMethods
      include InstanceMethods

      def self.load; end
      def self.save; end

      def initialize(hash)
          @id                 = hash[:id]
          @real_name          = hash[:name]               || "Unnamed"
          @num_targets        = hash[:num_targets]        || 0
          @targets_foe        = hash[:targets_foe]        || false
          @targets_user       = hash[:targets_user]       || false
          @targets_ally       = hash[:targets_ally]       || false
          @targets_all        = hash[:targets_all]        || false
          @affects_foe_side   = hash[:affects_foe_side]   || false
          @affects_user_side  = hash[:affects_user_side]  || false
          @long_range         = hash[:long_range]         || false
          @targeting_label    = hash[:targeting_label]
      end

      # @return [String] the translated name of this target
      def name
          return _INTL(@real_name)
      end

      def can_choose_distant_target?
          return @num_targets == 1 && @long_range
      end

      def can_target_one_foe?
          return @num_targets == 1 && @targets_foe
      end
  
      ###########################################################################################
      # Methods to determine what to highlight in graphics that explain how a move targets
      ###########################################################################################
      def show_foe_targeting?
          return @targets_foe || @affects_foe_side || @targets_all
      end

      def show_user_targeting?
          return @targets_user || @affects_user_side || @targets_all
      end

      def show_ally_targeting?
          return @targets_ally || @affects_user_side || @targets_all
      end

      def get_targeting_label
          return _INTL(@targeting_label) if @targeting_label
          if targets_all
            return _INTL("All")
          elsif @num_targets > 1
            return _INTL("Each")
          elsif @num_targets == 1
            return _INTL("One")
          elsif @targets_user
            return _INTL("User")
          end
          return _INTL("Error")
      end

      def spread?
        return @num_targets > 1
      end
  end
end

#===============================================================================

# Bide, Counter, Metal Burst, Mirror Coat (calculate a target)
GameData::Target.register({
  :id               => :None,
  :id_number        => 1,
  :name             => _INTL("None"),
})

GameData::Target.register({
  :id               => :User,
  :id_number        => 10,
  :name             => _INTL("User"),
  :targets_user     => true,
})

# Aromatic Mist, Helping Hand, Hold Hands
GameData::Target.register({
  :id               => :NearAlly,
  :id_number        => 100,
  :name             => _INTL("Near Ally"),
  :num_targets      => 1,
  :targets_ally     => true,
})

# Acupressure
GameData::Target.register({
  :id               => :UserOrNearAlly,
  :id_number        => 200,
  :name             => _INTL("User or Near Ally"),
  :num_targets      => 1,
  :targets_user     => true,
  :targets_ally     => true,
})

# Aromatherapy, Gear Up, Heal Bell, Life Dew, Magnetic Flux, Howl (in Gen 8+)
GameData::Target.register({
  :id               => :UserAndAllies,
  :id_number        => 5,
  :name             => _INTL("User and Allies"),
  :num_targets      => 2,
  :long_range       => true,
  :targets_user     => true,
  :targets_ally     => true,
  :targeting_label  => "Us",
})

# Me First
GameData::Target.register({
  :id               => :NearFoe,
  :id_number        => 400,
  :name             => _INTL("Near Foe"),
  :num_targets      => 1,
  :targets_foe      => true,
})

# Petal Dance, Outrage, Struggle, Thrash, Uproar
GameData::Target.register({
  :id               => :RandomNearFoe,
  :id_number        => 2,
  :name             => _INTL("Random Near Foe"),
  :num_targets      => 1,
  :targets_foe      => true,
  :targeting_label  => "Random",
})

GameData::Target.register({
  :id               => :ClosestNearFoe,
  :id_number        => 2,
  :name             => _INTL("Closest Near Foe"),
  :num_targets      => 1,
  :targets_foe      => true,
  :targeting_label  => "Closer",
})

GameData::Target.register({
  :id               => :AllNearFoes,
  :id_number        => 4,
  :name             => _INTL("All Near Foes"),
  :num_targets      => 2,
  :targets_foe      => true,
})

# For throwing a Poké Ball
GameData::Target.register({
  :id               => :Foe,
  :id_number        => 9,
  :name             => _INTL("Foe"),
  :num_targets      => 1,
  :targets_foe      => true,
  :long_range       => true,
})

# Unused
GameData::Target.register({
  :id               => :AllFoes,
  :id_number        => 6,
  :name             => _INTL("All Foes"),
  :num_targets      => 2,
  :targets_foe      => true,
  :long_range       => true,
})

GameData::Target.register({
  :id               => :NearOther,
  :id_number        => 0,
  :name             => _INTL("Near Other"),
  :num_targets      => 1,
  :targets_foe      => true,
})

GameData::Target.register({
  :id               => :AllNearOthers,
  :id_number        => 8,
  :name             => _INTL("All Near Others"),
  :num_targets      => 2,
  :targets_foe      => true,
  :targets_ally     => true,
})

# Most Flying-type moves, pulse moves (hits non-near targets)
GameData::Target.register({
  :id               => :Other,
  :id_number        => 3,
  :name             => _INTL("Other"),
  :num_targets      => 1,
  :targets_foe      => true,
  :long_range       => true,
})

# Flower Shield, Perish Song, Rototiller, Teatime
GameData::Target.register({
  :id               => :AllBattlers,
  :id_number        => 7,
  :name             => _INTL("All Battlers"),
  :num_targets      => 2,
  :targets_foe      => true,
  :targets_all      => true,
  :targets_user     => true,
  :long_range       => true,
})

GameData::Target.register({
  :id               => :UserSide,
  :id_number        => 40,
  :name             => _INTL("User Side"),
  :affects_user_side => true,
})

# Entry hazards
GameData::Target.register({
  :id               => :FoeSide,
  :id_number        => 80,
  :name             => _INTL("Foe Side"),
  :affects_foe_side => true,
})

GameData::Target.register({
  :id               => :BothSides,
  :id_number        => 20,
  :name             => _INTL("Both Sides"),
  :affects_foe_side => true,
  :affects_user_side => true,
  :targeting_label  => "Field",
})

GameData::Target.register({
  :id               => :UserOrNearOther,
  :id_number        => 21,
  :name             => _INTL("User Or Near Other"),
  :targets_foe      => true,
  :targets_user     => true,
  :targets_ally     => true,
  :num_targets      => 1,

})

GameData::Target.register({
  :id               => :Ally,
  :id_number        => 22,
  :name             => _INTL("Ally"),
  :num_targets      => 1,
  :targets_ally     => true,
})

# Create the targeting category used for the Info button
GameData::Target.register({
  :id               => :UserOrOther,
  :id_number        => 500,
  :name             => _INTL("User Or Other"),
  :targets_foe      => true,
  :long_range       => true,
  :num_targets      => 1,
  :targets_user     => true,
})
