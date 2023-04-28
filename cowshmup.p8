pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- todo
-- - color animate particles in draw

butarr={1,2,0,3,5,6,3,4,8,7,4,0,1,2,0}

dirx={-1,1, 0,0, -0.7, 0.7,0.7,-0.7}
diry={ 0,0,-1,1, -0.7,-0.7,0.7,0.7}

butarr[0]=0

shiparr={65,67,69,71,73}

shipspr=0

shots={}
shotwait=0

muzz={}


function _init()
 px,py=64,64
 spd=1.4
 lastdir=0
 t=0

 scroll=0
 xscroll=0
  
 boss=false
 
 mapsegs={3,3,3,3,3,2,1,0,1,7,6,5,10,4,11,6,11,11,5,9,10,8,1,0,15,14,1,13,12,19,19,18,17,16,18,17,16,17,16,19,22,21,20,27,26,25,23,24,3,3}
 mapsegi=0
 cursegs={}
 
 parts={}
end

function _draw()
 cls(2)
 for seg in all(cursegs) do
  map(seg.x,seg.y,xscroll,scroll-seg.o,18,8)
 end
 
 for p in all(parts) do
  if p.wait==nil then
   p.draw(p)
  end
 end
  
 for s in all(shots) do    
  spr(s.sani[flr(s.si)],s.x,s.y,1,s.sh)
 end
 
 for m in all(muzz) do    
  spr(m.sani[flr(m.si)],px+m.x,py+m.y,2,2)
 end
 
 --ship
 spr(shiparr[flr(shipspr*2.4+3.5)],px,py,2,2)
 local flamearr={76,77,78,77}
 local fframe=flamearr[t\3%4+1]
 spr(fframe,px+6,py+15)
 spr(fframe,px+3,py+15)
 
 print(#cursegs,5,5,7)
 print(scroll,5,11,7)
 print(xscroll,5,17,7)
 print(boss and "boss" or "noboss",5,23,7)
end

function _update60()
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
  if scroll-cursegs[1].o>=128 then
   deli(cursegs,1)
  end
 
 end
 
 --movement
 t+=1
 local dir=butarr[btn()&0b1111]
 
 if lastdir!=dir and dir>=5 then
  --anti-cobblestone
  px=flr(px)+0.5
  py=flr(py)+0.5
 end
 
 local dshipspr=0
 
 if dir>0 then
  px+=dirx[dir]*spd
  py+=diry[dir]*spd
  dshipspr=mysgn(dirx[dir])
 end
  
 shipspr+=mysgn(dshipspr-shipspr)*0.15
 shipspr=mid(-1,shipspr,1)
 
 lastdir=dir
 
 xscroll=mid(0,(px-10)/100,1)*-16
 
 
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
 
 doshots()
 domuzz()
 for p in all(parts) do
  dopart(p)
 end
  
end
-->8
--draw
-->8
--update
-->8
--tools

function mysgn(v) 
 return v==0 and 0 or sgn(v)
end

function rndrange(low,high)
 return flr(rnd(high+1-low)+low)
end
-->8
--gameplay

function doshots()
 for s in all(shots) do
  s.x+=s.sx
  s.y+=s.sy
  s.si+=0.5
  
  if flr(s.si)>#s.sani then
   s.si=1
  end
  
  if s.y<-16 then
   del(shots,s)
  end
 end
end


function shoot()
 local shotspd=-6
 shotwait=3
 
 add(shots,{
  x=px,
  y=py-5,
  sx=0,
  sy=shotspd,
  sani={96,97,98},
  si=(t\2)%3+1,
  sh=2
 })
 add(shots,{
  x=px+8,
  y=py-5,
  sx=0,
  sy=shotspd,
  sani={96,97,98},
  si=(t\2)%3+1,
  sh=2
 })
 
 add(muzz,{
  x=-4,
  y=-8,
  sani={99,101,103,105},
  si=0,
 })
 add(muzz,{
  x=4,
  y=-8,
  sani={99,101,103,105},
  si=0,
 })
 sfx(0)
end
-->8
--particles

function explode(ex,ey)
 sfx(1)
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=17,
  maxage=2,
  c=119,
  ctab={119,167} --★
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
   p.r=p.r or 1
   p.ctabv=p.ctabv or 0
  end
  p.age+=1
  
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
	  wait=ewait,
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
  wait=ewait,
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
	  wait=ewait,
	  maxage=rndrange(8,13)
	 })
 end
end

function domuzz()
 for m in all(muzz) do
  m.si+=1 
  if flr(m.si)>#m.sani then
   del(muzz,m)
  end
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
__gfx__
000000006ddddddddddddddddddddddd911991190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddddd666666d119911990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd66666666d6dddd5d199119910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd66666666d6dddd5d991199110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd66666666d6dddd5d911991190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700dddddddd66666666d6dddd5d119911990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddddd655555d199119910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddd991199110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd6ddddddd0000000000000000000000000000000000000000
00000000dd66dddddd666ddddd666ddddd6d6ddddd666ddddd6ddddddd666ddddd666ddddd666ddddd666ddd0000000000000000000000000000000000000000
00000000ddd6dddddddd6ddddddd6ddddd6d6ddddd6ddddddd6ddddddddd6ddddd6d6ddddd6d6ddddd6d6ddd0000000000000000000000000000000000000000
00000000ddd6dddddd666dddddd66ddddd666ddddd666ddddd666ddddddd6ddddd666ddddd666ddddd6d6ddd0000000000000000000000000000000000000000
00000000ddd6dddddd6ddddddddd6ddddddd6ddddddd6ddddd6d6ddddddd6ddddd6d6ddddddd6ddddd6d6ddd0000000000000000000000000000000000000000
00000000dd666ddddd666ddddd666ddddddd6ddddd666ddddd666ddddddd6ddddd666ddddd666ddddd666ddd0000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000011000000000000001100000000000000110000000000000011000000000000001100000000990000000070000000700000007000000000000
00000000000000167100000000000016710000000000001661000000000000167100000000000016710000009779000000777000007770000077700000000000
00700700000000111d100000000000111d1000000000011111100000000001d111000000000001d11100000097790000007c7000007c70000077700000000000
00077000000001ccc1100000000001ccc1100000000001cccc1000000000011ccc1000000000011ccc1000009aa9000000070000007c7000007c700000000000
0007700000001c77cc11000000001c77cc11000000001c77ccc10000000011c77cc10000000011c77cc100009aa900000000000000070000007c700000000000
0070070000001c7c1c11000000001c7c1c11000000001c7cc1c10000000011c7c1c10000000011c7c1c100000990000000070000000000000007000000000000
0000000000001c111c11100000011c111c11100000111c1111c11100000111c111c11000000111c111c100000000000000000000000700000007000000000000
0000000000001c111c17100000011c111c17100000171c1111c17100000171c111c11000000171c111c100000000000000000000000000000007000000000000
0000000000011cc17116100000161cc1171610000016117117116100000161711cc16100000161171cc110000000000000000000000000000000000000000000
000000000001d1c711d6d1000016d1c77116d10001d6d117711d6d10001d61177c1d6100001d6d117c1d10000000000000000000000000000000000000000000
00000000001ddd111d6d7d1001dddd1111dd6710176d6d1111d6d6710176dd1111dddd1001d7d6d111ddd1000000000000000000000000000000000000000000
00000000001dd6ddd6d66d1001dd66dddd6d66101666d6dddd6d66610166d6dddd66dd1001d66d6ddd6dd1000000000000000000000000000000000000000000
00000000001d676676d6dd1001d6676676d6dd101dd6d676676d6dd101dd6d6766766d1001dd6d676676d1000000000000000000000000000000000000000000
00000000000176d167d1110000117dd1171111000111171661711110001111711dd7110000111d761d6710000000000000000000000000000000000000000000
000000000000151155d110000001655155d11000000161511516100000011d551556100000011d55115100000000000000000000000000000000000000000000
00000000000001111111000000001111111100000000111111110000000011111111000000001111111000000000000000000000000000000000000000000000
00099000000990000009900000000000000000000000000770000000000000000000000000007000000700000000000000000000000000000000000000000000
00099000000990000009900000000000000000000000000770000000000070000007000000000000000000000000000000000000000000000000000000000000
00977900000990000009900000000000000000000000000770000000000070000007000000000000000000000000000000000000000000000000000000000000
00977900009aa9000009900000000000000000000000700770070000000000000000000000000000000000000000000000000000000000000000000000000000
09777790009779000009900000000007700000000007707777077000000000077000000000000000000000000000000000000000000000000000000000000000
0977779000977900009aa90000000777777000000007707777077000000000077000000070000000000000070000000000000000000000000000000000000000
97a77a7909a77a900097790000007777777700000000777777770000070000077000007000000000000000000000000000000000000000000000000000000000
97a77a7909a77a900097790000007777777700000070777777770700007000777700070000000000000000000000000000000000000000000000000000000000
9aa77aa909a77a90009aa90000077777777770000077777777777700000007777770000000000000000000000000000000000000000000000000000000000000
9aa77aa9099aa990009aa90000077777777770000007777777777000000007777770000007000007700000700000000000000000000000000000000000000000
9a9aa9a9099aa990009aa90000077777777770000000777777770000007007777770070000000007700000000000000000000000000000000000000000000000
999aa999099999900099990000007777777700000000777777770000000007777770000000000077770000000000000000000000000000000000000000000000
999aa999099999900099990000000777777000000000077777700000000000777700000000000077770000000000000000000000000000000000000000000000
90999909099999900099990000000077770000000000007777000000000000077000000000000007700000000000000000000000000000000000000000000000
90099009090990900009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099000000990000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc111ccc11
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c1c1c1ccccccccc1111ccc1
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc11111ccc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccc11111cc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccc11111c
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc11111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccccc1c1c1c11ccc1111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccc11ccc111
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
a2010000070401f6401f6300e6200d610050100301001050000100201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12030000256402c6602f6602f65027640206401a630136300e6500d650106401866022620106400b6300a65010630146101062001620006100061000000000000000000000000000000000000000000000000000