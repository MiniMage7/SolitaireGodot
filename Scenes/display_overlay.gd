extends Node2D

var game_board


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
