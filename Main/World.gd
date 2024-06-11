extends Node2D

const dir = preload("res://Scripts/enumDirections.gd")
const cam = preload("res://Scripts/cameraMovements.gd")

const INITIAL_CAMERA_POSITION = Vector2(702.74, 346.141)
const INITIAL_CAMERA_ZOOM = 1.7
var obstacles: Array[Vector2i] = []
var timeCanMove = true
var timeLastPosition : Vector2

func _ready():
	var obstaclesLayer : int
	
	for layerID in $TileMap.get_layers_count():
		if ($TileMap.get_layer_name(layerID) == "Obstacles"):
			obstaclesLayer = layerID
	self.obstacles = $TileMap.get_used_cells(obstaclesLayer)
	reset()

func reset():
	$Time.reset()
	$TileMap.reset()
	#$Camera2D.position = INITIAL_CAMERA_POSITION
	$Time/Camera2D.zoom.x = INITIAL_CAMERA_ZOOM
	$Time/Camera2D.zoom.y = INITIAL_CAMERA_ZOOM

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func moveCamera(timePosition: Vector2):
	if (!cam.cameraMovements.has(timePosition)):
		return
	var animationName = self.cam.cameraMovements[timePosition]
	
	if ($cameraAnimation.current_animation == self.cam.playForward[animationName]):
		$cameraAnimation.play(animationName)
	else:
		$cameraAnimation.play_backwards(animationName)

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
	elif (Vector2i(destination) == $TileMap.local_to_map(timeLastPosition)):
		timeCanMove = false
		print("Time never walks backwards!")
	else:
		timeLastPosition = timePosition
		timeCanMove = true

func _on_time_died():
	reset()


func _on_time_entered_door(timePosition: Vector2):
	moveCamera(timePosition)
