extends TileMap

var collectibles: Array[Vector2i] = []
var collectiblesLayer: int

const filpperSourceId = 0
const flipperCoordinates = Vector2i(1, 0)
const flipperAlternativeTile = 0

func _ready():
	for layerID in self.get_layers_count():
		if (self.get_layer_name(layerID) == "Collectibles"):
			collectiblesLayer = layerID
	self.collectibles = self.get_used_cells(collectiblesLayer)

func reset():
	var tileData: TileData
	var tileType: StringName
	
	for cell in collectibles:
		tileData = get_cell_tile_data(collectiblesLayer, cell)
		if (!tileData):
			continue
		#custom data layer, not tileMap layer
		tileType = tileData.get_custom_data_by_layer_id(0)
		if (tileType == "blank"):
			self.set_cell(collectiblesLayer, cell,
								self.filpperSourceId,
								self.flipperCoordinates,
								self.flipperAlternativeTile)
