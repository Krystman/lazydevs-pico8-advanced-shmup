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
 
 grape(ex,ey)
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
  p.age+=1

  
  if p.age>=p.maxage then
   del(parts,p)
  end
 end

 --age
 --maxage
 
end

function grape(ex,ey)
 local spokes=6
 local ang=rnd()
 local step=1/spokes
 local dist=8
 
 for i=1,spokes do
  --spawn blobs
	 add(parts,{
	  x=ex+sin(ang+step*i)*dist,
	  y=ey+cos(ang+step*i)*dist,
	  r=5,
	  maxage=120
	 })  
  
 end
 add(parts,{
  x=ex,
  y=ey,
  r=5,
  maxage=120
 })  
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
