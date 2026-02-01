extends Control

@export var player_path: NodePath
@onready var bar: ProgressBar = $"OxygenTank/Oxygen Meter"
@onready var oxygen_warning: Label = $"../Oxygen/Oxygen Warning"

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node(player_path) as CharacterBody2D
	bar.max_value = player.max_oxygen

# Called every frame. 'de	lta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	bar.value = player.oxygen
	if (bar.value <= 0.0):
		oxygen_warning.text = "No Oxygen"
	elif(bar.value <= 35.0):
		oxygen_warning.text = "Low Oxygen"
	else:
		oxygen_warning.text = ""
