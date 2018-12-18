extends Node


var TREE_SCENE = load("res://Objects/Tree.tscn")
var PERSON_SCENE = load("res://Objects/Person.tscn")
var CAR_SCENE = load("res://Objects/Car.tscn")
var GIFT_SCENE = load("res://Objects/Gift.tscn")
var HOME_SCENE = load("res://Objects/PersonHome.tscn")
var BUTTON_SCENE = load("res://Objects/Button.tscn")
var GATE_SCENE = load("res://Objects/Gate.tscn")

export var turns_left = 25
export var grid_height = 5
export var grid_width = 5


var level_data = {}
var selected_person = null


func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func get_selected_person():
	return selected_person


func _open_gate(id):
	for gate in $LevelGrid/YSort/Gates.get_children():
		if gate.get_gate_id() == id:
			gate.open_gate()

func _close_gate(id):
	for gate in $LevelGrid/YSort/Gates.get_children():
		if gate.get_gate_id() == id:
			gate.close_gate()
	
func _check_button(object):
	for button in $LevelGrid/YSort/Buttons.get_children():
		for person in $LevelGrid/YSort/People.get_children():
			if person.x_loc == button.x_loc and person.y_loc == button.y_loc:
				_open_gate(button.get_button_id())
				return
		
		for object in $LevelGrid/YSort/Moving.get_children():
			if object.x_loc == button.x_loc and object.y_loc == button.y_loc:
				_open_gate(button.get_button_id())
				return
		# Check if button is being moved off of
		
		_close_gate(button.get_button_id())

func _check_gate(new_loc):
	for gate in $LevelGrid/YSort/Gates.get_children():
		# Check if button is being moved off of
		if gate.x_loc == new_loc[0] and gate.y_loc == new_loc[1]:
			if gate.is_open():
				return true
			else:
				return false
	
	return true
			

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
		_check_button(object)
		
		if _check_gate(new_loc):
			object.move_on_grid(new_loc)
		object.turn_done()
		_check_button(object)
	
	# Process the player's people
	for person in $LevelGrid/YSort/People.get_children():
		var movement = person.get_next_movement()
		var new_loc = [person.x_loc + movement[0], person.y_loc + movement[1]]
		
		_check_button(person)
		
		# Check we are on a present
		for gift in $LevelGrid/YSort/Gifts.get_children():
			if gift.is_taken():
				continue
			if gift.x_loc == new_loc[0] and gift.y_loc == new_loc[1]:
				if gift.gift_id == person.person_id:
					print("got gift")
					person.toggle_gift()
					gift.set_gift_taken()
				else:
					return true
					
		# Check we are on a home
		for home in $LevelGrid/YSort/Homes.get_children():
			if home.x_loc == new_loc[0] and home.y_loc == new_loc[1]:
				if home.home_id == person.person_id and person.has_gift():
					print("Home!")
					$LevelGrid/YSort/Homes.remove_child(person)
				else:
					print("Home, but no gift")
					return true
				
			
					
		if _check_gate(new_loc):			
			person.move_on_grid(new_loc)
		_check_button(person)
		
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

func _load_level(level_data):
	grid_height = level_data['height']
	grid_width = level_data['width']
	
	for line_num in grid_width:
		var line = level_data['map'][line_num]
		for col_num in grid_height:
			
			if col_num >= len(line):
				continue
				
			var col = line[col_num]
			var type = col['type']
			var sprite = col['sprite']
			
			if type == 'static':
				# Spawn in an item
				if sprite == 'tree':
					$LevelGrid.set_cell(col_num, line_num, 2)
					var tree = TREE_SCENE.instance()
					$LevelGrid/YSort/Static.add_child(tree)
					print($LevelGrid.map_to_world(Vector2(col_num, line_num)))
					tree.set_position(convert_grid_to_pos(col_num, line_num))
					tree.x_loc = col_num
					tree.y_loc = line_num
			elif type == 'open':
				var sprite_id = -1
				if sprite == 'dirt':
					sprite_id = 0
				elif sprite == "road":
					sprite_id = 3
				elif sprite == "snow":
					sprite_id = 4
				$LevelGrid.set_cell(col_num, line_num, sprite_id)
				if col.has("person"):
					var person = PERSON_SCENE.instance()
					$LevelGrid/YSort/People.add_child(person)
					person.set_position(convert_grid_to_pos(col_num, line_num))
					person.connect("person_click", self, "_on_person_click")
					person.x_loc = col_num
					person.y_loc = line_num
					person.person_id = col['person']
				elif col.has("moving"):
					if col['moving'] == 'car':
						var car = CAR_SCENE.instance()
						$LevelGrid/YSort/Moving.add_child(car)
						car.set_position(convert_grid_to_pos(col_num, line_num))
						car.x_loc = col_num
						car.y_loc = line_num
						car.set_path(col['path'])
						car.turn_done()
				elif col.has("button"):
					var button = BUTTON_SCENE.instance()
					$LevelGrid/YSort/Buttons.add_child(button)
					button.set_position(convert_grid_to_pos(col_num, line_num))
					button.x_loc = col_num
					button.y_loc = line_num
					button.button_id = col['button']
				elif col.has("gate"):
					var gate = GATE_SCENE.instance()
					$LevelGrid/YSort/Gates.add_child(gate)
					gate.set_position(convert_grid_to_pos(col_num, line_num))
					gate.x_loc = col_num
					gate.y_loc = line_num
					gate.gate_id = col['gate']
						
				elif col.has("gift"):
					var gift = GIFT_SCENE.instance()
					$LevelGrid/YSort/Gifts.add_child(gift)
					gift.set_position(convert_grid_to_pos(col_num, line_num))
					gift.x_loc = col_num
					gift.y_loc = line_num
					gift.gift_id = col['gift']
			elif type == 'house':
				var home = HOME_SCENE.instance()
				$LevelGrid/YSort/Homes.add_child(home)
				home.set_position(convert_grid_to_pos(col_num, line_num))
				home.x_loc = col_num
				home.y_loc = line_num
				home.set_home_id(col['home'])			
			else:
				pass
	
func load_level_file(level_num):
	if typeof(level_num) != TYPE_INT:
		return 
	var file = File.new()
	file.open("res://Levels/TestLevel.json", file.READ)
	var file_text = file.get_as_text()
	
	var result_json = JSON.parse(file_text)

	if result_json.error == OK:
		_load_level(result_json.result)
			
			
		
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