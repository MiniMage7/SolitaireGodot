extends Area2D

var number_of_cards


# Called when the node enters the scene tree for the first time.
func _ready():
	number_of_cards = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Called when a new card is added to the column
func add_card(new_child_card):
	# If this is a stack of multiple cards
	if new_child_card.child_card_count == null:
		new_child_card.child_card_count = 0
	
	number_of_cards += new_child_card.child_card_count
	
	# If there are no cards in the column
	if number_of_cards - new_child_card.child_card_count == 0:
		# Set the card as the column's child
		self.add_child(new_child_card)
		$card.position.x = 0
		$card.position.y = -289
	else:
		# Otherwise tell the top card in the stack to do this process
		$card.add_card(new_child_card, number_of_cards)
	
#	# If this is a stack of multiple cards
#	if new_child_card.child_card_count != null:
#	# Call the add extra card function for each of them
#		for i in range(new_child_card.child_card_count):
#			add_extra_cards()
	
	number_of_cards += 1


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
	$card.change_click_detections()


# Called when a card is removed from the column, just modifies the card count
func remove_card():
	number_of_cards -= 1


# Called when more than 1 card is moved into the column at once
func add_extra_cards():
	print("EXTRA CARD ADDED")
	# If there are other cards in the stack, call this on them too
	if number_of_cards != 0:
		$card.add_extra_cards()
	
	number_of_cards += 1
