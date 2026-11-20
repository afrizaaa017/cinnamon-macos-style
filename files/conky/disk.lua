-- Blok disk kanan atas, rata kanan, digambar dengan Cairo agar bisa transparan.
pcall(require, 'cairo')
pcall(require, 'cairo_xlib')

local W = 260
local CREAM  = {0.827, 0.890, 0.867}
local ACCENT = {0.381, 0.680, 0.306}
local MUTED  = {0.600, 0.698, 0.573}
local A_TXT, A_ACC = 0.82, 0.88                 -- kepekatan teks dan aksen (1 = padat)
local ICON = "\xEF\x82\xA0"                     -- U+F0A0 ikon disk (FontAwesome)

local function extents(cr, s)
    local e = cairo_text_extents_t:create()
    pcall(tolua.takeownership, e)
    cairo_text_extents(cr, s, e)
    return e
end

local function read(path)
    local f = io.open(path)
    if not f then return nil end
    local v = f:read("*l"); f:close(); return v
end

local function cpu_temp()
    for i = 0, 15 do
        local d = "/sys/class/hwmon/hwmon" .. i
        if read(d .. "/name") == "coretemp" then
            local t = tonumber(read(d .. "/temp1_input"))
            if t then return string.format("%d°C", math.floor(t / 1000 + 0.5)) end
        end
    end
    return "-"
end


-- volume (persen, atau "Senyap" bila mute) lewat wpctl; hasil disimpan agar tidak memanggil terus
local vol_cache, vol_t = "-", 0
local function volume()
    local now = os.time()
    if now - vol_t >= 1 then
        vol_t = now
        local p = io.popen("wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null")
        local out = p and p:read("*l") or ""
        if p then p:close() end
        local v = tonumber(out:match("Volume:%s*([%d%.]+)"))
        if v then
            vol_cache = out:find("MUTED") and "Senyap" or (string.format("%d%%", math.floor(v * 100 + 0.5)))
        end
    end
    return vol_cache
end

-- kecerahan layar (persen) dari sysfs
local function brightness()
    local d = "/sys/class/backlight/intel_backlight"
    local b, m = tonumber(read(d .. "/brightness")), tonumber(read(d .. "/max_brightness"))
    if b and m and m > 0 then return string.format("%d%%", math.floor(b * 100 / m + 0.5)) end
    return "-"
end

-- "label  nilai" rata kanan: nilai putih di tepi kanan, label redup di kirinya
local function row(cr, label, value, y)
    cairo_select_font_face(cr, "Montserrat", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 15)
    local ve = extents(cr, value)
    cairo_set_source_rgba(cr, CREAM[1], CREAM[2], CREAM[3], A_TXT)
    cairo_move_to(cr, W - ve.x_advance, y); cairo_show_text(cr, value)
    local le = extents(cr, label)
    cairo_set_source_rgba(cr, MUTED[1], MUTED[2], MUTED[3], A_TXT)
    cairo_move_to(cr, W - ve.x_advance - 9 - le.x_advance, y); cairo_show_text(cr, label)
end

function conky_diskdraw()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local perc = conky_parse("${fs_used_perc /}") .. "%"
    cairo_select_font_face(cr, "Titillium Web", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 34)
    local pe = extents(cr, perc)
    cairo_set_source_rgba(cr, ACCENT[1], ACCENT[2], ACCENT[3], A_ACC)
    cairo_move_to(cr, W - pe.x_advance, 36); cairo_show_text(cr, perc)
    cairo_select_font_face(cr, "FontAwesome", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 34)
    local ie = extents(cr, ICON)
    cairo_move_to(cr, W - pe.x_advance - 10 - ie.x_advance, 36); cairo_show_text(cr, ICON)

    row(cr, "Root", conky_parse("${fs_used /} / ${fs_size /}"), 70)
    row(cr, "Suhu", cpu_temp(), 98)
    row(cr, "Baterai", (read("/sys/class/power_supply/BAT1/capacity") or "?") .. "%", 126)
    row(cr, "Volume", volume(), 154)
    row(cr, "Kecerahan", brightness(), 182)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
