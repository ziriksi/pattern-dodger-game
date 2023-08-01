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
