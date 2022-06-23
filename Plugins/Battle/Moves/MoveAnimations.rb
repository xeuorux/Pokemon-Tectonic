class PokeBattle_Scene
  # Returns the animation ID to use for a given move. If the move has no
  # animations, tries to use a default move animation depending on the move's
  # type. If that default move animation doesn't exist, trues to use Tackle's
  # move animation. Returns nil if it can't find any of these animations to use.
  def pbFindMoveAnimation(moveID, idxUser, hitNum)
    begin
      move2anim = pbLoadMoveToAnim
      # Find actual animation requested (an opponent using the animation first
      # looks for an OppMove version then a Move version)
      anim = pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
      return anim if anim
      # Actual animation not found, get the default animation for the move's type
      moveData = GameData::Move.get(moveID)
      target_data = GameData::Target.get(moveData.target)
      moveType = moveData.type
      moveKind = moveData.category
      moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
      moveKind += 3 if moveKind == 2 && target_data.num_targets > 0
      # [one target physical, one target special, user status,
      #  multiple targets physical, multiple targets special, non-user status]
      typeDefaultAnim = {
        :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,     :SWIFT,          :TAILWHIP],
        :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,            nil,             nil],
        :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,            :AIRCUTTER,      :FEATHERDANCE],
        :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,            :ACID,           :POISONPOWDER],
        :GROUND   => [:SANDTOMB,     :MUDSLAP,      :SHOREUP,     :EARTHQUAKE,    :EARTHPOWER,     :MUDSPORT],
        :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,     :ANCIENTPOWER,   :SANDSTORM],
        :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,            :STRUGGLEBUG,    :STRINGSHOT],
        :GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,            nil,             :CONFUSERAY],
        :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,            nil,             :METALSOUND],
        :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,            :INCINERATE,     :WILLOWISP],
        :WATER    => [:CRABHAMMER,   :WATERPULSE,   :AQUARING,    nil,            :SURF,           :WATERSPORT],
        :GRASS    => [:VINEWHIP,     :ENERGYBALL,   :COTTONGUARD, :RAZORLEAF,     nil,             :SPORE],
        :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,            :DISCHARGE,      :THUNDERWAVE],
        :PSYCHIC  => [:PSYCHOCUT,    :CONFUSION,    :CALMMIND,    nil,            :SYNCHRONOISE,   :MIRACLEEYE],
        :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,            :POWDERSNOW,     :HAIL],
        :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, :BREAKINGSWIPE, :TWISTER,        nil],
        :DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   :BRUTALSWING,   :SNARL,          :EMBARGO],
        :FAIRY    => [:PLAYROUGH,    :FAIRYWIND,    :POUT,        nil,            :DAZZLINGGLEAM,  :SWEETKISS]
      }
      if typeDefaultAnim[moveType]
        anims = typeDefaultAnim[moveType]
		#The the most correct possible animation
        if GameData::Move.exists?(anims[moveKind])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
        end
		#If the move is multitarget, but no such animation exists, try for the single target version
        if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
        end
		# If not even the single target version exists, try the "user status" animatio
        if !anim && GameData::Move.exists?(anims[2])
          anim = pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
        end
		# If not even the "user status" exists, fall back on the normal type
		if !anim
			anim = pbFindMoveAnimDetails(move2anim,typeDefaultAnim[:NORMAL][moveKind],idxUser)
		end
      end
      return anim if anim
	  
      # Default animation for the move's type not found, use Tackle's animation
      if moveData.category != 2 && GameData::Move.exists?(:TACKLE)
        return pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
      end
    rescue
    end
    return nil
  end
  
  #=============================================================================
  # Plays a move/common animation
  #=============================================================================
  # Plays a move animation.
  def pbAnimation(moveID,user,targets,hitNum=0)
    animID = pbFindMoveAnimation(moveID,user.index,hitNum)
    return if !animID
    anim = animID[0]
    target = (targets && targets.is_a?(Array)) ? targets[0] : targets
    animations = pbLoadBattleAnimations
    return if !animations
	speedMult = 1
    pbSaveShadows {
      if animID[1]   # On opposing side and using OppMove animation
        pbAnimationCore(animations[anim],target,user,true,speedMult)
      else           # On player's side, and/or using Move animation
        pbAnimationCore(animations[anim],user,target,false,speedMult)
      end
    }
  end
  
  def pbAnimationCore(animation,user,target,oppMove=false,speedMult=1)
    return if !animation
    @briefMessage = false
    userSprite   = (user) ? @sprites["pokemon_#{user.index}"] : nil
    targetSprite = (target) ? @sprites["pokemon_#{target.index}"] : nil
    # Remember the original positions of Pokémon sprites
    oldUserX = (userSprite) ? userSprite.x : 0
    oldUserY = (userSprite) ? userSprite.y : 0
    oldTargetX = (targetSprite) ? targetSprite.x : oldUserX
    oldTargetY = (targetSprite) ? targetSprite.y : oldUserY
    # Create the animation player
    animPlayer = PBAnimationPlayerX.new(animation,user,target,self,oppMove,false,speedMult)
    # Apply a transformation to the animation based on where the user and target
    # actually are. Get the centres of each sprite.
    userHeight = (userSprite && userSprite.bitmap && !userSprite.bitmap.disposed?) ? userSprite.bitmap.height : 128
    if targetSprite
      targetHeight = (targetSprite.bitmap && !targetSprite.bitmap.disposed?) ? targetSprite.bitmap.height : 128
    else
      targetHeight = userHeight
    end
    animPlayer.setLineTransform(
       PokeBattle_SceneConstants::FOCUSUSER_X,PokeBattle_SceneConstants::FOCUSUSER_Y,
       PokeBattle_SceneConstants::FOCUSTARGET_X,PokeBattle_SceneConstants::FOCUSTARGET_Y,
       oldUserX,oldUserY-userHeight/2,
       oldTargetX,oldTargetY-targetHeight/2)
    # Play the animation
    animPlayer.start
    loop do
      animPlayer.update
      pbUpdate
      break if animPlayer.animDone?
    end
    animPlayer.dispose
    # Return Pokémon sprites to their original positions
    if userSprite
      userSprite.x = oldUserX
      userSprite.y = oldUserY
      userSprite.pbSetOrigin
    end
    if targetSprite
      targetSprite.x = oldTargetX
      targetSprite.y = oldTargetY
      targetSprite.pbSetOrigin
    end
  end
end


class PBAnimationPlayerX
  def initialize(animation,user,target,scene=nil,oppMove=false,inEditor=false,speedMult=1)
    @animation     = animation
    @user          = (oppMove) ? target : user   # Just used for playing user's cry
    @usersprite    = (user) ? scene.sprites["pokemon_#{user.index}"] : nil
    @targetsprite  = (target) ? scene.sprites["pokemon_#{target.index}"] : nil
    @userbitmap    = (@usersprite && @usersprite.bitmap) ? @usersprite.bitmap : nil # not to be disposed
    @targetbitmap  = (@targetsprite && @targetsprite.bitmap) ? @targetsprite.bitmap : nil # not to be disposed
    @scene         = scene
    @viewport      = (scene) ? scene.viewport : nil
    @inEditor      = inEditor
    @looping       = false
    @animbitmap    = nil   # Animation sheet graphic
    @frame         = -1
    @framesPerTick = [Graphics.frame_rate/(20*speedMult),1].max   # 20 ticks per second
    @srcLine       = nil
    @dstLine       = nil
    @userOrig      = getSpriteCenter(@usersprite)
	# Now assumes the target is in the direct center of the screen if one isn't given
	# So that cells which focus on the target will be centered rather than at the top left
    @targetOrig    = @targetsprite ? getSpriteCenter(@targetsprite) : [@viewport.rect.width/2,@viewport.rect.height - 160]
    @oldbg         = []
    @oldfo         = []
    initializeSprites
  end
end
