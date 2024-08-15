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
        miscSearches = []
        cmdTag          = -1
        cmdBasePower	= -1
        cmdAccuracy     = -1
        cmdPriority     = -1
        cmdPP           = -1
        cmdTargeting    = -1
        cmdSignature    = -1
        cmdNotes        = -1
        cmdInvertList   = -1
        cmdEffectChance = -1
        miscSearches[cmdTag = miscSearches.length]          = _INTL("Tag")
        miscSearches[cmdBasePower = miscSearches.length]    = _INTL("Base Power")
        miscSearches[cmdAccuracy = miscSearches.length]     = _INTL("Accuracy")
        miscSearches[cmdEffectChance = miscSearches.length] = _INTL("Effect Chance")
        miscSearches[cmdPriority = miscSearches.length]     = _INTL("Priority")
        miscSearches[cmdPP = miscSearches.length]           = _INTL("Power Points")
        #miscSearches[cmdTargeting = miscSearches.length]    = _INTL("Targeting")
        miscSearches[cmdSignature = miscSearches.length]    = _INTL("Signature")
        miscSearches[cmdNotes = miscSearches.length]        = _INTL("Has Notes")
        miscSearches[cmdInvertList = miscSearches.length]   = _INTL("Invert Current")
        miscSearches.push(_INTL("Cancel"))
        searchSelection = pbMessage(_INTL("Which search?"), miscSearches, miscSearches.length + 1)
        if cmdTag > -1 && searchSelection == cmdTag
            return searchByMoveTag
        elsif cmdBasePower > -1 && searchSelection == cmdBasePower
            return searchByMoveBasePower
        elsif cmdAccuracy > -1 && searchSelection == cmdAccuracy
            return searchByMoveAccuracy
        elsif cmdEffectChance > -1 && searchSelection == cmdEffectChance
            return searchByMoveEffectChance
        elsif cmdPriority > -1 && searchSelection == cmdPriority
            return searchByMovePriority
        elsif cmdPP > -1 && searchSelection == cmdPP
            return searchByMovePP
        elsif cmdTargeting > -1 && searchSelection == cmdTargeting
            return searchByMoveTargeting
        elsif cmdSignature > -1 && searchSelection == cmdSignature
            return searchByMoveSignature
        elsif cmdNotes > -1 && searchSelection == cmdNotes
            return searchByMoveHasNotes
        elsif cmdInvertList > -1 && searchSelection == cmdInvertList
            return invertSearchList
        end
    end

    def searchByMoveTag
        selections = GameData::Move.moveTags.values
        selections.push(_INTL("None"))
        selections.push(_INTL("Cancel"))
        moveTagIndex = pbMessage(_INTL("Which tag?"), selections, selections.length)
        return if moveTagIndex == selections.length - 1

        if moveTagIndex == selections.length - 2
            moveTag = GameData::Move.moveTags.keys[moveTagIndex]

            dexlist = searchStartingList
            dexlist = dexlist.find_all do |dex_item|
                next false if autoDisqualifyFromSearch(dex_item[:move])
                next dex_item[:data].tagLabel.nil?
            end
        else
            moveTag = GameData::Move.moveTags.keys[moveTagIndex]

            dexlist = searchStartingList
            dexlist = dexlist.find_all do |dex_item|
                next false if autoDisqualifyFromSearch(dex_item[:move])
                next dex_item[:data].flags.include?(moveTag)
            end
        end
        return dexlist
    end
    
    def searchByStatComparison(&block)
        comparisonSelection = pbMessage(_INTL("Which comparison?"), [_INTL("Equal to"),_INTL("Greater than"), _INTL("Less than"),_INTL("Cancel"),], 4)
        return if comparisonSelection == 3

        valueInput = pbEnterText(_INTL("Enter value."), 0, 3)
        if valueInput && valueInput != ""
            reversed = valueInput[0] == "-"
            valueInput = valueInput[1..-1] if reversed
            valueIntAttempt = nil
            begin
                valueIntAttempt = Integer(valueInput)
            rescue
                return nil
            end
            
            dexlist = searchStartingList
            dexlist = dexlist.find_all do |dex_item|
                next false if autoDisqualifyFromSearch(dex_item[:move])
                value = block.call(dex_item[:data])
                case comparisonSelection
                when 0
                    next (value == valueIntAttempt) ^ reversed
                when 1
                    next (value > valueIntAttempt) ^ reversed
                when 2
                    next (value < valueIntAttempt) ^ reversed
                end

                next false
            end
        end
    end

    def searchByMoveBasePower
        searchByStatComparison { |moveData|
            moveData.base_damage
        }
    end

    def searchByMoveAccuracy
        searchByStatComparison { |moveData|
            accuracy = moveData.accuracy
            accuracy = 100 if accuracy <= 0
            next accuracy
        }
    end

    def searchByMoveEffectChance
        searchByStatComparison { |moveData|
            moveData.effect_chance
        }
    end

    def searchByMovePriority
        searchByStatComparison { |moveData|
            moveData.priority
        }
    end

    def searchByMovePP
        searchByStatComparison { |moveData|
            moveData.total_pp
        }
    end

    def searchByMoveTargeting
    end

    def searchByMoveAvailabilityByLevel
    end

    def searchByMoveTotalAvailability
    end

    def searchByMoveSignature
        selection = pbMessage(_INTL("Which search?"), [_INTL("Signature"), _INTL("Not Signature"), _INTL("Cancel")], 3)
        if selection != 2
            dexlist = searchStartingList

            dexlist = dexlist.find_all do |dex_item|
                if selection == 1
                    next !dex_item[:data].is_signature?
                else
                    next dex_item[:data].is_signature?
                end
            end
            return dexlist
        end
        return nil
    end

    def searchByMoveHasNotes
        dexlist = searchStartingList

        dexlist = dexlist.find_all do |dex_item|
            moveDetails = []
            PokeBattle_Move.from_pokemon_move(nil, Pokemon::Move.new(dex_item[:move])).getDetailsForMoveDex(moveDetails)
            next !moveDetails.empty?
        end
        return dexlist
    end

    def searchByMoveTypeMatchups
    end

    def invertSearchList
        dexlist = generateMoveList
        dexlist = dexlist.find_all do |dex_item|
            next false if autoDisqualifyFromSearch(dex_item[:move])
            next !@dexlist.any? { |current_item| current_item[:move] == dex_item[:move] }
        end
        return dexlist
    end

    ##################################################
    # SORTS
    ##################################################
    def sortByMoveMisc
        miscSorts = []
        cmdName                     = -1
        cmdType                     = -1
        cmdCategory                 = -1
        cmdBasePower                = -1
        cmdAccuracy                 = -1
        cmdEffectChance             = -1
        cmdPriority                 = -1
        cmdPP                       = -1
        miscSorts[cmdName = miscSorts.length]                     = _INTL("Name")
        miscSorts[cmdType = miscSorts.length]                     = _INTL("Type")
        miscSorts[cmdCategory = miscSorts.length]                 = _INTL("Category")
        miscSorts[cmdBasePower = miscSorts.length]                = _INTL("Base Power")
        miscSorts[cmdAccuracy = miscSorts.length]                 = _INTL("Accuracy")
        miscSorts[cmdEffectChance = miscSorts.length]             = _INTL("Effect Chance")
        miscSorts[cmdPriority = miscSorts.length]                 = _INTL("Priority")
        miscSorts[cmdPP = miscSorts.length]                       = _INTL("Power Points")
        miscSorts.push(_INTL("Cancel"))
        searchSelection = pbMessage(_INTL("Which sort"), miscSorts, miscSorts.length)
        return if searchSelection == miscSorts.length - 1
        @moveList.sort_by! do |dex_item|
            if cmdName > -1 && searchSelection == cmdName
                next dex_item[:data].name
            elsif cmdType > -1 && searchSelection == cmdType
                next GameData::Type.get(dex_item[:data].type).id_number
            elsif cmdCategory > -1 && searchSelection == cmdCategory
                next dex_item[:data].category
            elsif cmdBasePower > -1 && searchSelection == cmdBasePower
                next -dex_item[:data].base_damage
            elsif cmdAccuracy > -1 && searchSelection == cmdAccuracy
                accuracy = dex_item[:data].accuracy
                accuracy = 101 if accuracy <= 0
                next -accuracy
            elsif cmdPriority > -1 && searchSelection == cmdPriority
                next -dex_item[:data].priority
            elsif cmdPP > -1 && searchSelection == cmdPP
                next -dex_item[:data].total_pp
            elsif cmdEffectChance > -1 && searchSelection && cmdEffectChance
                next -dex_item[:data].effect_chance
            end
        end
    end
end