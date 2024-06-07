extends Node2D

const dir = preload("res://Global/enumDirections.gd")

var obstacles = []
var timeCanMove = true
var timeLastposition : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	var obstaclesLayer : int
	
	for layerID in $TileMap.get_layers_count():
		if ($TileMap.get_layer_name(layerID) == "Obstacles"):
			obstaclesLayer = layerID
	obstacles = $TileMap.get_used_cells(obstaclesLayer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_time_is_moving(timePosition, tileLength, direction):
	var destination : Vector2
	
	if (direction == dir.UP):
		destination = timePosition - Vector2(0, tileLength)
	elif (direction == dir.DOWN):
		destination = timePosition + Vector2(0, tileLength)
	elif (direction == dir.LEFT):
		destination = timePosition - Vector2(tileLength, 0)
	elif (direction == dir.RIGHT):
		destination = timePosition + Vector2(tileLength, 0)
	destination = $TileMap.local_to_map(destination)
	if (obstacles.find(Vector2i(destination)) != -1):
		timeCanMove = false
	elif (Vector2i(destination) == $TileMap.local_to_map(timeLastposition)):
		timeCanMove = false
		print("Time never walks backwards!")
	else:
		timeLastposition = timePosition
		timeCanMove = true
