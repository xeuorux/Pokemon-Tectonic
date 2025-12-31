module GameData
    class Item
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :real_name_plural
      attr_reader :pocket
      attr_reader :price
      attr_reader :sell_price
      attr_reader :real_description
      attr_reader :field_use
      attr_reader :battle_use
      attr_reader :consumable
      attr_reader :flags
      attr_reader :type
      attr_reader :move
      attr_reader :super
      attr_reader :cut
  
      DATA = {}
      DATA_FILENAME = "items.dat"

      BASE_DATA = {} # Data that hasn't been extended

      FLAG_INDEX = {}
      FLAGS_INDEX_DATA_FILENAME = "items_indexed_by_flag.dat"
      
      MACHINE_ORDER = {}
      MACHINE_ORDER_DATA_FILENAME = "machine_order.dat"

      SCHEMA = {
        "Name"        => [:name,        "s"],
        "NamePlural"  => [:name_plural, "s"],
        "Pocket"      => [:pocket,      "v"],
        "Price"       => [:price,       "u"],
        "SellPrice"   => [:sell_price,  "u"],
        "Description" => [:description, "q"],
        "FieldUse"    => [:field_use,   "e", { "OnPokemon" => 1, "Direct" => 2, "TM" => 3,
                                              "HM" => 4, "TR" => 5 }],
        "BattleUse"   => [:battle_use,  "e", { "OnPokemon" => 1, "OnMove" => 2, "OnBattler" => 3,
                                              "OnFoe" => 4, "Direct" => 5 }],
        "Consumable"  => [:consumable,  "b"],
        "Flags"       => [:flags,       "*s"],
        "Move"        => [:move,        "e", :Move]
      }
  
      extend ClassMethods
      include InstanceMethods
  
      def self.icon_filename(item)
        return "Graphics/Items/back" if item.nil?
        item_data = self.try_get(item)
        return "Graphics/Items/000" if item_data.nil?
        itemID = item_data.id
        # Check for files
        ret = itemID.to_s
        ret = ItemIconEvents::triggerModifyItemIconFileName(item, ret)
        ret = sprintf("Graphics/Items/%s", ret)
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
        if !hash[:sell_price] && hash[:price]
          hash[:sell_price] = hash[:price] / 2
        end

        @id               = hash[:id]
        @id_number        = hash[:id_number]   || -1
        @real_name        = hash[:name]        || "Unnamed"
        @real_name_plural = hash[:name_plural] || "Unnamed"
        @pocket           = hash[:pocket]      || 1
        @price            = hash[:price]       || 0
        @sell_price       = hash[:sell_price]  || 0
        @real_description = hash[:description] || ""
        @field_use        = hash[:field_use]   || 0
        @battle_use       = hash[:battle_use]  || 0
        @type             = hash[:type]        || 0
        @flags            = hash[:flags]       || []
        @flags.uniq!
        @consumable       = hash[:consumable]
        @consumable       = !is_important? if @consumable.nil?
        @move             = hash[:move]
        @super            = hash[:super]       || false
        @cut              = hash[:cut]       || false
        @defined_in_extension   = hash[:defined_in_extension] || false

        @flags.each do |flag|
          if FLAG_INDEX.key?(flag)
            FLAG_INDEX[flag].push(@id)
          else
            FLAG_INDEX[flag] = [@id]
          end
        end
      end
  
      # @return [String] the translated name of this item
      def name
        if is_TM?
          return _INTL("TM {1}",GameData::Move.get(@move).name)
        elsif is_TR?
          return _INTL("TR {1}",GameData::Move.get(@move).name)
        elsif is_HM?
          return _INTL("HM {1}",GameData::Move.get(@move).name)
        elsif @id == :AIDKIT && $PokemonGlobal && $PokemonGlobal.teamHealerUpgrades && $PokemonGlobal.teamHealerUpgrades > 0
          upgradeCount = $PokemonGlobal.teamHealerUpgrades || 0
          return _INTL("{1} +{2}",pbGetMessageFromHash(MessageTypes::Items, @real_name),upgradeCount)
        else
          return pbGetMessageFromHash(MessageTypes::Items, @real_name)
        end
      end
  
      # @return [String] the translated plural version of the name of this item
      def name_plural
        if is_machine?
          return _INTL("{1} TMs",GameData::Move.get(@move).name_plural)
        elsif is_TR?
          return _INTL("{1} TRs",GameData::Move.get(@move).name_plural)
        elsif is_HM?
          return _INTL("{1} HMs",GameData::Move.get(@move).name_plural)
        else
          return pbGetMessageFromHash(MessageTypes::ItemPlurals, @real_name_plural)
        end
      end
  
      # @return [String] the translated description of this item
      def description
        if is_machine?
            return pbGetMessageFromHash(MessageTypes::MoveDescriptions, GameData::Move.get(@move).real_description)
        else
            return pbGetMessageFromHash(MessageTypes::ItemDescriptions, @real_description)
        end
      end
  
      def is_TM?;                   return @field_use == 3; end
      def is_HM?;                   return @field_use == 4; end
      def is_TR?;                   return @field_use == 6; end
      def is_machine?;              return is_TM? || is_HM? || is_TR?; end
      def machine_index
        return GameData::Item.getMachineIndex(@id)
      end

      def is_poke_ball?
        return @flags.include?("PokeBall")
      end

      def is_snag_ball?
        return @flags.include?("SnagBall")
      end

      def no_ball_swap?
        return @flags.include?("NoBallSwap")
      end

      def is_mail?
        return @flags.include?("Mail")
      end

      def is_icon_mail?
        return @flags.include?("IconMail")
      end

      def is_berry?
        return @flags.include?("Berry")
      end

      def is_clothing?
        return @flags.include?("Clothing")
      end

      def is_choice_locking?
        return @flags.include?("ChoiceLocking")
      end

      def is_no_status_use?
        return @flags.include?("NoStatusUse")
      end

      def is_levitation?
        return @flags.include?("Levitation")
      end

      def is_endure?
        return @flags.include?("Endure")
      end

      def is_weather_rock?
        return @flags.include?("WeatherRock")
      end

      def is_attacker_recoil?
        return @flags.include?("AttackerRecoil")
      end

      def is_herb?
        return @flags.include?("Herb")
      end

      def is_leftovers?
        return @flags.include?("Leftovers")
      end

      def is_pinch?
        return @flags.include?("Pinch")
      end

      def is_key_item?
        return @flags.include?("KeyItem")
      end

      def is_consumable_key_item?
        return @flags.include?("KeyItem") && @consumable
      end

      def is_single_key_item?
        return @flags.include?("KeyItem") && !@consumable
      end

      def is_evolution_item?
        return @flags.include?("EvolutionItem")
      end

      def is_evolution_stone?
        return @flags.include?("EvolutionStone")
      end

      def is_fossil?
        return @flags.include?("Fossil")
      end

      def is_gem?
        return @flags.include?("TypeGem")
      end

      def is_mega_stone?
        return @flags.include?("MegaStone")
      end

      def is_mulch?
        return @flags.include?("Mulch")
      end

      def is_type_setting?
        return @flags.include?("TypeSetting")
      end
  
      def is_important?
        return true if is_key_item? || is_HM? || is_TM?
        return false
      end

      def is_single_purchase?
        return true if is_single_key_item? || is_HM? || is_TM?
        return false
      end
  
      def can_hold?;           return !is_important? && @pocket >= 9 && @pocket <= 13; end

      def consumed_after_use?
        return !is_important? && @consumable
      end

      def show_pocket_message?
        return !@flags.include?("SkipPocketMessage")
      end
  
      def unlosable?(species, ability)
        base_form_data = GameData::Species.get_species_form(species, 0)
        return false if base_form_data.nil?
        sticky_items = base_form_data.sticky_items
        return sticky_items.include?(@id)
      end

      def legal?(isNPC = false)
        return false if @cut
        return false if @super && !isNPC
        return true
      end

      def self.getByFlag(flag)
        if FLAG_INDEX.key?(flag)
          return FLAG_INDEX[flag]
        else
          return []
        end
      end

      def self.getMachineIndex(machineItemID)
        unless self.get(machineItemID)&.is_machine?
          raise _INTL("Cannot get machine index of item {1} ID. It either doesn't exist or isn't a machine!", machineItemID)
        end
        return MACHINE_ORDER[machineItemID] || -1
      end

      def self.load
        super
        const_set(:FLAG_INDEX, load_data("Data/#{self::FLAGS_INDEX_DATA_FILENAME}"))
        const_set(:MACHINE_ORDER, load_data("Data/#{self::MACHINE_ORDER_DATA_FILENAME}"))
      end

      def self.save
        super
        save_data(self::FLAG_INDEX, "Data/#{self::FLAGS_INDEX_DATA_FILENAME}")
        save_data(self::MACHINE_ORDER, "Data/#{self::MACHINE_ORDER_DATA_FILENAME}")
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
    schema = GameData::Item::SCHEMA
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    item_hash         = nil
    idx = 0
    baseFiles = ["PBS/items.txt","PBS/items_super.txt","PBS/items_machine.txt","PBS/items_cut.txt"]
    itemTextFiles = []
    itemTextFiles.concat(baseFiles)
    itemExtensions = Compiler.get_extensions("items")
    itemTextFiles.concat(itemExtensions)
    itemTextFiles.each do |path|
      baseFile = baseFiles.include?(path)
      # Read each line of items.txt at a time and compile it into an item
      pbCompilerEachPreppedLine(path) { |line, line_no|
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [item_id]
          # Add previous item's data to records
          if item_hash
            # If this is an extension modifying an existing item, modify it in-place
            if item_hash[:defined_in_extension] && GameData::Item::DATA[item_hash[:id]]
              existing_item = GameData::Item::DATA[item_hash[:id]]
              existing_item.instance_variable_set(:@real_name, item_hash[:name]) if item_hash[:name]
              existing_item.instance_variable_set(:@real_name_plural, item_hash[:name_plural]) if item_hash[:name_plural]
              existing_item.instance_variable_set(:@pocket, item_hash[:pocket]) if item_hash[:pocket]
              existing_item.instance_variable_set(:@price, item_hash[:price]) if item_hash[:price]
              existing_item.instance_variable_set(:@sell_price, item_hash[:sell_price]) if item_hash[:sell_price]
              existing_item.instance_variable_set(:@real_description, item_hash[:description]) if item_hash[:description]
              existing_item.instance_variable_set(:@field_use, item_hash[:field_use]) if item_hash[:field_use]
              existing_item.instance_variable_set(:@battle_use, item_hash[:battle_use]) if item_hash[:battle_use]
              existing_item.instance_variable_set(:@consumable, item_hash[:consumable]) if item_hash.key?(:consumable)
              existing_item.instance_variable_set(:@flags, item_hash[:flags]) if item_hash[:flags]
              existing_item.instance_variable_set(:@type, item_hash[:type]) if item_hash[:type]
              existing_item.instance_variable_set(:@move, item_hash[:move]) if item_hash[:move]
            else
              GameData::Item.register(item_hash)
            end
          end
          # Parse item ID
          item_id = $~[1].to_sym
          if GameData::Item.exists?(item_id)
            if !baseFile
              # Back up base entry for writing base PBS later (only if not already backed up)
              unless GameData::Item::BASE_DATA[item_id]
                # Create a deep clone of the existing item for backup
                old_item = GameData::Item::DATA[item_id]
                backup_hash = {
                  :id               => old_item.id,
                  :id_number        => old_item.id_number,
                  :name             => old_item.real_name,
                  :name_plural      => old_item.real_name_plural,
                  :pocket           => old_item.pocket,
                  :price            => old_item.price,
                  :sell_price       => old_item.sell_price,
                  :description      => old_item.real_description,
                  :field_use        => old_item.field_use,
                  :battle_use       => old_item.battle_use,
                  :consumable       => old_item.consumable,
                  :flags            => old_item.flags.clone,
                  :type             => old_item.type,
                  :move             => old_item.move,
                  :super            => old_item.super,
                  :cut              => old_item.cut,
                  :defined_in_extension => old_item.defined_in_extension,
                }
                GameData::Item::BASE_DATA[item_id] = GameData::Item.new(backup_hash)
              end
              # Extension is modifying an existing item, so we'll merge the data below
            else
              raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_id, FileLineData.linereport)
            end
          end
          # Construct item hash
          item_hash = {
            :id         => item_id,
            :id_number  => idx,
            :cut        => path == "PBS/items_cut.txt",
            :super      => path == "PBS/items_super.txt",
            :defined_in_extension   => !baseFile,
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
          if !item_hash
            raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
          end
          # Parse property and value
          property_name = $~[1]
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          # Record XXX=YYY setting
          item_hash[line_schema[0]] = property_value
          next if path == "PBS/items_cut.txt"
          case property_name
          when "Name"
            item_names.push(item_hash[:name])
          when "NamePlural"
            item_names_plural.push(item_hash[:name_plural])
          when "Description"
            item_descriptions.push(item_hash[:description])
          end
        end
      }
    end
    # Add last item's data to records
    if item_hash
      # If this is an extension modifying an existing item, modify it in-place
      if item_hash[:defined_in_extension] && GameData::Item::DATA[item_hash[:id]]
        existing_item = GameData::Item::DATA[item_hash[:id]]
        existing_item.instance_variable_set(:@real_name, item_hash[:name]) if item_hash[:name]
        existing_item.instance_variable_set(:@real_name_plural, item_hash[:name_plural]) if item_hash[:name_plural]
        existing_item.instance_variable_set(:@pocket, item_hash[:pocket]) if item_hash[:pocket]
        existing_item.instance_variable_set(:@price, item_hash[:price]) if item_hash[:price]
        existing_item.instance_variable_set(:@sell_price, item_hash[:sell_price]) if item_hash[:sell_price]
        existing_item.instance_variable_set(:@real_description, item_hash[:description]) if item_hash[:description]
        existing_item.instance_variable_set(:@field_use, item_hash[:field_use]) if item_hash[:field_use]
        existing_item.instance_variable_set(:@battle_use, item_hash[:battle_use]) if item_hash[:battle_use]
        existing_item.instance_variable_set(:@consumable, item_hash[:consumable]) if item_hash.key?(:consumable)
        existing_item.instance_variable_set(:@flags, item_hash[:flags]) if item_hash[:flags]
        existing_item.instance_variable_set(:@type, item_hash[:type]) if item_hash[:type]
        existing_item.instance_variable_set(:@move, item_hash[:move]) if item_hash[:move]
      else
        GameData::Item.register(item_hash)
      end
    end

    compile_machine_order

    # Save all data
    GameData::Item.save
    MessageTypes.setMessagesAsHash(MessageTypes::Items, item_names)
    MessageTypes.setMessagesAsHash(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessagesAsHash(MessageTypes::ItemDescriptions, item_descriptions)
    Graphics.update
  end

  def compile_machine_order
    GameData::Item::MACHINE_ORDER.clear
    pbCompilerEachPreppedLine("PBS/items_machine_order.txt") { |line, line_no|
      GameData::Item::MACHINE_ORDER[line.to_sym] = line_no
    }
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    File.open("PBS/items.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each_base do |i|
        next if i.cut || i.super || i.is_machine?
        write_item(f,i)
      end
    }
    File.open("PBS/items_super.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each_base do |i|
        next unless i.super
        write_item(f,i)
      end
    }
    File.open("PBS/items_cut.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each_base do |i|
        next unless i.cut
        write_item(f,i)
      end
    }
    File.open("PBS/items_machine.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each_base do |i|
        next if i.cut || i.super
        next unless i.is_machine?
        write_item(f,i)
      end
    }
    Graphics.update

    write_machine_order
  end

  def write_machine_order
    File.open("PBS/items_machine_order.txt", "wb") { |f|
      GameData::Item::MACHINE_ORDER.each do |machine_id, index|
        f.write(sprintf("%s\r\n",machine_id))
      end
    }
  end

  def write_item(f,item)
    # Use backed-up base data if it exists (i.e., if an extension modified this item)
    item_to_write = GameData::Item::BASE_DATA[item.id] || item
    f.write("\#-------------------------------\r\n")
    f.write(sprintf("[%s]\r\n", item_to_write.id))
    f.write(sprintf("Name = %s\r\n", item_to_write.real_name))
    f.write(sprintf("NamePlural = %s\r\n", item_to_write.real_name_plural))
    modifiedPocket = item_to_write.pocket
    # case item_to_write.pocket
    # when 1
    #   if item_to_write.is_evolution_item?
    #     modifiedPocket = 4
    #   elsif item_to_write.name.downcase.include?("fossil") || item_to_write.name.downcase.include?("token") || item_to_write.name.downcase.include?("ore") || item_to_write.name.downcase.include?("egg")
    #     modifiedPocket = 16
    #   end
    # when 2
    #   if item_to_write.name.downcase.include?("candy")
    #     modifiedPocket = 3
    #   end
    # when 3
    #   modifiedPocket = 14
    # when 4
    #   modifiedPocket = 5
    # when 5
    #   if item_to_write.is_berry?
    #     modifiedPocket = 9
    #   elsif item_to_write.is_gem?
    #     modifiedPocket = 10
    #   elsif item_to_write.is_herb?
    #     modifiedPocket = 11
    #   elsif item_to_write.is_clothing?
    #     modifiedPocket = 12
    #   else
    #     modifiedPocket = 13
    #   end
    # when 6
    #   modifiedPocket = 15
    # when 7
    #   modifiedPocket = 6
    # end
    f.write(sprintf("Pocket = %d\r\n", modifiedPocket))
    f.write(sprintf("Price = %d\r\n", item_to_write.price))
    f.write(sprintf("SellPrice = %d\r\n", item_to_write.sell_price)) if item_to_write.sell_price != item_to_write.price / 2
    field_use = GameData::Item::SCHEMA["FieldUse"][2].key(item_to_write.field_use)
    f.write(sprintf("FieldUse = %s\r\n", field_use)) if field_use
    battle_use = GameData::Item::SCHEMA["BattleUse"][2].key(item_to_write.battle_use)
    f.write(sprintf("BattleUse = %s\r\n", battle_use)) if battle_use
    # Assume important items aren't consumable
    # and other items are
    # So only note the exceptions
    if item_to_write.is_important?
      f.write(sprintf("Consumable = true\r\n")) if item_to_write.consumable
    else
      f.write(sprintf("Consumable = false\r\n")) unless item_to_write.consumable
    end
    f.write(sprintf("Flags = %s\r\n", item_to_write.flags.join(","))) if item_to_write.flags.length > 0
    f.write(sprintf("Move = %s\r\n", item_to_write.move)) if item_to_write.move
    f.write(sprintf("Description = %s\r\n", item_to_write.real_description)) unless item_to_write.real_description.blank?
  end
end