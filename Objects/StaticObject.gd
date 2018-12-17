extends Node

export var x_loc = 0
export var y_loc = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_position(pos):
	$ObjectSprite.position = pos
