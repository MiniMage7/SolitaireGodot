extends Area2D

var suit
var color
var value
var is_face_up
var card_name

var child_card_count

# Called when the node enters the scene tree for the first time.
func _ready():
	is_face_up = false
	$CollisionShape2D.set_deferred("disabled", true)
	child_card_count = 0
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_card(new_child_card):
	# If this card doesn't have any cards on top of it
	if child_card_count == 0:
		# Put the new card on top of it
		self.add_child(new_child_card)
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
