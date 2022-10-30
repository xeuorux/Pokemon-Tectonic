class Hash
	def add(key,value)
		self[key] = value
	end
end

class PokeBattle_AI_Boss
	# Always or never use a move (if possible)
	# Arrays of moves
	@@requiredMoves = []
	@@rejectedMoves = []

	# Determining if a move should be used based on unique conditions
	# Arrays of condition procs, that can evaluate multiple moves
	@@useMovesIFF = []
	@@rejectMovesIf = []
	@@requireMovesIf = []

	# Determining if a move should be used based on unique conditions
	# Hashes, where the key is a move ID and the value is a condition proc
	# which evaluates when to use that move
	@@useMoveIFF = {}
	@@rejectMoveIf = {}
	@@requireMoveIf = {}

	# Basic restriction on move use by round timing
	# Arrays of move ids
	@@firstTurnOnly = []
	@@lastTurnOnly = []
	@@nonFirstTurnOnly = []
	@@fallback = []

	# What happens when the move is actually decided upon
	# A hash, where the key is move ID and the value is the proc to call
	# after that move is decided upon
	@@decidedOnMove = {}
	
	# An array of moves that, when chosen, prevent any other moves from being used this turn
	# Also implicitly means that they can only be chosen on the first turn of a round
	@@wholeRound = []

	# Moves that have an IFF proc condition, and also show a telegraphing warning
	# to the player when the AI decides to use them
	# A hash, where the key is a move ID and the value is a hash describing this set of special behaviour
		# The inner hash must have a :condition entry whose value is a proc which is called to determine
		# when the move should be used
		# The inner hash must also have a :warning entry whose value is a proc which must return the string
		# of the warning that is to be shown to the player
	# A move given here implicitly means it can only be chosen on the first turn of a round
	@@warnedIFFMove = {} 

	# An array of procs
	# All of the procs are called when the turn starts
	@@beginTurn = []
end