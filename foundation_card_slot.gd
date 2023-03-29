extends Area2D

var number_of_cards


# Called when the node enters the scene tree for the first time.
func _ready():
	number_of_cards = 0


# Called when a new card is added to this foundation slot
func add_card(new_child_card):
	# If there are no cards in the slot
	if number_of_cards == 0:
		# Set the card as the slots's child
		self.add_child(new_child_card)
		$card.position.x = 0
		$card.position.y = 0
	else:
		# Otherwise tell the top card in the stack to do this process
		$card.add_card_foundation(new_child_card, number_of_cards)
	
	number_of_cards += 1


# Can be called when a card is removed from this slot, but since a card can't be face down here, just exit
# Returns if a card was flipped
func flip_top_card_up():
	return false


# Changes the hit boxes of all cards in the foundation slot so they work properly
func change_click_detections():
	# If there are no cards in the slot, do nothing
	if number_of_cards == 0:
		return
	# Otherwise tell the top card to change all the click detections in its stack
	$card.change_click_detections_foundation()


# Called when a card is removed from the slot, just modifies the card count
func remove_card():
	number_of_cards -= 1


# Is called when a card is looking for what holding object it is in, so this returns itself
func get_top_parent():
	return self


# Check if a card can be placed in the slot
func check_card_validity(card):
	# If the card has any child card's, return false
	if card.child_card_count != 0:
		return false
	# If there are no cards in the slot, return true if it is an ace
	if number_of_cards == 0:
		return card.value == 1
	# Otherwise, check if it can be placed on the card column
	return $card.check_card_validity_foundation(card.suit, card.value)


# Called when emptying the foundations for a new game
func reset_foundation():
	# If there are no cards in the foundation slot, theres nothing to reset
	if number_of_cards == 0:
		return
	# Then call the reset function on the cards
	$card.reset_cards()
	remove_child($card)
	number_of_cards = 0
