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
