extends Node

export var x_loc = 0
export var y_loc = 0

var home_id = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_position(pos):
	$HomeSprite.position = pos
	
func set_home_id(id):
	home_id = id
	
func get_home_id():
	return home_id