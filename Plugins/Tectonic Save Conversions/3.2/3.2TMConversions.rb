TM_CONVERSION_HASH = {
    :TM25 => :TMPROTECT,
    :TM126 => :TMENDURE,
    :TM120 => :TMSUBSTITUTE,
    :TM14 => :TMNUMB,
    :TM130 => :TMENCORE,
    :TM137 => :TMTAUNT,
    :TM136 => :TMBAR,
    :TM26 => :TMSCARYFACE,
    :TM16 => :TMSCREECH,
    :TM94 => :TMCHARM,
    :TM93 => :TMEERIEIMPULSE,
    :TM91 => :TMPARTINGSHOT,
    :TM112 => :TMAGILITY,
    :TM146 => :TMIRONDEFENSE,
    :TM117 => :TMAMNESIA,
    :TM144 => :TMCOSMICPOWER,
    :TM185 => :TMWORKUP,
    :TM148 => :TMBULKUP,
    :TM149 => :TMCALMMIND,
    :TM100 => :TMFLOWSTATE,
    :TM168 => :TMVANGUARD,
    :TM114 => :TMAIMTRUE,
    :TM69 => :TMHONECLAWS,
    :TM106 => :TMHONESIGHT,
    :TM113 => :TMFOCUSENERGY,
    :TM62 => :TMHEARTSWAP,
    :TM138 => :TMTRICK,
    :TM21 => :TMREST,
    :TM127 => :TMSLEEPTALK,
    :TM176 => :TMSTEALTHROCK,
    :TM123 => :TMSPIKES,
    :TM154 => :TMPOISONSPIKES,
    :TM151 => :TMFLAMESPIKES,
    :TM134 => :TMFROSTSPIKES,
    :TM18 => :TMREFLECT,
    :TM17 => :TMLIGHTSCREEN,
    :TM19 => :TMSAFEGUARD,
    :TM10 => :TMGREYMIST,
    :TM72 => :TMPUZZLEROOM,
    :TM145 => :TMODDROOM,
    :TM70 => :TMPOLARIZEDROOM,
    :TM103 => :TMTAILWIND,
    :TM34 => :TMSUNSHINE,
    :TM33 => :TMRAINSTORM,
    :TM32 => :TMSANDSTORM,
    :TM35 => :TMHAIL,
    :TM196 => :TMMOONGLOW,
    :TM197 => :TMECLIPSE,
    :TM12 => :TMFOLLOWME,
    :TM183 => :TMALLYSWITCH,
    :TM129 => :TMBATONPASS,
    :TM23 => :TMMEMENTO,
    :TM20 => :TMSELFDESTRUCT,
    :TM22 => :TMEXPLOSION,
    :TM85 => :TMFINALGAMBIT,
    :TM46 => :TMWEATHERBURST,
    :TM01 => :TMCOVET,
    :TM119 => :TMTRIATTACK,
    :TM03 => :TMCHAOSWHEEL,
    :TM24 => :TMSNORE,
    :TM27 => :TMRAPIDSPIN,
    :TM101 => :TMBODYSLAM,
    :TM159 => :TMNULLPULSE,
    :TM49 => :TMMEGAPUNCH,
    :TM142 => :TMHYPERVOICE,
    :TM141 => :TMINFERNOIMPACT,
    :TM102 => :TMFLAMETHROWER,
    :TM198 => :TMLIQUIDATION,
    :TM96 => :TMBUBBLEBLASTER,
    :TM150 => :TMLEAFBLADE,
    :TM28 => :TMENERGYBALL,
    :TM186 => :TMELECTROSLASH,
    :TM108 => :TMTHUNDERBOLT,
    :TM51 => :TMGLACIALRAM,
    :TM105 => :TMICEBEAM,
    :TM43 => :TMBRICKBREAK,
    :TM156 => :TMAURASPHERE,
    :TM157 => :TMPOISONJAB,
    :TM178 => :TMMIASMA,
    :TM187 => :TMTRAMPLE,
    :TM167 => :TMEARTHPOWER,
    :TM48 => :TMSTRAFE,
    :TM95 => :TMCOLDFRONT,
    :TM169 => :TMSEERSTRIKE,
    :TM111 => :TMPSYCHIC,
    :TM160 => :TMXSCISSOR,
    :TM161 => :TMBUGBUZZ,
    :TM175 => :TMADAMANTINEPRESS,
    :TM163 => :TMPOWERGEM,
    :TM54 => :TMWAILINGBLOW,
    :TM133 => :TMSHADOWBALL,
    :TM147 => :TMREND,
    :TM162 => :TMDRAGONPULSE,
    :TM132 => :TMCRUNCH,
    :TM158 => :TMDARKALLURE,
    :TM174 => :TMBULLETTRAIN,
    :TM170 => :TMFLASHCANNON,
    :TM190 => :TMPLAYROUGH,
    :TM192 => :TMMOONBLAST,
    :TM07 => :TMCRUELTY,
    :TM77 => :TMHEX,
    :TM199 => :TMBODYPRESS,
    :TM193 => :TMWARDPRESS,
    :TM181 => :TMFOULPLAY,
    :TM87 => :TMTRICKYTOXINS,
    :TM88 => :TMVOLTSWITCH,
    :TM89 => :TMUTURN,
    :TM90 => :TMFLIPTURN,
    :TM08 => :TMHYPERBEAM,
    :TM09 => :TMGIGAIMPACT,
    :TM04 => :TMFRENZYPLANT,
    :TM05 => :TMBLASTBURN,
    :TM06 => :TMHYDROCANNON,
    :TM11 => :TMROCKWRECKER,
    :TM13 => :TMMETEORASSAULT,

    # Indirect
    :TM02 => :TMDEFOG,
    :TM40 => :TMFAKETEARS,

}

TM_CUT_LIST = [
    :TM164,
    :TM02,
    :TM40,
    :TM135,
    :TM84,
    :TM00,
]

SaveData.register_conversion(:misc_fixes_v2) do
    game_version '3.2.0'
    display_title 'Swapping TMs over to their new ID representation'
    to_all do |save_data|
        echoln("")
        TM_CONVERSION_HASH.each do |key,value|
            echoln("Switching #{key} for #{value}: #{save_data[:bag].pbQuantity(key)}")
            save_data[:bag].pbChangeItem(key,value)
        end

        TM_CUT_LIST.each do |entry|
            echoln("Removing #{entry}: #{save_data[:bag].pbQuantity(entry)}")
            save_data[:bag].pbDeleteItem(entry,9999999)
        end
    end
end
  
def fixTMs
    mapData = Compiler::MapData.new
    for id in mapData.mapinfos.keys.sort
        map = mapData.getMap(id)
        next if !map || !mapData.mapinfos[id]
        mapName = mapData.mapinfos[id].name
        changed = false
        for key in map.events.keys
            event = map.events[key]
            event.pages.each do |page|
                page.list.each do |eventCommand|
                    eventCommand.parameters.map! { |parameter|
                        next parameter unless parameter.is_a?(String)

                        mappedParam = nil
                        TM_CONVERSION_HASH.each do |oldTMID, newTMID|
                            [" ",",",")"].each do |nextchar|
                                regex = "\(:#{oldTMID.to_s}#{nextchar}"
                                newText = "\(:#{newTMID.to_s}#{nextchar}"

                                oldParam = parameter.clone
                                newParam = parameter.gsub!(regex,newText)
                                if newParam
                                    eventName = event.name.gsub(",","")

                                    echoln "Map #{mapName} (#{id}), event #{eventName} (#{event.id}):\r\n"
                                    echoln("\tParameter #{oldParam} changed to #{newParam}")

                                    changed = true
                                    
                                    mappedParam = newParam
                                    break
                                end
                            end
                            break if mappedParam
                        end

                        next mappedParam.nil? ? parameter : mappedParam
                    }
                end
            end
        end
        mapData.saveMap(id) if changed
    end

    TM_CUT_LIST.each do |entry|
        writeAllCodeInstances(entry.to_s,"Analysis/tm_location_#{entry.to_s}.txt")
    end
end

def giveOldTMs
    GameData::Item.each do |itemData|
        next unless itemData.is_TM?
        next unless itemData.cut
        pbSilentItem(itemData.id)
    end
end