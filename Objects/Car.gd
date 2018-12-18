extends "res://Objects/MovingObject.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var car_path = [[0,0]]
var current = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_path(path):
	car_path = path
	

func turn_done():
	if current+1 > len(car_path):
		current = 0
	
	var next_path = car_path[current]
	current += 1
	set_next_movement(next_path)
	
func undo_done():
	if current == 0:
		current = len(car_path)-1
	else:
		current -= 1