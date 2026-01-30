in_progress = 0
start_end_game = 1
game_over = 2

left = 0 right = 1 up = 2 down = 3
valid_moves = { left, right, up, down }

map_sand_sprite = 16

MAP_W = 16
MAP_H = 16
TILE  = 8

function _init()
 player = {
  x = flr(rnd(120)),
  y = flr(rnd(114) + 8),
  startsprite = 0,
  endsprite = 1,
  sprite = 0,
  speed = 2,
  stuck = 0,
  w = 8,
  h = 8
 }

 enemy = {
  x = flr(rnd(120)),
  y = flr(rnd(114) + 8),
  startsprite = 4,
  endsprite = 5,
  sprite = 4,
  speed = 0.1,
  stuck = 0,
  w = 8,
  h = 8
 }

 shadow_objects = {} -- array of { outline_pts = { {x,y}, ... } }


 state = in_progress
 score = 0

 init_shadows()
end

function move(unit)
 unit.sprite += 1
 if unit.sprite > unit.endsprite then
  unit.sprite = unit.startsprite
 end
end

function draw_unit(unit)
 spr(unit.sprite, unit.x, unit.y)
end

function get_tile_at(px, py)
 return mget(flr(px / 8), flr(py / 8))
end

function get_map_cell(unit)
 return get_tile_at(unit.x + unit.w / 2, unit.y + unit.h / 2)
end

function hit_house(unit)
 return get_map_cell(unit) == map_sand_sprite
end

function move_unit(unit, direction)
 if hit_house(unit) then
  unit.stuck += 1
  if unit.stuck > 4 then
   unit.stuck = 0
  else
   return
  end
 end

 if direction == left then
  unit.x -= unit.speed
  unit.moving = true
 end
 if direction == right then
  unit.x += unit.speed
  unit.moving = true
 end
 if direction == up then
  unit.y -= unit.speed
  unit.moving = true
 end
 if direction == down then
  unit.y += unit.speed
  unit.moving = true
 end
end

function move_player()
 player.moving = false
 for i = 1, #valid_moves do
  if btn(valid_moves[i]) then
   move_unit(player, valid_moves[i])
  end
 end
 if player.moving then
  move(player)
 else
  player.sprite = player.startsprite
 end
end

function move_enemy()
 if enemy.x > player.x then move_unit(enemy, left) end
 if enemy.x < player.x then move_unit(enemy, right) end
 if enemy.y > player.y then move_unit(enemy, up) end
 if enemy.y < player.y then move_unit(enemy, down) end
 move(enemy)
 enemy.speed += 0.0005
end

function distance(p0, p1)
 local dx = p0.x - p1.x
 local dy = p0.y - p1.y
 return sqrt(dx * dx + dy * dy)
end

function check_game_over()
 if distance(enemy, player) < 7 and state != game_over then
  state = start_end_game
 end
end

function _update()
 move_player()
 move_enemy()
 check_game_over()
end

function _draw()
 cls()
 if state == in_progress then
  map(0, 0, 0, 0, 16, 16)
  draw_unit(player)
  draw_unit(enemy)

  draw_shadows(player)

  score += 1
  print("score: " .. score, 2, 2, 7)
 elseif state == start_end_game then
  sfx(0)
  state = game_over
 elseif state == game_over then
  camera()
  print("\135 game over \135")
  print("your final score was: " .. score)
  print("press action to try again")
  if btn(4) then _init() end
 end
end