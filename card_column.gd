extends Area2D

var number_of_cards
var top_child_card
# Called when the node enters the scene tree for the first time.
func _ready():
	number_of_cards = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_card(new_child_card):
	if number_of_cards == 0:
		top_child_card = new_child_card
		self.add_child(new_child_card)
		new_child_card.position.y = -289
	else:
		top_child_card.add_card(new_child_card)
	
	number_of_cards += 1

func flip_top_card_up():
	if number_of_cards == 0:
		return
	top_child_card.flip_top_card_up()
