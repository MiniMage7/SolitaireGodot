extends Node2D

@export var card_scene: PackedScene

var moves
var card_is_being_dragged = false

class Move:
	var card
	var first_position
	var second_position
	var card_was_flipped


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	randomize()
	
	start_game()


func _input(event):
	if event.is_action_pressed("Close Game"):
		get_tree().quit()
	
	elif event.is_action_pressed("New Game"):
		reset_board()
		start_game()
	
	elif event.is_action_pressed("Toggle Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	elif event.is_action_pressed("Undo"):
		undo()


func start_game():
	# Make and shuffle a deck of cards
	var deck = []
	
	for i in range(52):
		deck.append(make_card(i))
	
	deck.shuffle()
	var current_card
	
	# Deal cards onto board
	for i in range(7):
		for j in range(i + 1):
			current_card = deck.pop_front()
			get_node("CardColumn" + str(i + 1)).add_card(current_card)
			current_card.show()
	
	for i in range (1, 8):
		get_node("CardColumn" + str(i)).flip_top_card_up()
		get_node("CardColumn" + str(i)).change_click_detections()
	
	# Put the rest of the deck into the deck scene
	$Deck.create_deck(deck)
	$Deck.texture_normal = preload("res://assets/Cards/card_back.png")
	
	# Make an array to keep track of all the moves in the game
	moves = []
	
	# Start game timer
	$DisplayOverlay.get_node("GameTimer").reset_timer()
	
	# Reset move count
	$DisplayOverlay.reset_moves()


# Creates a card based off a passed index
func make_card(card_index: int):
	var card = card_scene.instantiate()
	
	match card_index / 13:
		0:
			card.suit = "heart"
			card.color = "red"
		1:
			card.suit = "diamond"
			card.color = "red"
		2:
			card.suit = "spade"
			card.color = "black"
		3:
			card.suit = "club"
			card.color = "black"
	
	card.value = (card_index % 13) + 1
	
	card.card_name = str(card.value) + "_" + card.suit
	
	# So the card can easily access the game_board when being moved
	card.game_board = self
	
	return card


# Called to reset all the baord items to start a new game
func reset_board():
	for i in range (1, 8):
		get_node("CardColumn" + str(i)).reset_column()
	
	for i in range(1, 5):
		get_node("FoundationCardSlot" + str(i)).reset_foundation()
	
	$Deck.reset_deck()


# Undo's moves in the game
func undo():
	# If there is no move to undo, do nothing
	if moves.is_empty():
		return
	
	if card_is_being_dragged:
		return
	
	card_is_being_dragged = true
	
	var move = moves.pop_back()
	
	# The deck has different treatment of each part of the move
	if move.card is String and move.card == "DeckFlip":
		# First position holds how many cards were face up
		$Deck.undo_deck_flip(move.first_position, move.second_position, move.card_was_flipped)
		card_is_being_dragged = false
		return
	
	for i in move.card.child_card_count + 1:
		move.card.get_parent().remove_card()
	
	move.card.get_parent().remove_child(move.card)
	move.first_position.add_card(move.card)
	
	# Necessary because cards moved from the deck sometimes have a different name
	move.card.name = "card"
	
	move.first_position.change_click_detections()
	move.second_position.change_click_detections()
	
	if move.card_was_flipped:
		move.first_position.flip_bottom_card_back()
	
	card_is_being_dragged = false


func add_move(move, remove_move = false):
	if remove_move:
		moves.pop_back()
		$DisplayOverlay.remove_move()
	else:
		moves.append(move)
		$DisplayOverlay.add_move()
