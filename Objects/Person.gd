extends "res://Objects/MovingObject.gd"

signal person_click(event, unit)

var person_id = 0
var does_have_gift = false
var at_home = false

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
		$Pivot/Sprite.modulate = Color(0,1,0)
		emit_signal("person_click", ev, self)

func set_shown():
	$Pivot/Sprite.show()
	at_home = false

func set_at_home():
	print("home1")
	$Pivot/Sprite.hide()
	at_home = true
	
func is_at_home():
	return at_home