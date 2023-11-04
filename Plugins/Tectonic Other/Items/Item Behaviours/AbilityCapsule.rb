ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc { |item,pkmn,scene|
    unless pkmn.canSwitchAbility?
      pbSceneDefaultDisplay(_INTL("It won't have any effect."),scene)
      next
    end
    newabilindex = (pkmn.ability_index + 1) % 2
    abil1,abil2 = pkmn.getPossibleAbilities
    newabil = GameData::Ability.get((newabilindex==0) ? abil1 : abil2)
    newabilname = newabil.name
    if pbSceneDefaultConfirm(_INTL("Would you like to change {1}'s Ability to {2}?", pkmn.name,newabilname),scene)
      pkmn.ability_index = newabilindex
      scene&.pbRefresh
      pbSceneDefaultDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname),scene)
      pkmn.calc_stats
      next true
    end
    next false
  })
  
  ItemHandlers::UseOnPokemon.copy(:ABILITYCAPSULE,:VIRALHELIX)