extends Area2D

@export var next_scene_path: String = "res://scenes/level_1.tscn"
@onready var exit_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var fade: CanvasLayer = $Fade
@onready var fade_rect: ColorRect = $Fade/FadeRect
var used = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node):
	if used:
		return
	if not body.is_in_group("Player"):
		return

	used = true
	exit_audio.play()
	var tween = create_tween()		
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
