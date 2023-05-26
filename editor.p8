pico-8 cartridge // http://www.pico-8.com
version 41
__lua__


function _init()
 --- customize here ---
 #include shmup_myspr.txt
 file="shmup_myspr.txt"
 arrname="myspr"
 data=myspr
 ----------------------
 
 debug={}
 _drw=draw_table
 _upd=update_table
 menuitem(1,"export",export)
 
 reload(0x0,0x0,0x2000,"cowshmup.p8")
 
 curx=1
 cury=1
 scrolly=0
 scrollx=0
 
 poke(0x5f2d, 1)
 debug[2]=""
end

function _draw()
 _drw()
 
 -- debug --
 cursor(4,4)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function _update60()
 debug[1]=stat(30)
 if stat(30) then
  debug[2]..=stat(31)
 end
 
 _upd()
end
-->8
--draw

function draw_table()
 cls(2)
 --spr(0,0,0,16,16)
 
	if menu then
		for i=1,#menu do
		 for j=1,#menu[i] do
		  local c=13
		  if i==cury and j==curx then
		   c=7
		  end
		  local mymnu=menu[i][j]
		  bgprint(mymnu.w,mymnu.x+scrollx,mymnu.y+scrolly,13)   
		  bgprint(mymnu.txt,mymnu.x+scrollx,mymnu.y+scrolly,c) 
		 end
		end
 end
 --[[
 for i=1,#data do
  for j=1,#data[i] do
   bgprint(data[i][j],2+18*j,2+8*i,7)
  end
 end
 ]]
end

function refresh_table()
 --[[menu={
  {
   {
    txt="hello",
    cmd="say hello",
    x=2,
    y=2
   }
  }
 }]]--
 menu={}
 for i=1,#data do
  local lne={}
  for j=1,#data[i] do
   add(lne,{
    txt=data[i][j],
    cmd="edit",
    cmdx=j,
    cmdy=i,
    x=-10+14*j,
    y=-4+8*i,
    w="   "
   })
  end
  add(menu,lne)
 end
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
 cury=mid(1,cury,#menu)
 
 if btnp(⬅️) then
  curx-=1
 end
 if btnp(➡️) then
  curx+=1
 end
 curx=mid(1,curx,#menu[cury])
 
 local mymnu=menu[cury][curx]
 if mymnu.y+scrolly>110 then
  scrolly-=1
 end
 if mymnu.y+scrolly<10 then
  scrolly+=1
 end
 scrolly=min(0,scrolly)
 
 if mymnu.x+scrollx>110 then
  scrollx-=1
 end
 if mymnu.x+scrollx<10 then
  scrollx+=1
 end
 scrollx=min(0,scrollx)
 
 if btnp(❎) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="edit" then
   data[mymnu.cmdy][mymnu.cmdx]+=1
  end
 end
 if btnp(🅾️) then
  local mymnu=menu[cury][curx]
  if mymnu.cmd=="edit" then
   data[mymnu.cmdy][mymnu.cmdx]-=1
  end
 end
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
 debug[1]="exported!"
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
