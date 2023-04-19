require 'socket'
require 'io/wait'

module CableClub
  HOST = "34.125.27.176"
  PORT = 9999
  
  ONLINE_TRAINER_TYPE_LIST = [
    [:POKEMONTRAINER_Red,:POKEMONTRAINER_Leaf],
    [:PSYCHIC_M,:PSYCHIC_F],
    [:BLACKBELT,:CRUSHGIRL],
    [:COOLTRAINER_M,:COOLTRAINER_F]
  ]
end

class Player
  attr_writer :online_trainer_type
  def online_trainer_type
    return @online_trainer_type || self.trainer_type
  end
end

def pbChangeOnlineTrainerType
  if $Trainer.online_trainer_type==$Trainer.trainer_type
    Kernel.pbMessage(_INTL("Hmmm...!\\1"))
    Kernel.pbMessage(_INTL("What is your favorite kind of Trainer?\\nCan you tell me?\\1"))
  else
    trainername=GameData::TrainerType.get($Trainer.online_trainer_type).name
    if ['a','e','i','o','u'].include?(trainername[0,1].downcase)
      msg=_INTL("Hello! You've been mistaken for an {1}, haven't you?\\1",trainername)
    else
      msg=_INTL("Hello! You've been mistaken for a {1}, haven't you?\\1",trainername)
    end
    pbMessage(msg)
    pbMessage(_INTL("But I think you can also pass for a different kind of Trainer.\\1"))
    pbMessage(_INTL("So, how about telling me what kind of Trainer that you like?\\1"))
  end
  commands=[]
  trainer_types=[]
  CableClub::ONLINE_TRAINER_TYPE_LIST.each do |type|
    t=type
    t=type[$Trainer.gender] if type.is_a?(Array)
    commands.push(GameData::TrainerType.get(t).name)
    trainer_types.push(t)
  end
  commands.push(_INTL("Cancel"))
  loop do
    cmd=pbMessage(_INTL("Which kind of Trainer would you like to be?"),commands,-1)
    if cmd>=0 && cmd<commands.length-1
      trainername=commands[cmd]
      if ['a','e','i','o','u'].include?(trainername[0,1].downcase)
        msg=_INTL("An {1} is the kind of Trainer you want to be?",trainername)
      else
        msg=_INTL("A {1} is the kind of Trainer you want to be?",trainername)
      end
      if pbConfirmMessage(msg)
        if ['a','e','i','o','u'].include?(trainername[0,1].downcase)
          msg=_INTL("I see! So an {1} is the kind of Trainer you like.\\1",trainername)
        else
          msg=_INTL("I see! So a {1} is the kind of Trainer you like.\\1",trainername)
        end
        pbMessage(msg)
        pbMessage(_INTL("If that's the case, others may come to see you in the same way.\\1"))
        $Trainer.online_trainer_type=trainer_types[cmd]
        break
      end
    else
      break
    end
  end
  pbMessage(_INTL("OK, then I'll just talk to you later!"))
end

# TODO: Automatically timeout.

# Returns false if an error occurred.
def pbCableClub
  if $Trainer.party_count == 0
    pbMessage(_INTL("I'm sorry, you must have a Pokémon to enter the Cable Club."))
    return
  end
  msgwindow = pbCreateMessageWindow()
  begin
    pbMessageDisplay(msgwindow, _ISPRINTF("What's the ID of the trainer you're searching for? (Your ID: {1:05d})\\^",$Trainer.public_ID($Trainer.id)))
    partner_trainer_id = ""
    loop do
      partner_trainer_id = pbFreeText(msgwindow, partner_trainer_id, false, 5)
      return if partner_trainer_id.empty?
      break if partner_trainer_id =~ /^[0-9]{5}$/
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} is not a trainer ID.", partner_trainer_id))
    end
    CableClub::connect_to(msgwindow, partner_trainer_id)
    raise Connection::Disconnected.new("disconnected")
  rescue Connection::Disconnected => e
    case e.message
    when "disconnected"
      pbMessageDisplay(msgwindow, _INTL("Thank you for using the Cable Club. We hope to see you again soon."))
      return true
    when "invalid party"
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, your party contains Pokémon not allowed in the Cable Club."))
      return false
    when "peer disconnected"
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, the other trainer has disconnected."))
      return true
    else
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server has malfunctioned!"))
      return false
    end
  rescue Errno::ECONNREFUSED
    pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server is down at the moment."))
    return false
  rescue
    pbPrintException($!)
    pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club has malfunctioned!"))
    return false
  ensure
    pbDisposeMessageWindow(msgwindow)
  end
end

module CableClub
  def self.pokemon_order(client_id)
    case client_id
    when 0; [0, 1, 2, 3]
    when 1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.pokemon_target_order(client_id)
    case client_id
    when 0..1; [1, 0, 3, 2]
    else; raise "Unknown client_id: #{client_id}"
    end
  end

  def self.connect_to(msgwindow, partner_trainer_id)
    pbMessageDisplayDots(msgwindow, _INTL("Connecting"), 0)
    host,port = get_server_info
    Connection.open(host,port) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_trainer_type = nil
      partner_party = nil
      frame = 0
      activity = nil
      seed = nil
      battle_type = nil
      chosen = nil
      partner_chosen = nil
      partner_confirm = false

      loop do
        if state != last_state
          last_state = state
          frame = 0
        else
          frame += 1
        end

        Graphics.update
        Input.update
        if Input.press?(Input::BACK)
          message = case state
            when :await_server; _INTL("Abort connection?\\^")
            when :await_partner; _INTL("Abort search?\\^")
            else; _INTL("Disconnect?\\^")
            end
          pbMessageDisplay(msgwindow, message)
          return if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
        end

        case state
        # Waiting to be connected to the server.
        # Note: does nothing without a non-blocking connection.
        when :await_server
          echoln "can_send?"
          if connection.can_send?
            echoln "can_send!"
            connection.send do |writer|
              writer.sym(:find)
              writer.int(partner_trainer_id)
              writer.str($Trainer.name)
              writer.int($Trainer.id)
              writer.sym($Trainer.online_trainer_type)
              write_party(writer)
            end
            state = :await_partner
          else
            pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nConnecting",$Trainer.public_ID($Trainer.id)), frame)
          end

        # Waiting to be connected to the partner.
        when :await_partner
          pbMessageDisplayDots(msgwindow, _ISPRINTF("Your ID: {1:05d}\\nSearching",$Trainer.public_ID($Trainer.id)), frame)
          connection.update do |record|
            case (type = record.sym)
            when :found
              client_id = record.int
              partner_name = record.str
              partner_trainer_type = record.sym
              partner_party = parse_party(record)
              pbMessageDisplay(msgwindow, _INTL("{1} {2} connected!",GameData::TrainerType.get(partner_trainer_type).name, partner_name))
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        # Choosing an activity (leader only).
        when :choose_activity
          pbMessageDisplay(msgwindow, _INTL("Choose an activity.\\^"))
          command = pbShowCommands(msgwindow, [_INTL("Single Battle"), _INTL("Double Battle"), _INTL("Trade")], -1)
          case command
          when 0..1 # Battle
            if command == 1 && $Trainer.party_count < 2
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, you must have at least two Pokémon to engage in a double battle."))
            elsif command == 1 && partner_party.length < 2
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, your partner must have at least two Pokémon to engage in a double battle."))
            else
              connection.send do |writer|
                writer.sym(:battle)
                seed = rand(2**31)
                writer.int(seed)
                battle_type = case command
                  when 0; :single
                  when 1; :double
                  else; raise "Unknown battle type"
                  end
                writer.sym(battle_type)
              end
              activity = :battle
              state = :await_accept_activity
            end

            when 2 # Trade
              connection.send do |writer|
                writer.sym(:trade)
              end
              activity = :trade
              state = :await_accept_activity

            else # Cancel
              # TODO: Confirmation box?
              return
            end

        # Waiting for the partner to accept our activity (leader only).
        when :await_accept_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to accept", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :ok
              case activity
              when :battle
                partner = NPCTrainer.new(partner_name, partner_trainer_type)
                (partner.partyID=0) rescue nil # EBDX compat
                do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                state = :choose_activity

              when :trade
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_confirm
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :choose_activity
                end

              else
                raise "Unknown activity: #{activity}"
              end

            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to #{activity.to_s}.", partner_name))
              state = :choose_activity

            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select an activity (follower only).
        when :await_choose_activity
          pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick an activity", partner_name), frame)
          connection.update do |record|
            case (type = record.sym)
            when :battle
              seed = record.int
              battle_type = record.sym
              partner = NPCTrainer.new(partner_name, partner_trainer_type)
              (partner.partyID=0) rescue nil # EBDX compat
              # Auto-reject double battles that we cannot participate in.
              if battle_type == :double && $Trainer.party_count < 2
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              else
                pbMessageDisplay(msgwindow, _INTL("{1} wants to battle!\\^", partner_name))
                if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                  connection.send do |writer|
                    writer.sym(:ok)
                  end
                  do_battle(connection, client_id, seed, battle_type, partner, partner_party)
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  state = :await_choose_activity
                end
              end

            when :trade
              pbMessageDisplay(msgwindow, _INTL("{1} wants to trade!\\^", partner_name))
              if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                connection.send do |writer|
                  writer.sym(:ok)
                end
                chosen = choose_pokemon
                if chosen >= 0
                  connection.send do |writer|
                    writer.sym(:ok)
                    writer.int(chosen)
                  end
                  state = :await_trade_confirm
                else
                  connection.send do |writer|
                    writer.sym(:cancel)
                  end
                  connection.discard(1)
                  state = :await_choose_activity
                end
              else
                connection.send do |writer|
                  writer.sym(:cancel)
                end
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end

        # Waiting for the partner to select a Pokémon to trade.
        when :await_trade_pokemon
          if partner_confirm
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to resynchronize", partner_name), frame)
          else
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner = NPCTrainer.new(partner_name, $Trainer.trainer_type)
              pbHealAll
              partner_party.each{|pkmn| pkmn.heal}
              pkmn = partner_party[partner_chosen]
              partner_party[partner_chosen] = $Trainer.party[chosen]
              do_trade(chosen, partner, pkmn)
              connection.send do |writer|
                writer.sym(:update)
                write_pkmn(writer, $Trainer.party[chosen])
              end
              partner_confirm = true

            when :update
              partner_party[partner_chosen] = parse_pkmn(record)
              partner_chosen = nil
              partner_confirm = false
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", partner_name))
              partner_chosen = nil
              partner_confirm = false
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end
        
        when :await_trade_confirm
          if partner_chosen.nil?
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to pick a Pokémon", partner_name), frame)
          else
            pbMessageDisplayDots(msgwindow, _INTL("Waiting for {1} to confirm the trade", partner_name), frame)
          end

          connection.update do |record|
            case (type = record.sym)
            when :ok
              partner_chosen = record.int
              pbHealAll
              partner_party.each {|pkmn| pkmn.heal}
              partner_pkmn = partner_party[partner_chosen]
              your_pkmn = $Trainer.party[chosen]
              abort=$Trainer.able_pokemon_count==1 && your_pkmn==$Trainer.able_party[0] && partner_pkmn.egg?
              able_party=partner_party.find_all { |p| p && !p.egg? && !p.fainted? }
              abort|=able_party.length==1 && partner_pkmn==able_party[0] && your_pkmn.egg?
              unless abort
                partner_speciesname = (partner_pkmn.egg?) ? _INTL("Egg") : partner_pkmn.speciesName
                your_speciesname = (your_pkmn.egg?) ? _INTL("Egg") : your_pkmn.speciesName
                loop do
                  pbMessageDisplay(msgwindow, _INTL("{1} has offered {2} ({3}) for your {4} ({5}).\\^",partner_name,
                      partner_pkmn.name,partner_speciesname,your_pkmn.name,your_speciesname))
                  command = pbShowCommands(msgwindow, [_INTL("Check {1}'s offer",partner_name), _INTL("Check My Offer"), _INTL("Accept/Deny Trade")], -1)
                  case command
                  when 0
                    check_pokemon(partner_pkmn)
                  when 1
                    check_pokemon(your_pkmn)
                  when 2
                    pbMessageDisplay(msgwindow, _INTL("Confirm the trade of {1} ({2}) for your {3} ({4}).\\^",partner_pkmn.name,partner_speciesname,
                        your_pkmn.name,your_speciesname))
                    if pbShowCommands(msgwindow, [_INTL("Yes"), _INTL("No")], 2) == 0
                      connection.send do |writer|
                        writer.sym(:ok)
                      end
                      state = :await_trade_pokemon
                      break
                    else
                      connection.send do |writer|
                        writer.sym(:cancel)
                      end
                      partner_chosen = nil
                      connection.discard(1)
                      if client_id == 0
                        state = :choose_activity
                      else
                        state = :await_choose_activity
                      end
                      break
                    end
                  end
                end
              else
                pbMessageDisplay(msgwindow, _INTL("The trade was unable to be completed."))
                partner_chosen = nil
                if client_id == 0
                  state = :choose_activity
                else
                  state = :await_choose_activity
                end
              end
              
            when :cancel
              pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} doesn't want to trade after all.", partner_name))
              partner_chosen = nil
              if client_id == 0
                state = :choose_activity
              else
                state = :await_choose_activity
              end

            else
              raise "Unknown message: #{type}"
            end
          end
        else
          raise "Unknown state: #{state}"
        end
      end
    connection.dispose
    end
  end

  def self.pbMessageDisplayDots(msgwindow, message, frame)
    pbMessageDisplay(msgwindow, message + "...".slice(0..(frame/8) % 3) + "\\^", false)
  end

  def self.do_battle(connection, client_id, seed, battle_type, partner, partner_party)
    pbHealAll # Avoids having to transmit damaged state.
    partner_party.each{|pkmn| pkmn.heal} # back to back battles desync without it.
    scene = pbNewBattleScene
    battle = PokeBattle_CableClub.new(connection, client_id, scene, partner_party, partner)
    battle.endSpeeches = [""]
    battle.items = []
    battle.internalBattle = false
    case battle_type
    when :single
      setBattleRule("single")
    when :double
      setBattleRule("double")
    else
      raise "Unknown battle type: #{battle_type}"
    end
    trainerbgm = pbGetTrainerBattleBGM(partner)
    Events.onStartBattle.trigger(nil, nil)
    # XXX: Hope both battles take place in the same area for things like Nature Power.
    pbPrepareBattle(battle)
    $PokemonTemp.clearBattleRules
    exc = nil
    pbBattleAnimation(trainerbgm, (battle.singleBattle?) ? 1 : 3, [partner]) {
      pbSceneStandby {
        # XXX: Hope we call rand in the same order in both clients...
        srand(seed)
        begin
          battle.pbStartBattle
        rescue Connection::Disconnected
          scene.pbEndBattle(0)
          exc = $!
        end
      }
    }
    raise exc if exc
  end

  def self.do_trade(index, you, your_pkmn)
    my_pkmn = $Trainer.party[index]
    $Trainer.pokedex.register(your_pkmn)
    $Trainer.pokedex.set_owned(your_pkmn.species)
    pbFadeOutInWithMusic(99999) {
      scene = PokemonTrade_Scene.new
      scene.pbStartScreen(my_pkmn, your_pkmn, $Trainer.name, you.name)
      scene.pbTrade
      scene.pbEndScreen
    }
    $Trainer.party[index] = your_pkmn
  end

  def self.choose_pokemon
    chosen = -1
    pbFadeOutIn(99999) {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $Trainer.party)
      screen.pbStartScene(_INTL("Choose a Pokémon."), false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    }
    return chosen
  end
  
  def self.check_pokemon(pkmn)
    pbFadeOutIn(99999) {
      scene = PokemonSummary_Scene.new
      screen = PokemonSummaryScreen.new(scene)
      screen.pbStartScreen([pkmn],0)
    }
  end

  def self.write_party(writer)
    writer.int($Trainer.party_count)
    $Trainer.party.each do |pkmn|
      write_pkmn(writer, pkmn)
    end
  end

  def self.write_pkmn(writer, pkmn)
    writer.sym(pkmn.species)
    writer.int(pkmn.level)
    writer.int(pkmn.personalID)
    writer.int(pkmn.owner.id)
    writer.str(pkmn.owner.name)
    writer.int(pkmn.owner.gender)
    writer.int(pkmn.exp)
    writer.int(pkmn.form)
    writer.nil_or(:sym, pkmn.item_id)
    writer.int(pkmn.numMoves)
    pkmn.moves.each do |move|
      writer.sym(move.id)
      writer.int(move.ppup)
    end
    writer.int(pkmn.first_moves.length)
    pkmn.first_moves.each do |move|
      writer.sym(move)
    end
    writer.int(pkmn.gender)
    writer.nil_or(:bool,pkmn.shiny?)
    writer.nil_or(:sym, pkmn.ability_id)
    writer.nil_or(:int, pkmn.ability_index)
    writer.nil_or(:sym, pkmn.nature_id)
    writer.nil_or(:sym, pkmn.nature_for_stats_id)
    GameData::Stat.each_main do |s|
      writer.int(pkmn.iv[s.id])
      writer.nil_or(:bool, pkmn.ivMaxed[s.id])
      writer.int(pkmn.ev[s.id])
    end
    writer.int(pkmn.happiness)
    writer.str(pkmn.name)
    writer.sym(pkmn.poke_ball)
    writer.int(pkmn.steps_to_hatch)
    writer.int(pkmn.obtain_method)
    writer.int(pkmn.obtain_map)
    writer.nil_or(:str,pkmn.obtain_text)
    writer.int(pkmn.obtain_level)
    writer.int(pkmn.hatched_map)
    writer.int(pkmn.cool)
    writer.int(pkmn.beauty)
    writer.int(pkmn.cute)
    writer.int(pkmn.smart)
    writer.int(pkmn.tough)
    writer.int(pkmn.sheen)
    writer.int(pkmn.numRibbons)
    pkmn.ribbons.each do |ribbon|
      writer.sym(ribbon)
    end
    writer.bool(!!pkmn.mail)
    if pkmn.mail
      writer.sym(pkmn.mail.item)
      writer.str(pkmn.mail.message)
      writer.str(pkmn.mail.sender)
      if pkmn.mail.poke1
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke1[0])
        writer.int(pkmn.mail.poke1[1])
        writer.bool(pkmn.mail.poke1[2])
        writer.int(pkmn.mail.poke1[3])
        writer.bool(pkmn.mail.poke1[4])
        writer.bool(pkmn.mail.poke1[5])
      else
        writer.nil_or(:sym,nil)
      end
      if pkmn.mail.poke2
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke2[0])
        writer.int(pkmn.mail.poke2[1])
        writer.bool(pkmn.mail.poke2[2])
        writer.int(pkmn.mail.poke2[3])
        writer.bool(pkmn.mail.poke2[4])
        writer.bool(pkmn.mail.poke2[5])
      else
        writer.nil_or(:sym,nil)
      end
      if pkmn.mail.poke3
        #[species,gender,shininess,form,shadowness,is egg]
        writer.sym(pkmn.mail.poke3[0])
        writer.int(pkmn.mail.poke3[1])
        writer.bool(pkmn.mail.poke3[2])
        writer.int(pkmn.mail.poke3[3])
        writer.bool(pkmn.mail.poke3[4])
        writer.bool(pkmn.mail.poke3[5])
      else
        writer.nil_or(:sym,nil)
      end
    end
    writer.bool(!!pkmn.fused)
    if pkmn.fused
      write_pkmn(writer, pkmn.fused)
    end
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      writer.str(pkmn.superHue.to_s)
      writer.nil_or(:bool,pkmn.superVariant)
    end
  end

  def self.parse_party(record)
    party = []
    record.int.times do
      party << parse_pkmn(record)
    end
    return party
  end

  def self.parse_pkmn(record)
    species = record.sym
    level = record.int
    pkmn = Pokemon.new(species, level, $Trainer)
    pkmn.personalID = record.int
    pkmn.owner.id = record.int
    pkmn.owner.name = record.str
    pkmn.owner.gender = record.int
    pkmn.exp = record.int
    form = record.int
    #pkmn.forced_form = form if MultipleForms.hasFunction?(pkmn.species,"getForm")
    pkmn.form_simple = form
    pkmn.item = record.sym
    pkmn.forget_all_moves
    for i in 0...record.int
      pkmn.moves[i] = Pokemon::Move.new(record.sym)
      pkmn.moves[i].ppup = record.int
    end
    pkmn.moves.compact!
    pkmn.clear_first_moves
    for i in 0...record.int
      pkmn.add_first_move(record.sym)
    end
    pkmn.gender = record.int
    pkmn.shiny = record.nil_or(:bool)
    pkmn.ability = record.nil_or(:sym)
    pkmn.ability_index = record.nil_or(:int)
    pkmn.nature = record.sym
    pkmn.nature_for_stats = record.nil_or(:sym)
    GameData::Stat.each_main do |s|
      pkmn.iv[s.id] = record.int
      pkmn.ivMaxed[s.id] = record.nil_or(:bool)
      pkmn.ev[s.id] = record.int
    end
    pkmn.happiness = record.int
    pkmn.name = record.str
    pkmn.poke_ball = record.sym
    pkmn.steps_to_hatch = record.int
    pkmn.obtain_method = record.int
    pkmn.obtain_map = record.int
    pkmn.obtain_text = record.nil_or(:str)
    pkmn.obtain_level = record.int
    pkmn.hatched_map = record.int
    pkmn.cool = record.int
    pkmn.beauty = record.int
    pkmn.cute = record.int
    pkmn.smart = record.int
    pkmn.tough = record.int
    pkmn.sheen = record.int
    for i in 0...record.int
      pkmn.giveRibbon(record.sym)
    end
    if record.bool() # mail
      m_item = record.sym()
      m_msg = record.str()
      m_sender = record.str()
      m_poke1 = []
      if m_species1 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke1[0] = m_species1
        m_poke1[1] = record.int()
        m_poke1[2] = record.bool()
        m_poke1[3] = record.int()
        m_poke1[4] = record.bool()
        m_poke1[5] = record.bool()
      else
        m_poke1 = nil
      end
      m_poke2 = []
      if m_species2 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke2[0] = m_species2
        m_poke2[1] = record.int()
        m_poke2[2] = record.bool()
        m_poke2[3] = record.int()
        m_poke2[4] = record.bool()
        m_poke2[5] = record.bool()
      else
        m_poke2 = nil
      end
      m_poke3 = []
      if m_species3 = record.nil_or(:sym)
        #[species,gender,shininess,form,shadowness,is egg]
        m_poke3[0] = m_species3
        m_poke3[1] = record.int()
        m_poke3[2] = record.bool()
        m_poke3[3] = record.int()
        m_poke3[4] = record.bool()
        m_poke3[5] = record.bool()
      else
        m_poke3 = nil
      end
      pkmn.mail = Mail.new(m_item,m_msg,m_sender,m_poke1,m_poke2,m_poke3)
    end
    if record.bool() # fused
      pkmn.fused = parse_pkmn(record)
    end
    if defined?(EliteBattle) # EBDX compat
      # this looks so dumb I know, but the variable can be nil, false, or an int.
      superhue = record.str
      if superhue == ""
        pkmn.superHue = nil
      elsif superhue=="false"
        pkmn.superHue = false
      else
        pkmn.superHue = superhue.to_i
      end
      pkmn.superVariant = record.nil_or(:bool)
    end
    pkmn.calc_stats
    return pkmn
  end
  
  def self.get_server_info
    ret = [HOST,PORT]
    if safeExists?("serverinfo.ini")
      File.foreach("serverinfo.ini") do |line|
        case line
        when /^\s*[Hh][Oo][Ss][Tt]\s*=\s*(.+)$/
          ret[0]=$1 if !nil_or_empty?($1)
        when /^\s*[Pp][Oo][Rr][Tt]\s*=\s*(\d{1,5})$/
          if !nil_or_empty?($1)
            port = $1.to_i
            ret[1]= port if port>0 && port<=65535
          end
        end
      end
    end
    return ret
  end
end

class PokeBattle_Battle
  attr_reader :client_id
end

class PokeBattle_CableClub < PokeBattle_Battle
  attr_reader :connection
  def initialize(connection, client_id, scene, opponent_party, opponent)
    @connection = connection
    @client_id = client_id
    player = NPCTrainer.new($Trainer.name, $Trainer.trainer_type)
    super(scene, $Trainer.party, opponent_party, [player], [opponent])
    @battleAI  = PokeBattle_CableClub_AI.new(self)
  end
  
  # Added optional args to not make v18 break.
  def pbSwitchInBetween(index, lax=false, cancancel=false)
    if pbOwnedByPlayer?(index)
      choice = super(index, lax, cancancel)
      # bug fix for the unknown type :switch. cause: going into the pokemon menu then backing out and attacking, which sends the switch symbol regardless.
      if !cancancel # forced switches do not allow canceling, and both sides would expect a response.
        @connection.send do |writer|
          writer.sym(:switch)
          writer.int(choice)
        end
      end
      return choice
    else
      frame = 0
      @scene.pbShowWindow(PokeBattle_Scene::MESSAGE_BOX)
      cw = @scene.sprites["messageWindow"]
      cw.letterbyletter = false
      begin
        loop do
          frame += 1
          cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
          @scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::BACK) && pbConfirmMessageSerious("Would you like to disconnect?")
          @connection.update do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} forfeited the match!", @opponent[0].full_name))
              @decision = 1
              pbAbort

            when :switch
              return record.int

            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = false
      end
    end
  end

  def pbRun(idxPokemon, duringBattle=false)
    ret = super(idxPokemon, duringBattle)
    if ret == 1
      @connection.send do |writer|
        writer.sym(:forfeit)
      end
      @connection.discard(1)
    end
    return ret
  end

  # Rearrange the battlers into a consistent order, do the function, then restore the order.
  def pbCalculatePriority(*args)
    begin
      battlers = @battlers.dup
      order = CableClub::pokemon_order(@client_id)
      for i in 0..3
        @battlers[i] = battlers[order[i]]
      end
      return super(*args)
    ensure
      @battlers = battlers
    end
  end
  
  def pbCanShowCommands?(idxBattler)
    last_index = pbGetOpposingIndicesInOrder(0).reverse.last
    return true if last_index==idxBattler
    return super(idxBattler)
  end
  
  # avoid unnecessary checks and check in same order
  def pbEORSwitch(favorDraws=false)
    return if @decision>0 && !favorDraws
    return if @decision==5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      # check in same order
      battlers = []
      order = CableClub::pokemon_order(@client_id)
      for i in 0..3
        battlers[i] = @battlers[order[i]]
      end
      battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        else
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
        end
      end
      break if switched.length==0
      pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switched.include?(b.index)
      end
    end
  end
end

class PokeBattle_CableClub_AI < PokeBattle_AI
  def pbDefaultChooseEnemyCommand(index)
    # Hurray for default methods. have to reverse it to show the expected order.
    our_indices = @battle.pbGetOpposingIndicesInOrder(1).reverse
    their_indices = @battle.pbGetOpposingIndicesInOrder(0).reverse
    # Sends our choices after they have all been locked in.
    if index == their_indices.last
      # TODO: patch this up to be index agnostic.
      # Would work fine if restricted to single/double battles
      target_order = CableClub::pokemon_target_order(@battle.client_id)
      for our_index in our_indices
        @battle.connection.send do |writer|
          pkmn = @battle.battlers[our_index]
          writer.sym(:choice)
          # choice picked was changed to be a symbol now.
          writer.sym(@battle.choices[our_index][0])
          writer.int(@battle.choices[our_index][1])
          move = @battle.choices[our_index][2] && pkmn.moves.index(@battle.choices[our_index][2])
          writer.nil_or(:int, move)
          # -1 invokes the RNG, out of order (somehow?!) which causes desync.
          # But this is a single battle, so the only possible choice is the foe.
          if @battle.singleBattle? && @battle.choices[our_index][3] == -1
            @battle.choices[our_index][3] = their_indices[0]
          end
          # Target from their POV.
          our_target = @battle.choices[our_index][3]
          their_target = target_order[our_target] rescue our_target
          writer.int(their_target)
          mega=@battle.megaEvolution[0][0]
          mega^=1 if mega>=0
          writer.int(mega) # mega fix?
        end
      end
      frame = 0
      @battle.scene.pbShowWindow(PokeBattle_Scene::MESSAGE_BOX)
      cw = @battle.scene.sprites["messageWindow"]
      cw.letterbyletter = false
      begin
        loop do
          frame += 1
          cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
          @battle.scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::BACK) && pbConfirmMessageSerious("Would you like to disconnect?")
          @battle.connection.update do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              @battle.pbDisplay(_INTL("{1} forfeited the match!", @battle.opponent[0].fullname))
              @battle.decision = 1
              @battle.pbAbort

            when :choice
              their_index = their_indices.shift
              partner_pkmn = @battle.battlers[their_index]
              @battle.choices[their_index][0] = record.sym
              @battle.choices[their_index][1] = record.int
              move = record.nil_or(:int)
              @battle.choices[their_index][2] = move && partner_pkmn.moves[move]
              @battle.choices[their_index][3] = record.int
              @battle.megaEvolution[1][0] = record.int # mega fix?
              return if their_indices.empty?

            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = true
      end
    end
  end

  def pbDefaultChooseNewEnemy(index, party)
    raise "Expected this to be unused."
  end
end

class Connection
  class Disconnected < Exception; end
  class ProtocolError < StandardError; end

  def self.open(host, port)
    # XXX: Non-blocking connect.
    begin
      socket = TCPSocket.open(host, port)
      connection = Connection.new(socket)
      yield connection
    end
  end

  def initialize(socket)
    @socket = socket
    @recv_parser = Parser.new
    @recv_records = []
    @discard_records = 0
  end

  def update
    if @socket.nread>0
      recvd = @socket.recv(4096)
      raise Disconnected.new("server disconnected") if recvd.empty?
      @recv_parser.parse(recvd) {|record| @recv_records << record}
    end
    # Process at most one record so that any control flow in the block doesn't cause us to lose records.
    if !@recv_records.empty?
      record = @recv_records.shift
      if record.disconnect?
        reason = record.str() rescue "unknown error"
        raise Disconnected.new(reason)
      end
      if @discard_records == 0
        begin
          yield record
        rescue
          raise # compat
        else
          raise ProtocolError.new("Unconsumed input: #{record}") if !record.empty?
        end
      else
        @discard_records -= 1
      end
    end
  end

  def can_send?
    return !IO.select(nil, [@socket],nil).nil?
  end

  def send
    # XXX: Non-blocking send.
    # but note we don't update often so we need some sort of drained?
    # for the send buffer so that we can delay starting the battle.
    writer = RecordWriter.new
    yield writer
    @socket.write_nonblock(writer.line!)
  end

  def discard(n)
    raise "Cannot discard #{n} messages." if n < 0
    @discard_records += n
  end
  
  def dispose
    @socket.close
    @parser = nil
  end
end

class Parser
  def initialize
    @buffer = ""
  end

  def parse(data)
    return if data.empty?
    lines = data.split("\n", -1)
    lines[0].insert(0, @buffer)
    @buffer = lines.pop
    lines.each do |line|
      yield RecordParser.new(line) if !line.empty?
    end
  end
end

class RecordParser
  def initialize(data)
    @fields = []
    field = ""
    escape = false
    # each_char and chars don't exist.
    for i in (0...data.length)
      char = data[i].chr
      if char == "," && !escape
        @fields << field
        field = ""
      elsif char == "\\" && !escape
        escape = true
      else
        field += char
        escape = false
      end
    end
    @fields << field
    @fields.reverse!
  end

  def empty?; return @fields.empty? end

  def disconnect?
    if @fields.last == "disconnect"
      @fields.pop
      return true
    else
      return false
    end
  end

  def nil_or(t)
    raise Connection::ProtocolError.new("Expected nil or #{t}, got EOL") if @fields.empty?
    if @fields.last.empty?
      @fields.pop
      return nil
    else
      return self.send(t)
    end
  end

  def bool
    raise Connection::ProtocolError.new("Expected bool, got EOL") if @fields.empty?
    field = @fields.pop
    if field == "true"
      return true
    elsif field == "false"
      return false
    else
      raise Connection::ProtocolError.new("Expected bool, got #{field}")
    end
  end

  def int
    raise Connection::ProtocolError.new("Expected int, got EOL") if @fields.empty?
    field = @fields.pop
    begin
      return Integer(field)
    rescue
      raise Connection::ProtocolError.new("Expected int, got #{field}")
    end
  end

  def str
    raise Connection::ProtocolError.new("Expected str, got EOL") if @fields.empty?
    @fields.pop
  end

  def sym
    raise Connection::ProtocolError.new("Expected sym, got EOL") if @fields.empty?
    @fields.pop.to_sym
  end

  def to_s; @fields.reverse.join(", ") end
end

class RecordWriter
  def initialize
    @fields = []
  end

  def line!
    line = @fields.map {|field| escape!(field)}.join(",")
    line += "\n"
    @fields = []
    return line
  end

  def escape!(s)
    t=s.clone(freeze: false)
    t.gsub!("\\", "\\\\")
    t.gsub!(",", "\,")
    return t
  end

  def nil_or(t, o)
    if o.nil?
      @fields << ""
    else
      self.send(t, o)
    end
  end

  def bool(b); @fields << b.to_s end
  def int(i); @fields << i.to_s end
  def str(s) @fields << s end
  def sym(s); @fields << s.to_s end
end