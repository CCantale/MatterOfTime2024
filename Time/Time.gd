extends CharacterBody2D

const dir = preload("res://Scripts/enumDirections.gd")

signal is_moving(position : Vector2, tileLength : int, direction : int)
signal is_jumping(currentPosition, jumpLength, direction, is_a_jump)
signal died()
signal entered_door(position: Vector2)
signal entered_camera_tile()

const INITIAL_POSITION = Vector2(320, 320)

@export var cutscene_is_running: bool

var MAX_SAND = 5
var sand: int
var step : int
var isCollecting: bool
var stepped_on_tile: bool
var last_arrow_key_pressed: int

func _ready():
	var defaultFrame : Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0)
	self.step = defaultFrame.get_width()
	
func reset():
	self.position = INITIAL_POSITION
	self.sand = MAX_SAND
	self.isCollecting = false
	#This one prevents the character to trigger actions multiple times
	#when many special tiles are stacked in the same place
	self.stepped_on_tile = false
	self.cutscene_is_running = false
	
func _process(_delta):
	checkIfMoving()

func checkIfMoving():
	var inputReceived = true
	var direction = -1
	
	if (self.cutscene_is_running):
		return
	if Input.is_action_just_pressed("ui_up"):
		direction = dir.UP
	elif Input.is_action_just_pressed("ui_down"):
		direction = dir.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		direction = dir.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		direction = dir.RIGHT
	else:
		inputReceived = false
	if (inputReceived == true):
		last_arrow_key_pressed = direction
		self.stepped_on_tile = false
		is_moving.emit(self.position, self.step, direction, false)

func move(destination: Vector2, is_a_jump: bool):
	self.position = destination
	if (is_a_jump == false):
		decreaseSand()
	isCollecting = false
	#debug position print
	print("time pos: ", self.position)

func decreaseSand():
	self.sand -= 1
	if (self.sand < 0):
		self.sand = 0
	if (self.sand == 0):
		await get_tree().create_timer(0.1).timeout
		if (isCollecting == false):
			died.emit()

func flip():
	isCollecting = true
	self.sand = MAX_SAND - self.sand

func enterDoor():
	isCollecting = true
	self.sand = MAX_SAND
	
func jump() -> void:
	self.stepped_on_tile = false
	is_moving.emit(self.position, self.step * 2, self.last_arrow_key_pressed, true)


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if (body is TileMap and self.stepped_on_tile == false):
		var tileMap = body
		var tileCoordinates = body.get_coords_for_body_rid(body_rid)
		for layer in tileMap.get_layers_count():
			var tileData = tileMap.get_cell_tile_data(layer, tileCoordinates)
			if (!tileData):
				continue
			self.stepped_on_tile = true
			var tileType: StringName = tileData.get_custom_data_by_layer_id(0)
			if (tileType == "flipper"):
				#replace the tile with an empty tile
				tileMap.set_cell(layer, tileCoordinates, 0, Vector2i(1, 0), 3)
				flip()
			if (tileType == "door"):
				enterDoor()
			if (tileType == "jumper"):
				jump()
			if (tileType == "hidden_camera"):
				entered_camera_tile.emit()
