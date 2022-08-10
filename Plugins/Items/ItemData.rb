module GameData
    class Item
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
    end
end