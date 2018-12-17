extends "res://Objects/MovingObject.gd"

signal person_click(event, unit)

var person_id = 0
var does_have_gift = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func set_person_id(id):
	person_id = id
	
func get_person_id():
	return person_id
	
func has_gift():
	return does_have_gift

func toggle_gift():
	does_have_gift = true

func _on_ClickArea_gui_input(ev):
	if ev.is_pressed():
		emit_signal("person_click", ev, self)
