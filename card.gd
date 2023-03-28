extends Area2D

# Qualities of the card
var suit
var color
var value
var is_face_up
var card_name

# Number of cards stacked on the card
var child_card_count = 0

# Whether the card is being clicked (dragged)
var is_being_clicked

# A reference to the main board
var game_board

# Variables used for when the card is being moved
var old_parent
var potential_new_parent


# Called when the node enters the scene tree for the first time.
func _ready():
	# All cards are created face down with no collision detection enabled
	is_face_up = false
	$CollisionShape2D.set_deferred("disabled", true)
	$TopClickDetection.set_deferred("disabled", true)
	$BottomClickDetection.set_deferred("disabled", true)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# This is where card movement during dragging is processed
func _process(_delta):
	# If the user is currently dragging
	if is_being_clicked:
		# Backup release check in case the user somehow released when not on the card
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			on_card_release()
		
		# User is dragging
		else:
			# The vector at the end is to adjust for the gameboard's offset
			self.position = get_viewport().get_mouse_position() + Vector2(420, 0)


# Called when a card is added to the column this card is a part of
func add_card_column(new_child_card, new_child_card_count):
	# If this card doesn't have any cards on top of it
	if child_card_count == 0:
		# Put the new card on top of it
		self.add_child(new_child_card)
		new_child_card.position.x = 0
		new_child_card.position.y = 40
	# If it already does have a card on it, try to put it on that card instead
	else:
		$card.add_card_column(new_child_card, new_child_card_count - 1)
	
	child_card_count = new_child_card_count


# Called when a card is added to the foundation slot this card is a part of
func add_card_foundation(new_child_card, new_child_card_count):
	# If this card doesn't have any cards on top of it
	if child_card_count == 0:
		# Put the new card on top of it
		self.add_child(new_child_card)
		new_child_card.position.x = 0
		new_child_card.position.y = 0
	# If it already does have a card on it, try to put it on that card instead
	else:
		$card.add_card_foundation(new_child_card, new_child_card_count - 1)
	
	child_card_count = new_child_card_count


# Flips the card face up
func flip_card_up():
	if is_face_up:
		return
	
	get_node("Sprite2D").texture = load("res://assets/Cards/" + card_name + ".png")
	is_face_up = true


# Flips the top card in a column face up
func flip_top_card_up():
	# If this is the top card, flip it up
	if child_card_count == 0:
		flip_card_up()
	# Otherwise call this function on the next highest card
	else:
		$card.flip_top_card_up()


# Modifies the collision of all cards in this card's column
func change_click_detections_column():
	# If this is the top card, have all click collision turned on
	if child_card_count == 0:
		$TopClickDetection.set_deferred("disabled", false)
		$BottomClickDetection.set_deferred("disabled", false)
	# If it's not the top card
	else:
		# If its face up, have the top part of the card's collison on
		if is_face_up:
			$TopClickDetection.set_deferred("disabled", false)
			$BottomClickDetection.set_deferred("disabled", true)
		# Call this on the next card in the column
		$card.change_click_detections_column()


# Modifies the collision of all cards in this card's foundation slot
func change_click_detections_foundation():
	# If this is the top card, have all click collision turned on
	if child_card_count == 0:
		$TopClickDetection.set_deferred("disabled", false)
		$BottomClickDetection.set_deferred("disabled", false)
	# If it's not the top card, diable all click detections
	else:
		$TopClickDetection.set_deferred("disabled", true)
		$BottomClickDetection.set_deferred("disabled", true)
		# Call this on the next card in the slot
		$card.change_click_detections_foundation()


# Checks for clicking and releasing on the card
func _on_input_event(_viewport, event, _shape_idx):
	# If the event relates to a left mouse button push
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# If its being pressed and there is no dragging yet
		if !is_being_clicked and event.pressed:
			# Call remove card on the card above it for every card being picked up
			for i in child_card_count + 1:
				get_parent().remove_card()
			
			# Set the card's parent to the gameboard to make movement easier
			# And store the card area the card came from
			old_parent = get_top_parent()
			get_parent().remove_child(self)
			game_board.add_child(self)
			
			# Change the collision detection to only be the center to the card
			$TopClickDetection.set_deferred("disabled", true)
			$BottomClickDetection.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", false)
			
			is_being_clicked = true
		# Otherwise if the card is being released
		elif is_being_clicked and !event.pressed:
			on_card_release()
	
	# If the event is a right mouse button push
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		auto_move()


# Store whatever card slot/column that the card last hovered over
func _on_area_entered(area):
	potential_new_parent = area


# Remove the last area when it leaves if a new area hasn't already overwritten it
func _on_area_exited(area):
	if is_being_clicked && potential_new_parent == area:
		potential_new_parent = null


# Called at the end of a drag or click
func on_card_release():
	is_being_clicked = false
	
	# Check if the card was over an area when released
	if potential_new_parent == null:
		potential_new_parent = old_parent
	
	# If the card is attempting to move somewhere different
	if potential_new_parent != old_parent:
		if !potential_new_parent.check_card_validity(self):
			# If it can't move there, put it back where it came from
			potential_new_parent = old_parent
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	get_parent().remove_child(self)
	
	# Necessary because cards moved from the deck have a different name
	self.name = "card"
	
	potential_new_parent.add_card(self)
	
	old_parent.flip_top_card_up()
	potential_new_parent.change_click_detections()
	old_parent.change_click_detections()


# Called when a card is removed from a card's column
func remove_card():
	child_card_count -= 1
	# Since there will always (eventually) be a card_column, this can be re-called until
	# it reaches the function in card_column where it won't be re-called
	# This will result in the number of child cards for each object in the column going down 1
	get_parent().remove_card()


# Is called all the way up until it reaches a non-card which returns itself
func get_top_parent():
	return get_parent().get_top_parent()


# Checks for in a column, if a card can be put in this column
func check_card_validity_column(passed_color, passed_value):
	# If there are no cards on this card, return true if its a different color and its value is 1 less
	if child_card_count == 0:
		return passed_color != color && passed_value + 1 == value
	# Otherwise check if it can be put on the next card
	return $card.check_card_validity_column(passed_color, passed_value)


# Checks for in a foundation slot, if a card can be put in this slot
func check_card_validity_foundation(passed_suit, passed_value):
	# If there are no cards on this card, return true if its a different color and its value is 1 less
	if child_card_count == 0:
		return passed_suit == suit && passed_value - 1 == value
	# Otherwise check if it can be put on the next card
	return $card.check_card_validity_foundation(passed_suit, passed_value)


# Called to delete all cards for a new game
func reset_cards():
	# If there are no cards on this card, just delete iself
	# Otherwise call this on the cards stacked on it and then delete itself
	if child_card_count != 0:
		$card.reset_cards()
		remove_child($card)
	queue_free()


func auto_move():
	# First check if the card can be moved to the foundation, and move it if it can
	for i in range(1,5):
		if game_board.get_node("FoundationCardSlot" + str(i)).check_card_validity(self):
			potential_new_parent = game_board.get_node("FoundationCardSlot" + str(i))
			old_parent = get_top_parent()
			get_parent().remove_card()
			on_card_release()
			return
	
	for i in range(1,8):
		if game_board.get_node("CardColumn" + str(i)).check_card_validity(self):
			potential_new_parent = game_board.get_node("CardColumn" + str(i))
			old_parent = get_top_parent()
			get_parent().remove_card()
			on_card_release()
			return
