pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--show cursor
--move the cursor
--backspace

function _init()
 --- customize here ---
 #include shmup_sched.txt
 file="shmup_sched.txt"
 arrname="sched"
 data=sched
 #include shmup_mapsegs.txt
 #include shmup_enlib.txt
 #include shmup_anilib.txt
 #include shmup_myspr.txt
 ----------------------
 
 debug={}
 msg={}
 
 _drw=draw_map
 _upd=update_map
 
 menuitem(1,"export",export)
 
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 reload(0x1000, 0x1000, 0x2000, "cowshmup.p8")
 
 curx=1
 cury=1
 scrolly=0
 scrollx=0
 
 scroll=0
 xscroll=0
 poke(0x5f2d, 1)
 
 selsched=nil
 
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
 domouse()
 mscroll=stat(36)
 
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

function domouse()
 mousex=stat(32)
 mousey=stat(33)
 
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
   clkl=true
   clkwait=true  
  end
 end
 
end
-->8
--draw

function draw_map()
 cls(2)
 for i=1,#mapsegs do
  local segnum=mapsegs[i]
  local sx=segnum\4*18
  local sy=segnum%4*8
  map(sx,sy,xscroll,scroll-((i-2)*64),18,8)
 end
 
 
 
 camera(-xscroll,0)
 for sch in all(sched) do
  local schx=sch[3]
  local schy=sch[4]+scroll-sch[1]
  
  local en=enlib[sch[2]]
  local ani=anilib[en[1]]

  if sch==selsched then
   local col=11+16*12
   fillp(flr(▥))
   line(0,sch[4],127,sch[4],col)
   fillp(flr(▤))
   line(sch[3],0,sch[3],127,col)
   
   line(sch[3],sch[4],sch[3]-128,sch[4]+128,col)
   line(sch[3],sch[4],sch[3]+128,sch[4]+128,col)
   line(sch[3],sch[4],sch[3]-128,sch[4]-128,col)
   line(sch[3],sch[4],sch[3]+128,sch[4]-128,col)
   fillp() 
  end
    
  mspr(cyc(t,ani,en[2]),schx,schy)
  
  if sch==selsched then
   local col=rnd({6,7})
   rect(schx-8,schy-8,schx+9,schy+9,col)
   
   
   
  end
  --rectfill(schx,schy,schx+16,schy+16,8)
 end
 camera()
 
 -- timeline
 
 for i=0,21 do
  local iscr=scroll+(20-i)-10
  local ens=spwnlst(iscr)
  
  if i==10 or iscr%5==0 then
   print(" "..tostrn(iscr,4),0,i*6,7)
   print("-",21,i*6,7)
  end

  if #ens>0 then
   local s=""
   local uix=26
   for j=1,#ens do
    print(tostrn(ens[j][2],2,"0"),uix,i*6,7)
    uix+=10
   end
  end
  
  
  if iscr<0 then
   break
  end
 end
 
 drawmenu()
 drawcur(mousex,mousey)
 
 --debug[1]=scroll
 
end

function draw_table()
 cls(2)
 --spr(0,0,0,16,16)
 
 drawmenu()
 
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
end

function drawcur(cx,cy)
 local col=rnd({6,7})
 line(cx,cy-1,cx,cy-2,col)
 line(cx,cy+1,cx,cy+2,col)
 line(cx-1,cy,cx-2,cy,col)
 line(cx+1,cy,cx+2,cy,col)
 
end
-->8
--update

function update_map()
 refresh_map()

 scroll+=mscroll*8
 
 xscroll=mid(0,(mousex-10)/108,1)\-0.0625
 cury=1
 if btnp(⬇️) then
  scroll-=1
  curx=2
 end
  
 if btnp(⬆️) then
  scroll+=1 
  curx=2
 end
 
 scroll=max(0,scroll)
 
 if btnp(⬅️) then
  curx-=1
 end
  
 if btnp(➡️) then
  curx+=1
 end
 curx=mid(2,curx,#menu[cury])
 
 if btnp(❎) then
  dobutton(menu[cury][curx])
 end
 
 -- mouse button control
 for my=1,#menu do
  for mx=1,#menu[my] do
	  if mousecol(menu[my][mx]) then
	   curx=mx
	   cury=my
	   if clkl then
	    dobutton(menu[cury][curx])
	   end
	  end
  end
 end
 
 if menu[cury][curx].cmdsch then
  selsched=menu[cury][curx].cmdsch
 else
  selsched=nil
 end

 if key=="t" then
  _drw=draw_table
  _upd=update_table
  refresh_table()
  return
 end
 
end

function update_table()
 refresh_table()
 
 if key=="m" then
  _drw=draw_map
  _upd=update_map
  refresh_map()
  return
 end
 
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
   local mymnu=menu[cury][curx]
   poke(0x5f30,1)
   local typeval=tonum(typetxt)
   if typeval==nil then
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

function msprc(si,sx,sy)
 local _x,_y,_w,_h,_ox,_oy,_fx,_nx=unpack(myspr[si])
 rect(sx-_ox,sy-_oy,sx-_ox+_w-1,sy-_oy+_h-1,rnd({8,14,15}))
end

function drawobj(obj)
 mspr(cyc(obj.age,obj.ani,obj.anis),obj.x,obj.y)
 
 --★
 if coldebug and obj.col then
  msprc(obj.col,obj.x,obj.y)
 end
end

function cyc(age,arr,anis)
 local anis=anis or 1
 return arr[(age\anis-1)%#arr+1]
end

function sortsched()
 if #sched<2 then return end
 
 repeat
	 local switch=false
	 for i=1,#sched-1 do
	  if sched[i][1]>sched[i+1][1] then   
	   sched[i],sched[i+1]=sched[i+1],sched[i]
	   switch=true
	  end
	 end
 until switch==false

end

function tostrn(v,l,ch)
 local ch=ch or " "
 local sv=tostr(v)
 if #sv<l then
  local diff=l-#sv
  for i=1,diff do
   sv=ch..sv
  end  
 end
 return sv
end

function spwnlst(scr)
 local ret={}
 for s in all(sched) do
  if s[1]==scr then
   add(ret,s)
  end
 end
 return ret
end

function mousecol(b)
 local wid=#b.w*4-1
 
 if mousex<b.x-1 then return false end
 if mousey<b.y-1 then return false end
 if mousex>b.x+wid then return false end
 if mousey>b.y+5 then return false end
 
 
 return true
end
-->8
--i/o
function export()
 sortsched()
 
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
 add(msg,{txt="exported!",t=120})
 --debug[1]="exported!"
end
-->8
--ui

function refresh_map()
 menu={}
 local lne={}
 add(lne,{
	 txt=tostrn(scroll,4),
	 w="    ",
	 cmd="",
	 x=4,
	 y=60,
	 c=6
 })
 
 local uix=26
 
 local ens=spwnlst(scroll)
 if #ens>0 then
  for i=1,#ens do
		 add(lne,{
			 txt=tostrn(ens[i][2],2,"0"),
			 w="  ",
			 cmd="editen",
			 cmdsch=ens[i],
			 x=uix,
			 y=60,
			 c=13
		 }) 
		 uix+=10  
  end 
 end
 
 add(lne,{
	 txt="+",
	 w=" ",
	 cmd="adden",
	 x=uix,
	 y=60,
	 c=13
 })
 
 add(menu,lne)
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

function dobutton(b)
 if b.cmd=="adden" then
	 local sch={}
	 sch[1]=scroll 
	 sch[2]=1
	 sch[3]=64
	 sch[4]=8
	 add(sched,sch)
	elseif b.cmd=="editen" then
	 del(sched,b.cmdsch)
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
