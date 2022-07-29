module GameData
    class Item
        def can_hold?;           return !is_important? && @pocket == 5; end

        def description
            if is_machine?
                return pbGetMessage(MessageTypes::MoveDescriptions, GameData::Move.get(@move).id_number)
            else
                return pbGetMessage(MessageTypes::ItemDescriptions, @id_number)
            end
        end
    end
end