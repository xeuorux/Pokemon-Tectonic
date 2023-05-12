module Compiler
	module_function

  #=============================================================================
  # Save individual trainer data to PBS file
  #=============================================================================
  def write_avatars
    File.open("PBS/avatars.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Avatar.each do |avatar|
        pbSetWindowText(_INTL("Writing avatar {1}...", avatar.id_number))
        Graphics.update if avatar.id_number % 20 == 0
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", avatar.id))
        f.write(sprintf("Ability = %s\r\n", avatar.abilities.join(",")))
        f.write(sprintf("Moves1 = %s\r\n", avatar.moves1.join(",")))
        f.write(sprintf("Moves2 = %s\r\n", avatar.moves2.join(","))) if !avatar.moves2.nil? && avatar.num_phases >= 2
        f.write(sprintf("Moves3 = %s\r\n", avatar.moves3.join(","))) if !avatar.moves3.nil? && avatar.num_phases >= 3
        f.write(sprintf("Moves4 = %s\r\n", avatar.moves4.join(","))) if !avatar.moves4.nil? && avatar.num_phases >= 4
        f.write(sprintf("Moves5 = %s\r\n", avatar.moves5.join(","))) if !avatar.moves5.nil? && avatar.num_phases >= 5
        f.write(sprintf("Turns = %s\r\n", avatar.num_turns)) if avatar.num_turns != DEFAULT_BOSS_TURNS
        f.write(sprintf("HPMult = %s\r\n", avatar.hp_mult)) if avatar.hp_mult != DEFAULT_BOSS_HP_MULT
        f.write(sprintf("HealthBars = %s\r\n", avatar.num_health_bars)) if avatar.num_health_bars != avatar.num_phases
        f.write(sprintf("Item = %s\r\n", avatar.item)) if !avatar.item.nil?
        f.write(sprintf("DMGMult = %s\r\n", avatar.dmg_mult)) if avatar.dmg_mult != DEFAULT_BOSS_DAMAGE_MULT
        f.write(sprintf("DMGResist = %s\r\n", avatar.dmg_resist)) if avatar.dmg_resist != 0.0
        f.write(sprintf("Form = %s\r\n", avatar.form)) if avatar.form != 0
        f.write(sprintf("Aggression = %s\r\n", avatar.aggression)) if avatar.aggression != PokeBattle_AI_Boss::DEFAULT_BOSS_AGGRESSION
      end
    }
    pbSetWindowText(nil)
    Graphics.update
  end
end