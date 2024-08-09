
SaveData.register_conversion(:global_switch_refactor_2_4_0) do
  game_version '2.4.0'
  display_title 'Setting global switches based on self-switches.'
  to_all do |save_data|
    globalSwitches = save_data[:switches]
    globalVariables = save_data[:variables]
    selfSwitches = save_data[:self_switches]
    itemBag = save_data[:bag]

    globalSwitches[112] = selfSwitches[[57,11,'B']] # Growlithe rescued
    echoln("Growlithe rescued: #{globalSwitches[112]}")

    globalSwitches[113] = selfSwitches[[10,4,'A']] # Raikou defeated
    globalSwitches[114] = selfSwitches[[10,6,'B']] # Raikou guards gone
    globalSwitches[115] = selfSwitches[[125,1,'A']] # Entei defeated
    globalSwitches[116] = selfSwitches[[125,6,'C']] # Entei guards gone
    globalSwitches[117] = selfSwitches[[124,1,'A']] # Suicune defeated
    globalSwitches[118] = selfSwitches[[124,6,'B']] # Suicune guards gone

    for i in 1..3 do
      echoln("Beast #{i} defeated / guards dismissed: #{globalSwitches[111 + i * 2]} / #{globalSwitches[112 + i * 2]}")
    end

    # Add a Rainbow Feather for each of the defeated legendary beasts
    itemBag.pbStoreItem(:RAINBOWFEATHER, 1, false) if globalSwitches[113]
    itemBag.pbStoreItem(:RAINBOWFEATHER, 1, false) if globalSwitches[115]
    itemBag.pbStoreItem(:RAINBOWFEATHER, 1, false) if globalSwitches[117]
    echoln("#{itemBag.pbQuantity(:RAINBOWFEATHER)} rainbow feathers earned")

    # Avatar chambers
    globalSwitches[126] = selfSwitches[[42,2,'A']] # Chamber 1 defeated
    globalSwitches[127] = selfSwitches[[84,6,'A']] # Chamber 2 defeated
    globalSwitches[128] = selfSwitches[[24,4,'A']] # Chamber 3 defeated
    globalSwitches[129] = selfSwitches[[106,3,'A']] # Chamber 4 defeated
    globalSwitches[130] = selfSwitches[[176,3,'A']] # Chamber 5 defeated
    globalSwitches[131] = selfSwitches[[199,2,'A']] # Chamber 6 defeated
    globalSwitches[132] = selfSwitches[[291,2,'A']] # Chamber 7 defeated
    globalSwitches[133] = selfSwitches[[303,5,'A']] # Chamber 8 defeated

    globalSwitches[134] = selfSwitches[[44,3,'A']] # Chamber 1 quested
    globalSwitches[135] = selfSwitches[[62,17,'A']] # Chamber 2 quested
    globalSwitches[136] = selfSwitches[[21,4,'A']] # Chamber 3 quested
    globalSwitches[137] = selfSwitches[[104,5,'A']] # Chamber 4 quested
    globalSwitches[138] = selfSwitches[[175,4,'A']] # Chamber 5 quested
    globalSwitches[139] = selfSwitches[[195,15,'B']] # Chamber 6 quested
    globalSwitches[140] = selfSwitches[[279,2,'A']] # Chamber 7 quested
    globalSwitches[141] = selfSwitches[[300,1,'A']] # Chamber 8 quested

    # Debug info
    for i in 1..8 do
      echoln("Chamber #{i} quested/defeated: #{globalSwitches[133 + i]} / #{globalSwitches[125 + i]}")
    end

    # NPC questlines
    # Imogene
    globalVariables[IMOGENE_STAGE_VAR] = 0
    globalVariables[IMOGENE_STAGE_VAR] += 1 if selfSwitches[[136,43,'A']] # Imogene 1 completed
    globalVariables[IMOGENE_STAGE_VAR] += 1 if selfSwitches[[117,6,'C']] # Imogene 2 completed
    globalVariables[IMOGENE_STAGE_VAR] += 1 if selfSwitches[[155,47,'B']] # Imogene 3 completed
    globalVariables[IMOGENE_STAGE_VAR] += 1 if selfSwitches[[25,20,'B']] # Imogene 4 completed
    globalVariables[IMOGENE_STAGE_VAR] += 1 if selfSwitches[[326,17,'B']] # Imogene 5 completed

    # Alessa
    globalVariables[ALESSA_STAGE_VAR] = 0
    globalVariables[ALESSA_STAGE_VAR] += 1 if selfSwitches[[56,56,'C']] # Alessa 1 completed
    globalVariables[ALESSA_STAGE_VAR] += 1 if selfSwitches[[122,23,'D']] # Alessa 2 completed
    globalVariables[ALESSA_STAGE_VAR] += 1 if selfSwitches[[187,84,'D']] # Alessa 3 completed
    globalVariables[ALESSA_STAGE_VAR] += 1 if selfSwitches[[193,21,'D']] # Alessa 4 completed
    globalVariables[ALESSA_STAGE_VAR] += 1 if selfSwitches[[120,22,'D']] # Alessa 5 completed

    # Skylar
    globalVariables[SKYLER_STAGE_VAR] = 0
    globalVariables[SKYLER_STAGE_VAR] += 1 if selfSwitches[[3,40,'B']] # Skyler 1 completed
    globalVariables[SKYLER_STAGE_VAR] += 1 if selfSwitches[[8,27,'C']] # Skyler 2 completed
    globalVariables[SKYLER_STAGE_VAR] += 1 if selfSwitches[[255,4,'B']] # Skyler 3 completed
    globalVariables[SKYLER_STAGE_VAR] += 1 if selfSwitches[[214,39,'B']] # Skyler 4 completed
    globalVariables[SKYLER_STAGE_VAR] += 1 if selfSwitches[[121,29,'D']] # Skyler 5 completed

    # Keoni
    globalVariables[KEONI_STAGE_VAR] = 0
    globalVariables[KEONI_STAGE_VAR] += 1 if selfSwitches[[81,20,'C']] # Keoni 1 completed
    globalVariables[KEONI_STAGE_VAR] += 1 if selfSwitches[[185,22,'D']] # Keoni 2 completed
    globalVariables[KEONI_STAGE_VAR] += 1 if selfSwitches[[222,4,'B']] # Keoni 3 completed
    globalVariables[KEONI_STAGE_VAR] += 1 if selfSwitches[[123,26,'B']] # Keoni 4 completed
    globalVariables[KEONI_STAGE_VAR] += 1 if selfSwitches[[213,20,'B']] # Keoni 5 completed

    # Eifion
    globalVariables[EIFION_STAGE_VAR] = 0
    globalVariables[EIFION_STAGE_VAR] += 1 if selfSwitches[[40,5,'B']] # Eifion 1 completed
    globalVariables[EIFION_STAGE_VAR] += 1 if selfSwitches[[11,22,'D']] # Eifion 2 completed
    globalVariables[EIFION_STAGE_VAR] += 1 if selfSwitches[[216,16,'C']] # Eifion 3 completed
    globalVariables[EIFION_STAGE_VAR] += 1 if selfSwitches[[328,4,'B']] # Eifion 4 completed
    globalVariables[EIFION_STAGE_VAR] += 1 if selfSwitches[[218,54,'D']] # Eifion 5 completed

    # Candy
    globalVariables[CANDY_STAGE_VAR] = 0
    globalVariables[CANDY_STAGE_VAR] += 1 if selfSwitches[[129,13,'B']] # Candy 1 completed
    globalVariables[CANDY_STAGE_VAR] += 1 if selfSwitches[[123,19,'B']] # Candy 2 completed
    globalVariables[CANDY_STAGE_VAR] += 1 if selfSwitches[[155,48,'B']] # Candy 3 completed
    globalVariables[CANDY_STAGE_VAR] += 1 if selfSwitches[[257,18,'B']] # Candy 4 completed
    globalVariables[CANDY_STAGE_VAR] += 1 if selfSwitches[[185,41,'C']] ||
                                              selfSwitches[[185,42,'B']] # Candy 5 completed
    
    globalSwitches[66] = false # "Met Eifion" scrubbed
    globalSwitches[67] = false # "Met Alessa" scrubbed

    # Debug info
    for i in 1..6 do
      name = ["Imogene","Alessa","Skyler","Keoni","Eifion","Candy"][i-1]
      echoln("#{name} questline stage: #{globalVariables[50 + i]}")
    end
  end
end
