pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

--todo
-- -sanitize cmd input
-- -creating new brains

function _init()
 --- customize here ---
 #include shmup_brains.txt
 file="shmup_brains.txt"
 arrname="brains"
 data=brains
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
 
 poke(0x5f2d, 1)
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
 dokeys()
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
-->8
--draw

function draw_brain()
 cls(13)
 drawmenu()

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

function update_brain()
 refresh_brain()

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
	 end
	 if btnp(➡️) then
	  selbrain+=1
	 end
	 selbrain=mid(1,selbrain,#data)
 else
	 if btnp(⬅️) then
	  curx-=1
	 end
	 if btnp(➡️) then
	  curx+=1
	 end
	 curx=mid(1,curx,#menu[cury])
 end
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="edit" then
   _upd=upd_type
   typetxt=tostr(mymnu.txt)
   typecur=#typetxt+1
   callback=enter_brain
  elseif mymnu.cmd=="newline" then
   add(data[mymnu.cmdb],"wai")
   add(data[mymnu.cmdb],"0")
   add(data[mymnu.cmdb],"0")   
  elseif mymnu.cmd=="setup" then

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
 add(msg,{txt="exported!",t=120})
 --debug[1]="exported!"
end
-->8
--ui

function refresh_brain()
 menu={}
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
  add(menu,lne)
  ly+=8
 end
 
 add(menu,{{
	 txt="+",
	 w=" ",
	 cmd="newline",
	 cmdb=selbrain,
	 x=3,
	 y=ly,
	 c=13    
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
 if mymnu.cmdi%3==1 then
  --editing command entry
  if typeval=="" then
   deli(data[mymnu.cmdb],mymnu.cmdi)
   deli(data[mymnu.cmdb],mymnu.cmdi)
   deli(data[mymnu.cmdb],mymnu.cmdi)
   return
  end
 else
  --editing parameters
  typeval=tonum(typetxt)
  if typeval==nil then
   typeval=0
  end
  typeval=tostr(typeval)
 end
 data[mymnu.cmdb][mymnu.cmdi]=typeval

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
