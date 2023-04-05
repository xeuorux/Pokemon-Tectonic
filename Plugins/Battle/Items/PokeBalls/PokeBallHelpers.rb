$BallTypes = {
  0  => :POKEBALL,
  1  => :GREATBALL,
  2  => :SAFARIBALL,
  3  => :ULTRABALL,
  4  => :MASTERBALL,
  5  => :NETBALL,
  6  => :DIVEBALL,
  7  => :NESTBALL,
  8  => :REPEATBALL,
  9  => :TIMERBALL,
  10 => :LUXURYBALL,
  11 => :PREMIERBALL,
  12 => :DUSKBALL,
  13 => :HEALBALL,
  14 => :QUICKBALL,
  15 => :CHERISHBALL,
  16 => :FASTBALL,
  17 => :LEVELBALL,
  18 => :LUREBALL,
  19 => :HEAVYBALL,
  20 => :LOVEBALL,
  21 => :FRIENDBALL,
  22 => :MOONBALL,
  23 => :SPORTBALL,
  24 => :DREAMBALL,
  25 => :BEASTBALL,
  26 => :BALLLAUNCHER,
  27 => :SLICEBALL,
  28 => :ROYALBALL,
  29 => :LEECHBALL,
  30 => :POTIONBALL,
  31 => :DISABLEBALL,
}

def pbBallTypeToItem(ball_type)
    ret = GameData::Item.try_get($BallTypes[ball_type])
    return ret if ret
    ret = GameData::Item.try_get($BallTypes[0])
    return ret if ret
    return GameData::Item.get(:POKEBALL)
end

def pbGetBallType(ball)
    ball = GameData::Item.try_get(ball)
    $BallTypes.keys.each do |key|
        return key if ball == $BallTypes[key]
    end
    return 0
end
