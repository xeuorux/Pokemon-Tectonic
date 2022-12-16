class Pokemon
    # @param move_id [Symbol, String, Integer] ID of the move to check
    # @return [Boolean] whether the Pokémon is compatible with the given move
  def compatible_with_move?(move_id)
    move_data = GameData::Move.try_get(move_id)
    return false if move_data.nil?
    return learnable_moves.include?(move_data.id)
  end
end