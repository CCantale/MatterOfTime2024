extends TileMap

var collectibles: Array[Vector2i] = []
var collectiblesLayer: int
var cameras: Array[Vector2i] = []
var cameraLayer: int

const filpperSourceId = 0
const flipperCoordinates = Vector2i(1, 0)
const flipperAlternativeTile = 0

const hiddenCameraSourceId = 1
const hiddenCameraCoordinates = Vector2i(0, 0)
const hiddenCameraAlternativeTile = 1

func _ready():
	var tileData: TileData
	var tileType: StringName
	
	for layerID in self.get_layers_count():
		if (self.get_layer_name(layerID) == "Collectibles"):
			collectiblesLayer = layerID
		elif (self.get_layer_name(layerID) == "Camera"):
			cameraLayer = layerID
	self.collectibles = self.get_used_cells(collectiblesLayer)
	self.cameras = self.get_used_cells(cameraLayer)
	for cell in cameras:
		tileData = self.get_cell_tile_data(cameraLayer, cell)
		if (!tileData):
			continue
		#custom data layer, not tileMap layer
		tileType = tileData.get_custom_data_by_layer_id(0)
		if (tileType == "camera"):
			self.set_cell(cameraLayer, cell,
							self.hiddenCameraSourceId,
							self.hiddenCameraCoordinates,
							self.hiddenCameraAlternativeTile)

func reset():
	var tileData: TileData
	var tileType: StringName
	
	for cell in collectibles:
		tileData = self.get_cell_tile_data(collectiblesLayer, cell)
		if (!tileData):
			continue
		#custom data layer, not tileMap layer
		tileType = tileData.get_custom_data_by_layer_id(0)
		if (tileType == "blank"):
			self.set_cell(collectiblesLayer, cell,
								self.filpperSourceId,
								self.flipperCoordinates,
								self.flipperAlternativeTile)
