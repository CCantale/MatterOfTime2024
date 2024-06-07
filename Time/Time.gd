extends CharacterBody2D

const dir = preload("res://Global/enumDirections.gd")
var step : int = 0

signal is_moving(position : Vector2, tileLength : int, direction : int)

var MAX_SAND = 5
var sand = MAX_SAND

func _ready():
	var defaultFrame : Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0)
	self.step = defaultFrame.get_width()
	
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
			
func decreaseSand():
	self.sand -= 1
	if (self.sand == 0):
		get_tree().quit()
		
func flip():
	self.sand = MAX_SAND - self.sand
	
	

func _on_flipper_body_entered(body):
	flip()
