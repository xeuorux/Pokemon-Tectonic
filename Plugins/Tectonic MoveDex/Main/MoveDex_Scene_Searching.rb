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
                next false if autoDisqualifyFromSearch(dex_item[:id])
                searchMoveName = dex_item[:data].name
                value = searchMoveName.downcase.include?(nameInput.downcase) ^ reversed # Boolean XOR
                next value
            end
            return dexlist
        end
        return nil
    end

    def searchByMoveType
    end

    def searchByMoveCategory
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

    def searchByMoveDescription
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