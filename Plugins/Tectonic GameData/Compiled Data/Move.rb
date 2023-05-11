module GameData
    class Move
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :function_code
      attr_reader :base_damage
      attr_reader :type
      attr_reader :category
      attr_reader :accuracy
      attr_reader :total_pp
      attr_reader :effect_chance
      attr_reader :target
      attr_reader :priority
      attr_reader :flags
      attr_reader :real_description
      attr_reader :animation_move
      attr_reader :signature_of
      attr_reader :primeval
      attr_reader :zmove
      attr_reader :cut
      attr_reader :tectonic_new
  
      DATA = {}
      DATA_FILENAME = "moves.dat"
  
      extend ClassMethods
      include InstanceMethods
  
      def initialize(hash)
        @id                 = hash[:id]
        @id_number          = hash[:id_number]   || -1
        @real_name          = hash[:name]        || "Unnamed"
        @function_code      = hash[:function_code]
        @base_damage        = hash[:base_damage]
        @type               = hash[:type]
        @category           = hash[:category]
        @accuracy           = hash[:accuracy]
        @total_pp           = hash[:total_pp]
        @effect_chance      = hash[:effect_chance]
        @target             = hash[:target]
        @priority           = hash[:priority]
        @flags              = hash[:flags]
        @real_description   = hash[:description] || "???"
        @animation_move     = hash[:animation_move]
        @signature_of       = nil
        @primeval           = hash[:primeval] || false
        @zmove              = hash[:zmove] || false
        @cut                = hash[:cut] || false
        @tectonic_new       = hash[:tectonic_new] || false
      end
  
      # @return [String] the translated name of this move
      def name
        return pbGetMessage(MessageTypes::Moves, @id_number)
      end
  
      # @return [String] the translated description of this move
      def description
        return pbGetMessage(MessageTypes::MoveDescriptions, @id_number)
      end
  
      def physical?
        return false if @base_damage == 0
        return @category == 0 if Settings::MOVE_CATEGORY_PER_MOVE
        return GameData::Type.get(@type).physical?
      end
  
      def special?
        return false if @base_damage == 0
        return @category == 1 if Settings::MOVE_CATEGORY_PER_MOVE
        return GameData::Type.get(@type).special?
      end
  
      def hidden_move?
        GameData::Item.each do |i|
          return true if i.is_HM? && i.move == @id
        end
        return false
      end

      def damaging?
        return physical? || special?
      end

      # The highest evolution of a line
      def signature_of=(val)
        @signature_of = val
      end

      def is_signature?()
        return !@signature_of.nil?
      end

      def empoweredMove?
        return @flags[/y/]
      end

      def categoryLabel
        return _INTL("Physical") if physical?
        return _INTL("Special") if special?
        return _INTL("Status")
      end

      def priorityLabel
        priorityLabel = @priority.to_s
                  priorityLabel = "+" + priorityLabel if @priority > 0
        return priorityLabel
      end

      def tagLabel
        category = nil
        @flags.split("").each do |flag|
          case flag
          when "i"
              category = _INTL("Bite")
          when "j"
              category = _INTL("Punch")
          when "k"
              category = _INTL("Sound")
          when "m"
              category = _INTL("Pulse")
          when "o"
              category = _INTL("Dance")
          when "p"
              category = _INTL("Blade")
          when "q"
              category = _INTL("Wind")
          end
        end
        return category
      end

      def can_be_forced?
        return false if [
          "0D4",   # Bide
          "14B",   # King's Shield
          # Struggle
          "002",   # Struggle
          "158",   # Belch
          # Moves that affect the moveset
          "05C",   # Mimic
          "05D",   # Sketch
          "069",   # Transform
          # Moves that call other moves
          "0AE",   # Mirror Move
          "0AF",   # Copycat
          "0B0",   # Me First
          "0B3",   # Nature Power
          "0B4",   # Sleep Talk
          "0B5",   # Assist
          "0B6",   # Metronome
          "16B",   # Instruct
          "57A",   # Hive Mind
          # Moves that require a recharge turn
          "0C2",   # Hyper Beam
          # Moves that start focussing at the start of the round
          "115",   # Focus Punch
          "171",   # Shell Trap
          "172",   # Beak Blast
          # Counter moves
          "071",   # Counter
          "072",   # Mirror Coat
          "073",   # Metal Burst
        ].include?(@function_code)
        return true
      end

      def learnable?
        return false if @cut
        return false if @primeval
        return false if @zmove
        return true
      end
    end
end
  
#===============================================================================
# Deprecated methods
#===============================================================================
# @deprecated This alias is slated to be removed in v20.
def pbGetMoveData(move_id, move_data_type = -1)
    Deprecation.warn_method('pbGetMoveData', 'v20', 'GameData::Move.get(move_id)')
    return GameData::Move.get(move_id)
end

# @deprecated This alias is slated to be removed in v20.
def pbIsHiddenMove?(move)
    Deprecation.warn_method('pbIsHiddenMove?', 'v20', 'GameData::Move.get(move).hidden_move?')
    return GameData::Move.get(move).hidden_move?
end

module Compiler
    module_function
  #=============================================================================
  # Compile move data
  #=============================================================================
  def compile_moves
    GameData::Move::DATA.clear
    move_names        = []
    move_descriptions = []
    idBase = 0
    ["PBS/moves.txt","PBS/moves_new.txt","PBS/moves_primeval.txt","PBS/moves_z.txt","PBS/moves_cut.txt"].each do |path|
      idNumber = idBase
      primeval = path == "PBS/moves_primeval.txt"
      cut = path == "PBS/moves_cut.txt"
      tectonic_new = path == "PBS/moves_new.txt"
      zmove = path == "PBS/moves_z.txt"
      # Read each line of moves.txt at a time and compile it into an move
      pbCompilerEachPreppedLine(path) { |line, line_no|
        idNumber += 1
        line = pbGetCsvRecord(line, line_no, [0, "vnssueeuuueissN",
          nil, nil, nil, nil, nil, :Type, ["Physical", "Special", "Status"],
          nil, nil, nil, :Target, nil, nil, nil, nil
        ])
        move_number = idNumber
        move_symbol = line[1].to_sym
        if GameData::Move::DATA[move_number]
          raise _INTL("Move ID number '{1}' is used twice.\r\n{2}", move_number, FileLineData.linereport)
        elsif GameData::Move::DATA[move_symbol]
          raise _INTL("Move ID '{1}' is used twice.\r\n{2}", move_symbol, FileLineData.linereport)
        end
        # Sanitise data
        if line[6] == 2 && line[4] != 0
          raise _INTL("Move {1} is defined as a Status move with a non-zero base damage.\r\n{2}", line[2], FileLineData.linereport)
        elsif line[6] != 2 && line[4] == 0
          print _INTL("Warning: Move {1} was defined as Physical or Special but had a base damage of 0. Changing it to a Status move.\r\n{2}", line[2], FileLineData.linereport)
          line[6] = 2
        end
        animation_move = line[14].nil? ? nil : line[14].to_sym
        # Construct move hash
        move_hash = {
          :id_number        => move_number,
          :id               => move_symbol,
          :name             => line[2],
          :function_code    => line[3],
          :base_damage      => line[4],
          :type             => line[5],
          :category         => line[6],
          :accuracy         => line[7],
          :total_pp         => line[8],
          :effect_chance    => line[9],
          :target           => GameData::Target.get(line[10]).id,
          :priority         => line[11],
          :flags            => line[12],
          :description      => line[13],
          :animation_move   => animation_move,
          :primeval         => primeval,
          :cut              => cut,
          :tectonic_new     => tectonic_new,
          :zmove            => zmove,
        }
        # Add move's data to records
        GameData::Move.register(move_hash)
        move_names[move_number]        = move_hash[:name]
        move_descriptions[move_number] = move_hash[:description]
      }
      idBase += 1000
    end
    # Save all data
    GameData::Move.save
    MessageTypes.setMessages(MessageTypes::Moves, move_names)
    MessageTypes.setMessages(MessageTypes::MoveDescriptions, move_descriptions)
    Graphics.update

    GameData::Move.each do |move_data|
      next if move_data.animation_move.nil?
      next if GameData::Move.exists?(move_data.animation_move)
      raise _INTL("Move ID '{1}' was assigned an Animation Move property {2} that doesn't match with any other move.\r\n", move_data.id, move_data.animation_move)
    end
  end

  #=============================================================================
  # Save move data to PBS file
  #=============================================================================
  def write_moves
    File.open("PBS/moves_new.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next unless m.tectonic_new
        write_move(f,m)
      end
    }
    File.open("PBS/moves_cut.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next unless m.cut
        write_move(f,m)
      end
    }
    File.open("PBS/moves_z.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next unless m.zmove
        write_move(f,m)
      end
    }
    File.open("PBS/moves_primeval.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next unless m.primeval
        write_move(f,m)
      end
    }
    File.open("PBS/moves.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Move.each do |m|
        next if m.tectonic_new
        next if m.cut
        next if m.zmove
        next if m.primeval
        write_move(f,m)
      end
    }
    Graphics.update
  end

  def write_move(f, m)
    f.write(sprintf("%d,%s,%s,%s,%d,%s,%s,%d,%d,%d,%s,%d,%s,%s,%s\r\n",
      m.id_number,
      csvQuote(m.id.to_s),
      csvQuote(m.real_name),
      csvQuote(m.function_code),
      m.base_damage,
      m.type.to_s,
      ["Physical", "Special", "Status"][m.category],
      m.accuracy,
      m.total_pp,
      m.effect_chance,
      m.target,
      m.priority,
      csvQuote(m.flags),
      csvQuoteAlways(m.real_description),
      m.animation_move.nil? ? "" : m.animation_move.to_s
    ))
  end
end