extends Node2D

@export var card_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	randomize()
	
	start_game()


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


func _on_new_game_pressed():
	reset_board()
	
	start_game()
