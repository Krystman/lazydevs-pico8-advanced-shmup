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
  if p.wait==nil then
   blob(p)
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
           myr-thk[i],154)

 end
 fillp()
 
 --★
 if myr==1 then
  line(p.x,p.y-1,p.x,p.y,154)
 elseif myr==2 then
  rectfill(p.x-1,p.y-2,p.x+1,p.y,154)
 end
 
 
end
-->8
function explode(ex,ey)
 add(parts,{
  x=ex,
  y=ey,
  r=17,
  maxage=2
 })
 
 grape(ex,ey,2,13,1,"return")
 grape(ex-rnd(5),ey-5,10,20,1,"return")
 grape(ex+rnd(5),ey-10,25,25,0.8,"fade") 
end

function dopart(p)
 if p.wait then
  -- wait countodwn
  p.wait-=1
  if p.wait<=0 then
   p.wait=nil
  end
 else
  --particle code
  p.age=p.age or 0
  p.spd=p.spd or 1
  if p.age==0 then
   p.ox=p.x
   p.oy=p.y
  end
  p.age+=1
  
  --movement
  if p.tox then
   p.x+=(p.tox-p.x)/(4/p.spd)
   p.y+=(p.toy-p.y)/(4/p.spd)   
  end
  
  --size
  if p.tor then
   p.r+=(p.tor-p.r)/(5/p.spd)
  end
  
  if p.age>=p.maxage or p.r<0.5 then
   if p.onend=="return" then
    p.onend=nil
    p.maxage+=32000
    p.tox=p.ox
    p.toy=p.oy
    p.tor=0
   elseif p.onend=="fade" then
    p.onend=nil
    p.maxage+=32000
    p.spd/=2
    p.tor=0
   else
    del(parts,p)
   end
  end
 end

 --sx/sy
 
 --tox / toy 
end

function grape(ex,ey,ewait,emaxage,espd,eonend)
 local spokes=6
 local ang=rnd()
 local step=1/spokes
 
 
 for i=1,spokes do
  --spawn blobs
  local myang=ang+step*i
  local dist=8
  local dist2=dist/2
  
	 add(parts,{
	  x=ex+sin(myang)*dist2,
	  y=ey+cos(myang)*dist2,
	  r=2,
	  tor=5,
	  tox=ex+sin(myang)*dist,
	  toy=ey+cos(myang)*dist,
	  wait=ewait,
	  maxage=emaxage,
	  onend=eonend,
	  spd=espd
	 })  
  
 end
 add(parts,{
  x=ex,
  y=ey,
  r=2,
  tor=7,
  wait=ewait,
  maxage=emaxage,
  onend=eonend,
  spd=espd
 })  
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
