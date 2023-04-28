pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- fireball
-- smoke

-- billowing (fire and smoke)
-- going up
-- smoke dissipates
-- sparks

--todo
-- color
-- size variation for grape
-- age variation for grape
-- sparks

function _init()
 parts={}
 slowmo=false
 t=0

end

function _draw()
 cls(12)
 
 for p in all(parts) do
  if p.age>=0 then
   p.draw(p)
  end
 end
 
 print(t,1,1,7)
 print(#parts,1,7,7)
end

function _update60()
 
 if btnp(❎) then
  explode(64,64)
  slowmo=false
 end
 
 if btnp(🅾️) then
  explode(64,64)
  slowmo=true
  t=0
 end
 
 if slowmo==false or btnp(➡️) then
  t+=1
  for p in all(parts) do
   dopart(p)
  end
 end
 
end


function rndrange(low,high)
 return flr(rnd(high+1-low)+low)
end
-->8
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
  deli(thk,3 and myr<=6 or 4)
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
  line(p.x+i,p.y,p.x-p.sx*2+i,p.y-p.sy*2,p.c)
 end
 
end
-->8
function explode(ex,ey)
 sfx(0)
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=17,
  maxage=2,
  c=119,
  age=-2,
  ctab={119,167}
 })
 
 sparkblast(ex,ey,2)
 sparkblast(ex,ey,8)
 
 grape(ex,ey,2,13,1,
       "return",{119,167,167,154},
       0
       )
 grape(ex-rnd(5),ey-5,10,20,1,
       "return",{167,154,169},
       -0.2
       )
 grape(ex+rnd(5),ey-10,25,25,0.8,
       "fade",{167,167,154,169,141,93},
       -0.3
       ) 

end

function dopart(p)
 -- age and wait
 p.age=p.age or 0
 if p.age==0 then
  p.ox=p.x
  p.oy=p.y
  p.r=p.r or 1
  p.ctabv=p.ctabv or 0
  p.spd=p.spd or 1
 end
 p.age+=1
 if p.age<=0 then return end
 --particle code
 
 
 --animate color
 if p.ctab then
  local i=(p.age+p.ctabv)/p.maxage
  i=mid(1,flr(1+i*#p.ctab),#p.ctab)
  p.c=p.ctab[i]
 end
 
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
  p.r+=(p.tor-p.r)/(5/p.spd)
 end
 if p.sr then
  p.r+=p.sr
 end
 
 if p.age>=p.maxage or p.r<0.5 then
  if p.onend=="return" then   
   p.maxage+=32000
   p.tox=p.ox
   p.toy=p.oy
   p.tor=nil
   p.sr=-0.3
  elseif p.onend=="fade" then
   p.maxage+=32000
   p.tor=nil
   p.sr=-0.1-rnd(0.3)
  else
   del(parts,p)
  end
  p.ctab=nil
  p.onend=nil
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
	  c=ectab[1],
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
  c=ectab[1],
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
	  c=10,
	  ctab={7,10},
	  sx=sin(ang2)*spd,
	  sy=cos(ang2)*spd,
	  drag=0.8,
	  age=-ewait,
	  maxage=rndrange(8,13)
	 })
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
12030000256402c6602f6602f65027640206401a630136300e6500d650106401866022620106400b6300a65010630146101062001620006100061000000000000000000000000000000000000000000000000000
