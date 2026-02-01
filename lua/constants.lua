MAP_W = 16
MAP_H = 16

-- Setup on init_objects()
MAP_W_MIN = 0 -- 0,16,32,48...
MAP_W_MAX = 0 -- 15,31,47...
MAP_H_MIN = 0 -- 0,16,32,48...
MAP_H_MAX = 0 -- 15,31,47...


TILE = 8

current_targets_destroyed = 0

MaskColor1 = 2
MaskColor2 = 7

collision_flags = { 0, 1 }

shadow_len = 1024

mask_pallets = {
    [0] = { 0, 7 },
    [1] = { 3, 4 },
    [2] = { 1, 13 },
    [3] = { 13, 15 },
    [4] = { 1, 6 },
    [5] = { 2, 3 },
    [6] = { 5, 10 },
    [7] = { 1, 9 },
    [8] = { 12, 4 }
}