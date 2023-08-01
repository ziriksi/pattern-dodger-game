pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- pattern dodger game

local menu_selected=0
local game={
	playing=false,
	bullet_count=30,
	bullet_speed=1,
	bullet_size=2,
	bullet_color=8,
	to_win=50
}
local player
local bullets={}
local bw={0,7}

function start_game()
	cls()
	new_player()
	game.playing=true
	game.to_win=50
	for i=1,game.bullet_count do
		new_bullet(
			cos(i/game.bullet_count)
			*game.bullet_speed,
			sin(i/game.bullet_count)
			*game.bullet_speed
			+game.bullet_speed
		)
	end
end

function _init()
	
end

function _update()
	if game.playing then
		update_player()
		update_bullets()
		if btnp(🅾️) and peek2(0x5f28)==128 then
			camera(0,0)
			sfx(0)
			game.playing=false
		end
	else
		-- menu
		if btnp(⬇️) then
			menu_selected=min(menu_selected+1,2)
			sfx(0)
		end
		if btnp(⬆️) then
		 menu_selected=max(menu_selected-1,0)
	  sfx(0)
	 end
	
		if btnp(➡️) then
			game[
				({
					"bullet_count",
					"bullet_speed",
					"bullet_size"
				})[menu_selected+1]
			]+=({10,0.5,1})[menu_selected+1]
			rectfill(67,13+menu_selected*13,83,25+menu_selected*13,11)
			sfx(0)
		end
		if btnp(⬅️) then
			game[
				({
					"bullet_count",
					"bullet_speed",
					"bullet_size"
				})[menu_selected+1]
			]-=({10,0.5,1})[menu_selected+1]
			rectfill(67,13+menu_selected*13,83,25+menu_selected*13,8)
		 sfx(0)
		end
		
		if btnp(🅾️) then
			local temp={bw[1],bw[2]}
			bw[1]=temp[2]
			bw[2]=temp[1]
			sfx(0)
		end
		
		if btnp(❎) then
			start_game()
			sfx(0)
		end
		game.bullet_count=mid(game.bullet_count,20,100)
		game.bullet_size=mid(game.bullet_size,1,5)
		game.bullet_speed=mid(round(game.bullet_speed*10)/10,0.5,5)
		
	end
end

function _draw()
	if game.playing then
		for i=1,5000 do
			pset(peek2(0x5f28)+rnd()*128,rnd()*128,bw[1])
		end
		circ(64,64,61,bw[2])
		
		-- draw bullets
		for i=1,#bullets do
			local b=bullets[i]
			if(b.cooldown==0) circfill(b.x,b.y,game.bullet_size,game.bullet_color)
		end
		
		-- draw player
		circfill(player.x,player.y,2,(player.dash>0 and 12 or bw[2]))
		
		local score_str=sub(tostr(player.score),0,4)
		if(score_str[4]==".") score_str=sub(score_str,0,3)
		score_str..=({"","k","m","b","t","q"})[player.score_suffix]
		print("score\n"..score_str,2,115,bw[2])
		print("to win\n",2,2,bw[2])
		print(game.to_win,2,9,game.bullet_color)
		
		rectfill(122,2,125,27,2)
		rectfill(122,2,125,2+player.life,8)
		
		-- results
		print("base score: "..player.base_score_str,138,10,bw[2])
		print("win multiplier: 5x",138,20,bw[2])
		if player.life<=0 then
			print("x",133,20,8)
		end
		print("perfect multiplier: 50x",138,30,bw[2])
		if player.life!=25 then
			print("x",133,30,8)
		end
		
		print("total: "..score_str,138,50,bw[2])
		print("press 🅾️ to continue",138,60,bw[2])
	else
		-- menu
		for i=1,4000 do
			pset(rnd()*128,rnd()*128,bw[1])
		end
		
		palt(1,true)
		palt(0,false)
		
		print("settings",2,2,bw[2])
		line(0,12,128,6)
		
		print("bullet count",2,17,bw[2])
		print_center(tostr(game.bullet_count),76,17,bw[2])
		print("points",100,17)
		spr(1,55,15)
		spr(2,89,15)
		
		print("bullet speed",2,30,bw[2])
		print_center(tostr(game.bullet_speed),76,30,bw[2])
		print((game.bullet_speed^2).."x",100,30)
		spr(1,55,28)
		spr(2,89,28)
		
		print("bullet size",2,43,bw[2])
		print_center(tostr(game.bullet_size),76,43,bw[2])
		print((game.bullet_size/2).."x",100,43)
		spr(1,55,41)
		spr(2,89,41)
		
		rect(67,13+menu_selected*13,83,25+menu_selected*13)
		
		line(0,52,128,58)
		
		print("use arrow keys to dodge the\nbullets. press ❎ to dash\nthrough them. you get points by\ngetting close to bullets. you\nget point bonuses for surviving\nlong enough and for taking no\nhits.",2,60,bw[2])
		print("press 🅾️ to swtich between\nlight and dark mode\npress ❎ to start",2,109,bw[2])
	end
end

-->8
-- bullets

function new_bullet(vx,vy)
	if(vx==0 and vy==0) return
	bullets[#bullets+1]={
		x=64,
		y=4,
		vx=vx,
		vy=vy,
		cooldown=0
	}
end

function bounce(b)
	-- before optimization
	--[[
	local speed=sqrt(b.vx^2+b.vy^2)
	local angle_go=atan2(b.vy,b.vx)
	local angle_hit=atan2(
		b.y-64,b.x-64
	)
	local diff=angle_go-angle_hit
	
	b.vx=sin(inv(angle_go-diff*2))*speed
	b.vy=cos(inv(angle_go-diff*2))*speed
	
	b.x+=b.vx
	b.y+=b.vy
	b.bounced=true
	]]--
	local speed=sqrt(b.vx^2+b.vy^2)
	local new_angle=inv(atan2(b.y-64,b.x-64)*2-atan2(b.vy,b.vx))
	b.vx=sin(new_angle)*speed
	b.vy=cos(new_angle)*speed
	
	b.x+=b.vx*2
	b.y+=b.vy*2
	b.bounced=true
end

function update_bullets()
	local bounced=false
	
	for i=1,#bullets do
		local b=bullets[i]
		b.x+=b.vx
		b.y+=b.vy
		b.bounced=false

		if sqrt((b.x-64)^2+(b.y-64)^2)>61 then
			bounce(b)
			bounced=true
		end
		
		if b.cooldown>0 then
			b.cooldown-=1
		end
	end
	
	-- time bounces together
	if bounced then
		game.bullet_color+=1
		game.to_win-=1
		sfx(1)
		if(game.bullet_color>14) game.bullet_color=8
		for i=1,#bullets do
			local b=bullets[i]
			if not b.bounced then
				while sqrt((b.x-64)^2+(b.y-64)^2)>61 do
					b.x+=b.vx
					b.y+=b.vy
				end
				bounce(b)
			end
		end
	end
	if player.life<=0 or game.to_win==0 then
		game.to_win=-1
		bullets={}
	
		local score_str=sub(tostr(player.score),0,4)
		if(score_str[4]==".") score_str=sub(score_str,0,3)
		score_str..=({"","k","m","b","t","q"})[player.score_suffix]
		player.base_score_str=score_str
		
		player.score*=(player.life>0 and 5 or 1)
		player.score*=(player.life==25 and 50 or 1)
		camera(128,0)
	end
end

-->8
-- math

function inv(angle)
	return (angle+0.5)%1
end

function lerp(x1,x2,n)
	if x1<x2 then
		return x1+(x2-x1)*n
	elseif x1>x2 then
		return x2+(x1-x2)*n
	else
		return x1
	end
end

function print_center(text,x,y,col)
	print(text,x-#text*2,y,col)
end

function round(x)
	return x%1>0.5 and ceil(x) or flr(x)
end

-->8
-- player
function new_player()
	player={
		x=64,
		y=116,
		vx=0,
		vy=0,
		dash=-50,
		score=0,
		score_suffix=1,
		life=25,
		base_score_str=""
	}
end

function update_player()
	local controls={
		{⬇️,0,1},
		{⬆️,0,-1},
		{⬅️,-1,0},
		{➡️,1,0}
	}
	for i=1,4 do
		local bind=controls[i]
		if btn(bind[1]) then
			player.vx+=bind[2]*2
			player.vy+=bind[3]*2
		end
	end
	
	player.dash-=1
	if btnp(❎) and player.dash<-20 then
		player.dash=4
	end
	
	player.vx=mid(player.vx,-4,4)
	player.vy=mid(player.vy,-4,4)
	
	if player.vx!=0 and not (btnp(⬇️) or btnp(⬆️)) then
		player.vx-=player.vx/abs(player.vx)
	end
	if player.vy!=0 and not (btnp(⬅️) or btnp(➡️)) then
		player.vy-=player.vy/abs(player.vy)
	end
	
	player.x+=player.vx*(player.dash>0 and 2.5 or 1)
	player.y+=player.vy*(player.dash>0 and 2.5 or 1)
	
	while sqrt((player.x-64)^2+(player.y-64)^2)>60 do
		local angle=atan2(
			player.y-64,player.x-64
		)+0.25
		player.x-=cos(angle)
		player.y+=sin(angle)
	end
	
	-- bullet interactions
	for i=1,#bullets do
	 local b=bullets[i]
	 local dist=sqrt((player.x-b.x)^2+(player.y-b.y)^2)-game.bullet_size*1.1
		if b.cooldown==0
		and (player.dash<0 or not (player.vx!=0 or player.vy!=0))
		and dist<2 then
			player.life-=1
			sfx(2)
			b.cooldown=15
			rectfill(0,0,128,128,game.bullet_color)
			circfill(b.x,b.y,10,bw[2])
		end
		local score=
		max((100-dist*10)/100
		*(game.bullet_speed^2)
		*game.bullet_size
		,0)
		for i=1,player.score_suffix-1 do
			score/=1000
		end
		player.score+=score
	end
	if player.score>1000 then
		player.score/=1000
		player.score_suffix+=1
	end
end

__gfx__
00000000111117777771111117777771177777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111770077007711170000007700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007001770080770f0077170fffd0770aaab070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700070ff880770f8880770fdd50770abb3070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000708882077082220770fdd50770abb3070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700177002077020077170d5550770b333070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111770077007711170000007700000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111117777771111117777771177777710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400001f5502450021550275502b5001d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002f35029450294402943029430294202941029410000003f3003f3003f3003f3003f3003f3003f3003f3002a4002a4002a4002a4000000000000000000000000000000000000000000000000000000000
000300000b0500f070130700f0500c0400b0300b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
