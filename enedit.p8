pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
 autosave=true
 dirty=false
 
 --- customize here ---
 #include shmup_enlib.txt
 #include shmup_myspr.txt
 #include shmup_anilib.txt
 file="shmup_enlib.txt"
 arrname="enlib"
 data=enlib
 ----------------------
 
 debug={}
 msg={}
 
 _drw=draw_table
 _upd=update_table
 
 menuitem(1,"export",export)
 
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 
 curx=2
 cury=2
 scrolly=0
 scrollx=0
 
 preven=nil
 prevshad=nil
 poke(0x5f2d, 1)
 t=0
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
 t+=1
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

function draw_table()
 cls(2)
 --spr(0,0,0,16,16)
 
 -- enemy preview
 camera()
 clip(0,0,128,50)
 fillp(0b11001100001100111100110000110011)
 rectfill(0,0,127,127,33)
 fillp(▒)
 line(63,0,63,127,13)
 line(0,25,127,25,13)
 fillp() 
 if prevshad then
  drawshad(prevshad)
 end
 if prevspr then
  mspr(prevspr,63,25)
 end

 clip()
 -- table view 
 clip(0,58,128,128)
 camera(0,-48)
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
 
 --[[
 for i=1,#data do
  for j=1,#data[i] do
   bgprint(data[i][j],2+18*j,2+8*i,7)
  end
 end
 ]]
 -- headers
 clip(0,50,128,8)
 camera(0,-48)
	if menu then
		for j=1,#menu[1] do
		 local mymnu=menu[1][j]
		 local c=mymnu.c or 13
			bgprint(mymnu.w,mymnu.x+scrollx,mymnu.y,13)
		 bgprint(mymnu.txt,mymnu.x+scrollx,mymnu.y,c) 
		end
 end
 camera()
 clip()

end

function refresh_table()
 menu={}
 
 local caps={"","ani","asp","brn","hp","col","gnd","cfl","cnc","shs","shh","fx"}
 
 local lne={}
 for i=1,#caps do
  add(lne,{
	  txt=caps[i],
	  w="   ",
	  cmd="",
	  x=-10+14*i,
	  y=4,
	  c=2  
  }) 
 end 
 add(menu,lne)
 
 for i=1,#data do
  local lne={}
  local linemax=#data[i]
  if i==cury-1 then
   linemax+=1  
  end
  add(lne,{
	  txt=i,
	  w="   ",
	  cmd="",
	  x=4,
	  y=-4+8*(i+1),
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
			  y=-4+8*(i+1), 
			 })
		 else
		  add(lne,{
		   txt=data[i][j],
		   cmd="edit",
		   cmdx=j,
		   cmdy=i,
		   x=-10+14*(j+1),
		   y=-4+8*(i+1),
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
  y=-4+8*(#data+2), 
 }})
end
-->8
--update

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
 cury=mid(2,cury,#menu)
 
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
 if mymnu.y+scrolly>62 then
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
   dirty=true 
  elseif mymnu.cmd=="newcell" then
   add(data[mymnu.cmdy],0)
   dirty=true 
  end
 end
 
 local mymnu=menu[cury][curx]
 if mymnu.cmdy then
  if mymnu.cmdy>=1 and mymnu.cmdy<=#enlib then
   local myen=enlib[mymnu.cmdy]
   if myen[1] and myen[1]>=1 and myen[1]<=#anilib then
    local prevani=anilib[myen[1]]
    local prevspd=myen[2] or 0
    prevspr=cyc(t,prevani,prevspd)
    prevshad={
   		x=63,y=25,
   		shads=myen[9] or 0,
   		shadh=myen[10] or 0
  		}
  		if prevshad.shads==0 then
  		 prevshad=nil
  		end
   else
    prevspr=nil
    prevshad=nil
   end
  else
   prevspr=nil
   prevshad=nil
  end
 else
  prevspr=nil
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
     dirty=true
     return
    end  
    typeval=0
   end
   
   data[mymnu.cmdy][mymnu.cmdx]=typeval
   _upd=update_table
   dirty=true
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

function cyc(age,arr,anis)
 local anis=anis or 1
 return arr[(age\anis-1)%#arr+1]
end

function mspr(si,sx,sy)
 -- robustness
 if si<1 or si>#myspr then
  return
 end
 -----
 local _x,_y,_w,_h,_ox,_oy,_fx,_nx=unpack(myspr[si])
 sspr(_x,_y,_w,_h,sx-_ox,sy-_oy,_w,_h,_fx==1)
 if _fx==2 then
  sspr(_x,_y,_w,_h,sx-_ox+_w,sy-_oy,_w,_h,true)
 end
 
 if _nx then
  mspr(_nx,sx,sy)
 end
end

function drawshad(obj)
 local ox,oy,ow,oh=obj.x,obj.y+obj.shadh,obj.shads,obj.shads/1.5
 ovalfill(ox-(ow-1),oy-(oh-1),ox+ow,oy+oh,0)
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
