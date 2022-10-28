class PokemonBag
    def reassignPockets()
        hashOfAllItems = {}
        for i in 0..PokemonBag.numPockets
            @pockets[i].each do |item_element|
                itemID = item_element[0]
                itemCount = item_element[1]
                if hashOfAllItems.has_key?(itemID)
                    hashOfAllItems[itemID] += itemCount
                else
                    hashOfAllItems[itemID] = itemCount
                end
            end
            @pockets[i] = []
        end

        hashOfAllItems.each do |key, value|
            echoln("Storing #{value} of #{key} back into the bag")
            pbStoreItem(key,value)
        end
    end
end