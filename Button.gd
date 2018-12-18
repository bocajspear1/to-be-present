extends Node

export var x_loc = 0
export var y_loc = 0

var button_id = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_position(pos):
	$ButtonSprite.position = pos
	
func set_button_id(id):
	button_id = id
	
func get_button_id():
	return button_id