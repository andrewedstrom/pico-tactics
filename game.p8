pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
local c_x = 3
local c_y = 4
local t = 0
local k
local move_opt
local board_w=8
local board_h=8

function _init()
	clear_move_opt()

 k={
 	x=4,
 	y=5,
 	selected=false,
 	draw=function(self)
 		local s = 16
 		if t % 30 > 15 then
 			s = 17
			end
			local y_o = 0
			if (self.selected) then
				y_o=1
			end
			spr(18,self.x*8,self.y*8)
 		spr(s,self.x*8,self.y*8-y_o)
 	end,
 	on_select=function(self)
 		self.selected= not self.selected
 		if self.selected then
 			move_opt[self.x][self.y]=true
 			move_opt[self.x-1][self.y]=true
 			move_opt[self.x+1][self.y]=true
	 		move_opt[self.x][self.y-1]=true
	 		move_opt[self.x][self.y+1]=true
			else
				clear_move_opt()
 		end
 	end
 }
end

function _update60()
	t += 1
	if (btnp(0)) c_x -= 1
	if (btnp(1)) c_x += 1
	if (btnp(2)) c_y -= 1
	if (btnp(3)) c_y += 1
	c_x = mid(1, c_x, 8)
	c_y = mid(1, c_y, 8)
	if btnp(❎) and c_x==k.x and c_y==k.y then
		k:on_select()
	end
	
end

function _draw()
	cls()
	local row,col
	for row=1,board_w do
		for col=1,board_h do
			local colr=(k.selected and move_opt[row][col] and 11) or 3
			rectfill(row * 8, col * 8, row * 8 + 6, col * 8 + 6, colr)
		end
	end	
	
	k:draw()

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

function clear_move_opt()
	move_opt={}
	for row=1,8 do
		move_opt[row]={}
		for col=1,8 do
			move_opt[row][col]=false
		end
	end	
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