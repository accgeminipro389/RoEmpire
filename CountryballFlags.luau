--!strict
-- Atlas cells: 8 per row, 128px, 6px pad, ball 116px. Order matters.
local atlases = { "rbxassetid://130540052352270", "rbxassetid://130665700889869", "rbxassetid://78241303995700", "rbxassetid://93288565420842", "rbxassetid://135650736335464" }
local codes = {
	"af ao aq ar at au bd bo br by ca california cd cl cm cn co cu de dk do dz ec eg es et fi fr gb gh gl gr gt hu id ie in iq ir is it jp ke kr kz lk ly ma mg ml mm mn mx my mz na ng ni nl no np nz om pa",
	"pe pg ph pk pl pt py ro rs ru sa sd se sn so sy td th tn tr tw tz ua us uy uz ve vn ye za",
	"ac ad ae ag ai al am as aw ax az ba bb be bf bg bh bi bj bl bm bn bq bs bt bv bw bz cc cf cg ch ci ck cp cr cv cw cx cy cz dg dj dm ee eh eo er eu fj fk fm fo ga gd ge gf gg gi gm gn gp gq gs",
	"gu gw gy hk hm hn hr ht ic il im io je jm jo kg kh ki km kn kp kw ky la lb lc li lr ls lt lu lv mc md me mf mh mk mo mp mq mr ms mt mu mv mw nc nf nr nu pf pm pn pr ps pw qa re rw sb sc sg sh",
	"si sj sk sl sm sr ss st sv sx sz ta tc tf tg tj tk tl tm to tt tv ug um un va vc vg vi vu wf ws xk yt zm zw",
}
local balls: { [string]: { atlas: number, x: number, y: number } } = {}
for a, line in codes do
	local k = 0
	for code in string.gmatch(line, "%S+") do
		balls[code] = { atlas = a, x = (k % 8) * 128 + 6, y = (k // 8) * 128 + 6 }
		k += 1
	end
end
return { atlases = atlases, size = 116, balls = balls }
