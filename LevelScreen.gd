extends Node

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$CurrentLevel.load_level_file(1)
	$MusicPlayer.playing = true
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass



# This is a turn
func _on_GoButton_pressed():
	$CurrentLevel.process_turn()
		
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			var person = $CurrentLevel.get_selected_person()
			if event.scancode == KEY_BACKSPACE:
				# First process the moving objects
				for object in $CurrentLevel/LevelGrid/YSort/Moving.get_children():
					object.undo()
				
				# Process the player's people
				for person in $CurrentLevel/LevelGrid/YSort/People.get_children():
					person.undo()
					person.set_shown()
			elif event.scancode == KEY_LEFT:
				if person != null:
					person.set_next_movement([-1, 0])
			elif event.scancode == KEY_RIGHT:
				if person != null:
					person.set_next_movement([1, 0])
			elif event.scancode == KEY_UP:
				if person != null:
					person.set_next_movement([0, -1])
			elif event.scancode == KEY_DOWN:
				if person != null:
					person.set_next_movement([0, 1])
			elif event.scancode == KEY_ENTER:
				$CurrentLevel.process_turn()

