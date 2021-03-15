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
-- teams are 1 and 2

function _init()
	move_opt = new_board()
	entities = new_board()

	make_knight(2,4)
	make_knight(5,5)
	make_ghost(7,4)
end

function _update60()
	t += 1
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
		local selected_changed=false
		forall_entites(function(e)
			if c_x==e.x and c_y==e.y then
				--if cursor is on an entity
				if selected then
					if not e:is_selected() and move_opt[e.x][e.y] then
						sfx(0)
						e:lose_health(selected.power)
					end

					-- deselect
					selected=nil
					move_opt = new_board()
				else
					selected=e
					e:move_opt()
				end
				selected_changed=true
			end
		end)
		--move
		if not selected_changed then
			if move_opt[c_x][c_y] then
				--move
				entities[selected.x][selected.y] = false
				selected.x=c_x
				selected.y=c_y
				entities[c_x][c_y]=selected
				selected=nil
				move_opt = new_board()
			else
				--deselect
				selected = nil
				move_opt = new_board()
			end
		end
	end
end

function _draw()
	cls()
	local row,col
	for row=1,board_w do
		for col=1,board_h do
			local colr=move_opt[row][col] and 11 or 3
			rectfill(row * 8, col * 8, row * 8 + 6, col * 8 + 6, colr)
		end
	end

	forall_entites(function(e)
		e:draw()
	end)

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
-->8
--utils

-- makes a new, empty, map-size
-- grid
function new_board(def)
	def=def or false
	b={}
	for row=1,board_w do
		b[row]={}
		for col=1,board_h do
			b[row][col]=false
		end
	end
	return b
end

function forall_entites(callback)
	for row=1,board_w do
		for col=1,board_h do
			local e = entities[row][col]
			if e then
				callback(e)
			end
		end
	end
end
-->8
--entities

function make_entity(x,y,health,props)
	local e = {
		kind = kind,
		x = x,
		y = y,
		power = 1,
		a_o = ceil(rnd(15)), -- animation offset
		health = health,
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
		end,
		draw_health=function(self)
			-- print(self.health, self.x * 8 + 2, self.y * 8 - 7, 7)
			local i
			for i = 1,self.health*2,2 do
				pset(self.x * 8 + i,self.y * 8 - 3, 8)
			end
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
	make_entity(x,y,3,{
		x=x,
		y=y,
		draw=function(self)
			local s = 16
			local y_o = 0
			if self:is_selected() then
				y_o=1
			elseif (t + self.a_o) % 30 > 15 then
				s = 17
			end
			self:draw_shadow()
			spr(s,self.x*8,self.y*8-y_o-1)
			self:draw_health()
		end
	})
end

function make_ghost(x,y)
	make_entity(x, y, 3, {
		draw=function(self)
			local s = 19
			local y_o = 0
			if (t + self.a_o) % 30 > 15 then
				y_o=1
			end
			local x, y = self.x*8, self.y*8-y_o-1
			spr(s,x,y)
			self:draw_health()
		end
	})
end

__gfx__
00000000770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000077700007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000777000077000007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000770000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000070000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00550060000000000000000002222004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05999060005500600000000000222204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09191060059990600000000000272704000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04fff050091910600000000020222204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4cccc4f004fff0500111100002227224000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcccc0404cccc4f01111110000222202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05565000f55650400111100020222004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04004000040040000000000002220004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002705027050270502705027050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
