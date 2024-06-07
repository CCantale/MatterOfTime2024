extends CharacterBody2D

const dir = preload("res://Global/enumDirections.gd")
var step : int = 0
var modX : int = 0
var modY : int = 0

signal is_moving(position : Vector2, tileLength : int, direction : int)

func _ready():
	var defaultFrame : Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0)
	self.step = defaultFrame.get_width()
	
func _process(_delta):
	var inputReceived = true
	var direction = -1
	
	if Input.is_action_just_pressed("ui_up"):
		self.modY = -1 * self.step
		direction = dir.UP
	elif Input.is_action_just_pressed("ui_down"):
		self.modY = self.step
		direction = dir.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		self.modX = -1 * self.step
		direction = dir.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		self.modX = self.step
		direction = dir.RIGHT
	else:
		inputReceived = false
	if (inputReceived == true):
		is_moving.emit(self.position, self.step, direction)
		if (self.get_parent().timeCanMove):
			self.position.x += self.modX
			self.position.y += self.modY
		self.modX = 0
		self.modY = 0
