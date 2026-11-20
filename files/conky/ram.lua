-- Panel RAM kanan bawah: ringkasan memori dan 5 aplikasi terboros dengan segmen. Digambar dengan Cairo.
pcall(require, 'cairo')
pcall(require, 'cairo_xlib')

local W = 320
local CREAM  = {0.827, 0.890, 0.867}
local ACCENT = {0.381, 0.680, 0.306}
local MUTED  = {0.600, 0.698, 0.573}
local A_TXT, A_ACC, A_LINE = 0.82, 0.88, 0.85   -- kepekatan teks, aksen/segmen terisi, garis segmen kosong
local SEG, SH, GAP = 20, 8, 2                   -- jumlah segmen, tinggi, celah (px)
local CHIP = "\xEF\x8B\x9B"                     -- U+F2DB ikon chip (FontAwesome)

local function extents(cr, s)
    local e = cairo_text_extents_t:create()
    pcall(tolua.takeownership, e)
    cairo_text_extents(cr, s, e)
    return e
end

local function total_mb()
    for l in io.lines("/proc/meminfo") do
        local k = l:match("^MemTotal:%s+(%d+)")
        if k then return tonumber(k) / 1024 end
    end
    return 1
end

-- 5 aplikasi terboros (RSS digabung per nama), disimpan 3 detik
local cache = {t = 0, rows = {}}
local function top5()
    local now = os.time()
    if now - cache.t >= 3 then
        local acc = {}
        local p = io.popen("ps -eo comm=,rss= 2>/dev/null")
        if p then
            for line in p:lines() do
                local name, rss = line:match("^(.-)%s+(%d+)%s*$")
                if name then acc[name] = (acc[name] or 0) + tonumber(rss) end
            end
            p:close()
        end
        local list = {}
        for k, v in pairs(acc) do list[#list + 1] = {name = k, mb = v / 1024} end
        table.sort(list, function(a, b) return a.mb > b.mb end)
        cache.rows = {}
        for i = 1, 5 do cache.rows[i] = list[i] end
        cache.t = now
    end
    return cache.rows
end

local function text(cr, s, x, y, col, a, family, weight, size, right)
    cairo_select_font_face(cr, family, CAIRO_FONT_SLANT_NORMAL, weight)
    cairo_set_font_size(cr, size)
    if right then x = x - extents(cr, s).x_advance end
    cairo_set_source_rgba(cr, col[1], col[2], col[3], a)
    cairo_move_to(cr, x, y); cairo_show_text(cr, s)
end

function conky_ramdraw()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    local N, B = CAIRO_FONT_WEIGHT_NORMAL, CAIRO_FONT_WEIGHT_BOLD

    -- ringkasan
    text(cr, CHIP, 0, 34, ACCENT, A_ACC, "FontAwesome", N, 30)
    local ie = extents(cr, CHIP)
    text(cr, conky_parse("${memperc}") .. "%", ie.x_advance + 8, 34, ACCENT, A_ACC, "Titillium Web", B, 31)
    local ram = conky_parse("${mem} / ${memmax}")
    text(cr, ram, W, 30, CREAM, A_TXT, "Montserrat", N, 15, true)
    cairo_select_font_face(cr, "Montserrat", CAIRO_FONT_SLANT_NORMAL, N); cairo_set_font_size(cr, 15)
    text(cr, "RAM", W - extents(cr, ram).x_advance - 9 - extents(cr, "RAM").x_advance, 30, MUTED, A_TXT, "Montserrat", N, 15)
    text(cr, "Swap", 0, 62, MUTED, A_TXT, "Montserrat", N, 15)
    text(cr, conky_parse("${swap} / ${swapmax}"), W, 62, CREAM, A_TXT, "Montserrat", N, 15, true)

    -- aplikasi terboros
    local total, rows = total_mb(), top5()
    local segw = (W - (SEG - 1) * GAP) / SEG
    for i = 1, 5 do
        local r = rows[i]
        if r then
            local y = 100 + (i - 1) * 40
            text(cr, r.name, 0, y, CREAM, A_TXT, "Montserrat", N, 15)
            text(cr, string.format("%d MB", math.floor(r.mb + 0.5)), W, y, CREAM, A_TXT, "Montserrat", N, 15, true)
            local filled = math.floor(r.mb / total * SEG + 0.5)
            if filled < 1 and r.mb > 0 then filled = 1 end
            if filled > SEG then filled = SEG end
            for s = 1, SEG do
                local x = (s - 1) * (segw + GAP)
                -- semua segmen berukuran sama: garis tepi 1 px; yang terisi juga berisi warna
                cairo_set_line_width(cr, 1.2)
                if s <= filled then
                    cairo_rectangle(cr, x + 0.6, y + 8.6, segw - 1.2, SH - 1.2)
                    cairo_set_source_rgba(cr, ACCENT[1], ACCENT[2], ACCENT[3], A_ACC)
                    cairo_fill_preserve(cr); cairo_stroke(cr)
                else
                    cairo_rectangle(cr, x + 0.6, y + 8.6, segw - 1.2, SH - 1.2)
                    cairo_set_source_rgba(cr, MUTED[1], MUTED[2], MUTED[3], A_LINE)
                    cairo_stroke(cr)
                end
            end
        end
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
