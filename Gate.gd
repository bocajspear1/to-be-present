extends Node

export var x_loc = 0
export var y_loc = 0

var gate_id = 0

var gate_open = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_position(pos):
	$GateSprite.position = pos
	
func set_gate_id(id):
	gate_id = id
	
func get_gate_id():
	return gate_id

func open_gate():
	if not gate_open:
		$GateSprite.hide()
		gate_open = true
		
func close_gate():
	if gate_open:
		$GateSprite.show()
		gate_open = false
		
func is_open():
	return gate_open