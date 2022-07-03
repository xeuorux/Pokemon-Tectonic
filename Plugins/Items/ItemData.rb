module GameData
    class Item
        def can_hold?;           return !is_important? && @pocket == 5; end
    end
end