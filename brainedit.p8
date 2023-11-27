pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--todo

-- goal
-------

-- todo
-------
-- autosave
-- position goto
-- how do i fire multiple bullets

function _init()
 --- customize here ---
 #include shmup_brains.txt
 #include shmup_brains_meta.txt
 file="shmup_brains.txt"
 filem="shmup_brains_meta.txt"
 
 arrname="brains"
 data=brains
 #include shmup_myspr.txt
 #include shmup_enlib.txt
 #include shmup_anilib.txt
 #include shmup_pats.txt
 ----------------------
 debug={}
 msg={}
 
 _drw=draw_brain
 _upd=update_brain
 
 menuitem(1,"export",export)
 
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 
 curx=1
 cury=1
 scrolly=0
 scrollx=0
 
 selbrain=1
 
 cmdlist={
  "hed",
  "wai",
  "asp",
  "got",
  "fir",
  "adr",
  "clo",
  "flw",
  "lop"
 }
 
 execy=0
 
 scroll=0
  
 enemies={}
 buls={} 
 
 muzz={}
 
 overlay=false
 showtrails=false
 showui=true
 
 newtrails={}
 curtrails={}
 
 pspr={
  x=64,
  y=110
 }
 
 poke(0x5f2d, 1)
 
 t=0
end

function _draw()
 _drw()
 
 if #msg>0 then
  bgprint(msg[1].txt,64-#msg[1].txt*2,80,14)
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
 t+=1
 dokeys()
 mscroll=stat(36)
 scroll+=0.2
 scroll=scroll%16
 _upd()
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
-->8
--draw

function draw_brain()
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
 circ(pspr.x,pspr.y,3,5)
 
 for e in all(enemies) do
  drawobj(e)
  if overlay and e==protag then
   local myang=e.ang
   if e.spd<0 then
    myang-=-0.5
   end
   local ox=sin(myang)
   local oy=cos(myang)
   
   local ox1=e.x+ox*12
   local oy1=e.y+oy*12
   
   pset(e.x,e.y,11)
   line(ox1,oy1,
        ox1+ox*8*abs(e.spd),
        oy1+oy*8*abs(e.spd),11)
  end
 end
 
 for s in all(buls) do
  drawobj(s) 
 end
 
 -- temp muzzle flashes
 for m in all(muzz) do
  m.r-=1
  if m.en then
   circfill(m.en.x,m.en.y,m.r,7)
  end
  if m.r<=0 then
   del(muzz,m)
  end
 end
 
 if showtrails then
  for t in all(curtrails) do
   pset(t[1],t[2],11)
  end
 end
 
 if showui then
  drawmenu()
  line(1+scrollx,execy+scrolly,1+scrollx,execy+6+scrolly,11)
 end
end

function draw_table()
 cls(2)
 --spr(0,0,0,16,16)
 
 drawmenu()
 
 --[[
 for i=1,#data do
  for j=1,#data[i] do
   bgprint(data[i][j],2+18*j,2+8*i,7)
  end
 end
 ]]
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

function update_setup()
 scrolly=0
 refresh_setup()
 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=mid(2,cury,#menu)
 curx=2
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="meta" then
   _upd=upd_type
   typetxt=tostr(mymnu.txt)
   typecur=#typetxt+1
   callback=enter_meta
  end
 end
 
 if btnp(🅾️) then
  _upd=update_brain
  refresh_brain()
  return
 end
 
 if data[selbrain] then
  if #enemies==0 then
   local selmeta=meta[selbrain]
   
   if enlib[selmeta[1]]!=nil then
    curtrails=newtrails
    reseten()
   end  
  end
  dobuls(buls)
  doenemies()  
  
 else
  enemies={}
 end

end

function update_brain()
 refresh_brain()
 
 pspr.x=stat(32)
 pspr.y=stat(33)
 
 if key=="1" then
  overlay= not overlay
 end
 if key=="2" then
  showtrails= not showtrails
 end
 if key=="3" then
  showui= not showui
 end
 
 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=mid(1,cury,#menu)
 
 if cury==1 then
	 if btnp(⬅️) then
	  selbrain-=1
	  enemies={}
	  curtrails={}
	 end
	 if btnp(➡️) then
	  selbrain+=1
	  enemies={}
	  curtrails={}
	 end
	 selbrain=mid(1,selbrain,#data+1)
 else
	 if btnp(⬅️) then
	  curx-=1
	 end
	 if btnp(➡️) then
	  curx+=1
	 end
	 curx=mid(1,curx,#menu[cury])
 end
 
 ---scrolling
 local mymnu=menu[cury][curx]
 if mymnu.y+scrolly>100 then
  scrolly-=4
 end
 if mymnu.y+scrolly<10 then
  scrolly+=4
 end
 scrolly=min(0,scrolly)

 --interaction
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="edit" then
   _upd=upd_type
   typetxt=tostr(mymnu.txt)
   typecur=#typetxt+1
   callback=enter_brain
  elseif mymnu.cmd=="newline" then
   add(data[mymnu.cmdb],"wai",mymnu.cmdi)
   add(data[mymnu.cmdb],0,mymnu.cmdi+1)
   add(data[mymnu.cmdb],0,mymnu.cmdi+2)
   cury+=1
   curx=1
  elseif mymnu.cmd=="setup" then
   refresh_setup()
   _upd=update_setup
   return
  elseif mymnu.cmd=="newbrain" then
   add(data,{
    "wai",0,0
   })
   add(meta,{
    1,64,10
   })
  end
  return 
 end
 if data[selbrain] then
  if #enemies==0 then
   local selmeta=meta[selbrain]
   if enlib[selmeta[1]]!=nil then
    curtrails=newtrails
    reseten()
   end
  end
  dobuls(buls)
  doenemies()
  
  if protag and t%5==0 then
   add(newtrails,{protag.x,protag.y})
  end

 else
  enemies={}
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

function split2d(s)
 local arr=split(s,"|",false)
 for k, v in pairs(arr) do
  arr[k] = split(v)
 end
 return arr
end

function spacejam(n)
 local ret=""
 for i=1,n do
  ret..=" "
 end
 return ret
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

function onscreen(obj)
 if obj.x<-8 then return false end
 if obj.y<-8 then return false end
 if obj.x>136 then return false end
 if obj.y>136 then return false end 
 return true
end

function spread(val)
 return (rnd(2)-1)*val
end
-->8
--i/o
function export()
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
 
 local s="meta=split2d\""
 for i=1,#meta do
  if i>1 then
   s..="|"
  end
  for j=1,#meta[i] do
	  if j>1 then
	   s..=","
	  end
	  s..=meta[i][j]
  end
 end
 s..="\""
 printh(s,filem,true)

 add(msg,{txt="exported!",t=120})
 --debug[1]="exported!"
end
-->8
--ui

function refresh_setup()
 menu={}
 menui={}
 add(menu,{{
	 txt="brain "..selbrain,
	 w="        ",
	 cmd="",
	 x=3,
	 y=3,
	 c=13  
 }})
 
 local cap={"en:"," x:"," y:"}
 local selmeta=meta[selbrain]
 for i=1,3 do
  local lne={}
  add(lne,{
	  txt=cap[i],
	  w="  ",
	  cmd="",
	  x=3,
	  y=3+i*6+2,
	  c=13  
  })
  add(lne,{
	  txt=selmeta[i],
	  w="   ",
	  cmd="meta",
	  cmdy=i,
	  x=3+12,
	  y=3+i*6+2,
	  c=13  
  })
  add(menu,lne)
 end

end

function refresh_brain()
 menu={}
 menui={}
 execy=-16
 
 if selbrain>#data then
  --empty brain slot
  add(menu,{{
	  txt="< new brain ",
	  w="           ",
	  cmd="newbrain",
	  x=3,
	  y=3,
	  c=13  
  }}) 
  return
 end
 
 add(menu,{{
	 txt="< brain "..selbrain.." >",
	 w="            ",
	 cmd="head",
	 x=3,
	 y=3,
	 c=13  
 }}) 
 add(menu,{{
	 txt="◆setup",
	 w="       ",
	 cmd="setup",
	 x=3,
	 y=3+8,
	 c=13 
 }})
 
 local mybra=brains[selbrain]
 local ly=19
 for i=1,#mybra,3 do
  if enemies[1] then
   local myen=enemies[1]
   if myen.brain==selbrain and myen.bri==i then
    execy=ly-9
   end
  end
 
  local lne={}
  add(lne,{
		 txt=mybra[i],
		 w="   ",
		 cmd="edit",
		 cmdi=i,
		 cmdb=selbrain,
		 x=3,
		 y=ly,
		 c=13    
  })
  local lx=3+14 
  for j=1,2 do
   local mytxt=tostr(mybra[i+j])
	  add(lne,{
			 txt=mytxt,
			 w=spacejam(#mytxt),
			 cmd="edit",
			 cmdi=i+j,
			 cmdb=selbrain,
			 x=lx,
			 y=ly,
			 c=13    
	  })
	  lx+=#mytxt*4+2
  end
  
  if cury==#menu+1 then
		 add(lne,{
			 txt="+",
			 w=" ",
			 cmd="newline",
			 cmdi=i+3,
			 cmdb=selbrain,
			 x=lx,
			 y=ly,
			 c=13    
		 })
  end
  
  add(menu,lne)
  ly+=8
 end
 
 if menu[cury] then
	 local mymnu=menu[cury][curx]
	 if mymnu and mymnu.cmd=="edit" then
		 add(menui,{{
			 txt="i:"..mymnu.cmdi,
			 w="    ",
			 cmd="",
			 x=3,
			 y=120,
			 c=15    
		 }})
	 end
	end
end

function refresh_table()
 menu={}
 menui={}
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

function enter_brain()
 _upd=update_brain

 local mymnu=menu[cury][curx]
 local typeval=typetxt
 enemies={}
 if mymnu.cmdi%3==1 then
  --editing command entry
  if typeval=="" then
   deli(data[mymnu.cmdb],mymnu.cmdi)
   deli(data[mymnu.cmdb],mymnu.cmdi)
   deli(data[mymnu.cmdb],mymnu.cmdi)
   if #data[mymnu.cmdb]==0 then
    deli(data,mymnu.cmdb)
    deli(meta,mymnu.cmdb)
    add(msg,{txt="brain deleted!",t=120})
   end
   
   return
  else 
   local found=false 
   for c in all(cmdlist) do
    if typeval==c then
     found=true
    end 
   end
   if not found then
    typeval="wai"
   end
  end
 else
  --editing parameters
  typeval=tonum(typetxt)
  if typeval==nil then
   typeval=0
  end
 end
 data[mymnu.cmdb][mymnu.cmdi]=typeval

end

function enter_meta()
 _upd=update_setup

 local mymnu=menu[cury][curx]
 local typeval=tonum(typetxt)
 enemies={}
 
 if typeval==nil then
  typeval=0
 end
 meta[selbrain][mymnu.cmdy]=typeval

end
-->8
--enemy

function dobrain(e,depth)
 --★ remove robustness
 if braincheck(e)==false then return end
 local depth=depth or 1
 if depth>100 then
  if #msg>0 then
   msg[1].t=5
  else
   add(msg,{txt="infinite loop",t=5})
  end
  return
 end 
 -- robustness code end
 
 local mybra=brains[e.brain]
 local quit=false
 if e.bri<#mybra then
  local cmd=mybra[e.bri]
  local par1=mybra[e.bri+1]
  local par2=mybra[e.bri+2]
  if cmd=="hed" then
   --set heading / speed
   e.ang=par1
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
   e.adrt=par1
   e.adrs=par2
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
   patshoot(e,par1,par2)
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
   e.flws=par1
   --par2??
  else
   --★ extra robustness
   return
  end
  e.bri+=3
  if quit then return end
  dobrain(e,depth+1)
 end
end

function doenemies()
 for e in all(enemies) do
  if e.wait>0 then
   e.wait-=1
  elseif e.dist<=0 then
   dobrain(e)
  end
  
  if e.flw then
   local diff=atan2(pspr.y-e.y,pspr.x-e.x)-e.ang   
   if abs(diff)>0.5 then
    diff-=sgn(diff)
   end
   
   e.ang+=mid(-e.flws,diff,e.flws)
   
   if dist(pspr.x,pspr.y,e.x,e.y)<25 then
    e.flw=false
   end
   e.ang=e.ang%1
  end
  
  if e.aspt then
   e.spd+=e.asps
   if abs(e.aspt-e.spd)<abs(e.asps) then
    e.spd=e.aspt
    e.aspt=nil
   end
  end
  if e.adrt then
   e.ang+=e.adrs
   if abs(e.adrt-e.ang)<abs(e.adrs) then
    e.ang=e.adrt
    e.adrt=nil
   end
  end
  
  e.sx=sin(e.ang)*e.spd
  e.sy=cos(e.ang)*e.spd
  e.dist=max(0,e.dist-abs(e.spd))
  
  e.x+=e.sx
  e.y+=e.sy
  
  e.age+=1
  
  if not onscreen(e) then
   del(enemies,e)
  else  
   dobulq(e)
  end
  
 end
end

function reseten()
 t=0
 enemies={}
 local selmeta=meta[selbrain]
 spawnen(selmeta[1],selmeta[2],selmeta[3])
 protag=enemies[1]
 newtrails={}
 buls={}
end

function spawnen(eni,enx,eny)
 local en=enlib[eni]
 
 add(enemies,{
  x=enx,
  y=eny,
  ani=anilib[en[1]],
  anis=en[2],
  sx=0,
  sy=0,
  ang=0,
  spd=0,
  brain=selbrain,
  bri=1,
  age=0,
  flash=0,
  hp=en[4],
  col=en[5],
  wait=0,
  dist=0,
  bulq={}
 })
	
end

function braincheck(e)
 if brains[e.brain]==nil then
  if #msg>0 then
   msg[1].t=5
  else
   add(msg,{txt="bad brain "..e.brain,t=5})
  end
  return false
 end
 
 local mybra=brains[e.brain]
 if e.bri<1 then
  if #msg>0 then
   msg[1].t=5
  else
   add(msg,{txt="brain command index < 1",t=5})
  end
  return false
 elseif e.bri<#mybra then
  local cmd=mybra[e.bri]
  local found=false
  for c in all(cmdlist) do
   if c==cmd then
    found=true
   end
  end
  if found==false then
	  if #msg>0 then
	   msg[1].t=5
	  else
	   add(msg,{txt="bad command "..cmd,t=5})
	  end
	  return false
  end
 end
 
 return true
end
--- tools 

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
-->8
--pats

function makepat(pat,pang)
 local mypat,ret=pats[pat],{}
 local patype,p2,p3,p4,p5,p6,p7,p8=unpack(mypat)
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
   ret=makepat(p3,pang)
  end
 elseif patype=="sprd" then
  for i=p3-1,p4-1 do
   for p in all(makepat(p2,pang)) do
    p.spd+=i*p6
    p.wait+=i*p7
    add(ret,p)
    if i>0 and p8>0 then
     local copyp=copylist(p)
     copyp.ang+=i*-p5
     add(ret,copyp)
    end
    p.ang+=i*p5
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
 
 if pang==-99 then
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
