module GameData
    class Item
        attr_reader :super
        attr_reader :cut

        def self.icon_filename(item)
            return "Graphics/Items/back" if item.nil?
            item_data = self.try_get(item)
            return "Graphics/Items/000" if item_data.nil?
            itemID = item_data.id
            # Check for files
            ret = sprintf("Graphics/Items/%s", itemID)
            if itemID == :TAROTAMULET && $PokemonGlobal.tarot_amulet_active
                ret += "_ACTIVE"
            end
            return ret if pbResolveBitmap(ret)
            # Check for TM/HM type icons
            if item_data.is_machine?
              prefix = "machine"
              if item_data.is_HM?
                prefix = "machine_hm"
              elsif item_data.is_TR?
                prefix = "machine_tr"
              end
              move_type = GameData::Move.get(item_data.move).type
              type_data = GameData::Type.get(move_type)
              ret = sprintf("Graphics/Items/%s_%s", prefix, type_data.id)
              return ret if pbResolveBitmap(ret)
              if !item_data.is_TM?
                ret = sprintf("Graphics/Items/machine_%s", type_data.id)
                return ret if pbResolveBitmap(ret)
              end
            end
            return "Graphics/Items/000"
        end

        def initialize(hash)
          @id               = hash[:id]
          @id_number        = hash[:id_number]   || -1
          @real_name        = hash[:name]        || "Unnamed"
          @real_name_plural = hash[:name_plural] || "Unnamed"
          @pocket           = hash[:pocket]      || 1
          @price            = hash[:price]       || 0
          @real_description = hash[:description] || "???"
          @field_use        = hash[:field_use]   || 0
          @battle_use       = hash[:battle_use]  || 0
          @type             = hash[:type]        || 0
          @move             = hash[:move]
          @super            = hash[:super]       || false
          @cut              = hash[:cut]       || false
        end

        def can_hold?;           return !is_important? && @pocket == 5; end

        def is_key_item?;        return @type == 6 || @type == 13; end
        def is_consumable_key_item?;      return @type == 13; end
        
        def is_important?
            return true if is_key_item? || is_HM? || is_TM?
            return false
        end

        def description
            if is_machine?
                return pbGetMessage(MessageTypes::MoveDescriptions, GameData::Move.get(@move).id_number)
            else
                return pbGetMessage(MessageTypes::ItemDescriptions, @id_number)
            end
        end
        
        def unlosable?(species, ability)
          return false if species == :ARCEUS && ability != :MULTITYPE
          return false if species == :SILVALLY && ability != :RKSSYSTEM
          combos = {
             :ARCEUS   => [:FISTPLATE,   :FIGHTINIUMZ,
                           :SKYPLATE,    :FLYINIUMZ,
                           :TOXICPLATE,  :POISONIUMZ,
                           :EARTHPLATE,  :GROUNDIUMZ,
                           :STONEPLATE,  :ROCKIUMZ,
                           :INSECTPLATE, :BUGINIUMZ,
                           :SPOOKYPLATE, :GHOSTIUMZ,
                           :IRONPLATE,   :STEELIUMZ,
                           :FLAMEPLATE,  :FIRIUMZ,
                           :SPLASHPLATE, :WATERIUMZ,
                           :MEADOWPLATE, :GRASSIUMZ,
                           :ZAPPLATE,    :ELECTRIUMZ,
                           :MINDPLATE,   :PSYCHIUMZ,
                           :ICICLEPLATE, :ICIUMZ,
                           :DRACOPLATE,  :DRAGONIUMZ,
                           :DREADPLATE,  :DARKINIUMZ,
                           :PIXIEPLATE,  :FAIRIUMZ],
             :SILVALLY => [:MEMORYDISC],
             :GIRATINA => [:GRISEOUSORB],
             :GENESECT => [:BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE],
             :KYOGRE   => [:BLUEORB],
             :GROUDON  => [:REDORB]
          }
          return combos[species] && combos[species].include?(@id)
        end

        def legal?(isTrainer = false)
          return false if @cut
          return false if @super && !isTrainer
          return true
        end
    end
end