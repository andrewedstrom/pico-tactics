pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
local c_x = 3
local c_y = 4
local t = 0
local move_opt
local selected
local board_w=8
local board_h=8
local entities
local teams={"player", "cpu"}
local current_team
local game_over

function _init()
	move_opt = new_board()
	entities = new_board()
	current_team=1
	game_over = false

	make_knight(4,4)
	make_knight(4,5)
	make_ghost(4,6)
	make_ghost(5,6)
end

function _update60()
	t += 1 --todo is there something built in for this?
	handle_input()
end

function handle_input()
	if (btnp(0)) c_x -= 1
	if (btnp(1)) c_x += 1
	if (btnp(2)) c_y -= 1
	if (btnp(3)) c_y += 1
	c_x = mid(1, c_x, 8)
	c_y = mid(1, c_y, 8)
	if btnp(❎) then
		local selected_changed = handle_entity_selection()
		if not selected_changed then
			if move_opt[c_x][c_y] and not entities[c_x][c_y] then
				--move
				entities[selected.x][selected.y] = false
				selected.x = c_x
				selected.y = c_y
				entities[c_x][c_y] = selected
				selected.has_moved = true
				check_turn_end()
				check_game_over()
				selected = nil
				move_opt = new_board()
			else
				--deselect
				selected = nil
				move_opt = new_board()
			end
		end
	end
end

function handle_entity_selection()
	local selected_changed = false
	forall_entites(function(e)
		if c_x==e.x and c_y==e.y and not selected_changed then
			if e.has_moved and not e:is_selected() then
				sfx(1)
				return
			end
			--if cursor is on an entity
			if selected then
				if not e:is_selected() and move_opt[e.x][e.y] and e.team != selected.team then
					-- attack
					sfx(0)
					e:lose_health(selected.power)

					--cursor teleports back to selected sprite
					c_x=selected.x
					c_y=selected.y
					selected.has_moved=true
					check_turn_end()
					check_game_over()

				end

				-- deselect
				selected = nil
				move_opt = new_board()
			elseif e.team == current_team then
				selected=e
				e:move_opt()
			else
				-- can't select this
				return
			end
			selected_changed=true
		end
	end)
	return selected_changed
end

function check_turn_end()
	local current_team_is_done = true
	forall_entites(function(e)
		if e.team == current_team and not e.has_moved then
			current_team_is_done = false
		end
	end)
	if current_team_is_done then
		forall_entites(function(e)
			e.has_moved = false
		end)
		current_team = current_team % #teams + 1
	end
end

function check_game_over()
	-- check if game over
	local i
	for i = 1, 2 do
		local entities_left_on_team = 0
		forall_entites(function(e)
			if e.team == i then
				entities_left_on_team+=1
			end
		end)
		if entities_left_on_team == 0 then
			game_over = true
		end
	end
end

function _draw()
	cls()
	local row,col
	for row=1,board_w do
		for col=1,board_h do
			local colr=move_opt[row][col] and 11 or 3
			local x = row*8
			local y = col*8

			if c_x == row and c_y == col then
				rect(x-1,y-1,x+7,y+7,1)
			end

			rectfill(x, y, x + 6, y + 6, colr)
		end
	end

	forall_entites(function(e)
		e:draw()
	end)

	draw_cursor()
	draw_hud()
	rect(0,0,127,127,13)

end

function draw_cursor()
	local c_s=2
	local ta = t % 48
	if (ta >= 6 and ta < 12) or
			(ta >= 36  and ta < 42) then
		c_s=3
	elseif ta >= 12 and ta <= 36 then
		c_s=4
	end

	spr(c_s, c_x * 8+3, c_y * 8+3)
end

function draw_hud()
	-- selected
	local x, y = 4, 80
	-- if selected then
	-- 	char_preview(entities[selected.x][selected.y], "selected", x, y)
	-- end
	local whose_turn = teams[current_team].."'s turn"
	print(whose_turn, 64 - #whose_turn * 2, 2, 7)

	if game_over then
		print("game over",60,90,7)
	end

	-- cursor
	local e = entities[c_x][c_y]
	if e then
		if not selected then
			char_preview(e, "select?", x, y)
		elseif not e:is_selected() and move_opt[e.x][e.y] then
			-- could attack
			-- x = 127 - 37
			-- char_preview(e, "attack? ", x, y)
			rect(x-3,y-3,127,y+18,7)

			x = print("attack ", x, y, 7)
			spr(e.s, x, y)

			for i = -1,e.health-2 do
				print("\135",x+6*i,y+10,8)
			end

			x = print(" with ", x+9, y, 7)
			local sel = entities[selected.x][selected.y]
			spr(sel.s, x, y)
			for i = -1,sel.health-2 do
				print("\135",x+6*i,y+10,8)
			end
			print(" ?",x+9,y,7)
		end
	end
end

function char_preview(e, text, x, y)
	rect(x-3,y-3,x+36,y+18,7)
	print(text, x, y, 7)
	spr(e.s,x,y+8)
	local i
	for i = 1,e.health do
		print("\135",x+4+6*i,y+8,8)
	end
end

-- function print_in_box(message)
-- 	print("\x8f", x, 0, 7) -- we use the top half of the diamond symbol as the pointy part of the height box
--     print_in_box(distance_from_ground .. "ft", x + 4, 6, 7, 0)
-- end

-->8
--utils

-- makes a new, empty, map-size
-- grid
function new_board(def)
	def = def or false
	b = {}
	for row = 1, board_w do
		b[row] = {}
		for col = 1, board_h do
			b[row][col] = false
		end
	end
	return b
end

function forall_entites(callback)
	for row=1, board_w do
		for col=1, board_h do
			local e = entities[row][col]
			if e then
				callback(e)
			end
		end
	end
end
-->8
--entities

function make_entity(kind,team,x,y,health,props)
	local e = {
		kind = kind,
		x = x,
		y = y,
		power = 1,
		max_health=3,
		health = health,
		has_moved=false,
		team = team,
		draw = function()
		end,
		update = function()
		end,
		draw_shadow = function(self)
			spr(18,self.x*8,self.y*8)
		end,
		lose_health = function(self, amt)
			self.health -= amt
			if self.health <= 0 then
				--die
				entities[self.x][self.y] = false
			end
		end,
		move_opt=function(self)
			--todo improve this shit
			--todo make dependent on range
			if self.x > 1 then
				move_opt[self.x-1][self.y]=true
			end
			if self.x < board_w then
				move_opt[self.x+1][self.y]=true
			end
			if self.y > 1 then
				move_opt[self.x][self.y-1]=true
			end
			if self.y < board_h then
				move_opt[self.x][self.y+1]=true
			end
		end,
		is_selected=function(self)
			return selected and selected.x==self.x and selected.y==self.y
		end
	}

	-- add aditional object properties
	for k, v in pairs(props) do
		e[k] = v
	end

	entities[x][y] = e
	return e
end

function make_knight(x,y)
	make_entity("knight", 1, x, y, 3, {
		x = x,
		y = y,
		s = 16,
		draw = function(self)
			local s = self.s
			local y_o = 0
			if self:is_selected() then
				y_o=1
			elseif t % 40 > 20 then
				s = 17
			end
			self:draw_shadow()
			if self.has_moved then
				pal(12, 13)
				pal(1, 0)
				pal(5, 1)
				pal(4, 2)
				pal(9, 4)
				pal(15, 9)
			end
			spr(s,self.x * 8, self.y * 8 - y_o - 1)
			pal()
		end
	})
end

function make_ghost(x,y)
	make_entity("ghost", 2, x, y, 1, {
		s = 19,
		draw = function(self)
			local y_o = 0
			if t % 40 > 20 then
				y_o = 1
			end
			local x, y = self.x * 8, self.y * 8 - y_o - 1
			if self.has_moved then
				pal(7, 13)
			end
			spr(self.s, x, y)
			pal()
		end
	})
end

__gfx__
00000000770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000070000000000000000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000111110017771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000001111100177710017711000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000001777100177110017171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000001771100171710011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000070001717100111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000770001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550060000000000000000007777004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555060005500600000000000777704000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05151060055550600000000000717104000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05fff050051510600000000070777704000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccc4f005fff0500111100007771774000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcccc0404cccc4f01111110000777707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05565000f55650400111100070777004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04004000040040000000000007770004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002705027050270502705027050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4b0100000a5500a550095500653004530005200654000520005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
