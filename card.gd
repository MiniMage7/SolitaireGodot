extends Area2D

# Qualities of the card
var suit
var color
var value
var is_face_up
var card_name

# Number of cards stacked on the card
var child_card_count

# Whether the card is being clicked (dragged)
var is_being_clicked

# A reference to the main board
var game_board

# Variables used for when the card is being moved
var old_parent
var potential_new_parent

# Called when the node enters the scene tree for the first time.
func _ready():
	is_face_up = false
	$CollisionShape2D.set_deferred("disabled", true)
	$TopClickDetection.set_deferred("disabled", true)
	$BottomClickDetection.set_deferred("disabled", true)
	child_card_count = 0
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_being_clicked:
		# Backup release check in case the user somehow released when not on the card
		if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			on_card_release()
		
		# User is dragging
		else:
			self.position = get_viewport().get_mouse_position()


func add_card(new_child_card):
	# If this card doesn't have any cards on top of it
	if child_card_count == 0:
		# Put the new card on top of it
		self.add_child(new_child_card)
		new_child_card.position.x = 0
		new_child_card.position.y = 40
	# If it already does have a card on it, try to put it on that card instead
	else:
		$card.add_card(new_child_card)
	
	child_card_count += 1

func flip_card_up():
	if is_face_up:
		return
	
	get_node("Sprite2D").texture = load("res://assets/Cards/" + card_name + ".png")
	is_face_up = true

func flip_top_card_up():
	if child_card_count == 0:
		flip_card_up()
	else:
		$card.flip_top_card_up()


func change_click_detections():
	if child_card_count == 0:
		$TopClickDetection.set_deferred("disabled", false)
		$BottomClickDetection.set_deferred("disabled", false)
	else:
		if is_face_up:
			$TopClickDetection.set_deferred("disabled", false)
		$card.change_click_detections()


# Checks for clicking and releasing on the card
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_being_clicked and event.pressed:
			# Set the card's parent to the gameboard to make movement easier
			old_parent = get_parent()
			old_parent.remove_child(self)
			game_board.add_child(self)
			
			$TopClickDetection.set_deferred("disabled", true)
			$BottomClickDetection.set_deferred("disabled", true)
			$CollisionShape2D.set_deferred("disabled", false)
			
			is_being_clicked = true
		
		elif is_being_clicked and !event.pressed:
			on_card_release()


# Store whatever card slot/column that the card last hovered over
func _on_area_entered(area):
	potential_new_parent = area


# Remove the last area when it leaves if a new area hasn't already overwritten it
func _on_area_exited(area):
	if potential_new_parent == area:
		potential_new_parent == null


func on_card_release():
	is_being_clicked = false
	
	# Check if the card was over an area when released
	if potential_new_parent == null:
		potential_new_parent == old_parent
	
	
	# TODO: Set card's new parent, check if any cards need to be flipped up, check for any hit box changes etc.
	
	#REMOVE THIS LATER
	$TopClickDetection.set_deferred("disabled", false)
	$BottomClickDetection.set_deferred("disabled", false)
	$CollisionShape2D.set_deferred("disabled", true)
	
	get_parent().remove_child(self)
	potential_new_parent.add_card(self)



