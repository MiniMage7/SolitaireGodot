extends TextureButton

var deck
var cards_in_deck

var flipped_deck
var cards_in_flipped_deck

var face_up_cards
var face_up_card_count


# Called when this deck is first made
func create_deck(passed_deck):
	deck = passed_deck
	cards_in_deck = 24
	
	flipped_deck = []
	cards_in_flipped_deck = 0
	
	face_up_cards = []
	face_up_card_count = 0


# Flips over the next 3 cards from the deck
func flip3():
	var card
	
	var move = get_parent().Move.new()
	move.card = "DeckFlip"
	move.first_position = deck.duplicate()
	move.second_position = flipped_deck.duplicate()
	move.card_was_flipped = face_up_cards.duplicate()
	get_parent().add_move(move)
	
	# Hide any currently shown cards, disable their collision, and remove them from the shown card list
	for i in range(face_up_card_count):
		card = face_up_cards.pop_front()
		card.hide()
		card.get_node("TopClickDetection").set_deferred("disabled", true)
		card.get_node("BottomClickDetection").set_deferred("disabled", true)
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
		
		# If the deck is empty, don't redo the texture and undo the move recording
		if cards_in_deck == 0:
			get_parent().add_move(move, true)
			return
		
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
		
		# If it's the top card
		if i + 1 == face_up_card_count:
			# Make it so that the card can be clicked
			card.get_node("TopClickDetection").set_deferred("disabled", false)
			card.get_node("BottomClickDetection").set_deferred("disabled", false)
	
	if cards_in_deck == 0:
		self.texture_normal = preload("res://assets/deck_empty.png")


# When the deck is clicked
func _on_pressed():
	flip3()


# Called when a card is being dragged from the flipped up cards
func remove_card():
	# Remove the card from face up
	face_up_card_count -= 1
	face_up_cards.pop_back()
	# Remove the card from flipped
	cards_in_flipped_deck -= 1
	flipped_deck.pop_back()
	
	if face_up_card_count == 0:
		if cards_in_flipped_deck == 0:
			return
		else:
			# Make the last card in flipped deck face up so that it can be used
			face_up_card_count = 1
			var card = flipped_deck[cards_in_flipped_deck - 1]
			face_up_cards.append(card)
			self.add_child(card)
			card.position.x = 190
			card.position.y = 70
			card.show()


# Can be called when a card is removed from this slot, but since a card can't be face down here, just exit
# Returns if a card was flipped
func flip_top_card_up():
	return false


# Is called when a card is looking for what holding object it is in, so this returns itself
func get_top_parent():
	return self


# Changes the hit boxes of the next card in the deck so it works properly
func change_click_detections():
	# If there are no cards to flip up, don't do anything
	if face_up_card_count == 0:
		return
	face_up_cards[face_up_card_count - 1].get_node("TopClickDetection").set_deferred("disabled", false)
	face_up_cards[face_up_card_count - 1].get_node("BottomClickDetection").set_deferred("disabled", false)
	# If there is more than 1 more card, make sure the card before it doesn't have its click detections on
	if face_up_card_count != 1:
		face_up_cards[face_up_card_count - 2].get_node("TopClickDetection").set_deferred("disabled", true)
		face_up_cards[face_up_card_count - 2].get_node("BottomClickDetection").set_deferred("disabled", true)


# Is called only when a card is attempted to be dragged from the deck and fails
func add_card(card):
	# Add the card to face up
	face_up_card_count += 1
	face_up_cards.append(card)
	# Add the card to flipped
	cards_in_flipped_deck += 1
	flipped_deck.append(card)
	
	add_child(card)
	card.position.x = 190 + 50 * (face_up_card_count - 1)
	card.position.y = 70
	
	# Check for if there's more than 3 cards and adjust the cards
	if face_up_card_count == 4:
		# Remove the first card from face up
		face_up_card_count -= 1
		var card_to_remove = face_up_cards.pop_front()
		self.remove_child(card_to_remove)
		
		# Move the other cards over
		for i in range(3):
			face_up_cards[i].position.x = 190 + 50 * i


# Called to reset the deck for a new game
func reset_deck():
	# Delete all cards in both decks
	for i in range(cards_in_flipped_deck):
		flipped_deck[i].queue_free()
	
	for i in range(cards_in_deck):
		deck[i].queue_free()
	
	# Then empty the arrays and set the card counts to 0
	cards_in_deck = 0
	cards_in_flipped_deck = 0
	face_up_card_count = 0
	deck = []
	flipped_deck = []
	face_up_cards = []


# Undo the flipping of cards from the deck
func undo_deck_flip(old_deck, old_flipped_deck, old_face_up_cards):
	var card
	
	# Hide any currently shown cards, disable their collision, and remove them from the shown card list
	for i in range(face_up_card_count):
		card = face_up_cards.pop_front()
		card.hide()
		card.get_node("TopClickDetection").set_deferred("disabled", true)
		card.get_node("BottomClickDetection").set_deferred("disabled", true)
		self.remove_child(card)
	
	# Restore all the values
	deck = old_deck
	cards_in_deck = deck.size()
	
	flipped_deck = old_flipped_deck
	cards_in_flipped_deck = flipped_deck.size()
	
	face_up_cards = old_face_up_cards
	face_up_card_count = face_up_cards.size()
	
	# Show the flipped cards
	for i in range(face_up_card_count):
		card = face_up_cards[i]
		
		self.add_child(card)
		card.position.x = 190 + 50 * i
		card.position.y = 70
		card.flip_card_up()
		card.show()
		
		# If it's the top card
		if i + 1 == face_up_card_count:
			# Make it so that the card can be clicked
			card.get_node("TopClickDetection").set_deferred("disabled", false)
			card.get_node("BottomClickDetection").set_deferred("disabled", false)
	
	# Change the image of the deck as needed
	if cards_in_deck == 0:
		self.texture_normal = preload("res://assets/deck_empty.png")
	else:
		self.texture_normal = preload("res://assets/Cards/card_back.png")
	
