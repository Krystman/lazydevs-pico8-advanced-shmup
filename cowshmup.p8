pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- main todo
-------------------
-- shadow/hover tweak
-- bullet cancelling
-- bullet origin
-- retargeting?

function _init()
 t=0
 debug={}
  
 #include shmup_myspr.txt
 #include shmup_anilib.txt
 #include shmup_enlib.txt
 #include shmup_sched.txt
 #include shmup_mapsegs.txt
 #include shmup_brains.txt
 #include shmup_pats.txt
 
 butarr=split "1,2,3,1,4,6,7,4,5,9,8,5,1,2,3,1"
 dirx=split "0,-1,1, 0,0, -0.7, 0.7,0.7,-0.7"
 diry=split "0, 0,0,-1,1, -0.7,-0.7,0.7,0.7"
 
 pal_flash=split "8,8,8,8,8,14,7,14,15,7,7,8,8,14,7"
 pal_wflash=split "7,7,7,7,7,7,7,7,7,7,7,7,7,7,7"
 
 
 freeze=0
 
 _upd=upd_menu
 _drw=drw_menu
 
 screen={
  x=0,
  y=0,
  col=split("0,0,144,128,0,0")
 }
 --★
 --coldebug=true
 
 
end

function startgame()
 px,py=64,64
 spd=1.4
 cutoff=90
 deadzone=8
 
 --spd=0.1
 
 lastdir=0
 shipspr=0

 scroll=0
 xscroll=0
 mapsegi=0
 cursegs={}
 
 boss=false

 parts={}
 shots={}
 shotwait=0
 enemies={}
 buls={} 
 schedi=1
 
 pspr={
  x=0,
  y=0,
  age=0,
  ani={3},
  col=myspr[28]
 }
 invul=0
 inviz=0
 freeze=0
 
 _upd=upd_game
 _drw=drw_game
 
 music(0)
 
 --★
 
 --scroll=208
 scroll=220
 for i=1,#sched do
  if sched[i][1]<scroll then
   schedi=i+1
  end
 end
 
end

function _draw() 
 _drw()
 
 --★
 cursor(4,4)
 color(7)
 for txt in all(debug) do
  print(txt)
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
  if freeze==0 then
   die2()
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
 for seg in all(cursegs) do
  map(seg.x,seg.y,0,scroll-seg.o,18,8)
 end

 for e in all(enemies) do
  if e.layer==2 then
   myoval(e.x,e.y+16,3,2,1)
   --circfill(e.x,e.y+16,3,1)
  end
 end
 myoval(pspr.x,pspr.y+16,3,2,1)
  
 for l=1,2 do
	 for e in all(enemies) do
	  if e.layer==l then
		  if e.flash>0 then
		   e.flash-=1
		   pal(pal_flash)
		  end
		  drawobj(e) 
		  pal()
	  end
	 end
 end
 
 for s in all(shots) do
  drawobj(s)  
  --mspr(cyc(s.age,s.ani,s.anis),s.x,s.y)

  if s.delme then
   del(shots,s)
  end
 end
 
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
 
 --ship
 if inviz<=0 then
	 if invul<=0 or (time()*9)%1<0.5 then
	  if freeze>0 then
	   pal(pal_wflash)
	  end
		 drawobj(pspr) 
		 local fframe=anilib[1][t\3%4+1]
		 for i=-1,2,3 do
		  mspr(fframe,pspr.x+i,py+8)
		 end
		 pal()
	 end
 else
  inviz-=1
 end
 
 for s in all(buls) do
  drawobj(s)
  --mspr(cyc(s.age,s.ani,s.anis),s.x,s.y)
 end
 
 camera()

 line(0,cutoff,128,cutoff,8)
 line(0,deadzone,128,deadzone,8)
 debug[1]=scroll
 debug[2]=#enemies
 debug[3]=#buls
end

function drw_menu()
 map(19,8)
end
-->8
--update

function upd_game()

 --scrolling
 scroll+=0.2
  
 if #cursegs<1 or scroll>cursegs[#cursegs].o then
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
  
  --★
  --if #cursegs>2 and scroll-cursegs[1].o>=128 then
  if #cursegs>3 then
   deli(cursegs,1)
  end
 
 end
 
 --spawning
 if schedi<=#sched and sched[schedi][1]<scroll then
  spawnen(unpack(sched[schedi],2))
  schedi+=1
 end
 
 --movement
 local dir=butarr[1+(btn()&0b1111)]
 
 if lastdir!=dir and dir>=5 then
  --anti-cobblestone
  px=flr(px)+0.5
  py=flr(py)+0.5
 end
  
 px+=dirx[dir]*spd
 py+=diry[dir]*spd
 local dshipspr=mysgn(dirx[dir])
  
 shipspr+=mysgn(dshipspr-shipspr)*0.15
 shipspr=mid(-1,shipspr,1)
 
 lastdir=dir

 xscroll=mid(0,(px-10)/108,1)\-0.0625
 
 pspr.x=flr(px)-xscroll
 pspr.y=flr(py)
 pspr.ani[1]=flr(shipspr*2.4+3.5)
 
 --xscroll=mid(0,(px-10)/100,1)*-16
 --2441
 
 if shotwait>0 then
  shotwait-=1
 else
  if btn(❎) then
   shoot() 
  end
 end
 
 if btnp(🅾️) then
  explode(64,64)
 end
 
 boss=btn(🅾️)
 
 if t%60==0 then
  --spawnen()
 end
 
 dobuls(shots)
 dobuls(buls)
 doenemies()
 
 -- shots vs enemies
 for e in all(enemies) do
  for s in all(shots) do
   if e.colshot and not s.delme and col2(e,s) then
    
    s.delme=true
    
    add(parts,{
			  draw=sprite,
			  x=s.x,
			  y=s.y+4,
			  maxage=5,
			  age=-1,
			  ani=anilib[4]
			 })  
    
    if s.y>deadzone then
     e.hp-=1
     e.flash=2
    end
    
    if e.hp<=0 then
     del(enemies,e)
     explode(e.x,e.y)
    end 
   end

  end
 end  
 -- ship vs enemies
 if invul<=0 then
	 for e in all(enemies) do
	  if e.colship and col2(pspr,e) then
	   die()
	  end
	 end
	 
	 for b in all(buls) do
	  if col2(pspr,b) then
	   die()
	  end
	 end
 else
  invul-=1
 end
 
 for p in all(parts) do
  dopart(p)
 end
  
end

function upd_menu()
 if btnp(❎) or btnp(🅾️) then
  startgame()
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

function mspr(si,sx,sy)
 local _x,_y,_w,_h,_ox,_oy,_fx,_nx=unpack(myspr[si])
 sspr(_x,_y,_w,_h,sx-_ox,sy-_oy,_w,_h,_fx==1)
 if _fx==2 then
  sspr(_x,_y,_w,_h,sx-_ox+_w,sy-_oy,_w,_h,true)
 end
 
 if _nx then
  mspr(_nx,sx,sy)
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

function cyc(age,arr,anis)
 local anis=anis or 1
 return arr[(age\anis-1)%#arr+1]
end

function drawobj(obj)
 mspr(cyc(obj.age,obj.ani,obj.anis),obj.x,obj.y)
 
 --★
 if coldebug and obj.col then
  msprc(obj.col,obj.x,obj.y)
 end
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

function myoval(ox,oy,ow,oh,oc)
 ovalfill(ox-(ow-1),oy-(oh-1),ox+ow,oy+oh,oc)
end
-->8
--gameplay

function die()
 freeze=30
 sfx(5)
end

function die2()
 explode(px-xscroll,py)
 inviz=30
 invul=150
end

function spawnen(eni,enx,eny,enb)
 
 local en=enlib[abs(eni)]
 
 add(enemies,{
  x=enx,
  y=eny,
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
  col=myspr[en[5]],
  layer=en[6],
  colshot=en[7]>0,
  colship=en[7]>1,
  wait=0,
  dist=0,
  bulq={}
 })
	
end

function doenemies()
 for e in all(enemies) do
  if e.wait>0 then
   e.wait-=1
  elseif e.dist<=0 then
   dobrain(e,1)
  end
  
  if e.movx then
   --★
   e.x+=(e.movx-e.x)/25
   e.y+=(e.movy-e.y)/25
   if dist(e.x,e.y,e.movx,e.movy)<1 then
	   e.x,e.y=e.movx,e.movy
	   e.movx=nil
	  end
  else
	  if e.flw then
	   e.adrt=atan2(pspr.y-e.y,pspr.x-e.x)
	   e.flw=dist(pspr.x,pspr.y,e.x,e.y)>25
	  end
	  
	  if e.aspt then
	   e.spd+=mid(-e.asps,e.aspt-e.spd,e.asps)
	   if e.spd==e.aspt then
	    e.aspt=nil
	   end
	  end
	  
	  if e.adrt then
	   if abs(e.adrt-e.ang)>0.5 then
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
   e.y+=e.layer==1 and 0.2+e.sy or e.sy
  end
  
  e.age+=1
  
  local oscr=col2(e,screen)
  
  if e.staged and not oscr then
   del(enemies,e)
  else
   e.staged=oscr
  end
  
  if e.y<=cutoff then
   dobulq(e)  
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
   e.brain=par1
   e.bri=par2-3
  elseif cmd=="lop" then
   --loop
   e.loop=e.loop and e.loop+1 or 1
   if e.loop<par1 then
    e.bri=par2-3
   else
    e.loop=0
   end
  elseif cmd=="fir" then
   --fire
   patshoot(e,par1,par2*e.mirr)
  elseif cmd=="clo" then
   --clone
   for i=1,par1 do
    local myclo=copylist(e)
    myclo.wait+=i*par2
    myclo.bri+=3
    add(enemies,myclo)
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
  end
  e.bri+=3
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
 
 local shotspd=-6
 shotwait=2
 
 for i=-4,4,8 do
  add(shots,{
   x=pspr.x+i,
   y=py-14,
   sx=0,
   sy=shotspd,
   ani=anilib[3],
   anis=2,
   age=(t\2)%3+1,
   col=myspr[29]
  })
	 add(parts,{
	   draw=sprite,
	   maxage=5,
	   x=i,
	   y=-4,
	   ani=anilib[2],
	   plock=true
	 })
 end

 sfx(0,3)
end

function makepat(pat,pang)
 local mypat,ret=pats[pat],{}
 local patype,p2,p3,p4,p5,p6,p7,p8,p9=unpack(mypat)
 if patype=="base" then
  add(ret,{
   age=0,
   x=0,
   y=0,
   ang=pang,
   spd=p2,
   ani=anilib[p3],
   anis=p4,
   col=myspr[p5],
   wait=0
  })
 elseif patype=="some" then
  if rnd()<p3 then
   ret=makepat(p2,pang)
  end
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
 elseif patype=="brst" then
  for i=1,p3 do
   local rndw,rnds=flr(rnd(p6)),rnd(p5)
   for p in all(makepat(p2,pang+spread(p4))) do
    p.wait+=rndw
    p.spd+=rnds
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

function patshoot(en,pat,pang)
 
 if abs(pang)==99 then
  pang=atan2(pspr.y-en.y,pspr.x-en.x)
 end

 local mybuls=makepat(pat,pang)

 for b in all(mybuls) do
  add(en.bulq,b)
 end
end

function dobulq(en)
 local oldb=#buls
 for b in all(en.bulq) do
  if b.wait<=0 then
	  b.x+=en.x
	  b.y+=en.y
	  b.sx=sin(b.ang)*b.spd
	  b.sy=cos(b.ang)*b.spd
	  
   add(buls,b)
   del(en.bulq,b)
  else
   b.wait-=1
  end
 end
 if oldb!=#buls then
	 add(muzz,{
	  en=en,
	  r=8
	 })
	end
	 
end
-->8
--particles

function explode(ex,ey)
 sfx(rnd({2,3,4}))

 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=17,
  maxage=2,
  ctab={119,167} --★
 })
 
 sparkblast(ex,ey,2)
 sparkblast(ex,ey,8)
 
 grape(ex,ey,2,13,1,
       "return",{119,167,167,154},
       0
       )
 grape(rndrange(ex-5,ex+5),ey-5,10,20,1,
       "return",{167,154,169},
       -0.2
       )
 grape(rndrange(ex-5,ex+5),ey-10,25,25,0.8,
       "fade",{167,167,154,169,141,93},
       -0.3
       ) 
end

--1855

function dopart(p)
 -- age and wait
 p.age=p.age or 0
 if p.age==0 then
  p.ox=p.x
  p.oy=p.y
  p.r=p.r or 1
  p.spd=p.spd or 1
 end
 p.age+=1
 if p.age<=0 then return end
 
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

function grape(ex,ey,ewait,
               emaxage,espd,
               eonend,ectab,
               edrift)
 local spokes=6
 local ang=rnd()
 local step=1/spokes
 
 
 for i=1,spokes do
  --spawn blobs
  local myang=ang+step*i
  local dist=7+rnd(3)
  local dist2=dist/2
  
	 add(parts,{
	  draw=blob,
	  x=ex+sin(myang)*dist2,
	  y=ey+cos(myang)*dist2,
	  r=2,
	  tor=rndrange(4,7),
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
  tor=7,
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
 --47
 
 for i=0,1 do
  line(p.x+i,p.y,p.x+p.sx*2+i,p.y+p.sy*2,p.c)
 end
 
end

function sprite(p)
 if p.age<=0 then
  return
 end
 
 local _x,_y=p.x,p.y
 if p.plock then
  _x+=pspr.x
  _y+=py
 end
 mspr(cyc(p.age,p.ani,p.anis),_x,_y)
end
__gfx__
000000cc0000000000000cc00000000000000c0009009090000700000700070000000700000a0000900000090090000000ccc00000880000ddd0008980070070
00000c11c00000000000c11c000000000000c1000900909007770000070007000000000000a7909090000009000000000cbbbc000899800d676d087778777777
0000c1671c000000000c1671c0000000000c16009700909077770000070000000000000000a79099a000090900000000cb777bc0897798d67776d977797c7777
0000c111d1c00000000c111d1c00000000c111009709a0907777007007000000700000000a77009a7090090000000000cb777bc8977798d77777d877787c77c7
000c1ccc11c0000000c1ccc11c00000000c1cc0977097097777707707700000070000000077790a77090000990000000cb777bc8977980d67776d089800707c7
00c1c77cc11c00000c1c77cc11c000000c1c7709770979a77777077077700000770000000777a0777009009a000000000cbbbc008998000d676d000000000070
00c1c7c1c11c00000c1c7c1c11c00000cc1c7c97a79a797777770077770700077000000000777777790909a70000000000ccc00008800000ddd0000000070070
00c1c111c111c000c11c111c111c000c111c1197a79a79707777707777000077700000000fff077779000a70000000000000ccc00000eee000000eeeeee00070
00c1c111c171c000c11c111c171c000c171c119aa79a79a00777777777000077700000000fff007779000a0000000000000c777c000e777e0000e776677e0777
0c11cc171161c00c161cc117161c000c1611719aa799a9a00077077777070077707000007ffffffff00000000900000000c66777c0e66666e00e77666677e7c7
0c1d1c711d6d1c0c16d1c77116d1c0c1d6d1179a9a99a9afffff007777000077700000007ffffffff0900000000000000c776667c0e776677e0e77677767e070
c1ddd111d6d7d1c1dddd1111dd671c176d6d11999a99999fffff007777000007700000077ffffffff009000000000000c7767776ce77776777ee76777776e000
c1dd6ddd6d66d1c1dd66dddd6d661c1666d6dd999a99999fffff000777000000700000077fffffffffffff00dd00cc00c7677777ce77776777e0e677777e0070
c1d676676d6dd1c1d6676676d6dd1c1dd6d676909999999fffff000077fffffff00000007fffffffffffff0d76dcb7c0c7677777ce77776777e00e77777e0fff
0c176d167d111c0c117dd1171111c0c1111716900990909fffffffffffffffffffffffffffffffffffffffd777dc777c0c677777c0e776677e0000e777e00fff
00c151155d11c000c1655155d11c000cc16151000900909fffffffffffffffffffffffffffffffffffffffd67d00c7bc00cc777c000eeeeee000000eee000fff
000c1111111c00000c11111111c000000c1111ffffffffffffffffffffffffffffffffffffffffffffffff0dd0000cc00000ccc00fffffffffffffffffffffff
0000ccccccc0000000cccccccc00000000ccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee
00ee00ee0000000eeee00000000000000ee00ee00ee0000000eeee00000000000000ee000000000000000000000000000000000000000000000000000000ee44
0e11ee440000eee4444e00000000000ee440e11ee440000eee4444e00000000000ee4400000000000000000000000000000000000000000000000000000e44ff
e16d14ff000e114ffff4eeee000000e14ffe16d14ff000e114ffff4eeee000000e14ff0000000000000000000000000000000000000000000000000000e4ffff
e1d14ff7000e14ff7fff4111e0000e14ff7e1d14ff7000e14ff7fff4111e0000e14ff7000000000000000000000000000000000000000000000000000e4ff77f
e11d4f7f00e1d4f7ff9f4d161e00e1d4f7fe1134f7f00e134f7ff9f43161e00e134f7f00000000000000000000000000000000000000000000000000e14f777f
0e1c4fff00e1c4fff99f4c1d1e00e1c4fff0e1b4fff00e1b4fff99f4b1d1e00e1b4fff0000000000000000000000000000000000000000000000000e124f77ff
e1dc4f990e1dc4f9999f4cd11e0e1dc4f99e13b4f990e13b4f9999f4b311e0e13b4f99000000000000000000000000000000000000000000000000e1824ffff9
e1cc47990e1cc47999974cc1e0e16cc4799e1bb47990e1bb47999974bb1e0e16bb4799000000000000000000000000000000000000000000000000e1824fff99
e1dcc4770e1dcc477774ccd1e0e1ddcc477e13bb4770e13bb477774bb31e0e1d3bb47700000000000000000000000000000000000000000000000e18824f9999
e1dcc7440e1dcc744447ccd1e0e11dcc744e13bba440e13bba4444abb31e0e113bba4400000000000000000000000000000000000000000000000e182e4f7999
e11dcd7ce161dcd7cc7dcd1e000e11dcd7ce113b3abe1613b3abba3b31e000e113b3ab0000000000000000000000000000000000000000000000e11e1e247777
0e11dc77e1d11dc7777cd11e000ee11dc770e113baae1d113baaaab311e000ee113baa000000000000000000000000000000000000000000000e1d1888824477
e16d1ddce111e1ddccdd11e000000e11dd1e16d133be111e133bb3311e000000e1133100000000000000000000000000000000000000000000e1d611888f2244
e1d111dd0eee0e1dddd1d61e000000ee116e1d111330eee0e133331d61e000000ee11600000000000000000000000000000000000000000000e16d1188eeff22
e111ee11000000e111111d1e00000000e1de111ee11000000e111111d1e00000000e1d00000000000000000000000000000000000000000000e1d11128e2def7
0eee00ee0000000eeeee11e0000000000e10eee00ee0000000eeeee11e0000000000e1000000000000000000000000000000000000000000000e111912822ee7
00000000000000000000ee000000000000e00000000000000000000ee000000000000e0000000000000000000000000000000000000000000000ee1111288ee7
00ee00ee0000000eeee00000000000000ee00ee00ee0000000eeee00000000000000ee0000000000000000000000000000000000000000000000e1d1111228ff
0e11ee440000eee4444e00000000000ee440e11ee440000eee4444e00000000000ee440000000000000000000000000000000000000000000000e1d7d1111288
e16d14ff000e114ffff4eeee000000e14ffe16d14ff000e114ffff4eeee000000e14ff000000000000000000000000000000000000000000000e1d776d111911
e1d14ff7000e14ff7fff4111e0000e14ff7e1d14ff7000e14ff7fff4111e0000e14ff7000000000000000000000000000000000000000000000e1676d116d11d
e1124f7f00e124f7ff9f42161e00e124f7fe1144f7f00e144f7ff9f44161e00e144f7f00000000000000000000000000000000000000000000e1dd66d11dd167
0e184fff00e184fff99f481d1e00e184fff0e194fff00e194fff99f491d1e00e194fff00000000000000000000000000000000000000000000e167dd1ee111d1
e12e4f990e12e4f9999f4e211e0e12e4f99e1494f990e1494f9999f49411e0e1494f99000000000000000000000000000000000000000000000e166d1e0eee11
e18847990e18847999974881e0e16884799e19947990e19947999974991e0e169947990000000000000000000000000000000000000000000000e111e00000ee
e12e84770e12e84777748e21e0e1d2e8477e14994770e14994777749941e0e1d49947700000000000000000000000000000000000000000000000eee00000000
e128ef440e128ef4444fe821e0e1128ef44e1499a440e1499a4444a9941e0e11499a440000000000000000000000000000000000cccccccccccccccc111ccc11
e11282fee161282feef2821e000e11282fee11494a9e161494a99a4941e000e11494a900000000000000000000000000000000001c1c1c1ccccccccc1111ccc1
0e112effe1d112effffe211e000ee112eff0e1149aae1d1149aaaa9411e000ee1149aa0000000000000000000000000000000000cccccccccccccccc11111ccc
e16d1228e111e122882211e000000e11221e16d1449e111e144994411e000000e114410000000000000000000000000000000000ccccccccccccccccc11111cc
e1d111220eee0e122221d61e000000ee116e1d111440eee0e144441d61e000000ee1160000000000000000000000000000000000cccccccccccccccccc11111c
e111ee11000000e111111d1e00000000e1de111ee11000000e111111d1e00000000e1d0000000000000000000000000000000000ccccccccccccccccccc11111
0eee00ee0000000eeeee11e0000000000e10eee00ee0000000eeeee11e0000000000e10000000000000000000000000000000000ccccccccc1c1c1c11ccc1111
00000000000000000000ee000000000000e00000000000000000000ee000000000000e0000000000000000000000000000000000cccccccccccccccc11ccc111
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
1111d00ddd00d11111d00ddd1d5665d1d57dd555bbbbbbbbbbbbbbbb99999999bb99999999999999999999bbdd111111111111511115d1dd8888888888888888
11110000000001111110000010d55d01d5555555bbbbbbbbbbbbbbbb99999999bbbb99999999bbbb9999bbbbdddd15111511dddd1511dddd8888888888888888
11111111111111111111111110000001dd555555bbbbbbbbbbbbbbbb99999999bbbbbbbbbbbbbbbbbbbbbbbbdddddddddddddddddddddddd8888888888888888
bbbbbbbbbbbbbbbb31111111111113bbbbbbbbbbbbbbbbbbbbbbbbbbbbb533bbbbbbbbbbbbbbbbbbbbb3b3bbb3bbbbb3bbbbbbb5555555555bbbbbbb11111111
bbbbbbbbbbbbbbbbb31111171111113bbbbbbbbbbbbbbbbbbbbbbbbbbbbd3bbbbbbbbbbbbbbbbbbbb3b3333333bbbbb3bbbbbb5cccccccccd5bbbbbb11111111
bbbbbbbbbbbbbbbb31111117111113bbbbbbbbbbbbbbbbb11bbbbbbbbbbd3bbbbbbbbbbbbbbbbbbb33355553533b3b33bbbbb57ddddddddddd5bbbbb15151515
bbbbbbbbbb3b3bbbb3111111111113bbbbb5bbb5bbb5bb1331b5bbb5bbb53bbbbbb5bbb5bbb5bbbb5554454545333335bbbb5d6dddddddddd5d5bbbb51515151
bbbbbbbb3b3b3b3bb31111171111113bddd5ddd5ddd5d13bb315ddd5bbb533bbbbb5ddd5ddd5bbbb4544454444555552bbb55d6dddddddddd55d5bbb55555555
bbbbbbbbbbbbbbbb31111117111113bbbbb5bbb5bbb5b13b3315bbb5bbbd3bbbbbbd3bb5bbbdbbbb4444444444222222bb5ddd6dddddddddd555d5bb55555555
bbbbbbbbbbbbbbbbb3111117111113bb3335333533353133b3153335bbbd3bbbbbbd3335333d3bbb4242424244422222b5dd5d6dddddddddd5555d5b33333333
bbbbbbbbbbbbbbbbb31111171111113bbbbbbbbbbbbbb13bb31bbbbbbbb53bbbbbb53bbbbbb53bbb44444444444422245d5d5d6dddddddddd55555d533333333
bb3bb3b3111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb53bbbbbb53bbb24242424242424245ddd5d6dddddddddd5555555dddddddd
33133131111111111111111111111111bbbbbbbbb111bbbbbbbbbbbbbbbb111bbbbd3bbbbbbd3bbb42424242444242425d5d5d6dddddddddd5555555d55d5ddd
11111111111111111111111331111111b11111bbb1711bbbbb11111bbbb1171bbbbd3bbbbbbd3bbb24242424222665245d5ddd6dddddddddd5555555dddddddd
111111111111111111111133331111111711771bb17111bbb1771171bb11171bbbb53bb5bbb53bbb42424242426555225ddd5d6dddddddddd5555555dddddddd
11111111111111111111113bb311111117177111b117171b11177171b171711bbbb5ddd5ddd53bbb24242424225555245d5d5d6dddddddddd5555555dddddddd
11111111133133131331313b3311331331111111b131711b11111113b117131bbbbd3bb5bbbd3bbb42424242422552225d5ddd6dddddddddd5555555dddddddd
111111113bb3bb3b3bb3b133b313b33b31331311bb31111111313313111113bbbbbd3335333d3bbb22222222242222425ddd5d6dddddddddd5555555dddddddd
77771771bbbbbbbbbbbbb13bb31bbbbbbbbbbbbbbbb1311bbbbbbbbbb1131bbbbbbbbbbbbbbbbbbb24242424242222245d5d5d6dddddddddd5555555dddddddd
b333333bbbbbbbbbbbbbbbbb3333333333333333bbbbbbbbcccccccccccccccccccccccc1111111122222222222442225d5ddd7ccccccccc75555555cccccccc
3b3bb3b3bbbbbbbbbbbbbbbb133333313b3bb3b3bbbbbbbbcccccccccccccccccccccccc1111111122222222244444225ddd5655555555555555555555555555
3bbbbbb3bbbbbbb11bbbbbbb131313113bbbbbb33bbbbbb3cccccccccccccccccccccccc1111111122222222244222225d5d65dddddddddddd555555dddddddd
bbbbbbbbbbbbbb1331bbbbbb31111113bbbbbbbb33bbbb33ccccccccc777c7cccccccccc1111111111111111142222215d565d666666666666d55555666dd666
3bbbbbb3bbbbb13bb31bbbbbb314413b3bbbbbb3b3bbbb3bccccccccccccccccc7c777cc11111111ccccccccc122221c5d65d66666666666666d555566d66d66
b3bbbbbbbbbbb13b331bbbbbb3122133b3bbbbbbb3bbbb33cccccccccccccccccccccccc11111111111111111cccccc1565d6666666666666666d55566d66d66
3b33b3b3bbbbb133b31bbbbb3312213b3b33b3b3333bb33bcccccccccccccccccccccccc11111111ccccccccc111111c55d666666666666666666d5566dddd66
333b3b33bbbbb13bb31bbbbbb313313b333b3b33b333333bcccccccccccccccccccccccc11111111111111111cccccc15d66666666666666666666d566666666
33333333bbbbb133331bbbbb33133133333333333333333333333333333333332222222211111111b3b3bbbb11122211b5666666666666666666665b66666666
13333331bbbbbb1331bbbbbb313333131333333113333331133333313333333322222222111111113333b3b311242211b5666666666666666666665b66dddd66
13131311bbbbbbb11bbbbbbb1333333113131311131313111313131133333333222222221111111135553333c242222cb5666666666666666666665b66d66d66
31111113bbbbbb3223bbbbbb2333333241111114411111133111111433333333322333221111111154445555c222222cb5666666666666666666665b66dddd66
b311313bbbbbbb3223bbbbbb23333332222442222224413bb3144222b333333b3333333311111111444445441c2222c1b5666666666666666666665b66666666
3313113bbbbbbbb33bbbbbbb33bbbb33332222333322213b33122233b3333333333333331111111144444444c1cccc1cb5555555555555555555555b55555555
b3113133bbbbbbbbbbbbbbbb3bbbbbb33332233333322133b31223333333333b3333333317777771424242421c1111c1b3333333333333333333333b33333333
b313113bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb333313bb313333bb333333b33333333111111114444444411cccc11b3333333333333333333333b33333333
__map__
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f09dc0c0c0c0c0c0c0c0c0c0c1c0c0c0c0c09d9df0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c0c1c0c0c0c0c0c2c3c0c0c0c0c0c0c0c0c0c1c0c0c0c0c0c0c2c3c0c0c0c0c1c0c0c0c0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e60000
f5e4f6f3f5e4f6f3f4f3f5e4e3e4e3e4e3e4c0c0c0c1c0d7c0c0c0c0c0c0e1e0e5e0e5e0f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c4c4c4c4c5e0c6c4c2c3c4c4c4c4c4c4c4c4c0cccdcdcdcdcec0c2c3c0cccdcdcdcdcec0c0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0e6e6e7e6e6e6e6e6e6e6e6e6e6e6e6e6e6e60000
f1f4f2c1f1f4f2c0c0c1f1f4f3f4f3f4f3f4e0e2c0d4c0c0c0c0c0c0c0e1e0f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c1c0c0f1f4f2c0c2c3c0c0c1e1e0e2c0c0c0dcdfdddddddec0c2c3c0dcdfdddddfdec0c0c4c4c2c3c0c0c1c0c0c0c0c0c2c3c4c4c4e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e8e6e60000
d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0e0e5e0e5e0e2c0c0c0c1f1f5e4f0e4f0e4f0e4f6f3f4f3f4f3f5e4e3e4f0e4f0e4f0e4c0c0c0c0c0c0c1c0c2c3c1c0c0f1f4f2c0c0c0dcdda5a5dfdec0c2c3c0dcdda5a5dfdec0d0d0d0e9e9d0d0d0d0d0d0d0d0e9e9d0d0d0b5b6b6b5b6b6b6b5b6b5b5b6b6b5b6b5b6b50000
d1d2e4d3d1d1d1d2e4d3d1d2e4d3d1d1d1d2e4f0e4f0e4f6f2c0c0c0c0e1e0f0e4f0e4f0e4f6f2c0c1c0c0c0f1f4f3f5e4f0e4f0e4f0c0c0c0c0c1c0c0c0c2c3c0c0c0c0c0c0c0c1c0dcdddfdddfdec0c2c3c0dcdddfdddfdec1d1d1d1d1d1d1d1d1e9e9d1d1d1d1d1d1d1d1c0c1c0c0e1e4e2c0c0c0c0c0c0c0c1c0c1c00000
e5e0f0e0e5e0e5e0f0e0e5e0f0e0e5e0e5e0f0e4f0e4f6f2c0c0c0d4e1e0f0e4f0e4f0e4f0e4e2c0c0c0c1c0c0c0c0f1f5e4f0e4f0e4b5b6b5b6b5b6b5b6b5b6b6b5b6b6b6b6b5b6c0dcdddfdddfdec1c2c3c0dcdfdddddfdec0c0c0c0c0c0c0c0c0c2c3c0c0c0c0c0c0c1c0c0c0c0c0f1f4f2c0c0c0c1c0c0c0c0c0c0c00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f6f2c0c0d7c0c0f1f5e4f0e4f0e4f0e4f6f2c0c0c0c0c0c0c1c0e1e4f0e4f0e4f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0dcdfdddddddec0c2c3c0dcdfdddddddec0c0c0c0c1c0c0c0c0c2c3c0c0c1c0c0c0c0c0c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c40000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e49ee4f0e0e2c1c0c0c0c0c0f1f5e4f0e4f09e9ee4e5e0e2c0c0c0c0c0c0f1f5e4f0e4f09e9ec0c0c0c1c0c0c0c0c0c0e1e0e2c0c1c09ec0dcdddddfdddec0c2c3c0dcdddddddfdec09ec0c0c0c0c0c0c0c2c3c0c0c0c0c0c0c09ec0c0c0a8aac0c0c0c0c0c0c0c0c0c0c0c0c00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f09de3e4f6f2c0c0c0c0c0c0e1e0f0e4f0e49d9df0e4f0e0e2c0c0c1c0c0e1e0f0e4f0e49d9dc0c0c0e1e0e2c0c0c0c0f1f4f2c0c0c09dc0dcdfdddddddec0c2c3c1dcdddddddfdec0c4c4c4c4c4c4c4c4c2c3c4c4c4c4c4c4c4c4c0c0a8b7b7a9a9a9aac0cccdcdcdcec0c09d0000
f0e4f0e4f0e4e3e4f0e4f0e4f0e4f0e4f0e4f4f3f4f2c0d5c0c0c0c1c0f1f5e4f0e4f0e4f0e4f0e4f6f2e1e0e2c0e1e0f0e4f0e4f0e4c0c1c0c0f1f4f2c0c0c1c0c0c0c0c0c1c0c0c0dcdddddddfdec0c2c3c0dcdfdddddddec0e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9c0cccdcdcdcdcdcdcdcddcabacaddecdcec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4e3e4f0e4f0c0c0c1c0d4c0c0c0c0c0c0c0f1f5e4e3e4e3e4f0e4f0e0e2f1f4f2c0f1f5e4f0e4f0e4f0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c1dcdfa5a5dddec0c2c3c0dcdfa5a5dfdec0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b0b1f9e9c0dcdda5a5dfdddddddfdcbbbcbddedddec10000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4c0c0c0c0c0c0d6c0c0c0c0c0c0f1f4f3f4f3f0e4f0e4f0e0e2c0c0c1e1e0f0e4f0e4f0e4cafacbfacacbcacafafafacbfafafacbfacac0dcdddddddfdec0c2c3c0dcdddddddfdec0f9b2b1e9f9f9e9e9e9e9e9f9f9e9b2b1f9e9c1dcddddddddddaedddddcaedddddedddec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c0c0c0c0d7c0c0c0c0c1c0cccdcee1e0e2c0e4f0e4f0e4f6f2c0c0c0f1f5e4f0e4f0e4f0dadadadadadbdadadadbdadadadadadadbdac0dcdfdddddfdec0c2c3c0dcdfdddddfdec0f9b0b1e9f9b2b1e9e9e9b0b1f9e9e9f9b0b1c0dcddaeddabacacadaedcdddddddedddec00000
f0e4e3e4f0e4f0e4f0e4f0e4f0e4e3e4f0e4c0c0c0c1c0c0c0c0c0c0c0dcdddef1f4f2c0f0e4f0e4f6e0e2c0e1e0e2f1f5e4f0e4f0e4f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8c0ecededededeec0c2c3c0ecededededeec0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b0b1f9e9c0dcdfa5abe9e9e9e9addcdddfdfdedddec00000
e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0c4c4c4c4c4c4c4c5e0c6c4ecefeec0c0c0c0e4f0e4f0e4f6f2c0f1f4f2e1e0f0e4f0e4f0e4f7e4f7e4f7e4f7e4f7e4f7e4f7e4f7e4f7c0fcffcfcffffec1c2c3c0fcffcfcffffec0f9b0b1e9f9f9e9e9e9e9b2b1f9e9b0b1f9e9c0dcdda5bbe9e9e9e9bddcdddfdddedddec00000
f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e49ec0c0c0c0c0c1f1f4f2c0fccffea0a1c09e9ee4e3e0f6f2c0c1c0c0c0f1f5e4e3e4e39ef0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f09ec0c1c0b8bac0c0c0c2c3c0c0c0b8bac0c1c0f9b2b1e9f9b0b1e9e9e9b0b1f9e9e9f9b0b19edcdfddaebbbcbcbddddcdddddfdeddde9e0000
e4e3e4e3e4f6f3f4f3f4f3f4f3f5e4e3e4e39dc1c0c0c0c0c0c0c0c0c0c0c0c0c0c0c09d9df4f3f4f2c0c0c0c1c0c0c0f1f4f3f4f39d9df0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e49dc8c4c4c4c4c4c4c9c2c3c0c0a8a9a9aac0c0f9f9e9e9f9b0b1e9e9e9e9f9b0b1b2b1f9e99ddcdddddfddddaedfa5dcdddddddeddde9d0000
f4f3f4f3f4f2c0c0c1c0c0c0c0f1f4f3f4f3d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0f0e4f0e4e3e4f0e4f0e4f0e4e3e4f0e4f0e4c7c0c0c0c0c0c0c7c2c3c0c0b8b9b9bac0c0f9b0b1e9f9f9e9e9e9e9b0b1f9e9b0b1f9e9c0dcdda5a5dda5a5dddddcdda5dfdedfdec00000
c0c0c0c1c0c0c0c0c0c0c0c0c1c0c0c0c0c0d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d2e4d3d1d1d1d1d1d1d1d2e4d3d1d2e4d3e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0d8c4c4c4c4c4c4d9c2c3c0c0c0c0c0c0c0c0f9b0b1e9f9b2b1e9e9e9b0b1f9e9e9f9b0b1c0dcdda5a5dfa5a5dddfdcdfdfdddedddec00000
cacafacacbcafacafafacacbcafacacbfacac4c4c4c4c4c4c4c4c4c5e0c6c4c4c4c4c4c4e5e4f0e4e5e0c6c4c4c4c5e0f0e4e5e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4a9a9a9a9a9a9a9aac2c3a8a9a9a9a9a9a9a9d1d1d1d1d1d1d1d1e9e9d1d1d1d1d1d1d1d1c1dcdddddddddddddddddcdda5dfdedddec00000
dadbdadadadadadadbdadadadbdadadadadbc0c0d7c0c0c0c0d6c0f1f4f2c0c0c1d5c0c0e4f0e4f0e4f6f2e1e0e2f1f5e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4e3e4f0b9b9b9b9b9b9b9bac2c3b8b9b9b9b9b9b9b9c4c4c4c4c4c4c4c4c2c3c4c4c4c4c4c4c4c4c0dcdddfdddddfdddddddcdda5dddedddec00000
eaeaebeaeaeaeaeaeaeaeaebeaebeaeaeaeac0c1c0c0c0d4c0c0c0c0c1c0c0c0c0c0d7c0f0e4f0e4f6e0e2f1f4f2c0f1f5e4f0e4f0e4f0e4e3e4f0e4f6f3f4f3f4f3f5e4f0e4f0e4c0a8a9aac0c1c0c0c2c3c0c0c0c0c0c1c0c0c0c1c0c0c0c0c1c0c2c3c0c0c0c0c1c0c0c0c0dcdfa5a5dda5dddddddcdddfdfdedfdec10000
e9e9e9e9e9e9fbe9e9e9e9e9e9e9e9fbe9e9c0c0c0c0c0c0c1c0c0c0d5e1e0e2c0c0c0c0e4f0e4f0e4f6f2c0c0c0c1e1e0f0e4f0e4f0e4f0e4f0e4f6f2a8a9a9aac1f1f5e4f0e4f0c0b8b9bac0c0a8aac2c3c0c1c0c0c0c0c0c0c0c0c0c0c0c0c0c0c2c3c0c1c0c0c0c0c1c0c0dcdda5a5dda5a5ddddecefefefeedddec00000
e9e9fbe9e9e9e9e9e9e9e9e9e9e9e9e9e9e99ec0c1c0c0c0c0c0c0c0c0f1f4f2c0c1c09e9ee4f0e4f6f2c0c0c0c0c0f1f5e4f0e4f09e9ee4f0e4f6f2a8b7b7b7b7aae1e4f0e4f09ec0c1c0c0c0c0b8bac2c3c0c0c0c0c0c0c0c0c0c0c0c1c0c0c0c0c2c3c0c0c0c0c0c0c0c09edcdfdddfdddddddddddfdfdfddddddde9e0000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e69de2c0c0c0e1e0e2c0c0c0c0c0c0c0c0c09d9dc0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c09d9df0e4f0e0e2b8b7b7b7b7baf1f5e4f0e49dc8c4c4c4c4c4c4c9c2c3c8c4c4c4c4c4c4c9c8c4c9a6a7c8c4c9c8c4c9c8c4c9c8c4c9c89ddcdda5a5dda5a5dddda4dda4dda4dfde9d0000
e6e6e7e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f6f2c0c0c0f1f4f2c0c0c0c1d6c0c0c1e1e0c0c0c0c0c0c0c0c0c0d7c0c0c0c1c0c0c0c0f0e4f0e4f0e0e2b8b7b7bac0e1e0f0e4f0e4c7d4c0c0c0d6c0c7c2c3c7d5d7d5c0d7c0c7c7d7c7a6a7c7d4c7c7d6c7c7d6c7c7d6c7c7c0dcdfa5a5dda5a5dddfb4ddb4ddb4dfdec00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e8e6e6e0e2c0c1c0c0d6c0c0e1e0e2c0c0d5c0f1f5c0c0c1c0e1e0e2d6c0c0c0c0c0c0c0c0c0c0e4f0e4f0e4f6f2a2c0c0c0c1f1f5e4f0e4f0c7c0d7d6d5c0d7c7c2c3c7c0c0d4c0d6c0c7c7d6c7a6a7c7d7c7c7d5c7c7d7c7c7d6c7c7c0dcdddddddfdddddddddddddfdddfdddec00000
e6e6e6e6e6e6e6e6e8e6e6e6e6e6e6e6e6e6f0e0e2c0d4c0c0c0c0f1f4f2c0c0c0d6e1e0c0c0c0c0f1f4f2c0d5c0c0c1c0c0c1c0c0c0f0e4f0e4f0e4c1c0a2a2c0a2e1e0f0e4f0e4d8c4c4c4c4c4c4d9c2c3d8c4c4c4c4c4c4d9d8c4d9a6a7d8c4d9d8c4d9d8c4d9d8c4d9d8c0ecededededededededededededededeec00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e4f0e0e2c0c0d7c0c0c1c0c0c0d7c0e1e0f0c0c0c0d5c0c0c0c0c0c0c0c0d4c0c0d5c0c0e4f0e4e3e4f0e0e2a0a1c1e1e4f0e4f0e4f0c8c4c4c4c4c4c4c9c2c3c8c4c4c4c4c4c4c9c8c4c9a6a7c8c4c9c8c4c9c8c4c9c8c4c9c8c0fccfcffdcfa3fdcfcffdfdffffffcffec10000
e6e6e6e6e6e6e6e6e6e6e6e6e7e6e6e6e6e6f0e4f0e0e2c0c0c0c0c0c0c1c0c0e1e0f0e4c0c0d4c0c0c0c1c0c0c0c0c0e1e0e2c0c0c0f0e4f0e4f0e4f0e0e2a0a1f1f4e4e3e4f0e4c7d7c0d4c0d7c0c7c2c3c7c0d4d5c0d7c0c7c7d5c7a6a7c7d6c7c7d5c7c7d4c7c7d4c7c7c0e9e9a3e9e9b3e9e9b2b1a3a3e9e9b0b1c00000
e6e6e6e8e6e6e6e6e6e6e6e6e6e6e6e6e6e6e4f0e4f0e0e2c0e1e0e2c0e1e0e5e0f0e4f0c0c0c0c0c0c0c0c0c0c0c1c0f1f4f2c0c0c0e4f0e4f0e4f0e4f0e0e5e0e5e0f0e4f0e4f0c7d5d6c0d5c0c0c7c2c3c7d5c0c0d6c0d6c7c7d4c7a6a7c7d4c7c7d4c7c7d5c7c7d7c7c7c1e9e9b3e9e9e9e9e9e9e9b3b3a3e9b2b1c00000
e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6f0e4f0e4f0e0e5e0f0e0e5e0f0e4f0e4f09e9ec0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c09ef0e4f0e4f0e4f0e4f0e4f0e4f0e4f0e4f09ed8c4c4c4c4c4c4d9c2c3d8c4c4c4c4c4c4d9d8c4d9a6a7d8c4d9d8c4d9d8c4d9d8c4d9d8c0e9e9e9e9e9e9e9e9e9e9e9e9b3e9e9e9c00000
__sfx__
1507000030013320132c0132c013386030b1000b10000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
4d0600001a660356502a6402d6402e6402564024620166201f620306201a62012620106202a6200e6201e620116100a6100861006610046100361003610026100161000610006100000000000000000000000000
12020000129701f9703c9703a67038670346703467033670316702e6702d6702b6701263013670146701567015670146701367012670106700f6700e6700d6700c6700b6700867004670006700b6700867005670
12020000129701f9703c970376703867027670396701c670306703067025670326700b6300e670106700867005670056700567008670096700a67008670076700567006670096700b67003670036700267002670
12020000129701f9703c970386703e670376703567035670376703367031670316701f63022670256702867029670146700b6700c67006670046702067024670256700b670216701d6701d630286302c62005600
010300003a0363f0463c0161b5002250017500225001750000000175000a5000a5000050000500005000050000700007000070000700007000070000700007000070000700007000070000700007000070000700
4d0c00000d5000d500105000c500155000c500175000c0001c5000c500175000c500155000c500105000c500135000c500155000c50019500185001a50018500195000c500175000c500155000c5001050000000
110c00001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001f0001c0001c0001c0001c0001c0001c0001c0001c000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13020000129701f9703c9703a67038670346703467033670316702e6702d6702b6701263013670146701567015670146701367012670106700f6700e6700d6700c6700b6700867004670006700b6700867005670
1108000018673275531f5531b5532250017553225001754300000175430a5000a5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
01010000266002d60033600316002e60021600166000e6000c6000b60019600246001c60009600066000960011600106000a60000600006000060000000000000000000000000000000000000000000000000000
a501000009900389003590036900329002f9002d90026900229001c90019900179001590012900109000e9000a900069000290002900049000590004900059000590004900029000190000900029000090001900
090100002930029300293001d40026300386003860001000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 40404040
00 40404040

