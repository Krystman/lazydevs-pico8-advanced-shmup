pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- todo
-- debug brain previes

function _init()
 autosave=true
 dirty=false
 _ENV["test"]=1
  
 --- customize here ---
 #include shmup_sched.txt
 file="shmup_sched.txt"
 arrname="sched"
 data=sched
 #include shmup_mapsegs.txt
 #include shmup_enlib.txt
 #include shmup_anilib.txt
 #include shmup_myspr.txt
 #include shmup_brains_trails.txt
 ----------------------
 
 --for i=1,#data do
 -- data[i][3]=flr(data[i][3])
 -- data[i][4]=flr(data[i][4])  
 --end
 
 -- process trails --
 for i=1,#trails do
  local myt=trails[i]
  for j=1,#myt do
   myt[j]=split(myt[j],":")
   if #myt[j]!=2 then
    myt[j]={0,0}
   end
  end
 end
 -------------------
  
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
 
 enemies={}
 
 scroll=0
 xscroll=0
 poke(0x5f2d, 1)
 
 selsched=nil
 t=0
 
 hgrid={
  78,--bridge
  154,--anthem
  308,--melody
  459,--danger
  614,--bridge2
  690, --anthem 2
  842, --melody 2
  994, --danger 2
  1148, --bridge 3
  1224, --anthem 3
  1377 --meldoy 3
 }
 
 undox=0
 undoy=0
 undot=0
 
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
 t+=1
 dokeys()
 domouse()
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

function draw_move()
 drawbg()
 
 local offx,offy=calcoffset(selsched)
 pset(undox+offx+xscroll,undoy+offy,rnd({5,6,7}))
 bgprint("x:"..selsched[3].." y:"..selsched[4].." scroll:"..selsched[1],20,120,13)
 drawmenu()
 
 drawcur(mousex,mousey)
end


function draw_drop()
 drawbg()

 drawmenu()
 drawcur(mousex,mousey)
end

function draw_map()
 drawbg()
 
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
    local brn=ens[j][5] or enlib[abs(ens[j][2])][3]
    print(tostrn(brn,2,"0"),uix,i*6,7)
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

function drawbg()
 cls(2)
 for i=1,#mapsegs do
  local segnum=mapsegs[i]
  local sx=segnum\4*18
  local sy=segnum%4*8
  map(sx,sy,xscroll,scroll-((i-2)*64),18,8)
 end
 
 camera(-xscroll,0)
 fillp(▤)
 line(64+8,0,64+8,128,13)
 line(15,0,15,128,13)
 line(128,0,128,128,13)
 fillp(▥)
 for g in all(hgrid) do
  local gy=-g+scroll
  line(-8,gy,128+16,gy,13)
 end
 fillp()
 genens()
 
 -- draw enemies
 
 if selsched then
   local col=11+16*12
   fillp(flr(▥))
   line(0,selsched[4],256,selsched[4],col)
   fillp(flr(▤))
   line(selsched[3],0,selsched[3],256,col)
   
   line(selsched[3],selsched[4],selsched[3]-256,selsched[4]+256,col)
   line(selsched[3],selsched[4],selsched[3]+256,selsched[4]+256,col)
   line(selsched[3],selsched[4],selsched[3]-256,selsched[4]-256,col)
   line(selsched[3],selsched[4],selsched[3]+256,selsched[4]-256,col)
   fillp()  
 end
 
 for en in all(enemies) do 
  drawshad(en)
 end
 
 for en in all(enemies) do
  mspr(en.s,en.x,en.y)
  if en.sched==selsched then
   rect(en.x-8,en.y-8,en.x+9,en.y+9,rnd({6,7}))
   drawtrail(en)
  end
  --print(en.age,en.x,en.y,7)
  --drawtrail(en)
 end
 
 camera()
end

function drawtrail(en)
 local mysched=en.sched
 
 local curtrails=trails[en.brain]
 
 for i=1,#curtrails do
  local t=curtrails[i]
  local enx=t[1]*en.mirr+mysched[3]
  local eny=t[2]+mysched[4]
  
  if en.ground then
   --eny=eny+(i-1)
  end
  
  --mspr(en.s,enx,eny)
  pset(enx,eny,7)
 end

end

-->8
--update

function update_move()
 refresh_move()
 xscroll=mid(0,(mousex-10)/108,1)\-0.0625
 
 if btnp(⬆️) then
  selsched[4]-=1
 end
 if btnp(⬇️) then
  selsched[4]+=1
 end
 if btnp(⬅️) then
  selsched[3]-=1
 end
 if btnp(➡️) then
  selsched[3]+=1
 end
 
 if key=="w" then
  selsched[1]+=1
  if selsched[1]>scroll then
   scroll=selsched[1]
  end
 end
 if key=="s" then
  selsched[1]-=1
  if selsched[1]<0 then selsched[1]=0 end
 end
 
 
 if clkl then
  local offx,offy=calcoffset(selsched)
  
  selsched[3]=flr(mousex-xscroll-offx)
  selsched[4]=flr(mousey-offy)
 end
 
 if btnp(❎)  then
  _drw=draw_map
  _upd=update_map
  dirty=true
  refresh_map() 
  return 
 elseif btnp(🅾️) or clkr then
  selsched[3]=undox
  selsched[4]=undoy
  selsched[1]=undot
  _drw=draw_map
  _upd=update_map
  refresh_map() 
  return 
 end

end

function update_drop()
 refresh_drop()

 if btnp(🅾️) or clkr then
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
 cury=mid(1,cury,#menu)
 curx=1
 
 if menu[cury][curx].cmd=="entype" then
  local sched=menu[cury][curx].cmdsch
  local mirr=sgn(sched[2])
  sched[2]=abs(sched[2])
  if btnp(⬅️) then
   sched[2]-=1
   dirty=true
  end
  if btnp(➡️) then
   sched[2]+=1
   dirty=true
  end
  sched[2]=mid(1,sched[2],#enlib)
  sched[2]=sched[2]*mirr
 elseif menu[cury][curx].cmd=="enbrain" then
  local sched=menu[cury][curx].cmdsch
  local mirr=sgn(sched[2])
  sched[2]=abs(sched[2])
  local myen=enlib[sched[2]]
  local brn=sched[5] or myen[3]

  if btnp(⬅️) then
   brn-=1
   dirty=true
  end
  if btnp(➡️) then
   brn+=1
   dirty=true
  end
  brn=mid(1,brn,#trails)
  
  if brn==myen[3] then
   sched[5]=nil
  else
   sched[5]=brn
  end
  sched[2]=sched[2]*mirr
 else
	 if btnp(❎) then
	  dobutton(menu[cury][curx])
	  return
	 end  
 end
 

  
 -- mouse button control
 local mousehit=false
 if mousemove or clkl then
	 for my=1,#menu do
	  for mx=1,#menu[my] do
		  if mousecol(menu[my][mx]) then
		   curx=mx
		   cury=my
		   mousehit=true
		   if clkl then
		    dobutton(menu[cury][curx])
		    return
		   end
		  end
	  end
	 end	 
	 if not mousehit and clkl then
	  _drw=draw_map
	  _upd=update_map
	  refresh_map() 
	  return
	 end
 end

end

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
  return
 end
 
 selsched=menu[cury][curx].cmdsch
 
 -- mouse button control
 local mousehit=false
 if mousemove or clkl then
	 for my=1,#menu do
	  for mx=1,#menu[my] do
		  if mousecol(menu[my][mx]) then
		   curx=mx
		   cury=my
 		  selsched=menu[cury][curx].cmdsch
		   mousehit=true
		   if clkl then
		    dobutton(menu[cury][curx])
		    return
		   end
		  end
	  end
	 end	 
 end
 if not mousehit then
  for en in all(enemies) do
   if col3(en) then
    selsched=en.sched
    mousehit=true
    if clkl then
     dropx=min(en.x+xscroll,128-6*4)
     dropy=en.y
     
     refresh_drop()
     _drw=draw_drop
     _upd=update_drop     
    end
   end
  end
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

function mspr(si,sx,sy,sudofx)
 local ms,sudofx=myspr[si],sudofx or 0
 local ssx,ssy,ssw,ssh,ox,oy,fx=unpack(ms)
 local fx=fx or 0
 if sudofx==1 then
  fx=fx>=2 and fx or 1-fx
  ox=-ox+ssw-1
 end

 sspr(ssx,ssy,ssw,ssh,sx-ox,sy-oy,ssw,ssh,fx==1)
 if fx>=2 then
  sspr(ssx,ssy,ssw,ssh,sx-ox+ssw-(fx-2),sy-oy,ssw,ssh,true)
 end
 local i=8
 while ms[i] do
  local noi,nox,noy,nfx=unpack(ms,i,i+3)
  nox,noy,nfx=nox or 0,noy or 0,nfx or 0 
  if sudofx==1 then
   nox,nfx=-nox,1-nfx
  end
  mspr(noi,sx+nox,sy+noy,nfx)
  i+=4
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

function col3(ob)
 local _bx,_by,_bw,_bh,_box,_boy,_bfx=unpack(myspr[ob.col])
 
 local a_left=mousex-xscroll
 local a_top=mousey
 local a_right=mousex-xscroll
 local a_bottom=mousey
 
 local b_left=flr(ob.x)-_box
 local b_top=flr(ob.y)-_boy
 local b_right=b_left+_bw-1
 local b_bottom=b_top+_bh-1

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

function copylist(org)
 local ret={}
 for k, v in pairs(org) do
  ret[k]=v
 end
 return ret
end

function drawshad(obj)
 local ox,oy,ow,oh=obj.x,obj.y+obj.shadh,obj.shads,obj.shads/1.5
 ovalfill(ox-(ow-1),oy-(oh-1),ox+ow,oy+oh,1)
end
-->8
--i/o
function export(auto)
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
 if auto==true then
  add(msg,{txt="autosave",t=60}) 
 else
  add(msg,{txt="exported!",t=120})
 end
 --debug[1]="exported!"
end
-->8
--ui

function refresh_move()
 menu={}
end

function refresh_drop()
 menu={}
 add(menu,{{
	 txt="< "..tostrn(abs(selsched[2]),2,"0").." >",
	 w="      ",
	 cmd="entype",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy,
	 c=13
 }})
 
 local myen=enlib[abs(selsched[2])]
 local brn=selsched[5] or myen[3]
 
 add(menu,{{
	 txt="< "..tostrn(brn,2,"0").." >",
	 w="      ",
	 cmd="enbrain",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy+6,
	 c=13
 }})
 
 local mirrt=selsched[2]<0 and "mirror" or "normal"
 add(menu,{{
	 txt=mirrt,
	 w="      ",
	 cmd="mirren",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy+12,
	 c=13
 }})
 add(menu,{{
	 txt="move",
	 w="      ",
	 cmd="moveen",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy+18,
	 c=13
 }})

 add(menu,{{
	 txt="copy",
	 w="      ",
	 cmd="copyen",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy+24,
	 c=13
 }}) 
 
 add(menu,{{
	 txt="delete",
	 w="      ",
	 cmd="delen",
	 cmdsch=selsched,
	 x=dropx,
	 y=dropy+30,
	 c=13
 }}) 

end

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
   local brn=ens[i][5] or enlib[abs(ens[i][2])][3]
		 add(lne,{
			 txt=tostrn(brn,2,"0"),
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

function genens()
 enemies={}
 for sch in all(sched) do
 
  if sch[1]<=scroll then
   local mirr=sgn(sch[2])
	  local en=enlib[abs(sch[2])]
	  local brn=sch[5] or en[3]
	  local ground=en[6]==1
   local curtrails=trails[brn]
   local enage=(scroll-sch[1])
   local trailage=enage+1
   
   if curtrails and trailage<=#curtrails then

		  local ani=anilib[en[1] ]   
		  local schx=sch[3]+(curtrails[trailage][1]*mirr)
		  local schy=sch[4]+curtrails[trailage][2]
				if ground then
				 --schy+=enage
				end
		  --local schx=sch[3]
		  --local schy=sch[4]+scroll-sch[1]
	 
		  add(enemies,{
		   x=schx,
		   y=schy,
		   s=cyc(t,ani,en[2]),
		   sched=sch,
		   col=en[5],
		   brain=brn,
		   age=enage,
		   mirr=mirr,
		   shads=en[9],
		   shadh=en[10],
		   ground=ground
		  })
	  end
  end
 end
end

function calcoffset(sch)
 local offx,offy=0,0
 local mirr=sgn(sch[2])
	local en=enlib[abs(sch[2])]
	local brn=sch[5] or en[3]
	local ground=en[6]==1
 local curtrails=trails[brn]
 local enage=(scroll-sch[1])
 local trailage=enage+1
 if trailage<=#curtrails then
		offx=curtrails[trailage][1]*mirr
		offy=curtrails[trailage][2]
		if ground then
			--offy+=enage
		end 
 end
 return offx,offy
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
	 dirty=true
	elseif b.cmd=="mirren" then
	 local sched=b.cmdsch
	 sched[2]=-sched[2]
	 dirty=true
 elseif b.cmd=="editen" then
  
  --dropx=mid(2,b.cmdsch[3],128-25)
  --dropy=mid(2,b.cmdsch[4],128-30)
  
  dropx=b.x
  dropy=b.y
  
  refresh_drop()
  _drw=draw_drop
  _upd=update_drop 
 elseif b.cmd=="entype" then
  local cx=mousex-dropx
  local sched=b.cmdsch
  local mirr=sgn(sched[2])
  sched[2]=abs(sched[2])

  if cx<=12 then
   sched[2]-=1
  else
   sched[2]+=1
  end
  sched[2]=mid(1,sched[2],#enlib)
  sched[2]=sched[2]*mirr
  dirty=true
 elseif b.cmd=="enbrain" then
  local cx=mousex-dropx
  local sched=b.cmdsch
  local mirr=sgn(sched[2])
  sched[2]=abs(sched[2])
  local myen=enlib[sched[2]]
  local brn=sched[5] or myen[3]

  if cx<=12 then
   brn-=1
  else
   brn+=1
  end
  brn=mid(1,brn,#trails)
  if brn==myen[3] then
   sched[5]=nil
  else
   sched[5]=brn
  end
  sched[2]=sched[2]*mirr
  dirty=true
 elseif b.cmd=="delen" then
  del(sched,b.cmdsch)
  _drw=draw_map
  _upd=update_map
  refresh_map()
  dirty=true
 elseif b.cmd=="copyen" then
  local newsched=copylist(b.cmdsch)
  add(sched,newsched)
  selsched=newsched
  
  undox=selsched[3]
  undoy=selsched[4]
  undot=selsched[1]
  
  _drw=draw_move
  _upd=update_move
  refresh_move()  
 elseif b.cmd=="moveen" then
  _drw=draw_move
  _upd=update_move
  undox=selsched[3]
  undoy=selsched[4]
  undot=selsched[1]
  refresh_move() 
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
