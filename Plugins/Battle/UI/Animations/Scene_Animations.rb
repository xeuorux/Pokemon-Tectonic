class PokeBattle_Scene
    def pbDamageAnimation(battler,effectiveness=0)
        return if @battle.autoTesting
        @briefMessage = false
        # Damage animation
        damageAnim = BattlerDamageAnimation.new(@sprites,@viewport,battler.index,effectiveness,battler)
        loop do
          damageAnim.update
          pbUpdate
          break if damageAnim.animDone?
        end
        damageAnim.dispose
    end

    #=============================================================================
    # Animates a party lineup appearing for the given side
    #=============================================================================
    def pbShowPartyLineup(side,fullAnim=false)
        @animations.push(LineupAppearAnimation.new(@sprites,@viewport,
        side,@battle.pbParty(side),getDisplayBallCount(side),@battle.pbPartyStarts(side),fullAnim))
        if !fullAnim
        while inPartyAnimation?; pbUpdate; end
        end
    end

  #=============================================================================
  # Animates a trainer's sprite and party lineup hiding (if they are visible).
  # Animates a Pokémon being sent out into battle, then plays the shiny
  # animation for it if relevant.
  # sendOuts is an array; each element is itself an array: [idxBattler,pkmn]
  #=============================================================================
  def pbSendOutBattlers(sendOuts,startBattle=false)
    return if sendOuts.length==0
    # If party balls are still appearing, wait for them to finish showing up, as
    # the FadeAnimation will make them disappear.
    while inPartyAnimation?; pbUpdate; end
    @briefMessage = false
    # Make all trainers and party lineups disappear (player-side trainers may
    # animate throwing a Poké Ball)
    if @battle.opposes?(sendOuts[0][0])
      fadeAnim = TrainerFadeAnimation.new(@sprites,@viewport,getDisplayBallCount(1), startBattle)
    else
      fadeAnim = PlayerFadeAnimation.new(@sprites,@viewport,startBattle)
    end
    # For each battler being sent out, set the battler's sprite and create two
    # animations (the Poké Ball moving and battler appearing from it, and its
    # data box appearing)
    sendOutAnims = []
    sendOuts.each_with_index do |b,i|
      pkmn = @battle.battlers[b[0]].disguisedAs || b[1]
      pbChangePokemon(b[0],pkmn)
      pbRefresh
      if @battle.opposes?(b[0])
        sendOutAnim = PokeballTrainerSendOutAnimation.new(@sprites,@viewport,
           @battle.pbGetOwnerIndexFromBattlerIndex(b[0])+1,
           @battle.battlers[b[0]],startBattle,i)
      else
        sendOutAnim = PokeballPlayerSendOutAnimation.new(@sprites,@viewport,
           @battle.pbGetOwnerIndexFromBattlerIndex(b[0])+1,
           @battle.battlers[b[0]],startBattle,i)
      end
      dataBoxAnim = DataBoxAppearAnimation.new(@sprites,@viewport,b[0])
      sendOutAnims.push([sendOutAnim,dataBoxAnim,false])
    end
    # Play all animations
    loop do
      fadeAnim.update
      sendOutAnims.each do |a|
        next if a[2]
        a[0].update
        a[1].update if a[0].animDone?
        a[2] = true if a[1].animDone?
      end
      pbUpdate
      if !inPartyAnimation?
        break if !sendOutAnims.any? { |a| !a[2] }
      end
    end
    fadeAnim.dispose
    sendOutAnims.each { |a| a[0].dispose; a[1].dispose }
    # Play shininess animations for shiny Pokémon
    sendOuts.each do |b|
      next if !@battle.showAnims || !@battle.battlers[b[0]].shiny?
      pbCommonAnimation("Shiny",@battle.battlers[b[0]])
    end
  end

    # Animates battlers flashing and data boxes' HP bars because of damage taken
    # by an attack. targets is an array, which are all animated simultaneously.
    # Each element in targets is also an array: [battler, old HP, effectiveness]
    def pbHitAndHPLossAnimation(targets,fastHitAnimation=false)
        @briefMessage = false
        # Set up animations
        damageAnims = []
        targets.each do |t|
            anim = BattlerDamageAnimation.new(@sprites,@viewport,t[0].index,t[2],t[0],fastHitAnimation)
            damageAnims.push(anim)
            @sprites["dataBox_#{t[0].index}"].animateHP(t[1],t[0].hp,t[0].totalhp,fastHitAnimation)
        end
        # Update loop
        loop do
        damageAnims.each { |a| a.update }
        pbUpdate
        allDone = true
        targets.each do |t|
            next if !@sprites["dataBox_#{t[0].index}"].animatingHP
            allDone = false
            break
        end
        next if !allDone
        damageAnims.each do |a|
            next if a.animDone?
            allDone = false
            break
        end
        next if !allDone
        break
        end
        damageAnims.each { |a| a.dispose }
    end

  #=============================================================================
  # Ability splash bar animations
  #=============================================================================
  def pbShowAbilitySplash(battler,fakeName=nil)
    return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    side = battler.index%2
    pbHideAbilitySplash(battler) if @sprites["abilityBar_#{side}"].visible
    @sprites["abilityBar_#{side}"].battler = battler
    @sprites["abilityBar_#{side}"].fakeName = fakeName
    abilitySplashAnim = AbilitySplashAppearAnimation.new(@sprites,@viewport,side)
    loop do
      abilitySplashAnim.update
      pbUpdate
      break if abilitySplashAnim.animDone?
    end
    abilitySplashAnim.dispose
  end
end