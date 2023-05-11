module GameData
    class Item
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :real_name_plural
      attr_reader :pocket
      attr_reader :price
      attr_reader :real_description
      attr_reader :field_use
      attr_reader :battle_use
      attr_reader :type
      attr_reader :move
      attr_reader :super
      attr_reader :cut
  
      DATA = {}
      DATA_FILENAME = "items.dat"
  
      extend ClassMethods
      include InstanceMethods
  
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
  
      def self.held_icon_filename(item)
        item_data = self.try_get(item)
        return nil if !item_data
        name_base = (item_data.is_mail?) ? "mail" : "item"
        # Check for files
        ret = sprintf("Graphics/Pictures/Party/icon_%s_%s", name_base, item_data.id)
        return ret if pbResolveBitmap(ret)
        return sprintf("Graphics/Pictures/Party/icon_%s", name_base)
      end
  
      def self.mail_filename(item)
        item_data = self.try_get(item)
        return nil if !item_data
        # Check for files
        ret = sprintf("Graphics/Pictures/Mail/mail_%s", item_data.id)
        return pbResolveBitmap(ret) ? ret : nil
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
  
      # @return [String] the translated name of this item
      def name
        return pbGetMessage(MessageTypes::Items, @id_number)
      end
  
      # @return [String] the translated plural version of the name of this item
      def name_plural
        return pbGetMessage(MessageTypes::ItemPlurals, @id_number)
      end
  
      # @return [String] the translated description of this item
      def description
        if is_machine?
            return pbGetMessage(MessageTypes::MoveDescriptions, GameData::Move.get(@move).id_number)
        else
            return pbGetMessage(MessageTypes::ItemDescriptions, @id_number)
        end
    end
  
      def is_TM?;              return @field_use == 3; end
      def is_HM?;              return @field_use == 4; end
      def is_TR?;              return @field_use == 6; end
      def is_machine?;         return is_TM? || is_HM? || is_TR?; end
      def is_mail?;            return @type == 1 || @type == 2; end
      def is_icon_mail?;       return @type == 2; end
      def is_poke_ball?;       return @type == 3 || @type == 4; end
      def is_snag_ball?;       return @type == 3 || (@type == 4 && $Trainer.has_snag_machine); end
      def is_berry?;           return @type == 5; end
      def is_key_item?;        return @type == 6 || @type == 13; end

      def is_evolution_stone?; return @type == 7; end
      def is_fossil?;          return @type == 8; end
      def is_apricorn?;        return @type == 9; end
      def is_gem?;             return @type == 10; end
      def is_mulch?;           return @type == 11; end
      def is_mega_stone?;      return @type == 12; end   # Does NOT include Red Orb/Blue Orb
      def is_consumable_key_item?;      return @type == 13; end
  
      def is_important?
        return true if is_key_item? || is_HM? || is_TM?
        return false
      end
  
      def can_hold?;           return !is_important? && @pocket == 5; end
  
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

module Compiler
    module_function

  #=============================================================================
  # Compile item data
  #=============================================================================
  def compile_items
    GameData::Item::DATA.clear
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    idBase = 0
    ["PBS/items.txt","PBS/items_super.txt","PBS/items_cut.txt"].each do |path|
      idNumber = idBase
      # Read each line of items.txt at a time and compile it into an item
      pbCompilerEachCommentedLine(path) { |line, line_no|
        idNumber += 1
        line = pbGetCsvRecord(line, line_no, [0, "vnssuusuuUN"])
        item_number = idNumber
        item_symbol = line[1].to_sym
        if GameData::Item::DATA[item_number]
          raise _INTL("Item ID number '{1}' is used twice.\r\n{2}", item_number, FileLineData.linereport)
        elsif GameData::Item::DATA[item_symbol]
          raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_symbol, FileLineData.linereport)
        end
        # Construct item hash
        item_hash = {
          :id_number   => item_number,
          :id          => item_symbol,
          :name        => line[2],
          :name_plural => line[3],
          :pocket      => line[4],
          :price       => line[5],
          :description => line[6],
          :field_use   => line[7],
          :battle_use  => line[8],
          :type        => line[9],
          :cut         => path == "PBS/items_cut.txt",
          :super       => path == "PBS/items_super.txt",
        }
        item_hash[:move] = parseMove(line[10]) if !nil_or_empty?(line[10])
        # Add item's data to records
        GameData::Item.register(item_hash)
        item_names[item_number]        = item_hash[:name]
        item_names_plural[item_number] = item_hash[:name_plural]
        item_descriptions[item_number] = item_hash[:description]
      }
      idBase += 1000
    end
    # Save all data
    GameData::Item.save
    MessageTypes.setMessages(MessageTypes::Items, item_names)
    MessageTypes.setMessages(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessages(MessageTypes::ItemDescriptions, item_descriptions)
    Graphics.update
  end

    #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    File.open("PBS/items.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        break if i.cut || i.super
        write_item(f,i)
      end
    }
    File.open("PBS/items_super.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        next unless i.super
        write_item(f,i)
      end
    }
    File.open("PBS/items_cut.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        next unless i.cut
        write_item(f,i)
      end
    }
    Graphics.update
  end

  def write_item(f,i)
    move_name = (i.move) ? GameData::Move.get(i.move).id.to_s : ""
    sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d\r\n"
    sprintf_text = "%d,%s,%s,%s,%d,%d,%s,%d,%d,%d,%s\r\n" if move_name != ""
    f.write(sprintf(sprintf_text,
      i.id_number,
      csvQuote(i.id.to_s),
      csvQuote(i.real_name),
      csvQuote(i.real_name_plural),
      i.pocket,
      i.price,
      csvQuoteAlways(i.real_description),
      i.field_use,
      i.battle_use,
      i.type,
      csvQuote(move_name)
    ))
  end
end