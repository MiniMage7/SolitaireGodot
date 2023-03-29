extends Node2D

@export var card_scene: PackedScene

var moves

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
	
	if event.is_action_pressed("New Game"):
		_on_new_game_pressed()
	
	if event.is_action_pressed("Toggle Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if event.is_action_pressed("Undo"):
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


# Called to clear the board and then start a new game
func _on_new_game_pressed():
	reset_board()
	start_game()


# Undo's moves in the game
func undo():
	# If there is no move to undo, do nothing
	if moves.is_empty():
		return
	
	var move = moves.pop_back()
	
	if move.card is String and move.card == "DeckFlip":
		# First position holds how many cards were face up
		$Deck.undo_deck_flip(move.first_position)
		return
	
	for i in move.card.child_card_count + 1:
		move.card.get_parent().remove_card()
	
	move.card.get_parent().remove_child(move.card)
	move.first_position.add_card(move.card)
	
	# Necessary because cards moved from the deck have a different name
	move.card.name = "card"
	
	move.first_position.change_click_detections()
	move.second_position.change_click_detections()
	
	if move.card_was_flipped:
		move.first_position.flip_bottom_card_back()
