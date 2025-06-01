pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- cattle crisis beta1
-- by lazy devs

-- todo
-------------------

-- nice to have
-- - focus butt doing something when not charged
-- - clean up game start
-- - popcorn on startscreen
-- - achievements
-- - boss dropping cows
-- - do i need bomb range?

-- pre release
-- - cover
-- - cleanup brains
-- - cleanup patterns

function _init()
 debug={}
  
 #include shmup_myspr.txt
 #include shmup_anilib.txt
 #include shmup_enlib.txt
 #include shmup_sched.txt
 #include shmup_mapsegs.txt
 #include shmup_brains.txt
 #include shmup_pats.txt
 
 cartdata("cattle_beta1")
 
 highscore=dget(0)
 recscr=dget(1)
 recx=dget(2)
 unlock=dget(3)
 hitbox=false
 
 menuitem(2,"clear save", function(b)
  if b&32 > 0 then
   highscore,recscr,recx,unlock=0,0,0,0
   for i=0,3 do
    dset(i,0)
   end
   gotomnu()
  end
 end)
 
 
 menuitem(1,"hitbox:off", function(b)
  hitbox = not hitbox
  menuitem(_,hitbox and "hitbox:on" or "hitbox:off")
  return true
 end)
 
 butarr=split "1,2,3,1,4,6,7,4,5,9,8,5,1,2,3,1"
 dirx=split "0,-1,1, 0,0, -0.7, 0.7,0.7,-0.7"
 diry=split "0, 0,0,-1,1, -0.7,-0.7,0.7,0.7"
 
 pal_flash=split "8,8,8,8,8,14,7,14,15,7,7,8,8,14,7"
 pal_wflash=split "7,7,7,7,7,7,7,7,7,7,7,7,7,7,7"
 pal_burn=split "9,9,9,9,9,10,7,10,15,7,7,9,9,10,7"
 pal_popup=split2d "13,7|13,6|4,10|2,9|7,14|9,10|6,7|7,12"
 
 poke(0x5600,unpack(split"6,6,8,0,0,1,0,0,34,34,34,34,0,0,0,0,4,0,0,0,0,0,5,5,0,0,0,0,0,0,0,0,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,0,0,0,0,112,0,0,0,0,0,7,0,112,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,112,112,112,240,224,224,128,0,128,136,156,191,159,143,3,0,63,123,115,243,227,195,67,0,156,220,220,220,221,220,156,0,241,227,225,225,255,127,127,31,238,238,238,238,238,206,142,0,113,112,112,127,63,63,15,0,6,0,6,15,15,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,0,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,14,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,6,6,0,0,0,0,0,0,0,0,0,0,28,54,54,54,62,28,0,0,14,12,12,12,30,30,0,0,30,48,24,12,62,62,0,0,30,48,28,48,62,30,0,0,28,26,26,62,62,24,0,0,62,2,30,48,62,30,0,0,28,6,30,54,62,28,0,0,62,48,24,12,6,6,0,0,28,54,28,54,62,28,0,0,28,54,60,48,60,28,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,15,12,6,0,6,6,0,0,224,252,254,254,158,143,143,0,0,1,3,3,131,131,128,0,6,199,207,207,15,31,31,0,128,255,255,255,30,30,30,0,127,127,127,127,30,30,30,12,15,15,15,15,15,15,15,0,0,240,240,240,240,112,112,0,0,15,15,31,31,0,0,15,15,15,15,14,14,14,142,192,192,192,224,224,224,241,243,31,61,57,56,56,127,127,127,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,15,15,14,14,14,14,14,254,112,240,248,248,120,120,120,251,0,7,7,7,0,0,0,31,254,252,252,112,0,224,240,240,119,123,121,0,199,207,223,159,240,240,240,0,63,255,255,255,30,30,30,0,12,30,158,222,30,30,30,0,0,28,127,127,254,254,254,0,14,207,239,239,251,251,251,0,14,63,63,127,31,31,31,0,15,15,15,15,240,120,120,120,120,120,120,112,156,156,128,128,128,128,128,128,227,227,227,227,251,255,127,63,220,192,222,222,220,156,28,28,255,243,225,99,7,31,63,124,238,224,238,238,206,142,14,206,121,112,49,3,15,31,62,120,15,15,14,14,14,14,6,6,24,24,16,0,0,0,0,0,28,54,54,62,62,54,0,0,30,54,30,54,62,30,0,0,60,6,6,6,62,60,0,0,30,54,54,54,62,30,0,0,62,6,30,6,62,62,0,0,62,6,30,6,6,6,0,0,60,6,54,54,62,60,0,0,54,54,62,62,54,54,0,0,30,12,12,12,30,30,0,0,60,24,24,26,30,12,0,0,54,30,14,30,62,54,0,0,6,6,6,6,62,62,0,0,34,54,62,62,54,54,0,0,50,54,62,62,54,38,0,0,28,54,54,54,62,28,0,0,30,54,62,30,6,6,0,0,28,54,54,54,30,60,0,0,30,54,62,30,54,54,0,0,60,6,28,56,62,30,0,0,30,12,12,12,12,12,0,0,54,54,54,54,62,28,0,0,54,54,54,54,28,8,0,0,34,42,42,42,62,28,0,0,54,54,28,28,54,54,0,0,18,18,30,12,12,12,0,0,62,48,24,12,62,62,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,28,20,62,62,28,0,0"))
 
 fadetable= split2d "131,131,5,5,13,13,13,13,6,6,6,6,6,7,7|1,1,5,5,13,13,13,13,13,6,6,6,6,6,7|2,141,141,134,134,134,134,134,6,6,6,6,6,7,7|3,3,3,3,13,13,13,13,6,6,6,6,6,7,7|4,4,4,134,134,134,143,143,143,15,15,15,15,7,7|5,5,134,134,134,134,134,134,6,6,6,6,6,7,7|6,6,6,6,6,6,6,6,7,7,7,7,7,7,7|7,7,7,7,7,7,7,7,7,7,7,7,7,7,7|8,8,8,142,142,14,14,14,14,14,15,15,15,7,7|9,9,9,10,10,143,143,135,135,15,15,15,15,7,7|10,10,10,135,135,135,135,135,135,15,15,15,7,7,7|11,11,11,11,11,138,138,6,6,6,6,6,6,7,7|12,12,12,12,12,12,6,6,6,6,6,6,7,7,7|13,13,13,13,6,6,6,6,6,6,6,6,7,7,7|14,14,14,14,14,15,15,15,15,15,15,7,7,7,7|15,15,15,15,15,15,15,7,7,7,7,7,7,7,7"
 fadeperc=0
 
 extab=split2d "119,119,167,167,154,169,141,93|119,167,167,154|167,154,169|167,167,154,169,141,93|2,3,4|2,1.5,1.2|1,1,1"
 
 freeze=0
 score=0
 
 released=false
 
 pers=0.85
 shotdmg=0.7
 bombdmg=40
 cutoff=90
 deadzone=8
 
 screen={
  x=0,
  y=0,
  col=split "0,0,144,128,0,0"
 }
 
 
 poke4(0x5f55,0x8180.2080)

 --poke(0x5f55,0x80,0x20,0x80,0x81)

 --poke(0x5f55,0x80)
 --poke(0x5f58,0x81)
 
 cls(0)
 logostr="@ABCDEFG\nHIJKLMNO\nPQRSTUVW\nXYZ[\\]^_\n▮■□⁙⁘‖◀▶"
 for i=2,5 do
  otprint(logostr,2+dirx[i],2+diry[i],7,7)
  otprint(logostr,3+dirx[i],5+diry[i],7,7)
 end 
 otprint(logostr,3,5,1,1)
 otprint(logostr,2,2,7,1)	
 poke4(0x5f55,0x0080.2060)
 
 --poke(0x5f55,0x60,0x20,0x80,0x00)

 --poke(0x5f55,0x60)
 --poke(0x5f58,0)

 
 gotomnu()
end

function gotomnu()
 mnucur=1
 
 mnu1=split2d "start,0|chekpoints,-1"
 chkp=split2d "1-chunkers,459|2-donuts,1007|3-boss,1445"
 mnu2={}
 if unlock==0 then
  mnu1[2]=nil
 else
  for i=1,#chkp do
   if i<=unlock then
    mnu2[i]=chkp[i]
   end
  end
 end
 
 mainmnu=mnu1
 shout=""
 shoutt=0
 
 t=0
 xscroll=0
 scroll=676
 mapsegi=0
 boss=false
 drawui=false
 clouds={}
 cloudt=0
 cursegs={}
 doscroll()

 parts={}
 shots={}
 picks={} 
 buls={}
 pspr=nil
 
 bombrs=-1
 bombrd=-1
 
 enemies={}
 spawnen(8,99,59,23)
 
 _upd=upd_menu
 _drw=drw_menu
end

function startgame(sscr)
 px,py=64,82
 t=0
 --spd=0.1
 
 lastdir,shipspr=0,0
 
 govertime=32000
 coyote=0
 
 shotwait=0
 enemies={}
 
 schedi=1
 
 pspr={
  x=0,
  y=0,
  ry=0,
  age=0,
  ani={3},
  col=myspr[11],
  shads=3,
  shadh=18
 }
 popt,bopt={},{}
 
 invul=0
 inviz=0
 freeze=0
 duck=0
 flashship=false
 
 -- gameplay
 score=0
 lives=2
 
 -- hyper
 hyper=false
 linger=0
 charge=0
 chargemax=400
 chargethrs=200
 nerf=2
 
 hypermult=1.5
 ch_pick=13
 ch_hit=0.3
 hasbomb=false
 
 --scoring
 starval=0
 starcount=0
 hypertally=0
 lastscore=0
 drawui=true
 callwhile=abs
 _upd=upd_game
 _drw=drw_game
 
 music(0)
 
 --★
 --scroll=220
 scroll=sscr
 mapsegi=0
 cursegs={}
 
 --scroll=0
 chkpmode=scroll>0
 for i=1,#sched do
  if sched[i][1]<scroll then
   schedi=i+1
  end
 end
 
 if scroll==0 then
  setupclouds()
  cloudt=270
 end
end

function _draw() 
 _drw()
 pal(0,131,1)
 --★
 cursor(4,16)
 color(7)
 for txt in all(debug) do
  print(txt)
 end
 
 --fading
 if fadeperc>0 then
  fadeperc=max(0,fadeperc-0.05)
  fade()
 end
end

function _update60()
 if slowmo then
  for i=0,60 do
   flip()
  end
 end
 
 if freeze>0 then
  freeze-=1
  callwhile()
  if freeze==0 then
   callback()
  end
 else
  t+=1
  _upd()
 end
end

-->8
--draw

function drw_game()
 camera(-xscroll,0)
 palt(0,false)
 for seg in all(cursegs) do
  map(seg.x,seg.y,0,scroll-seg.o,18,8)
 end
 palt()
 
 drawclouds()
 
 for e in all(enemies) do
  if e.shads>0 then
   drawshad(e)
   if e.beam then
    mspr(cyc(t,anilib[29],3),e.x,e.ry+e.shadh-18)
    clip(0,e.ry,128,e.shadh+1)
    mspr(cyc(t,anilib[10],5),e.x,e.ry+3+e.shadh-(t/2%16))
    clip()
   end
   --circfill(e.x,e.y+16,3,1)
  end
 end
 if pspr then drawshad(pspr) end
 
 -- bomb shadow
 if bombrs>0 then
 	oval2(bombx,bomby+2,bombrs+3,bombrs*pers+2,1)
 	oval2(bombx,bomby+2,bombrd+1,bombrd*pers,1,ovalfill)
 end
  
 for l=1,2 do
	 for e in all(enemies) do
	  if e.layer==l then
		   
		  if e.flash>0 then
		   e.flash-=1
		   pal(pal_flash)
		  end
		  if e.burn and t%12<4 then
		   pal(pal_burn)
		  end
		  
		  if e.opt then
				 for p in all(bopt) do
				  circ(p.x,p.y,8,14)
				 end
				 for p in all(bopt) do
				  drawobj(p)
				 end
			 else
			  drawobj(e)
			 end
  
		  pal()
	  end
	 end
 end

 --shots
 if hyper then
  pal(pal_wflash)  
 end
 for s in all(shots) do
  drawobj(s)  
  --mspr(cyc(s.age,s.ani,s.anis),s.x,s.y)

  if s.delme then
   del(shots,s)
  end
 end
 pal()
 
 for p in all(parts) do
  if p.age and p.age>=0 then
			--animate color
			if p.ctab then
			 p.ctabv=p.ctabv or 0
			 local i=(p.age+p.ctabv)/p.maxage
			 i=mid(1,flr(1+i*#p.ctab),#p.ctab)
			 p.c=p.ctab[i]
			end
   p.draw(p)
  end
 end
 
 -- bomb dome
 if bombrd>0 and bombdme>0 then
  local domesin=sin(bombdme/4)
  local domeh=(1-bombdme)*bombrd*pers
  
 	oval2(bombx,bomby-domeh,bombrd*domesin,bombrd*pers*domesin,7,ovalfill)
 	--oval2(bombx,bomby,bombrd,bombrd*pers,7,ovalfill)
 	if bombdme>0.8 then
	 	clip(0,0,128,bomby)
	 	circfill(bombx,bomby,bombrd,7)
	 	clip()
	 	
	 	--★★★★
	 	--streaks
	 	if bombdme==1 then
		 	for i=1,8 do
		 	 local ang=0.5/8*i-0.29
		 	 local ax=sin(ang)*bombrd
		 	 local ay=cos(ang)*bombrd*pers
		 	 for j in all({0.3,0.6}) do
		 	  clip(ax<0 and bombx+ax+xscroll or bombx+xscroll,
		 	       bomby+ay-j*bombrd,
		 	       abs(ax)+1,
		 	       j*bombrd+2)
		 	  oval2(bombx,bomby+ay/2,ax,bombrd*pers+ay,6)
		 		 fillp(▒) 
		 		 clip()
		 	 end
		 	 fillp()
		 	end
	 	end
 	end

 end

 
 --pickups
 for p in all(picks) do
  if p.magnet then
   line(p.x,p.y,p.x-p.sx*5,p.y-p.sy*5,7)
  end
 
  if p.typ==10 then
   oval2(p.x,p.y,7+sin(time()*4),7+cos(time()*4),7)
  elseif p.typ==37 then
   fillp(▥)
   line(-8,p.y,140,p.y,10)
   fillp()
  end
  
  drawobj(p)
 end
 
 --ship
 local dangerflash=false
 if pspr then
	 if inviz<=0 then
		 if freeze>0 or invul<=0 or (time()*9)%1<0.5 then
		 	pal(14,12)
		  if flashship or coyote>t then
		   pal(pal_wflash)
		  else
		   if hyper then
		    pal(14,rnd({7,6}))
		    fillp(▒)
		    circ(pspr.x,pspr.y+2,11+sin(time()*3)*2,7)
		    fillp()
		    if charge<40 then
		     dangerflash=t%4<2
		    elseif charge<80 then
		     dangerflash=t%8<4
		    end
		    if dangerflash then
		     pal(pal_wflash)
		    end
		   elseif hasbomb and t%8<4 then
		    pal(14,rnd({6,7}))
		   end
		  end
		  
			 for p in all(popt) do
			  drawobj(p)
			 end
			 
			 local fframe=anilib[1][t\3%4+1]
			 for i=-1,2,3 do
			  mspr(fframe,pspr.x+i,py+8)
			 end
			 pal()
		 end
	 else
	  inviz-=1
	 end
	 if hitbox then
	  rectfill(pspr.x,pspr.y,pspr.x+1,pspr.y+1,8)
	 end
 end
 
 -- enemy bullets
 for s in all(buls) do
  drawobj(s)
  --mspr(cyc(s.age,s.ani,s.anis),s.x,s.y)
 end
 
 -- hyper circles
 for h in all(hycirc) do
  oval2(pspr.x,pspr.y,h,h*pers,7)
 end
 
 camera()
 
 --gui
 
 --charge bar
 if drawui then
 
  if boss and boss.hp>0 then
   rectfill(47,3,80,6,1)
   rectfill(48,4,48+31*(boss.hp/boss.maxhp),5,8)
  end
  	 
	 if hasbomb or hyper then
	  rectfill(3,9,32,15,7)
	  rectfill(2,10,33,14,7)
	  print(hyper and "🅾️bomb!" or "🅾️hyper",4,10,t%16<8 and 13 or 6)
	 end 
	 rect(3,2,44,6,7)
	 line(3,7,44,7,13)
	 for i in all({2,45,23}) do
	  mspr(49,i,3)
	 end
	 clip(4,3,charge/chargemax*40,3)
	 local sp=hasbomb and 2 or 8
	 if hyper then
	  sp=-1
	  if dangerflash then
	   pal(6,8)
	   pal(7,14)
	  end
	 end
	 local j=t/sp%6
	 for i=-1,6 do
	  mspr(48,3+i*6+j,3)
	 end
	 pal()
	 clip()
	 
	 poke(0x5f58,0x81)
	 
	 --shoutout
	 if shoutt>0 then
	  shoutt-=1
	  if t%4<3 then
		  jotprint(addspace(shout),64,32,7,13,6,"c")
		 end
	 end
	 
	 --score
	 jotprint(addspace(score),126,2,7,13,6,"r")
	 
	 --lives
	 otprint("웃"..lives,2,119,7,13,6)
	 
	 -- star value 
	 if linger>0 then
	  linger-=1
	  if hyper or t%4<3 then
		  mspr(35,120,21)
		  jotprint(addspace(starval),114,19,10,4,9,"r")
	  end
	 end
	 
	 -- star count 
	 if linger>0 and not hyper then
	  line(100,28,126,28,7)
	  --local txt="★"..starcount
	  --otprint(txt,123-#txt*4,31,7,13)
	  if t%4<3 then
		  jotprint("+"..addspace(hypertally),126,31,7,13,6,"r")
		 end
		 poke(0x5f58,0)
		 local myscr="★"..starcount
	  otprint(myscr,122-#myscr*4,40,7,13)
	 end
	 
	 poke(0x5f58,0)
	 
	 -- score history
	 if lastscore>0 then
	  local txt="+"..tostr(lastscore,0x2)
	  otprint(txt,127-#txt*4,10,7,13)
	 end
 end
 
end

function drw_menu()
 drw_game()
 
 poke(0x5f54,0x80)
 poke(0x5f58,0x81)
 spr(0,31,3,9,6)
 jotprint(addspace(highscore),64,85,7,1,12,"c")
 poke(0x5f54,0)
 poke(0x5f58,0)

 otprint("\^#\#1highscore",48,76,7,1)
 otprint("\^#\#1beta ver1",47,47,7,1)
 
 local mtop=95 
 rectfill(38,mtop,96,mtop+#mainmnu*7+1,1)
 for i=1,#mainmnu do
  local iy=i*7+mtop-5
  if i==mnucur then
   rectfill(39,iy-1,95,iy+5,7)
  end
  print(mainmnu[i][1],40,iy,i==mnucur and 1 or 7)
 end
 
end

function drw_gover()
 cls(1)
 if score==highscore then
  otprint("highscore!",45,58,t%10<5 and 7 or 6,13)
 else
  otprint("score",55,58,7,13)
 end
 poke(0x5f58,0x81)
 jotprint(govert,64,30,7,13,6,"c")
 jotprint(addspace(score) ,64,66,7,13,6,"c")
 poke(0x5f58,0)
end
-->8
--update

function doscroll()
 while #cursegs<1 or scroll>cursegs[#cursegs].o do
  if boss then
   scroll-=64
   for seg in all(cursegs) do
    seg.o-=64
   end
  else
   mapsegi+=1  
  end
  
  local segnum=mapsegs[mapsegi]

  add(cursegs,{
   x=segnum\4*18,
   y=segnum%4*8,
   o=#cursegs<1 and -64 or cursegs[#cursegs].o+64
  })
  if #cursegs>3 then
   deli(cursegs,1)
  end
 end
end

function upd_game()
 --scrolling
 if t%5==0 then
  scroll+=1
  if not chkpmode and scroll==recscr then
   spawnpick(recx,0,1,37)
  end
 end
 
 doscroll()
 
 --spawning
 if schedi<=#sched and sched[schedi][1]<scroll then
  spawnen(unpack(sched[schedi],2))
  schedi+=1
 end
 
 --movement
 local dir=butarr[1+(btn()&0b1111)]
 
 if lastdir!=dir and dir>=5 then
  --anti-cobblestone
  px,py=flr(px)+0.5,flr(py)+0.5
 end
   
 --spd=hyper and 2 or 1.8
 spd=1.8
 
 px=mid(3, px+dirx[dir]*spd,123)
 py=mid(12,py+diry[dir]*spd,120)
 
 local dshipspr=mysgn(dirx[dir])  
 shipspr+=mysgn(dshipspr-shipspr)*0.15
 shipspr=mid(-1,shipspr,1)
 
 lastdir=dir

 xscroll=mid(0,(px-10)/108,1)\-0.0625
 
 pspr.x=flr(px)-xscroll
 pspr.y=flr(py)
 pspr.ry=pspr.y
 pspr.ani[1]=flr(shipspr*2.4+3.5)
 
 --xscroll=mid(0,(px-10)/100,1)*-16
 --2441
 
 --options
 local opta=(pspr.ani[1]-3)*0.04
 local opty,optr=-2,-11
 if hyper then
  opty,optr=-8,-9
  opta=time()
 end
 popt=makeopt(pspr,2,2,
      optr,optr/5,
      0.25+opta,
      opty)
  
 -- gameplay
 dobuls(shots)
 dobuls(buls)
 doenemies()
 dopicks()

 --shooting
 if not hyper and not hasbomb and charge>=chargethrs then
  sfx(60,-1,24,8)
  duck=t+30 
 end
 hasbomb=charge>=chargethrs

 shotframe=false
 if shotwait>0 then
  shotwait-=1
 else
  if btn(❎) then
   shoot() 
  end
 end
 
 if btnp(🅾️) then
  if hyper then
   bomb()
   return
  else
   if coyote>t then
    hyper,coyote=true,0
    bomb()
    return
   elseif hasbomb then
	   hyperon()
	   return
	  end
  end
 end
 
 if bombrd>0 then
  fadebomb()
 end
 if hyper then
  linger=200
  charge-=1
  if charge<=0 then
   coyote=t+30
   hyperoff()
  end
 elseif invul<=0 then
  nerf=mid(2,nerf-0.025,10)
 end
 -- collions
 -- shots vs enemies
 local hashit,dmgmult=false,hyper and hypermult or 1
 for e in all(enemies) do
 	--aura 
 	--★
 	if shotframe then
	 	pspr.col=myspr[12]
			if e.colshot and col2(pspr,e) then
			 e.flash=2
	  	if e.y>deadzone then
	  	 hashit=not hitenemy(e,shotdmg*dmgmult) or hashit
	 	 end   	
	 	end
	 	pspr.col=myspr[11]
 	end
 	
  for s in all(shots) do
   if e.colshot and not s.delme and e.hp>0 and col2(e,s) then
    
    s.delme=true
    
    add(parts,{
			  draw=sprite,
			  x=s.x,
			  y=s.y+4,
			  maxage=5,
			  age=-1,
			  ani=anilib[7]
			 })  
    e.flash=2
    if s.y>deadzone then
     hashit=not hitenemy(e,shotdmg*dmgmult) or hashit
    end   
   end
  end
 end
 if hashit and t>duck then
  sfx(6,3)
 end
 -- ship vs enemies
 if invul<=0 then
	 for e in all(enemies) do
	  if not hyper and e.colship and col2(pspr,e) then
	   die()
	   return
	  end
	 end
	 
	 for b in all(buls) do
	  if col2(pspr,b) then
	   die()
	   return
	  end
	 end
 else
  invul-=1
 end
 
 doparts()
 
 if govertime-t==180 then
  music(30)
 end
 if t>govertime then
  if not chkpmode then
	  recscr=2000
	  dset(1,recscr)
  end
 	gogover "all clear!"
 end

 if not chkpmode and unlock<#chkp and scroll>=chkp[unlock+1][2] then
  unlock+=1
  dset(3,unlock)
		shout,shoutt="checkpoint!",90
 end
end

function upd_menu()
 doenemies()
 if released then
	 if btnp(❎) then
	  if mainmnu[mnucur][2]<0 then
	   mainmnu=mnu2
	   mnucur=1
	  else
	   fadeout()
	   startgame(mainmnu[mnucur][2])
	  end
	 elseif btnp(🅾️) then
	  mainmnu=mnu1
	  mnucur=1
	 end
	 if btnp(⬆️) then
	  mnucur-=1
	 elseif btnp(⬇️) then
	  mnucur+=1
	 end
	 mnucur=mid(1,mnucur,#mainmnu)
 else
  released=not btn(❎) and not btn(🅾️)
 end
end

function upd_gover()
 if released then
	 if btnp(❎) or btnp(🅾️) then
	  fadeout()
	  released=false
	  gotomnu()
	 end
 else
  released=not btn(❎) and not btn(🅾️)
 end
end
-->8
--tools

function mysgn(v) 
 return v==0 and 0 or sgn(v)
end

function rndrange(low,high)
 return flr(rnd(high+1-low)+low)
end

function mspr(si,sx,sy,sudofx)
 local ms,sudofx=myspr[si],sudofx or 0
 local ssx,ssy,ssw,ssh,ox,oy,fx=unpack(ms)
 local fx=fx or 0
 if sudofx==1 then
  fx=fx>=2 and fx or 1-fx
  ox=-ox+ssw-1
 end

 sspr(ssx,ssy,ssw,ssh,sx-ox,sy-oy,ssw,ssh,fx==1)
 if fx>=2 then
  sspr(ssx,ssy,ssw,ssh,sx-ox+ssw-(fx-2),sy-oy,ssw,ssh,true)
 end
 local i=8
 while ms[i] do
  local noi,nox,noy,nfx=unpack(ms,i,i+3)
  nox,noy,nfx=nox or 0,noy or 0,nfx or 0 
  if sudofx==1 then
   nox,nfx=-nox,1-nfx
  end
  mspr(noi,sx+nox,sy+noy,nfx)
  i+=4
 end
end

--★
function msprc(si,sx,sy)
 local _x,_y,_w,_h,_ox,_oy,_fx,_nx=unpack(myspr[si])
 rect(sx-_ox,sy-_oy,sx-_ox+_w-1,sy-_oy+_h-1,rnd({8,14,15}))
end
  
function split2d(s)
 local arr={}
 for v in all(split(s,"|")) do
  add(arr,split(v))
 end
 return arr
end

function col2(oa,ob) 
 local _ax,_ay,_aw,_ah,_aox,_aoy,_afx=unpack(oa.col)
 local _bx,_by,_bw,_bh,_box,_boy,_bfx=unpack(ob.col)
 local a_left=flr(oa.x)-_aox
 local a_top=flr(oa.y)-_aoy
 local a_right=a_left+_aw-1
 local a_bottom=a_top+_ah-1
 
 local b_left=flr(ob.x)-_box
 local b_top=flr(ob.y)-_boy
 local b_right=b_left+_bw-1
 local b_bottom=b_top+_bh-1

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

function cyc(age,arr,anis,ahold)
 local frm=age\(anis or 1)
 return arr[ahold and (mid(1,frm,#arr)) or ((frm-1)%#arr+1)]
end

function drawobj(obj)
 if not obj then return end
 mspr(cyc(obj.age,obj.ani,obj.anis,obj.ahold),obj.x,obj.y)
end

function copylist(org)
 local ret={}
 for k, v in pairs(org) do
  ret[k]=v
 end
 return ret
end

function dist(x1,y1,x2,y2)
 local dx,dy=x2-x1,y2-y1
 return sqrt(dx*dx+dy*dy)
end

function spread(val)
 return (rnd(2)-1)*val
end

function drawshad(obj)
 local ox,oy,ow,oh=obj.x,obj.ry+obj.shadh,obj.shads,obj.shads/1.5
 ovalfill(ox-(ow-1),oy-(oh-1),ox+ow,oy+oh,1)
end

function otprint(txt,x,y,c,c2,c3)
 for i=2,5 do
  print(txt,x+dirx[i],y+diry[i],c2)
 end 
 print(txt,x,y,c)
 if c3 then
  clip(0,y+5,128,1)
  print(txt,x,y,c3)
  clip()
 end
end

function jotprint(txt,x,y,c,c2,c3,just)
 otprint(txt,x-scrlen(txt)/(just=="r" and 1 or 2),y,c,c2,c3)
end

function addspace(n)
 local r,txt="",tostr(n,0x2)
 while #txt>3 do
  r=" "..sub(txt,-3)..r
  txt=sub(txt,1,-4)
 end
 return txt..r
end

function scrlen(txt)
 local arr,m=split(txt,""),0
 for c in all(split("t,i,y")) do
  m+=count(arr,c)
 end
 return #txt*6-count(arr," ")*4-m
end

function fade()
 local i=fadeperc*16
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,7,1)
  else
   pal(c,fadetable[c+1][flr(i+1)],1)
  end
 end
end

function fadeout(spd,_wait)
 local spd,_wait=spd or 0.04,_wait or 0
 repeat
  fadeperc=min(fadeperc+spd,1)
  fade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function wait(_wait)
 for i=1,_wait do
  flip() 
 end
end

function oval2(ox,oy,ow,oh,oc,func)
 local func=func or oval
 func(ox-ow,oy-oh,ox+ow,oy+oh,oc)
end

function suckin()
 for p in all(picks) do
  if p.typ!=37 then
   p.magnet=true
  end
 end
end

function gogover(txt)
	govert=txt
	released=false
	fadeout()
	_upd=upd_gover
	_drw=drw_gover
	dset(1,recscr)
	dset(2,recx)
	if score>highscore then
	 highscore=score
	 dset(0,score)
	end
end
-->8
--gameplay

function hitenemy(e,dmg,bomb)
 e.hp-=dmg
 e.flash=2
 charge=min(chargemax,charge+ch_hit)
 
 if e.hp<=0 then
  local d=dist(e.x,e.y,pspr.x,pspr.y)
  local cows,mult=hyper and 1 or 0,1
  if not bomb then
	  if d<29 then
	   mult=4
	   cows=1
	  elseif d<43 then
	   mult=3
	   cows=1
	  elseif d<58 then
	   mult=2
	  end
		end
		
		if e.boss then 
		 mult=1
		 cows=0
		 e.brain=43
		 e.bri=1
		 e.wait=0
		 e.movx=nil
		 e.bulq={}
		 e.fncb=nil
		end
		
  cows=max(cows,e.cows)
  
  if cows>0 then
  	spawnpick(e.x,e.y,cows,hyper and 9 or 10)
  end
  
  local scr=0x.0001*e.score*mult
  score+=scr
  lastscore=scr
  if hyper then
   starval+=scr
  end
  
  explode(e.x,e.y,e.fx)
  if not e.boss then
   delen(e)
  end
  
  if mult>1 then
   popopup(e.x,e.y,43+mult,mult*2-3)
  end
  
  if e.canc>0 then
   --bullet cancel
   for b in all(buls) do
    if b.en==e then
     delbul(b)
    end
   end
  end
  return true
 else
  if e.boss and hyper then
   starval+=0x.0001*5
  end 
 end
 
 if not e.burn and e.maxhp>bombdmg and e.hp<bombdmg then
  e.burn={}
  for i=1,3 do
	  local flm={
	   draw=sprite,
	   maxage=1000,
	   x=rndrange(-8,8),
	   y=rndrange(-12,12),
	   plock=e,
	   ani=anilib[8],
	   anis=3
	  }
		 add(e.burn,flm)
		 add(parts,flm)
  end

 end
 
 return false
end

function delen(e)
 del(enemies,e)
 for p in all(e.burn) do
		del(parts,p)
 end
 if e.boss then
  --boss=false
  music(-1)
  sfx(50)
  govertime=t+350
 end
end

function dopicks()
 for p in all(picks) do
  p.age+=1
  
  if p.magnet then
   local ang=atan2(pspr.y-p.y,pspr.x-p.x)
   p.sx+=sin(ang)*0.3
   p.sy+=cos(ang)*0.3
   
   local spd=dist(0,0,p.sx,p.sy)
   if spd>4 then
    p.sx/=spd/4
    p.sy/=spd/4   
   end
  elseif p.typ==37 then
   p.sx,p.sy=0,t%5==0 and 1 or 0
  else
	  local psx=sin(time()/8+p.age/120)/2
	  local psy=1+cos(time()/8+p.age/120)/4
	  p.sx+=(psx-p.sx)/10
	  p.sy+=(psy-p.sy)/10
  end
  
  p.x+=p.sx
  p.y+=p.sy
  if p.x<3 or p.x>132 then
   p.sx=-p.sx
			p.x=mid(3,p.x,132)
  end
  
  if p.y>135 then
   del(picks,p)
  else
   if p.cool>0 then
    p.cool-=1
   elseif dist(p.x,p.y,pspr.x,pspr.y)<32 then
	   del(picks,p)
	   add(parts,{
	    draw=shwave,
	    x=p.x,
	    y=p.y,
	    c=7,
	    r=6,
	    sr=2.5,
	    maxage=6
	   })
	   local s1,s2,getch=0,6,ch_pick
				if p.typ==9 then
					score+=starval
					hypertally+=starval
					starcount+=1
					getch/=hyper and 2 or nerf
				elseif p.typ==37 then
				 popopup(p.x,p.y,147,7)
				 lives+=1
		   s1,s2,getch=8,24,0
		   duck=t+20
				end
				sfx(63,-1,s1,s2)
	   charge=min(chargemax,charge+getch)
   end
  end
 end
end

function popopup(x,y,ani,col)
 add(parts,{
  draw=popup,
 	x=x,
 	y=y,
 	sx=0,
 	sy=-2,
 	drag=0.85,
 	maxage=40,
 	ani={ani},
 	palnum=col
 })
end

function spawnpick(px,py,pnum,pani)
 
 local fullang=0.1*(pnum-1)
 local ang=atan2(pspr.y-py,pspr.x-px)-fullang/2
 
 for i=0,pnum-1 do
  local ang2=ang+i*0.1
	 add(picks,{
	  x=px,
	  y=py,
	  age=0,
	  sx=-sin(ang2)*4,
	  sy=-4-cos(ang2),
	  cool=5,
	  ani=anilib[pani],
	  anis=6,
	  typ=pani
	 })
 end

end

function makeopt(_org,_num,_ani,_radx,_rady,_ang,_yoff)
 local arr={_org}
 _org.cosy=0
 for i=0,_num-1 do
  --★
  local opang,j=_ang+i*(1/_num),i+2
  local _px,mycosy=0.5+sin(opang)*_radx,cos(opang)
		while j>1 and arr[j-1].cosy>mycosy do
		 j=j-1
		end 
		add(arr,{
	  x=_org.x+_px+(_px>0 and 1 or 0),
	  y=_org.y+_yoff+mycosy*_rady,
	  ani=anilib[_ani],
	  anis=1,
	  age=t,
	  cosy=mycosy
	 },j)
 end

 return arr
end

function die()
 freeze,flashship,coyote=30,true,0
 callwhile=function()
	 if btnp(🅾️) and (hasbomb or hyper) then
	  flashship=false
	  bomb()
	 end 
 end
 if hyper then
  hyperoff()
  callback=function()
   invul,flashship=150,false
  end
 else
  sfx(5)
  callback=function()
		 lives-=1
		 nerf=2
		 explode(px-xscroll,py)
		 inviz,invul,flashship=10,150,false
		 if lives<0 then
		  if not chkpmode then
			  local tmprec=min(scroll-py\5,1450)
					if tmprec>recscr then
				 	add(parts,{
				   draw=sprite,
				   maxage=120,
				   x=pspr.x,
				   y=py,
				   sy=-2.5,
				   sx=0,
				   grav=0.15,
				   floor=py+15,
				   anis=6,
				   ani=anilib[37]
				  })
			   recscr=tmprec
			   recx=pspr.x
			   dset(1,recscr)
			   dset(2,recx)
			  end
    end
		  lives,inviz,freeze=0,100,100
		  callback=function()
		 		callwhile=abs
		 		gogover "game over"
		  end
		  callwhile=doparts
		  music(-1,1000)
		 elseif lives==0 then
			 shout,shoutt="last  life",120
		 end 
  end
 end
end

function spawnen(eni,enx,eny,enb)
 --★
 local en=enlib[abs(eni)]
 local newen={
  x=enx,
  y=eny,
  ry=eny,
  ani=anilib[en[1]],
  anis=en[2],
  sx=0,
  sy=0,
  ang=0,
  spd=0,
  brain=enb or en[3],
  bri=1,
  mirr=sgn(eni),
  age=0,
  flash=0,
  hp=en[4],
  maxhp=en[4],
  col=myspr[en[5]],
  layer=en[6],
  colshot=en[7]>0,
  colship=en[7]>1,
  wait=0,
  dist=0,
  bulq={},
  canc=en[8],
  shads=en[9],
  shadspd=0,
  shadh=en[10],
  fx=en[11],
  score=en[12],
  cows=en[13],
  bul1x=en[14] or 0,
  bul2x=en[16] or 0,
  bul1y=en[15] or 0,
  bul2y=en[17] or 0
 }
	if eni==2 then
	 newen.opt=true
	 newen.opta=0
	 newen.opts=0
	 newen.optst=0
	end
	
 add(enemies,newen,1)
 return newen
end

function doenemies()
 for e in all(enemies) do
  if e.explfrq then
   if t%e.explfrq==0 then
    explode(e.x+rndrange(-27,27),e.y+rndrange(-18,18),2)
   end
  end
 
  if e.wait>0 or e.movx then
   e.wait-=1
  elseif e.dist<=0 then
   dobrain(e,1)
  end
  
  if e.movx then
   --★
   e.x+=(e.movx-e.x)/25
   e.ry+=(e.movy-e.ry)/25
   if dist(e.x,e.ry,e.movx,e.movy)<1 then
	   e.x,e.ry=e.movx,e.movy
	   e.movx=nil
	  end
  else
	  if e.flw then
	   e.adrt=atan2(pspr.y-e.ry,pspr.x-e.x)
	   e.flw=dist(pspr.x,pspr.y,e.x,e.ry)>25
	  end
	  
	  if e.aspt then
	   e.spd+=mid(-e.asps,e.aspt-e.spd,e.asps)
	   if e.spd==e.aspt then
	    e.aspt=nil
	   end
	  end
	  
	  if e.adrt then
	   while abs(e.adrt-e.ang)>0.5 do
	    e.adrt-=sgn(e.adrt-e.ang)
	   end
	   e.ang+=mid(-e.adrs,e.adrt-e.ang,e.adrs)
	   if e.ang==e.adrt then
	    e.adrt=nil
	   end
	  end  
   e.sx=sin(e.ang)*e.spd
   e.sy=cos(e.ang)*e.spd
   e.dist=max(0,e.dist-abs(e.spd))
   e.x+=e.sx
   
   e.ry+=(t%5==0 and e.layer==1) and 1+e.sy or e.sy
   if e.shadylock then
    e.shadh-=e.sy
   end
  end
  
  e.age+=1
  e.y=e.ry
  e.shads+=e.shadspd
  if e.hovmax then
   e.hovmax+=mid(-0.05,e.hovmaxt-e.hovmax,0.05)
   e.y+=sin(time())*e.hovmax+0.5
  end
  
  local oscr=col2(e,screen)
    
  if e.staged and not oscr then
   if e.boss then
    if e.y<-60 then
     delen(e)
    end
   else
    delen(e)
   end
  else
   e.staged=oscr
  end
  
  if e.y<=cutoff or e.boss then
   dobulq(e)  
  end
  
  if e.opt then  
   e.opts+=mid(-0.00008,e.optst-e.opts,0.00008)
   e.opta+=e.opts
  	bopt=makeopt(e,11,15,
      20,14,
      e.opta,
      5)  
  end

 end
end

function dobrain(e,depth) 
 local mybra=brains[e.brain]
 local quit=false
 if e.bri<#mybra then
  local cmd=mybra[e.bri]
  local par1=mybra[e.bri+1]
  local par2=mybra[e.bri+2]
  if cmd=="hed" then
   --set heading / speed
   e.ang=par1*e.mirr
   e.spd=par2
   e.aspt=nil
   e.flw=false
  elseif cmd=="wai" then
   --wait x frames
   e.wait=par1
   e.dist=par2
   quit=true
  elseif cmd=="asp" then
   --animate speed
   e.aspt=par1
   e.asps=par2
  elseif cmd=="adr" then
   --animate direction
   e.adrt=par1*e.mirr
   e.adrs=par2*e.mirr
   e.flw=false
  elseif cmd=="got" then
   --goto
   e.brain=par1>0 and par1 or e.brain
   e.bri=par2-3
  elseif cmd=="fnc" then
   --function
   e.fncb,e.fnci=e.brain,e.bri
   e.brain=par1>0 and par1 or e.brain
   e.bri=par2-3
  elseif cmd=="lop" then
   --loop
   e.loop=e.loop and e.loop+1 or 1
   if e.loop<par1 then
    e.bri=par2-3
   else
    e.loop=0
   end
  elseif cmd=="fr1" then
   --fire
   patshoot(e,par1,par2*e.mirr,e.bul1x*e.mirr,e.bul1y)
  elseif cmd=="fr2" then
   --fire2
   patshoot(e,par1,par2*e.mirr,e.bul2x*e.mirr,e.bul2y)
  elseif cmd=="fr3" then
   --fire2 mirrored
   patshoot(e,par1,par2*e.mirr*-1,e.bul2x*e.mirr*-1,e.bul2y)
  elseif cmd=="fr4" then
   --double fire 2
   patshoot(e,par1,par2*e.mirr,e.bul2x*e.mirr,e.bul2y)
   patshoot(e,par1,par2*e.mirr*-1,e.bul2x*e.mirr*-1,e.bul2y)  
  elseif cmd=="snd" then
   sfx(par1)
  elseif cmd=="clo" then
   --clone
   for i=1,par1 do
    local myclo=copylist(e)
    myclo.bulq=copylist(e.bulq)
    myclo.wait+=i*par2
    myclo.bri+=6
    add(enemies,myclo,1)
   end
  elseif cmd=="flw" then
   --follow
   e.flw=true
   e.adrs=par1
   --par2??
  elseif cmd=="mov" then
   --moveto
   e.movx=par1
   e.movy=par2
   quit=true
  elseif cmd=="shd" then
   --shadow control (lock,speed)
   e.shadylock=par1==1
   e.shadspd=par2
  elseif cmd=="mus" then
   --muisc
   music(par1,par2)
  elseif cmd=="trg" then
   --effect trigger
   if par1==1 then
    e.boss=true
				boss=e
   elseif par1==2 then
    e.optst=0.01
   elseif par1==3 then
    e.layer=2  
    e.colship=true
   elseif par1==4 then
    e.colshot=par2==1
   elseif par1==5 then    
    e.beam=par2==1
   elseif par1==6 then
    e.hovmax=e.hovmax or 0 
    e.hovmaxt=par2
   elseif par1==7 then
    e.colship=par2==1
   elseif par1==9 then
    e.hp=par2
    hitenemy(e,0)
   elseif par1==10 then
    e.explfrq=par2
   elseif par1==11 then
    explode(e.x,e.y,2)
		  fadeperc=2
    delen(e)
   end
  elseif cmd=="ani" then
   e.ani=anilib[par1]
   e.anis=par2
   e.ahold=false
  elseif cmd=="anh" then
   e.ani=anilib[par1]
   e.anis=par2
   e.age=0
   e.ahold=true
  end
  e.bri+=3
  if e.bri>#mybra and e.fncb then
   e.brain,e.bri=e.fncb,e.fnci+3
   e.fncb,e.fnci=nil,nil
  end
  
  if quit then return end
  dobrain(e,depth+1)
 end
end

function dobuls(arr)
 for bl in all(arr) do
  bl.age+=1
  bl.x+=bl.sx
  bl.y+=bl.sy
  if not col2(bl,screen) then
   del(arr,bl)
  end
 end
end


function shoot()
 --slowmo=true
 shotframe=true
 local shotspd=-6
 shotwait=2
 
 for i=-4,4,8 do
  add(shots,{
   x=pspr.x+i,
   y=py-14,
   sx=hyper and 0 or sgn(i)*0.2,
   sy=shotspd,
   ani=anilib[3],
   anis=2,
   age=(t\2)%3+1,
   col=myspr[18]
  })
	 add(parts,{
	   draw=sprite,
	   maxage=5,
	   x=i,
	   y=-4,
	   ani=anilib[5],
	   plock=pspr
	 })
 end
 for p in all(popt) do
  if p!=pspr do
	  local osprd=hyper and 0.8 or 1.1
	  add(shots,{
	   x=p.x,
	   y=p.y-14,
	   sx=osprd*sgn(p.x-pspr.x),
	   sy=shotspd,
	   ani=anilib[3],
	   anis=2,
	   age=1,
	   col=myspr[18]
	  })
		 add(parts,{
		  draw=sprite,
		  maxage=5,
		  x=0,
		  y=-4,
		  ani=anilib[6],
		  plock=p
		 })
	 end
 end
 if t>duck then
  sfx(hyper and 58 or 0,3)
 end
end

function makepat(pat,pang)
 local mypat,ret=pats[pat],{}
 local patype,p2,p3,p4,p5,p6,p7,p8,p9=unpack(mypat)
 if patype=="base" then
  add(ret,{
   age=0,
   x=0,
   y=0,
   ang=0,
   spd=p2,
   ani=anilib[p3],
   anis=p4,
   col=myspr[p5],
   wait=0,
   pang=pang
  })
 elseif patype=="sprd" then
  for i=p3-1,p4-1 do
   local rndw,rnds=flr(rnd(p7)),rnd(p6)
   for p in all(makepat(p2,pang)) do
    p.spd+=p9
    if p8==2 then
     --burst
     p.ang+=spread(p5)
     p.wait+=rndw
     p.spd+=rnds     
    else
     --spread
     p.spd+=i*p6
     p.wait+=i*p7
     if i>0 and p8>0 then
      --mirror
      local copyp=copylist(p)
      copyp.ang+=i*-p5
      add(ret,copyp)
     end
     p.ang+=i*p5
    end
    add(ret,p)   
   end
  end
 elseif patype=="comb" then
  for i=2,5 do
   if mypat[i]>0 then
    for p in all(makepat(mypat[i],pang)) do
     add(ret,p)
    end
   end
  end
 end
 
 return ret
end

function patshoot(en,pat,pang,ox,oy)
 for b in all(makepat(pat,pang)) do
  b.x,b.y=ox,oy
  add(en.bulq,b)
 end
end

function dobulq(en)
 for b in all(en.bulq) do
  if b.wait<=0 then
   if en.layer>1 or dist(pspr.x,pspr.y,en.x,en.y)>24 then
				add(parts,{
					draw=shwave,
					x=b.x,
					y=b.y,
					c=7,
					r=0,
					sr=1,
					maxage=6,
					plock=en
				})
		  b.x+=en.x
		  b.y+=en.y 
		  if abs(b.pang)==99 then
		   b.pang=atan2(pspr.y-b.y,pspr.x-b.x)
		  end
		  b.ang+=b.pang
		  b.sx=sin(b.ang)*b.spd
		  b.sy=cos(b.ang)*b.spd
		  if t>duck then
		  	sfx(7,3)
		  	duck=t+1
		  end
    add(buls,b)
   end
   del(en.bulq,b)
  else
   b.wait-=1
  end
 end
	 
end
-->8
--particles

function delbul(b)
 del(buls,b)
 add(parts,{
  draw=shwave,
  x=b.x,
  y=b.y,
  c=7,
  r=0,
  sr=0.5,
  maxage=7
 })
end

function explode(ex,ey,fx)
 local fx=fx or 0
 sfx(rnd(extab[5]))
 duck=t+30
 --7386-7322
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=fx==2 and 25 or 17,
  maxage=2,
  ctab={17,119}
 })
  
 sparkblast(ex,ey,2)
 sparkblast(ex,ey,8)

 if fx==1 then
		grape(ex,ey,2,20,1,
		      "fade",extab[1],
		      -0.3,1
		      )
	else 
  local escl=fx==2 and extab[6] or extab[7]
		grape(ex,ey,2,13,1,
		      "return",extab[2],
		      0,escl[1]
		      )
		grape(rndrange(ex-5,ex+5),ey-5,10,20,1,
		      "return",extab[3],
		      -0.2,escl[2]
		      )
		grape(rndrange(ex-5,ex+5),ey-10,25,25,0.8,
		      "fade",extab[4],
		      -0.3,escl[3]
		      ) 
		return
	end
end

function doparts()
 for p in all(parts) do
	 -- age and wait
	 p.age=p.age or 0
	 if p.age==0 then
	  p.ox=p.x
	  p.oy=p.y
	  p.r=p.r or 1
	  p.spd=p.spd or 1
	 end
	 p.age+=1
	 if p.age>0 then
		 
		 --particle code
		 
		 --movement
		 if p.tox then
		  p.x+=(p.tox-p.x)/(4/p.spd)
		  p.y+=(p.toy-p.y)/(4/p.spd)   
		 end
		 if p.sx then
		  p.x+=p.sx
		  p.y+=p.sy
		  if p.tox then
		   p.tox+=p.sx
		   p.toy+=p.sy
		  end
		  
		  if p.drag then
		   p.sx*=p.drag
		   p.sy*=p.drag
		  end
		  if p.grav then
		   if p.y>p.floor then
		    p.y=p.floor
		    p.sy*=-0.5
		   else
		    p.sy+=p.grav
		   end
		  end
		 end
		 
		 --size
		 if p.tor then
		  p.r+=(p.tor-p.r)/(5/p.spd)--★ spd
		 end
		 if p.sr then
		  p.r+=p.sr
		 end
		 
		 if p.age>=p.maxage or p.r<0.5 then
		  if p.onend=="return" then   
		   p.tox=p.ox
		   p.toy=p.oy
		   p.tor=nil
		   p.sr=-0.3
		  elseif p.onend=="fade" then
		   p.tor=nil
		   p.sr=-0.1-rnd(0.3)
		  else
		   del(parts,p)
		  end
		  p.ctab=nil
		  p.onend=nil
		  p.maxage=32000
	  end
	 end
 end
end

function grape(ex,ey,ewait,
               emaxage,espd,
               eonend,ectab,
               edrift,escl)
 local escl,step,ang=escl or 1,1/6,rnd()
 
 for i=1,6 do
  --spawn blobs
  local dist,myang=(7+rnd(3))*escl,ang+step*i
  local dist2=dist/2
  
	 add(parts,{
	  draw=blob,
	  x=ex+sin(myang)*dist2,
	  y=ey+cos(myang)*dist2,
	  r=2,
	  tor=rndrange(4,7)*escl,
	  tox=ex+sin(myang)*dist,
	  toy=ey+cos(myang)*dist,
	  sx=0,
	  sy=edrift,
	  age=-ewait,
	  maxage=emaxage,
	  onend=eonend,
	  spd=espd,
	  ctab=ectab,
	  ctabv=rnd(5)
	 })  
  
 end
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=2,
  tor=7*escl,
	 sx=0,
	 sy=edrift,
  age=-ewait,
  maxage=emaxage,
  onend=eonend,
  spd=espd,
  ctab=ectab
 })  
end

function sparkblast(ex,ey,ewait)
 local ang=rnd()
 
 for i=1,6 do
  local ang2=ang+rnd(0.5)
  local spd=rndrange(4,8)
	 add(parts,{
	  draw=spark,
	  x=ex,
	  y=ey,
	  ctab={7,10},
	  sx=sin(ang2)*spd,
	  sy=cos(ang2)*spd,
	  drag=0.8,
	  age=-ewait,
	  maxage=rndrange(8,13)
	 })
 end
end

function blob(p)
 local myr=flr(p.r)
 
 local thk={
  0,
  myr*0.05,
  myr*0.15,
  myr*0.3
 }
 local pat={
  0b1111111111111111,
  0b1011010010101101,
  0b1000000000000000,
  0,
 }
 
 --★
 if myr<=2 then 
  pat={0b1111111111111111}
  thk={0}
 elseif myr<=5 then
  deli(thk,4)
  deli(thk,2)
  pat={0b1111111111111111,0}
 elseif myr<=8 then  
  deli(thk,myr<=6 and 3 or 4)
  deli(pat,3)
  pat[2]=0b1010101010101010
 end
 
 for i=1,#thk do
  fillp(pat[i])
  circfill(flr(p.x),flr(p.y)-thk[i],
           myr-thk[i],p.c)

 end
 fillp()
 
 --★
 if myr==1 then
  line(p.x,p.y-1,p.x,p.y,p.c)
 elseif myr==2 then
  rectfill(p.x-1,p.y-2,p.x+1,p.y,p.c)
 end
 
end

function spark(p)
 for i=0,1 do
  line(p.x+i,p.y,p.x+p.sx*2+i,p.y+p.sy*2,p.c)
 end 
end

function shwave(p)
 --★ universal plock?
 local _x,_y=p.x,p.y
 if p.plock then
  _x+=p.plock.x
  _y+=p.plock.y
 end
 circ(_x,_y,p.r,p.c)
end

function sprite(p)
 if p.age<=0 then
  return
 end
 
 local _x,_y=p.x,p.y
 if p.plock then
  _x+=p.plock.x
  _y+=p.plock.y
 end
 mspr(cyc(p.age,p.ani,p.anis),_x,_y)
end

function popup(p)
 pal(pal_popup[t%8<4 and p.palnum or p.palnum+1])
 sprite(p)
 pal()
end
-->8
-- bomb/hyper

function hyperon()
 freeze,flashship,starval,starcount,hypertally,hycirc=30,true,0,0,0,{}

 for i=0,5 do
  add(hycirc,100+i*60)
 end
 
 callwhile=function()
  if freeze==20 then
   sfx(60,-1,0,21)
  end
	 for i=1,6 do
	  hycirc[i]+=(2-hycirc[i])/8
	 end
	 if btnp(🅾️) then
	  callback()
	 	bomb()
	 end
 end
 callback=function()
  callwhile,linger,hyper,flashship,invul,hycirc=abs,200,true,false,120
 end
end

function hyperoff()
 sfx(61)
 hyper,invul,charge,duck=false,60,0,t+30
end

function bomb(range)
 sfx(62)
 
 if not hyper then
  hyper,starval,starcount,hypertally,linger=true,0,0,0,200
 end
 
 duck=t+1
 bombrange=range or 55
 bombx=pspr.x
 bomby=pspr.y
 flashship=true
 invul=0
 
 bombrs=0
 bombrd=bombrs
 
 bombdme=0
 
 bombphase=1
 
 freeze=2060
 callwhile=bombwhile
 callback=bombend
 
 bombt=0
 bombspd=0
end

function bombwhile()
 -- 1: grow shadow
 -- 2: dome descend
 -- 3: flash shockwave
 -- 4: shrink
 bombt+=1
 if bombphase<=2 then
  bombrs+=(bombrange-bombrs)/10
  bombrd=bombrs
  
  for b in all(buls) do
   if dist(bombx,bomby,b.x,b.y)<bombrs then
    delbul(b)
    spawnpick(b.x,b.y,1,9)
   end
  end
  
  if bombphase==2 then
		 bombdme+=bombspd
		 bombspd+=0.02
		 if bombdme>1 then
			 bombdme=1
			 bombphase=3
			 fadeperc=0.5
			 bombspd=0.2
			 bombt=0
				for b in all(buls) do
				 delbul(b)
				end
		 end  
  elseif bombt>20 then
   bombphase=2
  end
 elseif bombphase==3 then
  fadebomb()
  if bombt>=14 then
   freeze=0
  end 
 end
 doparts()
end

function bombend()
 flashship=false
	callwhile=abs
	
	for e in all(enemies) do
		if e.colshot and dist(bombx,bomby,e.x,e.y)<bombrange+8 then
		 hitenemy(e,bombdmg,true)
		end
	end
	hyper=false
	charge=max(0,charge-chargethrs)
	invul=60
	nerf-=1
	nerf+=nerf*2

	printh(starcount.." x "..tostr(starval,0x2),"cattlestats.txt",false)

end

function fadebomb()
 bombrd-=bombspd
 bombrs+=bombspd*4
 bombspd=bombspd+0.25
 --★
 if bombrd<0 then
  suckin()
  bombrs=0
 end
end
-->8
-- clouds

function drawclouds()
	--for cda in all(clouds) do
	 local cda=clouds[1]
		for cld in all(cda) do	  
	  for d in all(split2d("5,7|-1,6|-3,7")) do
 		 circfill(cld.x,cld.y,cld.r+d[1],d[2])
	  end  
		 cld.y+=0.1
		 --cld.y=64
		 --cld.x=64
		 
		 if cld.y>160 then
		  del(cda,cld)
		  if cloudt<=t then
		  	cloudscl+=rnd(0.15)
		  	cld.r/=cloudscl
		  end
		  if cld.r>8 then
		   add(cda,cld,1)
	    cld.y-=192
	   end
		 end
		end
	--end
end

function setupclouds()
 clouds,cloudscl={{},{},{}},1
 for k,v in pairs(split2d("20,2.5,20,4|47,4,20,12|80,8,25,16")) do
  for i=0,5 do
   for d=-1,1,2 do   
				add(clouds[k],{
				 x=72+(v[1]-rnd(v[4]))*d,
					y=i*32-8*(d+1),
					r=v[3],
					dy=v[2]
				}) 	  	  
   end
  end
 end
end
__gfx__
000000ee0000000000000ee00000000000000e0009009090000700000700070000000700000a00009000000900900000000eee00000eee0000000ee000070070
00000e11e00000000000e11e000000000000e1000900909007770000070007000000000000a79090900000090000000000eccce000eddde00000e88e00777777
0000e1671e000000000e1671e0000000000e16009700909077770000070000000000000000a79099a0000909000000000ecbbbce0ed676de000e8998e07c7777
0000e111d1e00000000e111d1e00000000e111009709a0907777007007000000700000000a77009a7090090000000000ecb777bced67776de0e897798e7c77c7
000e1ccc11e0000000e1ccc11e00000000e1cc0977097097777707707700000070000000077790a77090000990000000ecb777bced77777dee8977798e0707c7
00e1c77cc11e00000e1c77cc11e000000e1c7709770979a77777077077700000770000000777a0777009009a00000000ecb777bced67776dee897798e0000070
00e1c7c1c11e00000e1c7c1c11e00000ee1c7c97a79a797777770077770700077000000000777777790909a7000000000ecbbbce0ed676de00e8998e00070070
00e1c111c111e000e11c111c111e000e111c1197a79a79707777707777000077700000000fff077779000a700000000000eccce000eddde0000e88e000fff070
00e1c111c171e000e11c111c171e000e171c119aa79a79a00777777777000077700000000fff007779000a0000000000000eee00000eee000000ee0000fff777
0e11cc171161e00e161cc117161e000e1611719aa799a9a00077077777070077707000007110110ff000000009000000ff0ede000eee0000eee00ffffffff7c7
0e1d1c711d6d1e0e16d1c77116d1e0e1d6d1179a9a99a9a000ee007777000077700000007221221ff090000000000000ffed7de0e888e00eb7be0ffffffff070
e1ddd111d6d7d1e1dddd1111dd671e176d6d11999a9999900e11007777000007700000077122210ff009000000000000ffe777ee89798eec777ceffffffff000
e1dd6ddd6d66d1e1dd66dddd6d661e1666d6dd999a999990e151000777000000700000077221221776667700eeeee00fffe777ee87778eeb777beffffffff070
e1d676676d6dd1e1d6676676d6dd1e1dd6d6769099999990e151000077fffffff000000071111117666777eed676deefffe777ee89798eec777ceffffffff111
0e176d167d111e0e117dd1171111e0e11117169009909090e1110111110011111001101101101106667777ed67776defffed7de0e888e00eb7be0ffffffff911
00e151155d11e000e1655155d11e000ee16151000900909e1d67122222112222211221221000900009090deed676deefff0ede000eee0000eee00ffffffff991
000e1111111e00000e11111111e000000e1111000007fffe1667111122111112211221221909a90099900f00eeeee00fff0eee0f000001110000000000000eee
0000eeeeeee0000000eeeeeeee00000000eeee000074fffe16dd12222211222221122222109aaa999a990ff0ee00000000e000e0000118880000000000eee111
0990007777700007770000000770000777700077774afffe1d1112211111111221111122109aa999a7a90f9e11e00000ee100e1e0018888800000000ee111888
977907111117007111700000711700711117007444aafff0e1dd1222221122222101112219a7a909a77a9991661000ee1150e171018888880000000e11888888
9779717117717071711700071771771171117074aaaafff00e11111111111111110001111a77aa00a77aabb66160ee116d5e17150188ee88000000e128888888
9779717177111771711170071111771171711774aaaafff000ee011111001111100000110bbb0ee00000011d61de1166d11e1661188eeee800000e1288888888
97790711111117711717170711717071177117074aaaffffffffffff0e1d00eee000e1dd1e00e11e00011881dd1166d11eee16d1188eeee80000e18288888888
9779071771711771717117071771707171171774aa99ffffffffffffe16d0e11100ee1dd1ee016610018821e11e5d11ee00e1d111888ee88000e188288888eee
97790070070770077111117711117007071717749944ffffffffffff0e11e16660e1e1dd111e1dd1018821d0ee011ee0000e161e1888888800e182828e88eeee
9aa9c77770000e007171170711117000071770744447ffffffffffff00eee1ddde1611dd18211dd1018e1ddbbbbee000000e1d1e1288888800e1288828eeeee1
9aa9cc77700014000707700071170000007000777770ffffffffffff0e110e111e1d28118e828118188e21d000000333bbb0e1e0012888820e128888e2888eef
9aa9c77770014700e1110f4007700bbbbbbb00070000000e0000ffffe16d00e00e118888fe880ee0118ee21000033322bbb00e000122288e0e1888888e222888
9aa9cc777014ff0e12221f900777777777000078700000e2e000ffff0e110e1eee188ee8ee82e11e1288eee030332244000000ee001222220e1888288eeef222
9999c777701499e18f821990711111111170078e87000e282e00ffff00eee1611e18e22288881dd101818880033244240000ee1100011222e188828888eeeff7
0990cc77711149e18e8817471d66ddd66d1778eee870e28882e0ffffffffe1d66e1821112e821dd10011881003322424000e118800000111e182888888eeeeee
0990c777712814e128821bb716166d661617788eee87e228882effffffff0e1dd0e1e19a18221661000111103324422200e188218822eeeee1825888888eee22
77fbcc777e128ee182210bb716616d6166170788eee80e228882ffffffff00e110e12e11e2212112fffffff3332242110e1882472282ee22e1282888888822f7
777bccc770e1280e111e0bb715665d56651700788eee00e22888011110000000000e12ef211efffffffffff0331221110e18e19a82882211e12888825882fff7
f77b0cccc00e1100eee00bb71d55ddd55d17000788ee000e22881222111111110000e1111ee0fffffffffff003312211e188e249582211d6e12888e22882efee
fffb00ccc000ee00eee00bb719aa9a99941700078eee000e288801221212122210000eeee000fffffffffff033331122e188ef21282155660e12888fe82ee811
99fbbbb00e11000e111e0bb07111111111700078eee800e288820122121212121ffffffffffffffffffffff000333311e1188ef7e8215d660e122888882e8119
000ee000e18810e18881ebb0077777777700078eee880e2888220122121212221ffffffffffffffffffffff0030033330e1888888221dd660e112828882e8199
00e11e0e18f821e1e8821bbfffffffffffff78eee887e288822e0122122212111ffffffffffffffffffffff0000000330e1888882221dd6600e11228882e8199
0e1881ee18e821e188221bbfffffffffffff788e8870e22822e00111111111110fffffffffffffffffffffffffffffff00e188888821dd6700e1112282121119
e18e811e188821e122211bbfffffffffffff078887000e222e000011111111000fffffffffffffffffffffffffffffff000e11888211d611000e191222111911
e188211e1288210e12110bbfffffffffffff0078700000e2e000ffffffffffffffffffffffffffffffffffffffffffff000e1d112211d1190000e11111119991
e182110e12221e00e1100bbfffffffffffff00070000000e0000ffffffffffffffffffffffffffffffffffffffffffff0000e1d61111d111fffff11911111911
e1211100e111e0bbbbbbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000e111111d115fffff11d11911111
0e1110000eee00bbbbbbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000ee11915d11fffff11511111111
00ee000bb000000eee00000eeeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff111115ddfffff1115d11d11d
000000eee00000e1110000e111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff5d111111fffff011551111d1
0000ee111000011888000e124ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff01d151d11d1
000e1188800018822e00e184f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff011151111d1
00e188888001ee2e8800e184f7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000ccccccc01111101111
0e188888800182e8880e1284ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000cc777777701101100111
0e18888ee01282e888e128e4f9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000c77000000001101100011
e1888eeeee1282e888e188f44ffffff00007770000000000000eee0000000000000eefffffffffffffffffffffffffffff00000000c700770000001101100011
e188222eee12e2e888e1288e44fffff0007887000000000000e11100000000000ee44fffffffffffffffffffffffffffff0000000c70077ee000001101100001
e18211122e12e22f820e1282effffff0078e87000000000eee1ddd0000000000e44fffffffffffffffffffffffffffffff000000c70077111e00000101100001
e18e19911e112e22290e1d288efffff078ee870000000ee1111ddd00000ee00e4fffffffffffffffffffffffffffffffff000000c70e167761eee00001000001
e128e1111e1112ff2200e16288fffff78eee87000eeee1188826dd0000e11ee4ffffffffffffffffffffffffffffffeeee00eee0c70e1ee77111100001000001
0e12211110e1112ef7000e1288fffff078ee8700e111188888e26d000e16d114f9ffffffffffffffffffffffffffff11110e111ee700e1eee1d6700000000001
0e12199110e11128e80000e128fffff0078e870e16118888ee226600e16dd184f99fffffffffffffffffffffffffff11d1e1f8211ee00e1111177e1288888888
00e11118800e11288200000e11fffff0007887e1d1188e8efe292200e1dd1824f99f900000eeffffffffffffffffff11610e1f88211eeeee111d7e1288888888
000e11222000e11288000000eefffff0000777e1d188e8efe22199000e151824f99f9000ee11ffffffffffffffffff11d100e1e8882111111c117e1288888eee
0000ee1110000ee1110000000eee000eeee000e1128ee8ee2111110000e1e824f999900e118800000eee000000000011dd000e1e8881882211c17e128e88eeee
000000eee000000eeebbb000e22e00e6776e00e1188e88e2161ddd000e11e824f79990e18888000ee111e00000000011110000e1ee18fe82511d7e1128eeeee1
0000ee11100ee007fbbbb00e282e0e67bb76e0e12888888211d11100e1827f22477770e1888800e118881e00000000119a00000e118eeee251d77e1212888eef
000e118440e11e0f9bbbb0e2882ee67bccb76ee18888e8821d11000e188f118e24477e1888880e18888e81e00000001119000000e18822821d77718215222888
00e1884ffe1661e99bbbbe28882ee7bcddcb7ee18288e8881d10000e18e11288f2244e1888880e188888e81e0000001111000000e18211282feff882156d5222
0e1ee4ff7e1dd1e99bbbb0e2882ee7bcddcb7ee1e988ef88211100e11e1112888ff22e188882e18888888881e00000eeee000000e18211282e1ee2821d66d15d
0e1824f7f0e11e0bbbbbb00e282ee67bccb76ee1f188eee8881111e1d111522288ef7e182288e188888828821e00000000eeeeeeee18ee8112e228882d11d1d6
e12824fff00ee00bbbbbb000e22e0e67bb76e0e18e888eefe888eee16d12d6d5288efe128888e1288888888e81e00000ee11111110e1111111222888e2dd11d1
e12824f99000eeee000bb0000eee00e6776e000e1888888effeeff0e1111d77d2e8efe1288880e1288288888e81e000e1188888880128288281118888e22211d
e12e24f9900e1111e00000eeee00000eeee0000e128e22d8eee22200e111d11d18ef7e1888ee0e12282888888e81e0e188ffeee82e11211288effffe11888222
e12e224770e166161e000edddde000e8888e0000e12e2928ee288800e11d1dd191288e188eef00e1322888888e81e0e18e8888888e111e128e22dff188222211
e18882244e1d11e161e0ed6776de0e977779e000e118f2288288ef00e1d6d11111911e1888ee000e13288888efe81e188888888820eeee1222d1dff82221116d
e12888e22e118881d1eed676676de87799778e0e1d112888828e82000e1d61111111de1288880000e13288888e881e1888888888200000e121d16ff821111d76
0e12888efe1282211e0ed76dd67de87988978e0e16111228828e290000e1116d111d6e12888800000e13288888821e1288888888200000e121611ff2167711d5
0e1282888e112221d1eed76dd67de87988978ee1d66111122128e500000e1dd6dd16d0e12888000000e132888821e0e12288888820000e1e82116ff21ee7711d
00e122888e1d111d61eed676676de87799778ee16d6d11e111122800000e16ddd11d10e132220000000e13222231e0e13322222210000e1881ee1ff811eee1d6
000e111ef0e1dddd1e00ed6776de0e977779e00e16dd1e0eee1111000000e1661ee1100e113300000000e133311e000e1133333210000e111e00eff8e11111d7
0000ee11100e1111e0000edddde000e8888e0000e111e00000eeee0000000e11e00ee000ee11000000000e111ee00000ee111111100000e1e0000ff88e111115
000000eee000eeee000000eeee00000eeee000000eee000000000000000000ee0000000000ee0000000000eee000000000eeeeeee000000e00000ff88eeef111
bbbbbbb111bbbbbbbbbbbbbb11111111dd5555dddd5555ddb9999999999999bbbbbbbbbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddd5d55d55d88888888
bbb1111161111bbbbbbbbbbb17777761d566665dd56ddd5db9999999999999bbbbbb4444bbbb44444444bbbbdddd5d55dddd55d555d5ddddd55d5d6588888888
bbb16dd1611661bbbbbbbbbb17777761d565565dd5655d5db9999999999999bbbb44999944449999999944bbddd5151155d5115111515ddddd55d65588888888
bbb16dd1611661bbb9abb9ab17777761d566665dd56ddd5db9999999999999bbbb49999999999999999994bbdd51515111515151515115dd5dd5d55d88888888
bbb16666666661bbb9a999ab17777761d57ccc5dd57ccc5dbb9999999999999bb4999999999999999999994bdd115111515151511151115ddd5d556588888888
bbb1d11ddd11d1bbb9abb9ab17777761d57dd55dd566665dbb9999999999999bb9999999999999999999999bd551111151111111111151dd5dd6565d88888888
bbb31111111113bbb9a333ab17777761d576655dd555555dbb9999999999999bb9999999999999999999999bd1511111111111111111515d5d5555dd88888888
bbbbbbbbbbbbbbbbbbbbbbbb17666661d576655ddd55555dbb9999999999999bb9999999999999999999999bd1111111111111111111111ddd5ddd5d88888888
11111111111111111111111116ddddd1d57dd55db3333333333333bb99999999b9999999999999999999999bd1111111111111111111111d8888888888888888
111111116111111111777777176666d1d57dd55d333b3b3b3bbb333399999999b9999999999999999999999bd5111111111111111111115d8888888888888888
11116dd16116611111777777176666d1d576655d3bbbbbbbbbbb3b3b99999999b9999999999999999999999bd1111111111111111111111d8888888888888888
11116dd161166111116666661dddddd1d576655dbbbbbbbbbbbbbbbb99999999b9999999999999999999999bd111111111111111111115dd8888888888888888
1111666666666111116666661cccccc1d57dd55dbbbbbbbbbbbbbbbb99999999bb99999999999999999999bbdd51111111111111111111dd8888888888888888
1111d11ddd11d11111d11ddd1d5665d1d57dd555bbbbbbbbbbbbbbbb99999999bb99999999999999999999bbdd111111111111511115d1dd8888888888888888
11111111111111111111111111d55d11d5555555bbbbbbbbbbbbbbbb99999999bbbb99999999bbbb9999bbbbdddd15111511dddd1511dddd8888888888888888
11111111111111111111111111111111dd555555bbbbbbbbbbbbbbbb99999999bbbbbbbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddd8888888888888888
bbbbbbbbbbbbbbbb31111111111113bbbbbbbbbbbbbbbbbbbbbbbbbbbbb533bbbbbbbbbbbbbbbbbbbbb3b3bbb3bbbbb3bbbbbbb5555555555bbbbbbb11111111
bbbbbbbbbbbbbbbbb31111171111113bbbbbbbbbbbbbbbbbbbbbbbbbbbbd3bbbbbbbbbbbbbbbbbbbb3b3333333bbbbb3bbbbbb5cccccccccd5bbbbbb11111111
bbbbbbbbbbbbbbbb31111117111113bbbbbbbbbbbbbbbbb00bbbbbbbbbbd3bbbbbbbbbbbbbbbbbbb33355553533b3b33bbbbb57ddddddddddd5bbbbb15151515
bbbbbbbbbb3b3bbbb3111111111113bbbbb5bbb5bbb5bb0330b5bbb5bbb53bbbbbb5bbb5bbb5bbbb5554454545333335bbbb5d6dddddddddd5d5bbbb51515151
bbbbbbbb3b3b3b3bb31111171111113bddd5ddd5ddd5d03bb305ddd5bbb533bbbbb5ddd5ddd5bbbb4544454444555552bbb55d6dddddddddd55d5bbb55555555
bbbbbbbbbbbbbbbb31111117111113bbbbb5bbb5bbb5b03b3305bbb5bbbd3bbbbbbd3bb5bbbdbbbb4444444444222222bb5ddd6dddddddddd555d5bb55555555
bbbbbbbbbbbbbbbbb3111117111113bb3335333533353033b3053335bbbd3bbbbbbd3335333d3bbb4242424244422222b5dd5d6dddddddddd5555d5b33333333
bbbbbbbbbbbbbbbbb31111171111113bbbbbbbbbbbbbb03bb30bbbbbbbb53bbbbbb53bbbbbb53bbb44444444444422245d5d5d6dddddddddd55555d533333333
bb3bb3b3111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb53bbbbbb53bbb24242424242424245ddd5d6dddddddddd5555555dddddddd
33133131111111111111111111111111bbbbbbbbb111bbbbbbbbbbbbbbbb111bbbbd3bbbbbbd3bbb42424242444242425d5d5d6dddddddddd5555555d55d5ddd
11111111111111111111111331111111b11111bbb1711bbbbb11111bbbb1171bbbbd3bbbbbbd3bbb24242424222665245d5ddd6dddddddddd5555555dddddddd
111111111111111111111133331111111711771bb17111bbb1771171bb11171bbbb53bb5bbb53bbb42424242426555225ddd5d6dddddddddd5555555dddddddd
11111111111111111111113bb311111117177111b117171b11177171b171711bbbb5ddd5ddd53bbb24242424225555245d5d5d6dddddddddd5555555dddddddd
11111111133133131331313b3311331331111111b131711b11111113b117131bbbbd3bb5bbbd3bbb42424242422552225d5ddd6dddddddddd5555555dddddddd
111111113bb3bb3b3bb3b133b313b33b31331311bb31111111313313111113bbbbbd3335333d3bbb22222222242222425ddd5d6dddddddddd5555555dddddddd
77771771bbbbbbbbbbbbb13bb31bbbbbbbbbbbbbbbb1311bbbbbbbbbb1131bbbbbbbbbbbbbbbbbbb24242424242222245d5d5d6dddddddddd5555555dddddddd
b333333bbbbbbbbbbbbbbbbb3333333333333333bbbbbbbbcccccccccccccccccccccccc1111111122222222222442225d5ddd7ccccccccc75555555cccccccc
3b3bb3b3bbbbbbbbbbbbbbbb033333303b3bb3b3bbbbbbbbcccccccccccccccccccccccc1111111122222222244444225ddd5655555555555555555555555555
3bbbbbb3bbbbbbb00bbbbbbb030303003bbbbbb33bbbbbb3cccccccccccccccccccccccc1111111122222222244222225d5d65dddddddddddd555555dddddddd
bbbbbbbbbbbbbb0330bbbbbb30000003bbbbbbbb33bbbb33ccccccccc777c7cccccccccc1111111111111111142222215d565d666666666666d55555666dd666
3bbbbbb3bbbbb03bb30bbbbbb304403b3bbbbbb3b3bbbb3bccccccccccccccccc7c777cc11111111ccccccccc122221c5d65d66666666666666d555566d66d66
b3bbbbbbbbbbb03b330bbbbbb3022033b3bbbbbbb3bbbb33cccccccccccccccccccccccc11111111111111111cccccc1565d6666666666666666d55566d66d66
3b33b3b3bbbbb033b30bbbbb3302203b3b33b3b3333bb33bcccccccccccccccccccccccc11111111ccccccccc111111c55d666666666666666666d5566dddd66
333b3b33bbbbb03bb30bbbbbb303303b333b3b33b333333bcccccccccccccccccccccccc11111111111111111cccccc15d66666666666666666666d566666666
33333333bbbbb033330bbbbb33033033333333333333333333333333333333332222222211111111b3b3bbbb11122211b5666666666666666666665b66666666
03333330bbbbbb0330bbbbbb303333030333333003333330033333303333333322222222111111113333b3b311242211b5666666666666666666665b66dddd66
03030300bbbbbbb00bbbbbbb0333333003030300030303000303030033333333222222221111111135553333c242222cb5666666666666666666665b66d66d66
30000003bbbbbb3223bbbbbb2333333240000004400000033000000433333333322333221111111154445555c222222cb5666666666666666666665b66dddd66
b300303bbbbbbb3223bbbbbb23333332222442222224403bb3044222b333333b3333333311111111444445441c2222c1b5666666666666666666665b66666666
3303003bbbbbbbb33bbbbbbb33bbbb33332222333322203b33022233b3333333333333331111111144444444c1cccc1cb5555555555555555555555b55555555
b3003033bbbbbbbbbbbbbbbb3bbbbbb33332233333322033b30223333333333b3333333317777771424242421c1111c1b3333333333333333333333b33333333
b303003bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333303bb303333bb333333b33333333111111114444444411cccc11b3333333333333333333333b33333333
__label__
b3bbbb3b3bbbbbb3b3jj3j3b3bbbbbb3b3bbbb3b3bbbbbb3b3j5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dj3b3bbbbbb3b3jj3j3b3bbbbbb3b3bbbb3b3bbbbbb3
b3bbbb33b3bbbbbb33j3jj3bb3bbbbbbb3bbbb33b3bbbbbb33j5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bj3bb3bbbbbb33j3jj3bb3bbbbbbb3bbbb33b3bbbbbb
333bb33b3b33b3b3b3jj3j333b33b3b3333bb33b3b33b3b3b3j5333533353335333533353335333533353j333b33b3b3b3jj3j333b33b3b3333bb33b3b33b3b3
b333333b333b3b33b3j3jj3b333b3b33b333333b333b3b33b3jbbbbbbbbbbbbbbbbbbbbbbbb77bbbbbbbbj3b333b3b33b3j3jj3b333b3b33b333333b333b3b33
3333333333333333333333333333333333333377733333333377bbbbbbbbbbbb77777777b77117bbbbbbbj333333333333333333333333333333333333333333
3b3bb3b3j333333j3b3bb3b3j333333j3b3777111733333j37117bb777777777111111117117717bbbbbb7777777733j3b3bb3b3j333333j3b3bb3b3j333333j
3bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jj3b7111777173j3jj7177177111111111777777771777717bbbbb7111111117jj3bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jj
bbbbbbbb3jjjjjj3bbbbbbbb3jjjjjj3b71777777717jjj71777171777777777777777771777717bbbb7177777777173bbbbbbbb3jjjjjj3bbbbbbbb3jjjjjj3
3bbbbbb3b3jj3j3b3bbbbbb3b3jj3j3b717777777771722717777117777777777777777717777117bbb717777777717b3bbbbbb3b3jj3j3b3bbbbbb3b3jj3j3b
b3bbbbbb33j3jj3bb3bbbbbb33j3jj3b717777777771723717777117777777777777777717777117bbb7177777777717b3bbbbbb33j3jj3bb3bbbbbb33j3jj3b
3b33b3b3b3jj3j333b33b3b3b3jj3j33717777117771737177777171117777111177771117777117bbb71777777777173b33b3b3b3jj3j333b33b3b3b3jj3j33
333b3b33b3j3jj3b333b3b33b3j3jj37177771117771177177777711117777111177771117777117bbb7177711111117333b3b33b3j3jj3b333b3b33b3j3jj3b
33333333333333333333333333333337177771117111177177777711117777111177771117777117bbb717771111111173333333333333333333333333333333
j333333j3b3bb3b3j333333j3b3bb3b7177771111111171777777717117777111177771117777117bbb71777111111117333333j3b3bb3b3j333333j3b3bb3b3
j3j3j3jj3bbbbbb3j3j3j3jj3bbbbbb7177771171111171777177771717777117177771117777117bbb7177777771117j3j3j3jj3bbbbbb3j3j3j3jj3bbbbbb3
3jjjjjj3bbbbbbbb3jjjjjj3bbbbbbb7177771171111771777117771717777117177771171777117bb717777777717724jjjjjj3bbbbbbbb3jjjjjj3bbbbbbbb
b3jj3j3b3bbbbbb3b3jj3j3b3bbbbbb7177771177177717771117771717777117177771171777117bb7177777777173222244j3b3bbbbbb3b3jj3j3b3bbbbbb3
33j3jj3bb3bbbbbb33j3jj3bb3bbbbbb71777117b7bb717771117771117777117177771171777117bb7177771111117333222j3bb3bbbbbb33j3jj3bb3bbbbbb
b3jj3j333b33b3b3b3jj3j333b33b3b3717771177173717777777777117777117177771171777117777177771111117b33322j333b33b3b3b3jj3j333b33b3b3
b3j3jj3b333b3b33b3j3jj3b333b3b33717771171717177777777777117777117177771171777111111177771111117bb3333j3b333b3b33b3j3jj3b333b3b33
333333333333333333333333333333337177711177711777777777771177771171777711717777777771777777777717b333333b333333333333333333333333
3b3bb3b3j333333j3b3bb3b3j333333j71777777777717771111177771777711717777117177777777717777777777173b3bb3b3j333333j3b3bb3b3j333333j
3bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jj37177777777177771111177771777711717777117177777777717777777777173bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jj
bbbbbbbb3jjjjjj3bbbbbbbb3jjjjjj3b7177777771177771111177771777711717777117177777777717777777777117bbbbbbb3jjjjjj3bbbbbbbb3jjjjjj3
3bbbbbb3b3jj3j3b3bbbbbb3b3jj3j3b37111777111111111111111111111111771111117711111111111111111111117bbbbbb3b3jj3j3b3bbbbbb3b3jj3j3b
b3bbbbbb33j3jj3bb3bbbbbb33j3jj3bb37111111777111777777771111771117711111171777111117771111777711173bbbbbb33j3jj3bb3bbbbbb33j3jj3b
3b33b3b3b3jj3j333b33b3b3b3jj3j333b711177777771177777777771777711111777111777711777777771177771117b33b3b3b3jj3j333b33b3b3b3jj3j33
333b3b33b3j3jj3b333b3b33b3j3jj3b3337177777777717777777777177771177777777177771777777777117777117333b3b33b3j3jj3b333b3b33b3j3jj3b
33333333333333333333333333333333333717777777771177777777717777177777777717777177777777771777711733333333333333333333333333333333
j333333j3b3bb3b3j333333j3b3bb3b3j337177771177711777111777117771777777777717771777711777717777117j333333j3b3bb3b3j333333j3b3bb3b3
j3j3j3jj3bbbbbb3j3j3j3jj3bbbbbb3j371777711177711777111777111111777711777711111777111177717777117j3j3j3jj3bbbbbb3j3j3j3jj3bbbbbb3
3jjjjjj3bbbbbbbb3jjjjjj3bbbbbbbb3j717777111111117771117771777717771111777177717777111771117771174jjjjjj3bbbbbbbb3jjjjjj3bbbbbbbb
b3jj3j3b3bbbbbb3b3jj3j3b3bbbbbb3b37177771111111177711177717777177771117711777177777111111177711722244j3b3bbbbbb3b3jj3j3b3bbbbbb3
33j3jj3bb3bbbbbb33j3jj3bb3bbbbbb337177771171111177717777711777177777111111777117777771111177711733222j3bb3bbbbbb33j3jj3bb3bbbbbb
b3jj3j333b33b3b3b3jj3j333b33b3b3b37177771177111177777777711777117777771111777111777777111177711733322j333b33b3b3b3jj3j333b33b3b3
b3j3jj3b333b3b33b3j3jj3b333b3b33b3717777117b7771777777771117771117777771117771111177777171771117b3333j3b333b3b33b3j3jj3b333b3b33
3333333333333333333333333333333333j71777117b7b71777777711117771111177777117771177111777711771117b333333b333333333333333333333333
3b3bb3b3j333333j3b3bb3b3j333333j3jb71777117717717777777111177711771117777177717777111777117711173b3bb3b3j333333j3b3bb3b3j333333j
3bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jjjbb717771171717177717777111777177771117771777177711117771711117j3bbbbbb3j3j3j3jj3bbbbbb3j3j3j3jj
bbbbbbbb3jjjjjj3bbbbbbbb3jjjjjj423b7177711177711777117771717771777111177717771777111177711771173bbbbbbbb3jjjjjj3bbbbbbbb3jjjjjj3
3bbbbbb3b3j44j3b3bbbbbb3b3j4422223b717777777777177711777711777177711117771777177777777771777717b3bbbbbb3b3jj3j3b3bbbbbb3b3jj3j3b
b3bbbbbbb3j22j33b3bbbbbb33j222333bbb71777777771177711177771777177777777771777177777777711777717bb3bbbbbb33j3jj3bb3bbbbbb33j3jj3b
3b33b3b333j22j3b3b33b3b3b3j22333bbbb7177777771117771111771177717777777771177711777777771117711733eeeeee3b3jj3j333b33b3b3b3jj3j33
333b3b33b3j33j3b333b3b33b3j3333bbbbb711177711111177111171117771177777777117771117777711111111117e111111eb3j3jj3b333b3b33b3j3jj3b
3333333333j33j333333333333jbbbbbbbbbb711111111111111171111111111177777111111111111111111111111171dddddd1eee333333333333333333333
j333333j3j3333j3j333333j3jbbbbbbbbbbb711111111111111111111111111111111111111111111111111171111711dddddd1111ee3b3j333333j3b3bb3b3
j3j3j3jjj333333jj3j3j3jjjbbbbbbbbbbbbb711111111111111111111111111111111111111111111111117e71178826dddd6288811eeee3j3j3jj3bbbbbb3
4jjjjjj4233333324jjjjjj423bbbbbbbbbbbbb771117117771777177717771111171717771777177111117711177888e26dd62e888881111ejjjjj3bbbbbbbb
22244222233333322224422223bbbbbbbbbbbbbbb77711171717111171171711111717171117171171117716118888ee22666622ee88881161ej3j3b3bbbbbb3
3322223333bbbb33332222333bbbbbbbbbbbbbbbb1317117711771117117771111171717711771117111e1d1188e8efe29222292efe8e8811d1ejj3bb3bbbbbb
333223333bbbbbb333322333bbbbbbbbbbbbbbbbbb311117171711117117171111177717111717117111e1d188e8efe2219999122efe8e881d1e3j333b33b3b3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb13117771777117117171111117117771717177711e1128ee8ee211111111112ee8ee8211ejj3b333b3b33
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111111111111111111111111111111111111e1188e88e2161dddddd1612e88e8811e333333333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111111111111111111111111111111111be12888888211d111111d11288888821eb3b3j333333j
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe18888e8821d11777711d1288e88881ebbb3j3j3j3jj
bbbbbbbbbbbbbbbbbb3b3bbbbbbbbbbb1711771bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe18288e8881d17777771d1888e88281ebbbb3jjjjjj3
bbbbbbbbbbbbbbbb3b3b3b3bbbbbbbbb17177111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1e988ef8821117777111288fe889e1ebbb3b3j44j3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb31111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1f188eee88811111111888eee881f1ebbbbb3j22j33
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb31331311bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe18e888eefe888eeee888efee888e81eb3b333j22j3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1888888effeeffffeeffe8888881eb3b33b3j33j3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe128e22d8eee222222eee8d22e821e3333333j33j33
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe12e2928ee28888882ee8292e21e33333j3j3333j3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe118f2288288effe8828822f811ej3j3jjj333333j
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1771171bbbbbbbbbbbbbbbbbbbbbbbbbbbbbe1d112888828e8228e828888211d1ejjjj423333332
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11177171bbbbbbbbbbbbbbbbbbbbbbbbbbbbbe16111228828e2992e82882211161e4422223333332
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11111113bbbbbbbbbbbbbbbbbbbbbbbbbbbbe1d66111122128e55e82122111166d1e223333bbbb33
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11313313bbbbbbbbbbbbbbbbbbbbbbbbbbbbe16d6d11e11112288221111e11d6d61e23333bbbbbb3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe16dd1ebeee11111111eeebe1dd61ebbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbe111ebbbbceeeeeeeecbbbbe111ebbbbbbb333333b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbeeebbbb5cc717717cc5bbbbeeebbbbbbb3b3bb3b3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1171bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb57c77111177cd5bbbbbbbbbbbbj3bbbbbb3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11171bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3b3bbbbbbbbbbbbbbb5d6cc711717cc5d5bbbbbbbbbbj3bbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb171711bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3b3b3b3bbbbbbbbbbbb55d6c77177177c55d5bbbbbbbbj3b3bbbbbb3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb117131bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5ddd6cc711117cc555d5bbbbbbbj3bb3bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111113bbbbbbbbb1111111111111111111111111111111111111bbbbb5dd511c77111177c1155d5bbbbbbj333b33b3b3
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1131bbbbbbbbb111111111111111111111111111111111111111bbb5d5d511cc771177cc11555d5bbbbbj3b333b3b33
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb117171777117717171177117711771777177711bbb5ddd111cc777777cc1115555bbbbbj3333333333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb117171171171117171711171117171717171111bbb5d5d111ccc7777ccc1115555bbbbbbj3j333333j
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb117771171171117771777171117171771177111bbb5d5d1111cccccccc11115555bbbbbbbjj3j3j3jj
bbbbbbbbbbbbbbbbbbbbbbbbbb3b3bbbbbbbbbbbbbbbbb117171171171717171117171117171717171111bbb5ddd51111cccccc111155555bbbbbb324jjjjjj4
bbbbbbbbbbbbbbbbbbbbbbbb3b3b3b3bbbbbbbbbbbbbbb117171777177717171771117717711717177711bbb5d5d51111111111111155555bbbbbb3222244222
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111111111111111111111111111111111111111bbb5d5ddd611111111115555555bbbbbbb333222233
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111111111111111111111111111111111bbbb5ddd5d6d11111111d5555555bbbbbbbb33322333
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb5d5d5d6dddddddddd5555555bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11111b111bbb11111bb311133bb111bbb111bbbbbb5d5ddd7ccccccccc75555555bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb17777717771b1777771317771b317771b17771bbbbb5ddd56555555555555555555bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb171111b1771bb1117713b1771b1771771771771bbbb5d5d65dddddddddddd555555bbbbbbbbbbbbbbbb
bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5b17777151771bbb17713bb1771bb177711771771bbb55d565d66666dd66666d55555bbbbbbbbbbbbbbbb
ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5dd1117711771dd17713b3b1771b1771771771771ddd55d65d66666d66d66666d5555bbbbbbbbbbbbbbbb
bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5b1777771777711771j3bb1777711777771777771bbb5565d666666d66d666666d555bbbbbbbbbbbbbbbb
3335333533353335333533353335333533353335333531cccc11cccc11cc1j3331cccc131ccc131ccc15333555d6666666dddd6666666d55bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111bb1111bb11bj3b33111133b111bbb111bbbbbb5d66666666666666666666d5bbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj333333333333jbbbbbbbbbbbbbb5666666111111116666665bbbbbbbb111bbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj3j333333j3jbbbbbbbbbbbbbbb5666666111111116666665bbbb1111161111bbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbjj3j3j3jjjbbbbbbbbbbbbbbbb5666666151515156666665bbbb16dd1611661bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111111111111111111111111111111111111111111111111111111115151516666665bbbb16dd1611661bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1777777777777777777777777777777777777777777777777777777777155555556666665bbbb16666666661bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1771171117111711171117777777777777777777777777777777777777155555555555555bbbb1d11ddd11d1bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1717777177171717177177777777777777777777777777777777777777133333333333333bbbb31111111113bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1711177177111711777177777777777777777777777777777777777777133333333333333bbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb17771771771717171771777777777777777777777777777777777777771bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb17117771771717171771777777777777777777777777777777777777771bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb17777777777777777777777777777777777777777777777777777777771bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbb3b3bbbbbbbbbbbbbbbbbbbbbbbbb11111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbb3b3b3b3bbbbbbbbbbbbbbbbbbbbbbb11177171717771717177711771777177117771177111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11711171717111717171717171171171711711711111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11711177717711771177717171171171711711777111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11711171717111717171117171171171711711117111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb311177171717771717171117711777171711711771111111111111111111b3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3
33133131331331313313313133133131331331111111111111111111111111111111111111111111111111111111111113133131331331313313313133133131
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
77771771777717717777177177771771777717717777177177771771777717717777177177771771777717717777177177771771777717717777177177771771
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
13313313133133131331331313313313133133131331331313313313133133131331331313313313133133131331331313313313133133131331331313313313
3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b3bb3bb3b
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3b3bb3b3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbj3bbbbbb3jbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbj3bbbbbbbb3jb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5bbb5

__map__
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c0c0c0c0c0c0c0c0c0c0c1c0c0c0c0c0c0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c0c1c0c0c0c0c0c2c3c0c0c0c0c0c0c0c0c0c1c0c0c0c0c0c0c2c3c0c0c0c0c1c0c0c0c0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e60000
f5e4f6f3f5e4f6f3f4f3f5e4e3e4e3e4e3e4c0c0c0c1c0d7c0c0c0c0c0c0e1e0e5e0e5e0f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c4c4c4c4c5e0c6c4c2c3c4c4c4c4c4c4c4c4c0cccdcdcdcdcec0c2c3c0cccdcdcdcdcec0c0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0e6e6e7e6e6e6e6e6e6e6e6e6e6e6e6e6e6e60000
f1f4f2c1f1f4f2c0c0c1f1f4f3f4f3f4f3f4e0e2c0d4c0c0c0c0c0c0c0e1e0f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c1c0c0f1f4f2c0c2c3c0c0c1e1e0e2c0c0c0dcdfdddddddec0c2c3c0dcdfdddddfdec0c0c4c4c2c3c0c0c1c0c0c0c0c0c2c3c4c4c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e8e6e60000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0e0e5e0e5e0e2c0c0c0c1f1f5e4f0e4f0e4f0e4f6f3f4f3f4f3f5e4e3e4f0e4f0e4f0e4c0c0c0c0c0c0c1c0c2c3c1c0c0f1f4f2c0c0c0dcdda5a5dfdec0c2c3c0dcdda5a5dfdec0d0d0d0e9e9d0d0d0d0d0d0d0d0e9e9d0d0d0b5b6b6b5b6b6b6b5b6b5b5b6b6b5b6b5b6b50000
d1d2e4d3d1d1d1d2e4d3d1d2e4d3d1d1d1d2e4f0e4f0e4f6f2c0c0c0c0e1e0f0e4f0e4f0e4f6f2c0c1c0c0c0f1f4f3f5e4f0e4f0e4f0c0c0c0c0c1c0c0c0c2c3c0c0c0c0c0c0c0c1c0dcdddfdddfdec0c2c3c0dcdddfdddfdec1d1d1d1d1d1d1d1d1e9e9d1d1d1d1d1d1d1d1c0c1c0c0e1e4e2c0c0c0c0c0c0c0c1c0c1c00000
e5e0f0e0e5e0e5e0f0e0e5e0f0e0e5e0e5e0f0e4f0e4f6f2c0c0c0d4e1e0f0e4f0e4f0e4f0e4e2c0c0c0c1c0c0c0c0f1f5e4f0e4f0e4b5b6b5b6b5b6b5b6b5b6b6b5b6b6b6b6b5b6c0dcdddfdddfdec1c2c3c0dcdfdddddfdec0c0c0c0c0c0c0c0c0c2c3c0c0c0c0c0c0c1c0c0c0c0c0f1f4f2c0c0c0c1c0c0c0c0c0c0c00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f6f2c0c0d7c0c0f1f5e4f0e4f0e4f0e4f6f2c0c0c0c0c0c0c1c0e1e4f0e4f0e4f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0dcdfdddddddec0c2c3c0dcdfdddddddec0c0c0c0c1c0c0c0c0c2c3c0c0c1c0c0c0c0c0c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c40000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e0e2c1c0c0c0c0c0f1f5e4f0e4f0e4f0e4e5e0e2c0c0c0c0c0c0f1f5e4f0e4f0e4c0c0c0c0c1c0c0c0c0c0c0e1e0e2c0c1c0c0c0dcdddddfdddec0c2c3c0dcdddddddfdec0c0c0c0c0c0c0c0c0c2c3c0c0c0c0c0c0c0c0c0c0c0a8aac0c0c0c0c0c0c0c0c0c0c0c0c00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4e3e4f6f2c0c0c0c0c0c0e1e0f0e4f0e4f0e4f0e4f0e0e2c0c0c1c0c0e1e0f0e4f0e4f0c0c0c0c0e1e0e2c0c0c0c0f1f4f2c0c0c0c0c0dcdfdddddddec0c2c3c1dcdddddddfdec0c4c4c4c4c4c4c4c4c2c3c4c4c4c4c4c4c4c4c0c0a8b7b7a9a9a9aac0cccdcdcdcec0c0c00000
f0e4f0e4f0e4e3e4f0e4f0e4f0e4f0e4f0e4f4f3f4f2c0d5c0c0c0c1c0f1f5e4f0e4f0e4f0e4f0e4f6f2e1e0e2c0e1e0f0e4f0e4f0e4c0c1c0c0f1f4f2c0c0c1c0c0c0c0c0c1c0c0c0dcdddddddfdec0c2c3c0dcdfdddddddec0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0cccdcdcdcdcdcdcdcddcabacaddecdcec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4e3e4f0e4f0c0c0c1c0d4c0c0c0c0c0c0c0f1f5e4e3e4e3e4f0e4f0e0e2f1f4f2c0f1f5e4f0e4f0e4f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c1dcdfa5a5dddec0c2c3c0dcdfa5a5dfdec0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b0b1f9e9c0dcdda5a5dfdddddddfdcbbbcbddedddec10000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c0c0c0c0c0c0d6c0c0c0c0c0c0f1f4f3f4f3f0e4f0e4f0e0e2c0c0c1e1e0f0e4f0e4f0e4cafacbfacacbcacafafafacbfafafacbfacac0dcdddddddfdec0c2c3c0dcdddddddfdec0f9b2b1e9f9f9e9e9e9e9e9f9f9e9b2b1f9e9c1dcddddddddddaedddddcaedddddedddec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c0c0c0d7c0c0c0c0c1c0cccdcee1e0e2c0e4f0e4f0e4f6f2c0c0c0f1f5e4f0e4f0e4f0dadadadadadbdadadadbdadadadadadadbdac0dcdfdddddfdec0c2c3c0dcdfdddddfdec0f9b0b1e9f9b2b1e9e9e9b0b1f9e9e9f9b0b1c0dcddaeddabacacadaedcdddddddedddec00000
f0e4e3e4f0e4f0e4f0e4f0e4f0e4e3e4f0e4c0c0c0c1c0c0c0c0c0c0c0dcdddef1f4f2c0f0e4f0e4f6e0e2c0e1e0e2f1f5e4f0e4f0e4f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8c0ecededededeec0c2c3c0ecededededeec0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b0b1f9e9c0dcdfa5abe9e9e9e9addcdddfdfdedddec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c4c4c4c4c4c4c4c5e0c6c4ecefeec0c0c0c0e4f0e4f0e4f6f2c0f1f4f2e1e0f0e4f0e4f0e4f7e4f7e4f7e4f7e4f7e4f7e4f7e4f7e4f7c0fcffcfcffffec1c2c3c0fcffcfcffffec0f9b0b1e9f9f9e9e9e9e9b2b1f9e9b0b1f9e9c0dcdda5bbe9e9e9e9bddcdddfdddedddec00000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c0c0c0c0c0c0c1f1f4f2c0fccffea0a1c0c0f0e4e3e0f6f2c0c1c0c0c0f1f5e4e3e4e3e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c0c1c0b8bac0c0c0c2c3c0c0c0b8bac0c1c0f9b2b1e9f9b0b1e9e9e9b0b1f9e9e9f9b0b1c0dcdfddaebbbcbcbddddcdddddfdedddec00000
e4e3e4e3e4f6f3f4f3f4f3f4f3f5e4e3e4e3c0c1c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0f3f4f3f4f2c0c0c0c1c0c0c0f1f4f3f4f3f4e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c8c4c4c4c4c4c4c9c2c3c0c0a8a9a9aac0c0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b2b1f9e9c0dcdddddfddddaedfa5dcdddddddedddec00000
f4f3f4f3f4f2c0c0c1c0c0c0c0f1f4f3f4f3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0e4f0e4e3e4f0e4f0e4f0e4e3e4f0e4f0e4c7c0c0c0c0c0c0c7c2c3c0c0b8b9b9bac0c0f9b0b1e9f9f9e9e9e9e9b0b1f9e9b0b1f9e9c0dcdda5a5dda5a5dddddcdda5dfdedfdec00000
c0c0c0c1c0c0c0c0c0c0c0c0c1c0c0c0c0c0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2e4d3d1d1d1d1d1d1d1d2e4d3d1d2e4d3e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0d8c4c4c4c4c4c4d9c2c3c0c0c0c0c0c0c0c0f9b0b1e9f9b2b1e9e9e9b0b1f9e9e9f9b0b1c0dcdda5a5dfa5a5dddfdcdfdfdddedddec00000
cacafacacbcafacafafacacbcafacacbfacac4c4c4c4c4c4c4c4c4c5e0c6c4c4c4c4c4c4e5e4f0e4e5e0c6c4c4c4c5e0f0e4e5e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4a9a9a9a9a9a9a9aac2c3a8a9a9a9a9a9a9a9d1d1d1d1d1d1d1d1e9e9d1d1d1d1d1d1d1d1c1dcdddddddddddddddddcdda5dfdedddec00000
dadbdadadadadadadbdadadadbdadadadadbc0c0d7c0c0c0c0d6c0f1f4f2c0c0c1d5c0c0e4f0e4f0e4f6f2e1e0e2f1f5e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4e3e4f0b9b9b9b9b9b9b9bac2c3b8b9b9b9b9b9b9b9c4c4c4c4c4c4c4c4c2c3c4c4c4c4c4c4c4c4c0dcdddfdddddfdddddddcdda5dddedddec00000
eaeaebeaeaeaeaeaeaeaeaebeaebeaeaeaeac0c1c0c0c0d4c0c0c0c0c1c0c0c0c0c0d7c0f0e4f0e4f6e0e2f1f4f2c0f1f5e4f0e4f0e4f0e4e3e4f0e4f6f3f4f3f4f3f5e4f0e4f0e4c0a8a9aac0c1c0c0c2c3c0c0c0c0c0c1c0c0c0c1c0c0c0c0c1c0c2c3c0c0c0c0c1c0c0c0c0dcdfa5a5dda5dddddddcdddfdfdedfdec10000
e9e9e9e9e9e9fbe9e9e9e9e9e9e9e9fbe9e9c0c0c0c0c0c0c1c0c0c0d5e1e0e2c0c0c0c0e4f0e4f0e4f6f2c0c0c0c1e1e0f0e4f0e4f0e4f0e4f0e4f6f2a8a9a9aac1f1f5e4f0e4f0c0b8b9bac0c0a8aac2c3c0c1c0c0c0c0c0c0c0c0c0c0c0c0c0c0c2c3c0c1c0c0c0c0c1c0c0dcdda5a5dda5a5ddddecefefefeedddec00000
e9e9fbe9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0c0c1c0c0c0c0c0c0c0c0f1f4f2c0c1c0c0f0e4f0e4f6f2c0c0c0c0c0f1f5e4f0e4f0e4f0e4f0e4f6f2a8b7b7b7b7aae1e0f0e4f0e4c0c1c0c0c0c0b8bac2c3c0c0c0c0c0c0c0c0c0c0c0c1c0c0c0c0c2c3c0c0c0c0c0c0c0c0c0dcdfdddfdddddddddddfdfdfdddddddec00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e0e2c0c0c0e1e0e2c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0e4f0e4f0e0e2b8b7b7b7b7baf1f5e4f0e4f0c8c4c4c4c4c4c4c9c2c3c8c4c4c4c4c4c4c9c8c4c9a6a7c8c4c9c8c4c9c8c4c9c8c4c9c8c0dcdda5a5dda5a5dddda4dda4dda4dfdec00000
e6e6e7e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f2c0c0c0f1f4f2c0c0c0c1d6c0c0c1e1e0c0c0c0c0c0c0c0c0c0d7c0c0c0c1c0c0c0c0f0e4f0e4f0e0e2b8b7b7bac0e1e0f0e4f0e4c7d4c0c0c0d6c0c7c2c3c7d5d7d5c0d7c0c7c7d7c7a6a7c7d4c7c7d6c7c7d6c7c7d6c7c7c0dcdfa5a5dda5a5dddfb4ddb4ddb4dfdec00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e8e6e6e0e2c0c1c0c0d6c0c0e1e0e2c0c0d5c0f1f5c0c0c1c0e1e0e2d6c0c0c0c0c0c0c0c0c0c0e4f0e4f0e4f6f2a2c0c0c0c1f1f5e4f0e4f0c7c0d7d6d5c0d7c7c2c3c7c0c0d4c0d6c0c7c7d6c7a6a7c7d7c7c7d5c7c7d7c7c7d6c7c7c0dcdddddddfdddddddddddddfdddfdddec00000
e6e6e6e6e6e6e6e6e8e6e6e6e6e6e6e6e6e6f0e0e2c0d4c0c0c0c0f1f4f2c0c0c0d6e1e0c0c0c0c0f1f4f2c0d5c0c0c1c0c0c1c0c0c0f0e4f0e4f0e0c1c0a2a2c0a2e1e0f0e4f0e4d8c4c4c4c4c4c4d9c2c3d8c4c4c4c4c4c4d9d8c4d9a6a7d8c4d9d8c4d9d8c4d9d8c4d9d8c0ecededededededededededededededeec00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e4f0e0e2c0c0d7c0c0c1c0c0c0d7c0e1e0f0c0c0c0d5c0c0c0c0c0c0c0c0d4c0c0d5c0c0e4f0e4e3e4f0e0e2a0a1c1e1e0f0e4f0e4f0c8c4c4c4c4c4c4c9c2c3c8c4c4c4c4c4c4c9c8c4c9a6a7c8c4c9c8c4c9c8c4c9c8c4c9c8c0fccfcffdcfa3fdcfcffdfdffffffcffec10000
e6e6e6e6e6e6e6e6e6e6e6e6e7e6e6e6e6e6f0e4f0e0e2c0c0c0c0c0c0c1c0c0e1e0f0e4c0c0d4c0c0c0c1c0c0c0c0c0e1e0e2c0c0c0f0e4f0e4f0e4f0e0e2a0a1f1f5e4e3e4f0e4c7d7c0d4c0d7c0c7c2c3c7c0d4d5c0d7c0c7c7d5c7a6a7c7d6c7c7d5c7c7d4c7c7d4c7c7c0e9e9a3e9e9b3e9e9b2b1a3a3e9e9b0b1c00000
e6e6e6e8e6e6e6e6e6e6e6e6e6e6e6e6e6e6e4f0e4f0e0e2c0e1e0e2c0e1e0e5e0f0e4f0c0c0c0c0c0c0c0c0c0c0c1c0f1f4f2c0c0c0e4f0e4f0e4f0e4f0e0e5e0e5e0f0e4f0e4f0c7d5d6c0d5c0c0c7c2c3c7d5c0c0d6c0d6c7c7d4c7a6a7c7d4c7c7d4c7c7d5c7c7d7c7c7c1e9e9b3e9e9e9e9e9e9e9b3b3a3e9b2b1c00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f0e4f0e4f0e0e5e0f0e0e5e0f0e4f0e4f0e4c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4d8c4c4c4c4c4c4d9c2c3d8c4c4c4c4c4c4d9d8c4d9a6a7d8c4d9d8c4d9d8c4d9d8c4d9d8c0e9e9e9e9e9e9e9e9e9e9e9e9b3e9e9e9c00000
__sfx__
1507000030013320132c0132c013386030b1000b10000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
4d0600001a660356502a6402d6402e6402564024620166201f620306201a62012620106202a6200e6201e620116100a6100861006610046100361003610026100161000610006100000000000000000000000000
12020000129701f9703c9703a67038670346703467033670316702e6702d6702b6701263013670146701567015670146701367012670106700f6700e6700d6700c6700b6700867004670006700b6700867005670
12020000129701f9703c970376703867027670396701c670306703067025670326700b6300e670106700867005670056700567008670096700a67008670076700567006670096700b67003670036700267002670
12020000129701f9703c970386703e670376703567035670376703367031670316701f63022670256702867029670146700b6700c67006670046702067024670256700b670216701d6701d630286302c62005600
010300003a0363f0463c0161b5002250017500225001750000000175000a5000a5000050000500005000050000700007000070000700007000070000700007000070000700007000070000700007000070000700
060300003264009600106000c600156000c600176000c6001c6000c600176000c600156000c600106000c600136000c600156000c60019600186001a60018600196000c600176000c600156000c6001060000600
010100002115316130141200f1200c1200c1000a100091000810008100071000710006100051000c100171000c100151000c10010100001000010000100001000010000100001000010000100001000010000100
090c00000f063184101c4101f410234101f4101c4101841017410184101c4101f410234201f4201c4101841017410184101c4101f410234201f4201c420184100f063184141c4101f410234201f4201842017420
090c00000f063194141c4102141023420214201c4101941017414194101c4102141023420214201c420194100f033194141c4202142023430214301c420194100f063194241c420214301a440194401a4321c430
110c00000023000230002300023000230002300023000230002300023000230002300023000230002300023000230002300023000230002300023000230002300723007230072300723007230072300723007230
150c0000092400924009240092400924009240092400924009240092400924009240092400924009240092400f063092400924009240216550924009240092400f0630924009240092402d6552d6450924009240
150c00001f2301c230182301723013230102300c2300b230072300b2301023013230172301c2301f230232301f2301c230182301723013230102300c2300b230072300b2301023013230172301c2301f23023230
050c00001c5441854013540105450c54507545045400053004534075350c5451054513545185451c5401f5401c54018540135401054513545105450c5400753004534075350c5451054513545185451c5401f540
110c00001b2211f2201f2201f2201f2201f2201f2201f2201f2221f2221f2201f2201e2201e2201f2201f2201f2201f2201c2201c2201c2201c220172201c22013220132201c2201c2201f2201f2202122021220
110c0000212202122021220212202122021220212202122021220212201e2201e2201f2201f22021220212222122221222232202322023220232200e220122202122021220232202322021221212201f2201f220
050c00002354023540235402354024540245402354023540235402354021540215401f5401f540265402654226542265421c5421c5411c5411c5411e5401e5411e5411e5411f5401f5411f5411f5411c5401c540
150c00000f073043440425004265326202d62304250042453e605135001323517245326202d62332625042650f073043550425004265326202d62304350042653e6053e6051a63426631326202d6253200000000
150c0000022200233002240022502d62026625023300e330022200f07302225022202d6202662502230022350b2200b3200b2300b2402d620266250b230172300b2300b2300b2200f0632d620266250b2300b230
150c00001f2551c255182451724513235102350c2350b235072250b2251023513235172351c2351f245232551f2551c255182451724513235102350c2350b235072250b2251023513235172351c2351f24523255
110c000004337040001031012325103250400004320040001034504335103051c00000335003050c3251c0001031013325103251230510310123251032510000103441050404335105000c335105000333510700
150c00001f2211f2201f2201f2201f2201f2201f2201f2201f2221f2221f2201f2201f2201f2201f2201f2201f2201f2201f2201f2201f2201f2201f2201f2201c2201c2201c2201c2201c2201c2201c2201c220
050c00000f06304770047700477004770047700477004770047700477004770047700477004770047700477004770047700477004770047700477004770047700477004770047700477004770047700477004770
150c00002122021222212202122021221212212122021220212212122021220212202122021220212222122213240122401324015240172421524017240192401a240192401a2401c2401e2501c2501e2501f250
050c00000977009770097700977009770097700977009770097700977009770097700977009770097700977012073067740677006770067700677006770067701377113770137701377013770137701377013770
150c00000f0731824513245102450c3450434504235002350f073072350c2351023513235182351c2451f2550f07318245132451023513245102450c235072250f073072250c2351023513245182451c2451f255
150c00000f07315245122450e245093450634502235092350f07312235152351a2351e23521235262452a2550f0731a24517245122350e2450d2450b2350e2250f07315225172351b2351e24523245272452a255
150c0000002200032000230002402d62026625003200c3200022010633002250f0532d620266250022000225002200032000230002402d620266250022000220002200022010043100032d62026625004250c420
150c0000072200723007240072402d620266250f0731332007230072300f063072352d625266250f0530f0530f0730b3050c601106010e61111611156111d6112361126611296112f61132611356113b6113b611
110c00001f2201f2201f2201f2201f2201f2201f2201f2201f2221f2221f2201f2201e2201e2201f2201f2201f2201f2201c2201c2201c2201c220172201c22013220132201c2201c2201f2201f2202122021220
110c00000f073232451f2451a23517230132250e2250b2250e23513235175051a2251f22023220262302b2300b2300b2200b2200b2000b200174050b2350b2001b4041e405174050b2402d62021621156112d600
090c00001f2241c220172201522513225102250d2200b2200d224102251322517225192251c2251f2202322013230122301323015230172301523017230192301a230192301a2301c2301e2301c2301e2301f230
110c00001c2201922013220102200d220072200422001220102201322017220192201c2201f220232202522028230252301f2301c2301f2301c2301923013230102301323017230192301c2301f2302323025230
150c0000072300733007230072302d6202662507330133300723010633072250f0532d6202662507220072350b2200b3200b2200b2202d620266250b2200b2300b2300b230100330f0532d62026625326252d625
150c00000f073232351f2351a23517335133350e2250b2250f07313215172251a2251f23523235262452b2450f073232351e2351a23517245122450e2350b2250f073062150b2250e22512235172351e24526245
110c00002322023220232202322024220242202322023220232202322021220212201f2201f220262202622226222262221a2211a2201a2201a2201c2201c220172200223106230172301a230122301a2301e230
050c00001f5401f5401f5401f5401f5401f5401f5401f5401f5421f5421f5401f5401e5401e5401f5401f5401f5401f5401c5401c5401c5401c540175401c54013540135401c5401c5401f5401f5402154021540
050c00002154021540215402154021540215402154021540155401a5401e5401e5401f5401f54026541265422654226542235402354023540235400e5400b540125402654023540235401e5411e5401f5401f540
110c000004337040001031012325103250400004310040001034504345103051c00000345100000c3451c0001031013325103251230510310123251032510000103141232513325123001c614136122362228640
090800001842018420174201742018420184251a4201a4201a4201a42018420184201a4201a4251b4301b4301b4301b43018420184251b4201b4251f4301f4301f4301f4301f4301f4301e4311f4311f4301f430
0d080000133201332011320113201332013325163201632016320163201332013320163201632518320183201832018320133201332518320183251b3301b3301b3301b3301b3301b3301a3311b3311b3301b330
110800001b2201b2201a2201a2201b2201b2251d2301d2301d2301d2301b2301b2301d2301d2301f2301f2301f2301f2301b2301b2301f2301f23522230222302223022230222302223023231232302323023230
0111000010063100032a63510063100032a6052a6351500310063100332a6351500310063100432a6350000010063100032a6351006310003100032a6351003310063100332a6351500310063100332a63500000
091100000f2300f2320f2320f2300f2300e2300f2301123011230112301123011232112300f230112301323013230132300f2300f2300e2300e2300c2300c230112301323014230142301423214232142300b200
111100000c2240c2200c2200c2200c2200a2200c2200e2200e2200e2200e2200e2200e2240c2200e2200f2200f2200f2200c2200c2200a2200a22007220072201422016220182201822018220182200640017400
11110000182301823218230182301823017230182301a2301a2301a2301a2321a2301a230182301a2301c2321c2301c23021230212321c2301c2301823018230112301f230202302023220230202321420014200
091100001522015222152221522015220102201522017220172201722017220172221722015220172201822018220182201c2201c2201822018220102201022014220182201d2201d2201d2221d2221720017200
1511000000265002650c2650026500265002650c2650026500265002650c2650026500265002650c2650026500265002650c2650026500265002650c2650026500265002650c2650026500265002650c26500265
1511000000220002200c2200022000220002200c2200022000220002200c2200022000220002200c2200022000220002200c2200022000220002200c2200022000220002200c2200022000220002200c22000220
151100000334500345083450734503345003450834507345033550035508355073550335500355083550735503355003550835507355033550035508355073550336500365083650736503365003650836507365
010e00002d6402b64028640266302463022630206301d6301b6201962016620116200d6200b62009620076200362003620026200062002620026200c6000c2001120013200142001420014200142001420000000
1511000010063092302a6351006309330092302a6350924010063092402a6350923010063100632a6350923010063092302a6351006309240092402a6350924010063083302a6351006310063082402a63508330
1511000010063093452a635100630c345093552a6351034510063093552a6351035510063100632a63510355100531000309204092340934509245106001030510073013250d3350833510073100630d36508375
11110000182301823018230182301823017230182301a2301a2301a2301a2301a2301a230182301a2301c2301c2301c230242302423021230212301c2301c230112301323014230142300d2300d230082300b200
1511000010063003452a6350406303345003452a6350734510063003552a6350735510063100632a6350735510063003552a6351006303355003552a6350735510063083652a6350336510063083652a63500365
010f00001c3551c3551c3501c3501e3551e3551e3501e3501a3551a3551a3501a3501a3501810318173204401e440204502245022450224562245622452220000000000000000000000000000000000000000000
010f00001356513565135601356515565155651556015565115651156511560115651f5011f501245001824016240182501a2501a2501a2521a2521a252180000000000000000000000000000000000000000000
130f00000c0450c0450c0400c0400e0550e0550e0500e0500a0650a0650a0600a0600706100060140001405012050140601606016062160601606016060220000000000000000000000000000000000000000000
1507000030513325132c5132c513385030b5000b50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010100002115316130141200f1200c120161002115316130141200f1200c1200f1002115316130141200f1200c120151000c10010100001000010000100001000010000100001000010000100001000010000100
01030000025560455606556085560a5560d5561055612556155561955620556255562d556005003757000500005003d570005003e5003f570005000050000500347703a400347503a5003a710000003e71000000
14040000341162c14629146281362255621556205561f5561d5561c5561b556195561755614556115460b546095360c52607526075263f7003f7003f7003f7003b5003f5003f5003f5003f500000000000000000
570300000a070050700407004070030700207001070000700007000070000700007038570046703f5600f66014660226602f660396603d6603b660376603266029660206601a600146600e6600b6000866008660
080100001f720237302a740347503f7201c72038700017002e5702e5702e5702e5702e5602e5603e7603e7603e7503e7503e7503e7403e7403e7303e7303e7203e7203e7203e7203e7103e7103e7103e71500000
__music__
00 0a150857
00 0b091757
01 11131458
00 11132659
00 1b190e58
00 121a0f5a
00 1b191d44
00 21232244
00 1b192444
00 121a2544
00 1b192444
00 1c101e44
00 160c0d44
00 0c180d44
00 0a0c0d44
02 201f0b44
01 27282944
01 2a313244
00 2c2b3644
00 2d2e3344
00 2b2c3644
00 2e353344
00 2a322f44
00 2a2f3144
00 2c363044
00 332e2d44
00 362b2c44
00 2e353444
02 2a312f44
00 41424344
00 37383940
00 40404040

