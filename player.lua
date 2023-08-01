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
