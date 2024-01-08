class_name BoneChainSprite
extends MeshInstance
tool

export(Texture) var atlas: Texture setget set_atlas

export(bool) var add_frame: bool setget set_add_frame
export(Vector3) var frame_vector := Vector3.FORWARD
export(Texture) var frame_texture: Texture
export(Dictionary) var frames := {} setget set_frames

var _directory_texture: ImageTexture

func set_atlas(new_atlas: Texture) -> void:
	if atlas != new_atlas:
		atlas = new_atlas
		atlas_changed()

func set_add_frame(new_add_frame: bool) -> void:
	if new_add_frame:
		frames[frame_vector.normalized()] = frame_texture
		frames_changed()

func set_frames(new_frames: Dictionary) -> void:
	frames.clear()

	for key in new_frames:
		if key is Vector3 and new_frames[key] is Texture:
			frames[key] = new_frames[key]

	frames_changed()

func _init() -> void:
	_directory_texture = ImageTexture.new()
	material_override.set_shader_param("directory", _directory_texture)

func _ready() -> void:
	atlas_changed()
	frames_changed()

func atlas_changed() -> void:
	material_override.set_shader_param("atlas", atlas)

func frames_changed() -> void:
	var frame_count = frames.size()

	var size_image_count = 1
	var size_vectors = frame_count
	var size_rects = frame_count * 2
	var size = size_image_count + size_vectors + size_rects

	var directory_image := Image.new()
	directory_image.create(size, 1, false, Image.FORMAT_RGBF)

	directory_image.lock()

	directory_image.set_pixel(0, 0, Color(frame_count, 0.0, 0.0))

	var keys = frames.keys()
	var key_count = keys.size()
	for i in range(0, keys.size()):
		var vector = keys[i]
		var texture: AtlasTexture = frames[vector]
		var vector_color = Color(vector.x + 1.0, vector.y + 1.0, vector.z + 1.0)
		directory_image.set_pixel(size_image_count + i, 0, vector_color)

		var position_color = Color(texture.region.position.x, texture.region.position.y, 0.0)
		var size_color = Color(texture.region.size.x, texture.region.size.y, 0.0)
		directory_image.set_pixel(size_image_count + size_vectors + (i * 2), 0, position_color)
		directory_image.set_pixel(size_image_count + size_vectors + (i * 2) + 1, 0, size_color)

	directory_image.unlock()

	_directory_texture.create(size, 1, Image.FORMAT_RGBF, 0)
	_directory_texture.set_data(directory_image)

	property_list_changed_notify()
