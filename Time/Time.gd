extends CharacterBody2D

const dir = preload("res://Scripts/enumDirections.gd")

signal is_moving(position : Vector2, tileLength : int, direction : int)
signal died()
signal entered_door(position: Vector2)

const INITIAL_POSITION = Vector2(320, 320)
var MAX_SAND = 5
var sand: int
var step : int
var isCollecting: bool

func _ready():
	var defaultFrame : Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0)
	self.step = defaultFrame.get_width()
	
func reset():
	self.position = INITIAL_POSITION
	self.sand = MAX_SAND
	self.isCollecting = false
	
func _process(_delta):
	checkIfMoving()

func checkIfMoving():
	var inputReceived = true
	var direction = -1
	var modX = 0
	var modY = 0
	
	if Input.is_action_just_pressed("ui_up"):
		modY = -1 * self.step
		direction = dir.UP
	elif Input.is_action_just_pressed("ui_down"):
		modY = self.step
		direction = dir.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		modX = -1 * self.step
		direction = dir.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		modX = self.step
		direction = dir.RIGHT
	else:
		inputReceived = false
	if (inputReceived == true):
		is_moving.emit(self.position, self.step, direction)
		if (self.get_parent().timeCanMove):
			self.position.x += modX
			self.position.y += modY
			decreaseSand()
			isCollecting = false
			print(self.position)

func decreaseSand():
	self.sand -= 1
	if (self.sand == 0):
		await get_tree().create_timer(0.1).timeout
		if (isCollecting == false):
			died.emit()

func flip():
	isCollecting = true
	self.sand = MAX_SAND - self.sand

func _on_flipper_body_entered(_body):
	flip()

func enterDoor():
	isCollecting = true
	self.sand = MAX_SAND
	entered_door.emit(self.position)

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if (body is TileMap):
		var tileMap = body
		var tileCoordinates = body.get_coords_for_body_rid(body_rid)
		for layer in tileMap.get_layers_count():
			var tileData = tileMap.get_cell_tile_data(layer, tileCoordinates)
			if (!tileData):
				continue
			var tileType: StringName = tileData.get_custom_data_by_layer_id(0)
			if (tileType == "flipper"):
				#replace the tile with an empty tile
				tileMap.set_cell(layer, tileCoordinates, 0, Vector2i(1, 0), 3)
				flip()
			elif (tileType == "door"):
				enterDoor()
