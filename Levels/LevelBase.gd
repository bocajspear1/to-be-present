extends Node


var TREE_SCENE = load("res://Objects/Tree.tscn")
var PERSON_SCENE = load("res://Objects/Person.tscn")
var CAR_SCENE = load("res://Objects/Car.tscn")
var GIFT_SCENE = load("res://Objects/Gift.tscn")
var HOME_SCENE = load("res://Objects/PersonHome.tscn")

export var turns_left = 25
export var grid_height = 5
export var grid_width = 5


var level_data = {}
var selected_person = null


func _ready():
	load_level(1)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_selected_person():
	return selected_person

func process_turn():
	
	# Check everybody has a move
	for person in $LevelGrid/YSort/People.get_children():
		var movement = person.get_next_movement()
		if movement[0] == 0 and movement [1] == 0:
			return false
		
	# First process the moving objects
	for object in $LevelGrid/YSort/Moving.get_children():
		var movement = object.get_next_movement()
		var new_loc = [object.x_loc + movement[0], object.y_loc + movement[1]]
		object.move_on_grid(new_loc)
		object.turn_done()
	
	# Process the player's people
	for person in $LevelGrid/YSort/People.get_children():
		var movement = person.get_next_movement()
		var new_loc = [person.x_loc + movement[0], person.y_loc + movement[1]]
		
		
		# Check we are on a present
		for gift in $LevelGrid/YSort/Gifts.get_children():
			if gift.is_taken():
				continue
			if gift.x_loc == new_loc[0] and gift.y_loc == new_loc[1]:
				if gift.get_gift_id() == person.get_person_id():
					person.toggle_gift()
					gift.set_gift_taken()
				else:
					return true
					
		# Check we are on a home
		for home in $LevelGrid/YSort/Homes.get_children():
			if home.x_loc == new_loc[0] and home.y_loc == new_loc[1]:
				if home.get_home_id() == person.get_person_id() and person.has_gift():
					$LevelGrid/YSort/Homes.remove_child(person)
				else:
					return true
				
			
					
					
		person.move_on_grid(new_loc)
		
	return true

func can_move_on_grid(grid_pos):
	
	if grid_pos[0] >= grid_width or grid_pos[0] < 0:
		return false
	if grid_pos[1] >= grid_height or grid_pos[1] < 0:
		return false
	
	for object in $LevelGrid/YSort/Moving.get_children():
		var obj_loc = object.get_current_location()
		if obj_loc[0] ==  grid_pos[0] and obj_loc[1] == grid_pos[1]:
			return false
			
	for person in $LevelGrid/YSort/People.get_children():
		var person_loc = person.get_current_location()
		if person_loc[0] == grid_pos[0] and person_loc[1] == grid_pos[1]:
			return false
			
	for static_obj in $LevelGrid/YSort/Static.get_children():
		if static_obj.x_loc == grid_pos[0] and static_obj.y_loc == grid_pos[1]:
			return false
	
	return true
	
	# We are not colliding with anything, move us
	#var real_pos = convert_grid_to_pos(grid_x, grid_y)
	#target.move_to([grid_x, grid_y], real_pos)
	
	# Do stuff here is grid tile is special (gift, end)
	
	
func load_level(level_num):
	if typeof(level_num) != TYPE_INT:
		return 
	var file = File.new()
	file.open("res://Levels/TestLevel.json", file.READ)
	var file_text = file.get_as_text()
	
	var result_json = JSON.parse(file_text)

	if result_json.error == OK:
		level_data = result_json.result
		grid_height = level_data['height']
		grid_width = level_data['width']
		
		for line_num in grid_width:
			var line = level_data['map'][line_num]
			for col_num in grid_height:
				
				if col_num < len(line):
					var col = line[col_num]
					var type = col['type']
					var sprite = col['sprite']
					
					if type == 'static':
						# Spawn in an item
						if sprite.begins_with('tree'):
							$LevelGrid.set_cell(col_num, line_num, 3)
							var tree = TREE_SCENE.instance()
							$LevelGrid/YSort/Static.add_child(tree)
							print($LevelGrid.map_to_world(Vector2(col_num, line_num)))
							tree.set_position(convert_grid_to_pos(col_num, line_num))
							tree.x_loc = col_num
							tree.y_loc = line_num
					elif type == 'open':
						var sprite_id = -1
						if sprite.begins_with('dirtroad'):
							sprite_id = 1
						elif sprite == "snow":
							sprite_id = 5
						$LevelGrid.set_cell(col_num, line_num, sprite_id)
						if col.has("person_id"):
							var person = PERSON_SCENE.instance()
							$LevelGrid/YSort/People.add_child(person)
							person.set_position(convert_grid_to_pos(col_num, line_num))
							person.connect("person_click", self, "_on_person_click")
							person.x_loc = col_num
							person.y_loc = line_num
						if col.has("moving"):
							if col['moving'] == 'car':
								var car = CAR_SCENE.instance()
								$LevelGrid/YSort/Moving.add_child(car)
								car.set_position(convert_grid_to_pos(col_num, line_num))
								car.x_loc = col_num
								car.y_loc = line_num
								car.set_path(col['path'])
								car.turn_done()
						if col.has("gift_id"):
							var gift = GIFT_SCENE.instance()
							$LevelGrid/YSort/Gifts.add_child(gift)
							gift.set_position(convert_grid_to_pos(col_num, line_num))
							gift.x_loc = col_num
							gift.y_loc = line_num
					elif type == 'house':
						var home = HOME_SCENE.instance()
						$LevelGrid/YSort/Homes.add_child(home)
						home.set_position(convert_grid_to_pos(col_num, line_num))
						home.x_loc = col_num
						home.y_loc = line_num
						home.set_home_id(col['home_id'])
				else:
					pass
			
			
		
	else:
		print("Error: ", result_json.error)
		print("Error Line: ", result_json.error_line)
		print("Error String: ", result_json.error_string)
	
	file.close()

func convert_grid_to_pos(grid_x, grid_y):
	var pos = $LevelGrid.map_to_world(Vector2(grid_x, grid_y))
	pos.x += $LevelGrid.position.x + $LevelGrid.cell_size.x/2
	pos.y += $LevelGrid.position.y + $LevelGrid.cell_size.y/2
	return pos

func _on_person_click(event, person):
	selected_person = person