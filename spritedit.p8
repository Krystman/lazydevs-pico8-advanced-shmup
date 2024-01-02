pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--todo
-- direct spritemap selection

function _init()
 autosave=true
 dirty=false
 
 --- customize here ---
 #include shmup_myspr.txt
 #include shmup_myspr_meta.txt
 file="shmup_myspr.txt"
 filem="shmup_myspr_meta.txt"
 arrname="myspr"
 data=myspr
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 ----------------------
 
 --[[meta={}
 for x=1,#data do
  mobj={}
  mobj[1]="spr "..x
  mobj[2]=0
  meta[x]=mobj
 end]]--
 
 debug={}
 msg={}
 
 _drw=draw_list
 _upd=update_list
 
 menuitem(1,"export",export)
 
 
 curx=1
 cury=1
 scrolly=0
 scrollx=0
 
 poke(0x5f2d, 1)
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
 mscroll=stat(36)
 
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
-->8
--draw
function draw_edit()
 -- background
 fillp(0b11001100001100111100110000110011)
 rectfill(0,0,127,127,33)
 fillp(▒)
 line(63,0,63,127,13)
 line(0,63,127,63,13)
 fillp()
 
 draw_menu()
 
 -- draw sprite
 if selspr then
  if meta[selspr][2]>0 then
   wrapmspr(meta[selspr][2],63,63)
   msprc(selspr,63,63)
  else
   wrapmspr(selspr,63,63)
  end
 end
 
 -- blinking dot
 if (time()*2)%1<0.5 then
  pset(63,63,rnd({8,13,7,15}))
 end
end

function draw_list()
 fillp(0b11001100001100111100110000110011)
 rectfill(0,0,127,127,33)
 fillp(▒)
 line(63,0,63,127,13)
 line(0,63,127,63,13)
 fillp()
   
 draw_menu()
 
 -- draw sprite
 local mymnu=menu[cury][curx]
 if mymnu and mymnu.cmdy then
  if meta[mymnu.cmdy][2]>0 then
   wrapmspr(meta[mymnu.cmdy][2],63,63)
   msprc(mymnu.cmdy,63,63)
  else
   wrapmspr(mymnu.cmdy,63,63)
  end
 end
 
 if (time()*2)%1<0.5 then
  pset(63,63,rnd({8,13,7,15}))
 end
end

function draw_table()
 cls(2)
 draw_menu()
end

function draw_menu()
 
 --spr(0,0,0,16,16)
 
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
function update_edit()
 refresh_edit()
 
 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=(cury-1)%#menu+1
 cury-=mscroll
 cury=mid(1,cury,#menu)
 
 if cury==1 then
  curx=1
  if btnp(⬅️) then
   selspr-=1
  elseif btnp(➡️) then
   selspr+=1
  end
  selspr=mid(1,selspr,#data)	
 elseif cury>=11 then
  curx=1
 else
  curx=2
  if cury<=7 then
   --nudge
	  if btnp(⬅️) then
	   local mymnu=menu[cury][curx]
	   data[mymnu.cmdy][mymnu.cmdx]-=1
	   dirty=true
	  elseif btnp(➡️) then
	   local mymnu=menu[cury][curx]
	   data[mymnu.cmdy][mymnu.cmdx]+=1
	   dirty=true
	  end  
  end
 end
 
 if btnp(🅾️) then
  _drw=draw_list
  _upd=update_list
  refresh_list()
  cury=selspr
  curx=1
  scrollx=0
  scrolly=oldscroll
  return
 end
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="editval" then
   _upd=upd_type
 	 local s=tostr(data[mymnu.cmdy][mymnu.cmdx])
   if s=="[nil]" or s==nil then
    s=""
   end
   typetxt=s
   typecur=#typetxt+1
   typecall=enter_edit
  elseif mymnu.cmd=="editcol" then
   _upd=upd_type
 	 local s=tostr(meta[selspr][2])
   typetxt=s
   typecur=#typetxt+1
   typecall=enter_editcol
  elseif mymnu.cmd=="sprhead" then
   _upd=upd_type
 	 local s=tostr(meta[selspr][1])
   typetxt=s
   typecur=#typetxt+1
   typecall=enter_editname 
  elseif mymnu.cmd=="delspr" then
			deli(data,selspr)
			deli(meta,selspr)
			selspr-=1
			if selspr==0 then
			 selspr=1
			end
			_drw=draw_list
			_upd=update_list
			refresh_list()
			cury=selspr
			curx=1
			scrolly=0
			scrollx=0
			dirty=true
			return
  elseif mymnu.cmd=="copyspr" then
			local newspr=copylist(data[selspr])
			local newmet=copylist(meta[selspr])

			add(data,newspr)
			add(meta,newmet)
			_drw=draw_list
			_upd=update_list
			refresh_list()
			selspr=#data
			cury=selspr
			curx=1
			scrolly=0
			scrollx=0
			dirty=true
			return   
  end
 end
end

function update_list()
 refresh_list()
 if btnp(⬆️) then
  cury-=1
 end
 if btnp(⬇️) then
  cury+=1
 end
 cury=(cury-1)%#menu+1
 cury-=mscroll
 cury=mid(1,cury,#menu)
 
 curx=1
 
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
  if mymnu.cmd=="newline" then
   add(data,{0,0,0,0,0,0})
   add(meta,{"new",0})
   dirty=true
  elseif mymnu.cmd=="editspr" then
   oldscroll=scrolly
   selspr=mymnu.cmdy
   _upd=update_edit
   _drw=draw_edit
   scrolly=0
   scrollx=0
   refresh_edit()
   cury=1
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
   typecall=enter_table
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
   typecall()
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

function wrapmspr(si,sx,sy)
 if si==nil then
  bgprint("[nil]",sx-5*2+1,sy-2,14)
  return
 end
 if myspr[si]==nil then
  bgprint("["..si.."]",sx-5*2+1,sy-2,14)
  return
 end
 
 local ms=myspr[si]
 
 if ms[8] then
  --check for loops
  if ms[8]==si then
   bgprint("[loop]",sx-6*2+1,sy-2,14)
   return
  else
   if checkloop(ms,10) then
    bgprint("[loop]",sx-6*2+1,sy-2,14)
    return   
   end
  end
 end
 mspr(si,sx,sy)
end

function checkloop(ms,depth)
 depth-=1
 if depth<=0 then
  return true
 end
 
 if ms==nil then
  return true
 end
 
 if ms[8] then
  return checkloop(myspr[ms[8]],depth)
 else
  return false
 end
end

function mspr(si,sx,sy)
 local ms=myspr[si]
 sspr(ms[1],ms[2],ms[3],ms[4],sx-ms[5],sy-ms[6],ms[3],ms[4],ms[7]==1)
 if ms[7]==2 then
  sspr(ms[1],ms[2],ms[3],ms[4],sx-ms[5]+ms[3],sy-ms[6],ms[3],ms[4],true)
 end
 
 if ms[8] then
  mspr(ms[8],sx,sy)
 end
end

function msprc(si,sx,sy)
 local _x,_y,_w,_h,_ox,_oy,_fx,_nx=unpack(myspr[si])
 if _fx==2 then
  _w*=2
 end
 --sspr(_x,_y,_w,_h,sx-_ox,sy-_oy,_w,_h,_fx==1)
 rect(sx-_ox,sy-_oy,sx-_ox+_w-1,sy-_oy+_h-1,rnd({8,14,15}))
end

function spacejam(n)
 local ret=""
 for i=1,n do
  ret..=" "
 end
 return ret
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
 
 if auto then
  add(msg,{txt="autosave",t=60}) 
 else
  add(msg,{txt="exported!",t=120})
 end
 --debug[1]="exported!"
end
-->8
--ui
function refresh_edit()
 menu={}
 
 add(menu,{{
	 txt="< "..selspr.." "..meta[selspr][1].." >",
	 w="",
	 cmd="sprhead",
	 x=2,
	 y=2
 }})
 
 local lab={"  x:","  y:","wid:","hgt:"," ox:"," oy:"," fx:","nxt:"}
 
	for i=1,8 do
	 local s=tostr(data[selspr][i])
	 
	 if s==nil then
	  s="[nil]"
	 end
	
		add(menu,{
			{
			 txt=lab[i],
			 w="    ",
			 x=2,
			 y=3+i*7
			},{
			 txt=s,
			 w=spacejam(#s),
			 cmd="editval",
			 cmdy=selspr,
			 cmdx=i,
			 x=2+16,
			 y=3+i*7
			}
		}) 
 end
 
 local coltxt=meta[selspr][2]==0 and "off" or tostr(meta[selspr][2])
	
	add(menu,{
		{
		 txt="col:",
		 w=spacejam(4),
		 x=2,
		 y=4+9*7
		},{
		 txt=coltxt,
		 w=spacejam(#coltxt),
		 cmd="editcol",
		 cmdy=selspr,
		 x=19,
		 y=4+9*7
		}
	})

 add(menu,{{
	 txt="copy",
	 w="",
	 cmd="copyspr",
	 x=2,
	 y=5+10*7
 }})
  
 add(menu,{{
	 txt="delete",
	 w="",
	 cmd="delspr",
	 x=2,
	 y=6+11*7
 }})
end

function refresh_list()
 menu={}
 for i=1,#data do
  local lne={}
  local linemax=#data[i]
  if i==cury then
   linemax+=1  
  end
  add(lne,{
	  txt=i.." "..meta[i][1],
	  w="",
	  cmd="editspr",
	  cmdy=i,
	  x=2,
	  y=-4+6*i
  })
  add(menu,lne)
 end
 add(menu,{{
  txt=" + ",
  w="   ",
  cmd="newline",
  x=2,
  y=-4+6*(#data+1)+2, 
 }})
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

function enter_table()
  
 local mymnu=menu[cury][curx]
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
 refresh_table()
end

function enter_edit()

 local mymnu=menu[cury][curx]
 local typeval=tonum(typetxt)
 
 if mymnu.cmdx==8 then
  if typeval!=nil then
   if data[mymnu.cmdy][7]==nil then
    data[mymnu.cmdy][7]=0
   end
  end
 end

 if typeval==nil then
  if mymnu.cmdx>=7 and mymnu.cmdx==#data[mymnu.cmdy] then
   deli(data[mymnu.cmdy],mymnu.cmdx)
  else
   data[mymnu.cmdy][mymnu.cmdx]=0
  end
 else
  data[mymnu.cmdy][mymnu.cmdx]=typeval
 end 

 _upd=update_edit
 refresh_edit()
 dirty=true
end

function enter_editcol()

 local mymnu=menu[cury][curx]
 local typeval=tonum(typetxt)
 
 if typeval==nil or typeval<1 then
  meta[selspr][2]=0
 else
  meta[selspr][2]=typeval
 end
 
 _upd=update_edit
 refresh_edit()
 dirty=true
end

function enter_editname()

 local mymnu=menu[cury][curx]
 local typeval=filter(tostr(typetxt))
 
 if typeval!="" then
  meta[selspr][1]=typeval
 end
 
 _upd=update_edit
 refresh_edit()
 dirty=true
end

function filter(s)
 local s2=""
 for i=1,#s do
  local c=s[i]
  if c=="," then
   c="."
  elseif c=="|" then
   c="/"
  end
  s2..=c
 end
 return s2
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
