def candyMachine(candyAmount,level)
    if candyAmount == 0
        pbMessage(_INTL("A candy machine. It's out of candy."))
    else
        unless isTempSwitchOn?("A")
            if candyAmount == 1
                pbMessage(_INTL("A candy machine. It has one batch of candy."))
            else
                pbMessage(_INTL("A candy machine. It contains #{candyAmount} batches of candy."))
            end
        end
        cost = candyBatchCost(level)
        if $Trainer.money < cost
            pbMessage(_INTL("A batch costs ${1}. You can't afford to pay that much!",cost.to_s_formatted))
        else
            if pbConfirmMessage(_INTL("Buy some candy for ${1}?",cost.to_s_formatted))
                setTempSwitchOn("A")
                $Trainer.money = $Trainer.money - cost
                pbMessage(_INTL("You put in $#{cost}."))

                # Modify the candy machine
                case candyAmount
                when 3
                    setMySwitch("A")
                when 2
                    setMySwitch("B")
                when 1
                    setMySwitch("C")
                end

                # Give the candy
                itemsGiven = candiesForLevel(level)
                for i in 0...itemsGiven.length/2
                    pbReceiveItem(itemsGiven[i*2],itemsGiven[i*2 + 1])
                end
            end
        end
    end
end

def candyBatchCost(level)
    case level
    when 0..15
        return 250
    when 16..20
        return 450
    when 21..25
        return 750
    when 26..30
        return 1150
    when 31..35
        return 1500
    when 36..40
        return 2150
    when 41..45
        return 2750
    when 46..50
        return 3500
    when 51..55
        return 4000
    when 56..60
        return 4750
    when 61..65
        return 5250
    when 65..70
        return 6500
    when 71..100
        return 10_000
    else
        pbMessage(_INTL("Unassigned level passed to candyBatchCost: #{level}")) if $DEBUG
	    return 250
    end
end