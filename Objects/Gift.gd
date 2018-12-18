extends Node

export var x_loc = 0
export var y_loc = 0

var gift_id = 0
var taken = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func set_position(pos):
	$GiftSprite.position = pos

func is_taken():
	return taken

func set_gift_taken():
	$GiftSprite.hide()
	taken = true
	
func reset():
	$GiftSprite.show()
	taken = false