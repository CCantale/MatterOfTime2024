extends Node2D

const dir = preload("res://Scripts/enumDirections.gd")
const cam = preload("res://Scripts/cameraMovements.gd")

const INITIAL_CAMERA_POSITION = Vector2(702.74, 246.141)
const INITIAL_CAMERA_ZOOM = 1.7

@export var timeCanMove = true

var obstacles: Array[Vector2i] = []
var timeLastPosition : Vector2

func _ready():
	var obstaclesLayer : int
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	for layerID in $TileMap.get_layers_count():
		if ($TileMap.get_layer_name(layerID) == "Obstacles"):
			obstaclesLayer = layerID
	self.obstacles = $TileMap.get_used_cells(obstaclesLayer)
	reset()

func reset():
	$Time.reset()
	$TileMap.reset()
	$Time/RemoteTransform2D.remote_path = ""
	if ($cameraAnimation.is_playing()):
		$cameraAnimation.stop()
	$Camera2D.position = INITIAL_CAMERA_POSITION
	$Camera2D.zoom.x = INITIAL_CAMERA_ZOOM
	$Camera2D.zoom.y = INITIAL_CAMERA_ZOOM

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	#print("camera pos: ", $Camera2D.position)

func moveCamera():
	var animationName: String
	
	if (cam.povCamera.has(timeLastPosition)):
		handlePovCamera(cam.povCamera[timeLastPosition])
		return
	$Time/RemoteTransform2D.remote_path = ""
	if (!cam.cameraMovements.has(timeLastPosition)):
		return
	animationName = self.cam.cameraMovements[timeLastPosition]
	$cameraAnimation.play(animationName)
	#To check that the animation called is the right one
	#print(animationName)

func handlePovCamera(animationName: String):
	var remoteTransform = $Time/RemoteTransform2D
	
	$cameraAnimation.play(animationName)
	await $cameraAnimation.animation_finished
	remoteTransform.remote_path = "../../Camera2D"
	
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
	#prints camera position at every step
	#print("camera", $Camera2D.position)

func _on_time_died():
	reset()

func _on_time_entered_camera_tile():
	moveCamera()
