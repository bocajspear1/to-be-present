extends Node

export var x_loc = 0
export var y_loc = 0

var history = []
var next_move = [0,0]

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_position(pos):
	$Pointer.position = pos
	$Pivot.position = pos

func get_next_movement():
	return next_move

func set_next_movement(movement):
	$Pointer.show()
	if movement[0] > 0 and movement[1] == 0:
    	$Pointer.rotation_degrees = 0
	elif movement[0] < 0 and movement[1] == 0:
		$Pointer.rotation_degrees = 180
	elif movement[0] == 0 and movement[1] > 0:
		$Pointer.rotation_degrees = 90
	elif movement[0] == 0 and movement[1] < 0:
		$Pointer.rotation_degrees = 270
	next_move = movement
	
func clear_next_movement():
	$Pointer.hide()
	next_move = [0,0]

func get_current_location():
	return [x_loc, y_loc]

func undo():
	if len(history) > 0:
		var last_pos = history[len(history)-1]
		x_loc = last_pos[0]
		y_loc = last_pos[1]
		var grid = get_parent().get_parent().get_parent().get_parent()
		$Pivot.position = grid.convert_grid_to_pos(last_pos[0], last_pos[1])
		history.pop_back()

func move_on_grid(grid_pos):
	history.append([x_loc, y_loc])
	var grid = get_parent().get_parent().get_parent().get_parent()
	if grid.can_move_on_grid(grid_pos):
		x_loc = grid_pos[0]
		y_loc = grid_pos[1]
		set_position(grid.convert_grid_to_pos(grid_pos[0], grid_pos[1]))
		
func turn_done():
	pass





