extends Node2D

var game_board

var number_of_moves


# Called when the node enters the scene tree for the first time.
func _ready():
	game_board = get_parent()


# Called to clear the board and then start a new game
func _on_new_game_pressed():
	game_board.reset_board()
	game_board.start_game()


# Called to undo the last move
func _on_undo_pressed():
	game_board.undo()


func add_move():
	number_of_moves += 1
	$MoveCounter.text = "Moves: " + str(number_of_moves)


func remove_move():
	number_of_moves -= 1
	$MoveCounter.text = "Moves: " + str(number_of_moves)


func reset_moves():
	number_of_moves = 0
	$MoveCounter.text = "Moves: 0"
