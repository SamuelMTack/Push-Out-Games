class_name Tetromino
extends RefCounted

# Tetromino shapes defined as arrays of Vector2i
# Each shape has 4 rotations.
# The center of rotation is roughly (0,0) or (1,1) depending on the shape, 
# but for simplicity we'll define them relative to a pivot.
# Standard SRS (Super Rotation System) shapes usually fit in a bounding box.
# Here we use a simplified offset model.

const I = {
	"cells": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	"color": Color(0, 1, 1) # Cyan
}

const J = {
	"cells": [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	"color": Color(0, 0, 1) # Blue
}

const L = {
	"cells": [Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	"color": Color(1, 0.64, 0) # Orange
}

const O = {
	"cells": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"color": Color(1, 1, 0) # Yellow
}

const S = {
	"cells": [Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0)],
	"color": Color(0, 1, 0) # Green
}

const T = {
	"cells": [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	"color": Color(0.5, 0, 0.5) # Purple
}

const Z = {
	"cells": [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
	"color": Color(1, 0, 0) # Red
}

const SHAPES = [I, J, L, O, S, T, Z]
