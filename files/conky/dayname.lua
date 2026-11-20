-- Nama hari besar dengan potongan abstrak, plus blok jam dan tanggal bertingkat (Cairo).
-- Tanpa garis tepi; huruf dibuat sedikit transparan.
pcall(require, 'cairo')
pcall(require, 'cairo_xlib')

local SIZE, TRACK, BASE = 112, 17, 130          -- ukuran huruf, jarak antar huruf, garis dasar (px)
local CREAM  = {0.827, 0.890, 0.867}            -- #d3e3dd (putih kehijauan)
local ACCENT = {0.381, 0.680, 0.306}            -- #61AD4E (hijau daun)
local A_DAY  = 0.86                              -- kepekatan nama hari (1 = padat, makin kecil makin transparan)
local A_INFO = 0.90                              -- kepekatan jam dan tanggal

local function extents(cr, s)
    local e = cairo_text_extents_t:create()
    pcall(tolua.takeownership, e)
    cairo_text_extents(cr, s, e)
    return e
end

-- satu huruf nama hari
local function glyph(cr, ch, x, y)
    cairo_move_to(cr, x, y)
    cairo_text_path(cr, ch)
    cairo_set_source_rgba(cr, CREAM[1], CREAM[2], CREAM[3], A_DAY)
    cairo_fill(cr)
end

-- potongan miring: persegi panjang tipis yang diputar lalu "menghapus" huruf
local function slash(cr, cx, cy, angle_deg, len, thick)
    cairo_save(cr)
    cairo_translate(cr, cx, cy)
    cairo_rotate(cr, math.rad(angle_deg))
    cairo_rectangle(cr, -len / 2, -thick / 2, len, thick)
    cairo_set_operator(cr, CAIRO_OPERATOR_CLEAR)
    cairo_fill(cr)
    cairo_restore(cr)
end

-- huruf dibelah mendatar, bagian bawah bergeser ke samping
local function split_shift(cr, ch, x, adv, capH, f, gap, dx)
    local ycut = BASE - capH * f
    local top = BASE - capH - 40
    cairo_save(cr)
    cairo_rectangle(cr, x - 30, top, adv + 60 + math.abs(dx), (ycut - gap / 2) - top)
    cairo_clip(cr); glyph(cr, ch, x, BASE)
    cairo_restore(cr)
    cairo_save(cr)
    cairo_rectangle(cr, x - 30, ycut + gap / 2, adv + 60 + math.abs(dx), 80)
    cairo_clip(cr); glyph(cr, ch, x + dx, BASE)
    cairo_restore(cr)
end

-- teks polos; track = jarak antar huruf (0 = satu tarikan)
local function plain(cr, str, x, y, col, alpha, track)
    cairo_set_source_rgba(cr, col[1], col[2], col[3], alpha)
    if track == 0 then
        cairo_move_to(cr, x, y); cairo_show_text(cr, str); return
    end
    for i = 1, #str do
        local ch = str:sub(i, i)
        cairo_move_to(cr, x, y); cairo_show_text(cr, ch)
        x = x + extents(cr, ch).x_advance + track
    end
end

function conky_dayname()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- ===== nama hari =====
    cairo_select_font_face(cr, "Titillium Web", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, SIZE)
    local day = string.upper(os.date("%A"))
    local n = #day
    local p1, p2, p3 = 2, math.floor(n / 2) + 1, n - 1
    if p3 - p2 < 2 then p3 = n end
    local capH = extents(cr, "H").height
    local x = 0
    for i = 1, n do
        local ch = day:sub(i, i)
        local e = extents(cr, ch)
        local mid = x + e.x_bearing + e.width / 2
        if i == p2 then
            split_shift(cr, ch, x, e.x_advance, capH, 0.38, 3, 8)       -- belah dan geser
        else
            glyph(cr, ch, x, BASE)
            if i == p1 then slash(cr, mid, BASE - capH * 0.55, -38, e.width * 2, 4)      -- miring "/"
            elseif i == p3 then slash(cr, mid, BASE - capH * 0.62, 28, e.width * 2, 3)   -- miring "\"
            end
        end
        x = x + e.x_advance + TRACK
    end

    -- ===== jam dan tanggal bertingkat =====
    local y0 = BASE + 30
    cairo_select_font_face(cr, "Titillium Web", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 44)
    local t = os.date("%H.%M")
    local te = extents(cr, t)
    plain(cr, t, 0, y0 + 40, CREAM, A_INFO, 0)
    local dx = te.x_advance + 20
    cairo_set_source_rgba(cr, ACCENT[1], ACCENT[2], ACCENT[3], A_INFO)  -- garis pemisah
    cairo_rectangle(cr, dx, y0 + 4, 3, 40); cairo_fill(cr)
    cairo_select_font_face(cr, "Montserrat", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 14)
    plain(cr, string.upper(os.date("%d %B")), dx + 18, y0 + 20, ACCENT, A_INFO, 3)
    plain(cr, os.date("%Y"), dx + 18, y0 + 42, CREAM, A_INFO, 5)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
