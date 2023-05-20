def inflictFirstAble(statusToInflict)
    return unless GameData::Status::DATA.key?(statusToInflict)

    $Trainer.able_party.each do |partyMember|
        next unless partyMember.status == :NONE

        partyMember.status = statusToInflict

        case statusToInflict
        when :SLEEP
            pbMessage(_INTL("{1} fell asleep!", partyMember.name))
        when :POISON
            pbMessage(_INTL("{1} was poisoned!", partyMember.name))
        when :BURN
            pbMessage(_INTL("{1} was burned!", partyMember.name))
        when :NUMB
            pbMessage(_INTL("{1} is numbed!", partyMember.name))
        when :FROSTBITE
            pbMessage(_INTL("{1} was frostbitten!", partyMember.name))
        when :DIZZY
            pbMessage(_INTL("{1} is dizzy!", partyMember.name))
        when :LEECHED
            pbMessage(_INTL("{1} became leeched!", partyMember.name))
        end

        break
    end
end

def inflictSleep
    inflictFirstAble(:SLEEP)
end

def inflictPoison
    inflictFirstAble(:POISON)
end

def inflictBurn
    inflictFirstAble(:BURN)
end

def inflictFrostbite
    inflictFirstAble(:FROSTBITE)
end

def inflictDizzy
    inflictFirstAble(:DIZZY)
end

def inflictLeeched
    inflictFirstAble(:LEECHED)
end

def cleanseWholeParty
    $Trainer.able_party.each do |partyMember|
        next if partyMember.status == :NONE

        case status
        when :SLEEP			then pbMessage(_INTL("{1} woke up!", partyMember.name))
        when :POISON		then pbMessage(_INTL("{1} was cured of its poisoning.", partyMember.name))
        when :BURN	        then pbMessage(_INTL("{1}'s burn was healed.", partyMember.name))
        when :FROSTBITE     then pbMessage(_INTL("{1}'s frostbite was healed.", partyMember.name))
        when :NUMB 			then pbMessage(_INTL("{1} is no longer numbed.", partyMember.name))
        when :DIZZY			then pbMessage(_INTL("{1} is no longer dizzy!", partyMember.name))
        when :LEECHED       then pbMessage(_INTL("{1} is no longer being leeched!", partyMember.name))
        end

        partyMember.heal_status
    end
end