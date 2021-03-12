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

function _init()
	move_opt = new_board()
	entities = new_board()

	make_knight(2,4)
	make_knight(5,5)
end

function _update60()
	t += 1
	if (btnp(0)) c_x -= 1
	if (btnp(1)) c_x += 1
	if (btnp(2)) c_y -= 1
	if (btnp(3)) c_y += 1
	c_x = mid(1, c_x, 8)
	c_y = mid(1, c_y, 8)
	if btnp(❎) then
		local new_selection=false
		forall_entites(function(e)
			--selecting
			if c_x==e.x and c_y==e.y then
				if not selected then
					selected=e
					e:move_opt()
				else
					selected=nil
					move_opt = new_board()
				end
				new_selection=true
			end
		end)
		--move
		if not new_selection then
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

function make_knight(x,y)
	entities[x][y] = {
		x=x,
		y=y,
 	draw=function(self)
 		local s = 16
 		if t % 30 > 15 then
 			s = 17
			end
			local y_o = 0
			if selected and selected.x==self.x and selected.y==self.y then
				y_o=1
			end
			spr(18,self.x*8,self.y*8)
 		spr(s,self.x*8,self.y*8-y_o)
 	end,
 	move_opt=function(self)
			--todo improve this shit
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
 	end
 }
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
00550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05999060005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09191060059990600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04fff050091910600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
422224f004fff0500111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5565040455654f01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04004000f40040400111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
