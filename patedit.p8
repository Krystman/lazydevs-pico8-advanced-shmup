pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- todo
------------------
-- burst collapsed into spread
-- shift?


-- assumptions
------------------
-- bullets don't change direction
-- bullets don't change speed


function _init()
 autosave=true
 dirty=false
 
 --- customize here ---
 #include shmup_pats.txt
 file="shmup_pats.txt"
 arrname="pats"
 data=pats

 #include shmup_myspr.txt
 #include shmup_anilib.txt
 ----------------------

 for p in all(pats) do
  if p[1]=="sprd" then
   p[9]=0
  end
 end
 
 debug={}
 msg={}
 
 _drw=draw_pats
 _upd=update_pats
 
 menuitem(1,"export",export)
 
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 
 curx=1
 cury=1
 scrolly=0
 scrollx=0
 scroll=0
 
 pspr={
  x=64,
  y=110
 }
 
 enspr={
  x=64,
  y=64,
  bulq={}
 }
 
 buls={} 
 
 poke(0x5f2d, 1)
 
 selpat=1

 fireang=-99
end

function _draw()
 _drw()
 
 if #msg>0 then
  if msg[1].txt=="autosave" then
   rectfill(119,119,125,125,0)
   print("\^:0d1d11111f000000",120,120,sin(time()*3)>-0.3 and 6 or 5) 
  else
   bgprint(msg[1].txt,64-#msg[1].txt*2,80,14)
  end
  msg[1].t-=1
  if msg[1].t<=0 then
   deli(msg,1)
  end  
 end
 
 -- debug --
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function _update60()
 dokeys()
 domouse()
 mscroll=stat(36)
 scroll+=0.2
 scroll=scroll%16
 
 _upd()
 if time()%2==0 then
  if autosave and dirty then
   export(true)
   dirty=false
  end
 end
end

function dokeys()
 if stat(30) then
  key=stat(31)
  if key=="p" then
   poke(0x5f30,1)
  end
 else
  key=nil
 end
 
end

function domouse()
 local oldmousex=mousex
 local oldmousey=mousey
 
 mousex=stat(32)
 mousey=stat(33)
 
 mousemove=false
 if mousex!=oldmousex or oldmousey!=mousey then
  mousemove=true
 end
 
 if stat(34)==0 then
  clkwait=false
 end
 clkl=false
 clkr=false
 if not clkwait then
  if stat(34)==1 then
   clkl=true
   clkwait=true
  elseif stat(34)==2 then
   clkr=true
   clkwait=true  
  end
 end
 
end
-->8
--draw

function draw_pats()
 cls(13)
 
 if flr(scroll)%2==0 then
  fillp(0b0000111100001111.1)
 else
  fillp(0b1111000011110000.1)
 end
 for i=0,7 do
  line(i*16,0,i*16,128,5)
 end
 fillp(▥)
 for i=-1,7 do
  line(0,i*16+scroll,128,i*16+scroll,5)
 end
 fillp()

 --enemy
 line(enspr.x-2,enspr.y-2,enspr.x+2,enspr.y+2,5)
 line(enspr.x-2,enspr.y+2,enspr.x+2,enspr.y-2,5)
 
 local myang=0
 if fireang==-99 then
  myang=atan2(pspr.y-enspr.y,pspr.x-enspr.x)
 end
 line(enspr.x+sin(myang)*8,enspr.y+cos(myang)*8,
      enspr.x+sin(myang)*12,enspr.y+cos(myang)*12,5)
 
 --player
 circ(pspr.x,pspr.y,3,5)

 for s in all(buls) do
  drawobj(s) 
 end
   
 drawmenu()

 bgprint(#buls,3,120,5)

end

function draw_table()
 cls(2)
 --spr(0,0,0,16,16)
 
 drawmemnu()
end

function drawmenu()
	if menu then
		for i=1,#menu do
		 for j=1,#menu[i] do
		  local mymnu=menu[i][j]
		  local c=mymnu.c or 13
		  if i==cury and j==curx then
		   c=7
		   if _upd==upd_type then
		    c=0
		   end
		  end
		  
		  bgprint(mymnu.w,mymnu.x+scrollx,mymnu.y+scrolly,13)   
		  bgprint(mymnu.txt,mymnu.x+scrollx,mymnu.y+scrolly,c) 
		 end
		end
 end
 
	if menui then
		for i=1,#menui do
		 for j=1,#menui[i] do
		  local mymnui=menui[i][j]
		  local c=mymnui.c or 13
		  if i==cury and j==curx then
		   c=7
		   if _upd==upd_type then
		    c=0
		   end
		  end 
		  bgprint(mymnui.w,mymnui.x,mymnui.y,13)   
		  bgprint(mymnui.txt,mymnui.x,mymnui.y,c) 
		 end
		end
 end
 
 if _upd==upd_type then
  local mymnu=menu[cury][curx]
  
  local txt_bef=sub(typetxt,1,typecur-1)
  local txt_cur=sub(typetxt,typecur,typecur)
  local txt_aft=sub(typetxt,typecur+1)
  txt_cur=txt_cur=="" and " " or txt_cur 
  
  if (time()*2)%1<0.5 then
   txt_cur="\^i"..txt_cur.."\^-i"
  end
   
  local txt=txt_bef..txt_cur..txt_aft
		bgprint(txt,mymnu.x+scrollx,mymnu.y+scrolly,7)
 end
end


-->8
--update

function update_pats()

 if key=="1" then
  if fireang==-99 then
   fireang=0
  else
   fireang=-99
  end
 end
 
 refresh_pats()
 
 enspr.x=mousex
 enspr.y=mousey
 
 if clkl and selpat<=#pats then
  patshoot(enspr,selpat,fireang)
 end
 dobulq(enspr)
 dobuls(buls)
 
 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=mid(1,cury,#menu)
 
 if cury==1 then
  curx=1
  if btnp(⬅️) then
   selpat-=1
  end
  if btnp(➡️) then
   selpat+=1
  end
  selpat=mid(1,selpat,#pats+1)
 elseif cury==2 then
  curx=1
 elseif cury==#menu then
  curx=1
 else
	 curx=2
 end
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="patedit" then
   _upd=upd_type
   typetxt=tostr(mymnu.txt)
   typecur=#typetxt+1
   callback=enter_pat
   return
  elseif mymnu.cmd=="newpat" then
   add(pats,newpat("base"))
   dirty=true
   return
  elseif mymnu.cmd=="delpat" then
   deli(pats,selpat)
   add(msg,{txt="pat deleted!",t=120})
   dirty=true
  end
 end
 
 
end

function update_table()
 refresh_table()

 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=(cury-1)%#menu+1
 cury-=mscroll
 cury=mid(1,cury,#menu)
 
 if btnp(⬅️) then
  curx-=1
 end
 if btnp(➡️) then
  curx+=1
 end
 if cury<#menu then
  curx=(curx-2)%(#menu[cury]-1)+2
 else
  curx=1
 end
 local mymnu=menu[cury][curx]
 if mymnu.y+scrolly>110 then
  scrolly-=4
 end
 if mymnu.y+scrolly<10 then
  scrolly+=4
 end
 scrolly=min(0,scrolly)
 
 if mymnu.x+scrollx>110 then
  scrollx-=2
 end
 if mymnu.x+scrollx<20 then
  scrollx+=2
 end
 scrollx=min(0,scrollx)
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="edit" then
   _upd=upd_type
   typetxt=tostr(mymnu.txt)
   typecur=#typetxt+1
   callback=enter_table
  elseif mymnu.cmd=="newline" then
   add(data,{0})  
  elseif mymnu.cmd=="newcell" then
   add(data[mymnu.cmdy],0)
  end
 end
end

function upd_type()
 if key then
  if key=="\r" then
   -- enter
   poke(0x5f30,1)
   callback()
   return
  elseif key=="\b" then
   --backspace
   if typecur>1 then
    if typecur>#typetxt then
	    typetxt=sub(typetxt,1,#typetxt-1)
	   else
			  local txt_bef=sub(typetxt,1,typecur-2)
			  local txt_aft=sub(typetxt,typecur)
			  typetxt=txt_bef..txt_aft
	   end
	   typecur-=1
   end
  else
   if typecur>#typetxt then
    typetxt..=key
   else
		  local txt_bef=sub(typetxt,1,typecur-1)
		  local txt_aft=sub(typetxt,typecur)
		  typetxt=txt_bef..key..txt_aft
   end
   typecur+=1
  end
 end
 
 if btnp(⬅️) then
  typecur-=1
 end
 if btnp(➡️) then
  typecur+=1
 end
 typecur=mid(1,typecur,#typetxt+1)
end
-->8
--tools

function bgprint(txt,x,y,c)
 print("\#0"..txt,x,y,c)
end

function spacejam(n)
 local ret=""
 for i=1,n do
  ret..=" "
 end
 return ret
end

function split2d(s)
 local arr=split(s,"|",false)
 for k, v in pairs(arr) do
  arr[k] = split(v)
 end
 return arr
end

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
-->8
--i/o
function export(auto)
 local s=arrname.."=split2d\""
 
 for i=1,#data do
  if i>1 then
   s..="|"
  end
  for j=1,#data[i] do
	  if j>1 then
	   s..=","
	  end
	  s..=data[i][j]
  end
 end
 
 s..="\""
 printh(s,file,true)
 if auto==true then
  add(msg,{txt="autosave",t=60}) 
 else
  add(msg,{txt="exported!",t=120})
 end
 --debug[1]="exported!"
end
-->8
--ui

function refresh_pats()
 menu={}
 if selpat>#pats then
	 add(menu,{
	  {
		  txt="< new pat ",
		  w="          ",
		  cmd="newpat",
		  x=4,
		  y=4,
		  c=13  
	  }
	 })
	 return 
 end
 local mypat=pats[selpat]
 add(menu,{
  {
	  txt="< pat "..selpat.." >",
	  w="    ",
	  cmd="pat",
	  x=4,
	  y=4,
	  c=13  
  }
 })
 
 add(menu,{
  {
	  txt=mypat[1],
	  w="    ",
	  cmd="patedit",
	  cmdy=selpat,
	  cmdx=1,
	  x=4,
	  y=12,
	  c=13  
  }
 })
 
 local mycap={}
 if mypat[1]=="base" then
	 mycap={
	  "spd :",
	  "ani :",
	  "anis:",
	  "col :" 
	 }
 elseif mypat[1]=="some" then
	 mycap={
	  "src :",
	  "perc:"
	 } 
 elseif mypat[1]=="sprd" then
	 mycap={
	  "src :",
	  "from:",
	  "to  :",
	  "ang :",
	  "spd :",
	  "time:",
	  "type:",
	  "spd+:"
	 }  
 elseif mypat[1]=="comb" then
	 mycap={
	  "src1:",
	  "src2:",
	  "src3:",
	  "src4:",
	  "src5:"
	 } 
 else
  for i=2,#mypat do
   add(mycap,"p"..i..":")
  end
 end
 
 for i=2,#mypat do
	 add(menu,{
		 {
		  txt=mycap[i-1],
		  w="     ",
		  cmd="",
		  cmdy=selpat,
		  cmdx=i,
		  x=4,
		  y=6+i*7,
		  c=13  
	  },
	  {
		  txt=mypat[i],
		  w=spacejam(#tostr(mypat[i])),
		  cmd="patedit",
		  cmdy=selpat,
		  cmdx=i,
		  x=24,
		  y=6+i*7,
		  c=13  
	  }
	 }) 
 end
 
	add(menu,{
	 {
	  txt="delete",
	  w="      ",
	  cmd="delpat",
	  cmdy=selpat,
	  x=4,
	  y=6+#mypat*7+9,
	  c=13  
		}
	})

end

function refresh_table()
 menu={}
 for i=1,#data do
  local lne={}
  local linemax=#data[i]
  if i==cury then
   linemax+=1  
  end
  add(lne,{
	  txt=i,
	  w="   ",
	  cmd="",
	  x=4,
	  y=-4+8*i,
	  c=2  
  })
  for j=1,linemax do
   if j==#data[i]+1 then
			 add(lne,{
			  txt="+",
			  w=" ",
			  cmd="newcell",
			  cmdy=i,
			  x=-10+14*(j+1),
			  y=-4+8*i, 
			 })
		 else
		  add(lne,{
		   txt=data[i][j],
		   cmd="edit",
		   cmdx=j,
		   cmdy=i,
		   x=-10+14*(j+1),
		   y=-4+8*i,
		   w="   "
		  })
   end
  end
  add(menu,lne)
 end
 add(menu,{{
  txt=" + ",
  w="   ",
  cmd="newline",
  x=4,
  y=-4+8*(#data+1), 
 }})
end

function newpat(typ)
 if typ=="base" then
  return {
   "base",
   1,
   11,
   3,
   40
  } 
 elseif typ=="some" then
  return {
   "some",
   1,
   0.5
  }
 elseif typ=="sprd" then
  return {
   "sprd",
   1,
   1,
   1,
   0.1,
   0,
   0,
   0,
   0,
  }
 elseif typ=="comb" then
  return {
   "comb",
   1,
   0,
   0,
   0,
   0
  }
 else
  return {
   typ
  } 
 end

end

function enter_pat()
 local mymnu=menu[cury][curx]
 local typeval=typetxt
 
 if mymnu.cmdx==1 then
  --tricky!!
  if data[mymnu.cmdy][mymnu.cmdx]!=typetxt and typetxt!="" then
   data[mymnu.cmdy]=newpat(typetxt)   
  end
 else
  typeval=tonum(typeval)
  if typeval==nil then
   typeval=0
  end
  data[mymnu.cmdy][mymnu.cmdx]=tonum(typeval)
 end
 _upd=update_pats
 dirty=true
end

function enter_table()
 local mymnu=menu[cury][curx]
 local typeval=typetxt
 if typeval==nil or typeval=="" then
  if mymnu.cmdx==#data[mymnu.cmdy] and typetxt=="" then
   --delete cell
   deli(data[mymnu.cmdy],mymnu.cmdx)
   if mymnu.cmdx==1 then
    deli(data,mymnu.cmdy)
   end
   _upd=update_table
   return
  end  
  typeval=0
 end   
 data[mymnu.cmdy][mymnu.cmdx]=typeval
 _upd=update_table
end
-->8
--pats

function dobuls(arr)
 for s in all(arr) do
  s.age+=1
  s.x+=s.sx
  s.y+=s.sy
    
  if s.y<-16 or s.y>130 then
   del(arr,s)
  end
 end
end

function patshoot(en,pat,pang)
 if pang==-99 then
  pang=atan2(pspr.y-en.y,pspr.x-en.x)
 end

 local mybuls=makepat(pat,pang)

 for b in all(mybuls) do
  add(en.bulq,b)
 end
end

function dobulq(en)
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
   col=p5,
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

function spread(val)
 return (rnd(2)-1)*val
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
