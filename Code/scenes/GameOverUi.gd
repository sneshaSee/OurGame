extends CanvasLayer
@onready var restart: Button = $CenterContainer/VBoxContainer/Restart
@onready var quit: Button = $CenterContainer/VBoxContainer/Quit

var character_body: CharacterBody2D = null

func _ready() -> void:
	hide()
	
func _on_retry_pressed() ->  void:
	get_tree().paused = false;
	get_tree().reload_current_scene()	

func _on_quit_pressed():
	get_tree().quit()

func game_over():
	show()
	get_tree().paused = true
	
