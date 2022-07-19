PokEstate::GrantAwards.add(:GEN1AWARD1,
    proc { |pokedex|
        next generationReward(1,10,:POKEBALL)
    }
)

PokEstate::GrantAwards.add(:GEN1AWARD2, 
    proc { |pokedex|
        next generationReward(1,25,:POKEBALL)
    }
)

PokEstate::GrantAwards.add(:GEN1AWARD3, 
    proc { |pokedex|
        next generationReward(1,40,:GREATBALL)
    }
)

PokEstate::GrantAwards.add(:GEN1AWARD4, 
    proc { |pokedex|
        next generationReward(1,70,:GREATBALL)
    }
)

PokEstate::GrantAwards.add(:GEN1AWARD5, 
    proc { |pokedex|
        next generationReward(1,100,:ULTRABALL)
    }
)