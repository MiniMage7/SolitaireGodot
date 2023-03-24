extends TextureButton

var deck
var cards_in_deck

var flipped_deck
var cards_in_flipped_deck

var face_up_cards
var face_up_card_count

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func create_deck(passed_deck):
	deck = passed_deck
	cards_in_deck = 24
	
	flipped_deck = []
	cards_in_flipped_deck = 0
	
	face_up_cards = []
	face_up_card_count = 0


func flip3():
	var card
	
	# Hide any currently shown cards and remove them from the shown card list
	for i in range(face_up_card_count):
		card = face_up_cards.pop_front()
		card.hide()
		self.remove_child(card)
	
	# Get the number of cards to flip (3 unless theres less than 3 cards, then all the cards)
	face_up_card_count = cards_in_deck
	
	if face_up_card_count > 3:
		face_up_card_count = 3
	
	# If there are no cards to flip, refill deck
	if face_up_card_count == 0:
		cards_in_deck = cards_in_flipped_deck
		deck = flipped_deck
		
		cards_in_flipped_deck = 0
		flipped_deck = []
		
		# Change icon back to deck
		self.texture_normal = preload("res://assets/Cards/card_back.png")
		
		return
	
	# Flip the cards
	for i in range(face_up_card_count):
		card = deck.pop_front()
		
		face_up_cards.append(card)
		flipped_deck.append(card)
		cards_in_flipped_deck += 1
		cards_in_deck -= 1
		
		self.add_child(card)
		card.position.x = 190 + 50 * i
		card.position.y = 70
		card.flip_card_up()
		card.show()
	
	if cards_in_deck == 0:
		self.texture_normal = preload("res://assets/deck_empty.png")



func _on_pressed():
	flip3()
