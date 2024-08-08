class MoveDex_Scene
    ##################################################
    # FILTERS
    ##################################################
    def searchByMoveName
        nameInput = pbEnterText(_INTL("Search name..."), 0, 12)
        if nameInput && nameInput != ""
            reversed = nameInput[0] == "-"
            nameInput = nameInput[1..-1] if reversed
            dexlist = searchStartingList
            dexlist = dexlist.find_all do |dex_item|
                next false if autoDisqualifyFromSearch(dex_item[:move])
                searchMoveName = dex_item[:data].name
                value = searchMoveName.downcase.include?(nameInput.downcase) ^ reversed # Boolean XOR
                next value
            end
            return dexlist
        end
        return nil
    end

    def searchByMoveType
        while true
            typeInput = pbEnterText(_INTL("Search type..."), 0, 12)
            typeInput.downcase!
            if typeInput && typeInput != ""
                reversed = typeInput[0] == "-"
                typeInput = typeInput[1..-1] if reversed

                # Don't do the search if one of the input type names isn't an actual type
                typeIsReal = false
                GameData::Type.each do |type_data|
                    next unless type_data.name.downcase == typeInput
                    typeIsReal = true 
                    break
                end

                unless typeIsReal
                    pbMessage(_INTL("Invalid input: {1}", type_input_entry))
                    next
                end

                dexlist = searchStartingList
                dexlist = dexlist.find_all do |dex_item|
                    next false if autoDisqualifyFromSearch(dex_item[:move])
                    typeMatches = GameData::Type.get(dex_item[:data].type).name.downcase == typeInput
                    next typeMatches ^ reversed # Boolean XOR
                end
                return dexlist
            end
            return nil
        end
    end

    def searchByMoveCategory
        selections = [_INTL("Physical"),_INTL("Special"),_INTL("Status"),_INTL("Adaptive"),_INTL("Cancel")]
        moveCategorySelection = pbMessage(_INTL("Which category?"), selections, selections.length)
        return if moveCategorySelection == selections.length - 1

        dexlist = searchStartingList
        dexlist = dexlist.find_all do |dex_item|
            next false if autoDisqualifyFromSearch(dex_item[:move])
            moveCategory = dex_item[:data].category
            categoryMatches = moveCategory == moveCategorySelection
            # Show adaptive moves in searches for physical or special
            categoryMatches = true if moveCategory == 3 && [0,1].include?(moveCategorySelection)
            next categoryMatches
        end
        return dexlist
    end

    def searchByMoveDescription
        moveDescriptionInput = pbEnterText(_INTL("Search move desc..."), 0, 20)
        moveDescriptionInput.downcase!

        if moveDescriptionInput && moveDescriptionInput != ""
            reversed = moveDescriptionInput[0] == "-"
            moveDescriptionInput = moveDescriptionInput[1..-1] if reversed

            dexlist = searchStartingList
            dexlist = dexlist.find_all do |dex_item|
                next false if autoDisqualifyFromSearch(dex_item[:move])
                moveDescription = dex_item[:data].description.downcase
                textMatches =  moveDescription.include?(moveDescriptionInput)
                next textMatches ^ reversed # Boolean XOR
            end
            return dexlist
        else
            return nil
        end
    end

    def searchByMoveMisc
    end

    def searchByMoveBasePower
    end

    def searchByMoveAccuracy
    end

    def searchByMovePriority
    end

    def searchByMoveTag
    end

    def searchByMoveTargeting
    end

    def searchByMovePP
    end

    def searchByMoveAvailabilityByLevel
    end

    def searchByMoveTotalAvailability
    end

    def searchByMoveSignature
    end

    def searchByMoveTypeMatchups
    end

    ##################################################
    # SORTS
    ##################################################
    def sortByMoveMisc
    end

    def sortByMoveName
    end

    def sortByMoveType
    end

    def sortByMoveCategory
    end

    def sortByMoveBasePower
    end

    def sortByMoveAccuracy
    end

    def sortByMovePriority
    end

    def sortByMovePP
    end

    def sortByMoveEarliestAvailability
    end

    def sortByMoveTotalAvailability
    end
end