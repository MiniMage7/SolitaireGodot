extends Area2D

var number_of_cards


# Called when the node enters the scene tree for the first time.
func _ready():
	number_of_cards = 0


# Called when a new card is added to the column
func add_card(new_child_card):
	# If there are no cards in the column
	if number_of_cards == 0:
		# Set the card as the column's child
		self.add_child(new_child_card)
		$card.position.x = 0
		$card.position.y = -289
	else:
		# Otherwise tell the top card in the stack to do this process
		$card.add_card_column(new_child_card, number_of_cards + new_child_card.child_card_count)
	
	number_of_cards += new_child_card.child_card_count + 1


# Flips the top card in a column face up
func flip_top_card_up():
	# If there are no cards in the column, do nothing
	if number_of_cards == 0:
		return
	# Otherwise tell the top card to flip the top card up
	$card.flip_top_card_up()


# Changes the hit boxes of all cards in the column so they work properly
func change_click_detections():
	# If there are no cards in the column, do nothing
	if number_of_cards == 0:
		return
	# Otherwise tell the top card to change all the click detections in its column
	$card.change_click_detections_column()


# Called when a card is removed from the column, just modifies the card count
func remove_card():
	number_of_cards -= 1


# Is called when a card is looking for what column it is in, so this returns itself
func get_top_parent():
	return self


# Check if a card can be placed in the column
func check_card_validity(card):
	# If there are no cards in the column, return true if it is a king
	if number_of_cards == 0:
		return card.value == 13
	# Otherwise, check if it can be placed on the card column
	return $card.check_card_validity_column(card.color, card.value)


# Called to reset a column for a new game
func reset_column():
	# If there are no cards in the column, theres nothing to reset
	if number_of_cards == 0:
		return
	# Then call the reset function on the cards
	$card.reset_cards()
	remove_child($card)
	number_of_cards = 0
