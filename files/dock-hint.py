#!/usr/bin/env python3
"""Penanda kecil di tepi bawah layar: tanda bahwa dock Plank bersembunyi di sana.

Garis tipis setengah bening di tengah bawah. Kursor menembusnya, jadi dock tetap
muncul saat kursor menyentuh tepi layar. Penanda memudar saat kursor mendekati dock.
Ubah W, H, GAP, ALPHA di bawah untuk menyesuaikan.
"""
import math

import cairo
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk

W, H = 90, 4          # ukuran garis (piksel)
GAP = 3               # jarak dari tepi bawah layar
ALPHA = 0.40          # kepekatan putih (0 sampai 1)
ZONE_H = H + GAP      # tinggi zona = setinggi garis (dihitung dari tepi bawah layar)
FALLBACK_SPAN = 319   # lebar dock bila tidak terbaca dari Plank (piksel)

win = Gtk.Window(type=Gtk.WindowType.POPUP)
win.set_app_paintable(True)
win.set_decorated(False)
win.set_keep_above(True)
win.set_skip_taskbar_hint(True)
win.set_skip_pager_hint(True)
win.set_accept_focus(False)
win.set_default_size(W, H)
visual = win.get_screen().get_rgba_visual()
if visual:
    win.set_visual(visual)


def draw(_widget, cr):
    cr.set_operator(cairo.OPERATOR_SOURCE)
    cr.set_source_rgba(0, 0, 0, 0)
    cr.paint()
    r = H / 2
    cr.set_source_rgba(1, 1, 1, ALPHA)
    cr.arc(r, r, r, math.pi / 2, 3 * math.pi / 2)
    cr.arc(W - r, r, r, -math.pi / 2, math.pi / 2)
    cr.close_path()
    cr.fill()
    return False


win.connect("draw", draw)

geo = Gdk.Display.get_default().get_primary_monitor().get_geometry()
win.move(geo.x + (geo.width - W) // 2, geo.y + geo.height - H - GAP)
win.show_all()
win.input_shape_combine_region(cairo.Region())  # kursor menembus penanda

pointer = Gdk.Display.get_default().get_default_seat().get_pointer()


import ctypes
import ctypes.util
import subprocess


class _Rect(ctypes.Structure):
    _fields_ = [("x", ctypes.c_short), ("y", ctypes.c_short),
                ("width", ctypes.c_ushort), ("height", ctypes.c_ushort)]


_x11 = ctypes.CDLL(ctypes.util.find_library("X11"))
_xext = ctypes.CDLL(ctypes.util.find_library("Xext"))
_x11.XOpenDisplay.restype = ctypes.c_void_p
_xext.XShapeGetRectangles.restype = ctypes.POINTER(_Rect)
_xext.XShapeGetRectangles.argtypes = [ctypes.c_void_p, ctypes.c_ulong, ctypes.c_int,
                                      ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int)]
_dpy = _x11.XOpenDisplay(None)

# Zona sentuh jendela Plank: tertutup = garis 1 px di tepi bawah, terbuka = seluruh dock.
plank_id = None       # id jendela Plank
plank_x = geo.x       # posisi jendela Plank di layar
plank_y = geo.y + geo.height - 100


def find_plank():
    """Cari jendela Plank dan posisinya (dipanggil tiap 2 detik)."""
    global plank_id, plank_x, plank_y
    try:
        out = subprocess.check_output(["wmctrl", "-l"], text=True, timeout=2)
        for line in out.splitlines():
            f = line.split()
            if f and f[-1] == "plank":
                plank_id = int(f[0], 16)
                info = subprocess.check_output(["xwininfo", "-id", f[0]], text=True, timeout=2)
                for l in info.splitlines():
                    if "Absolute upper-left X" in l:
                        plank_x = int(l.split()[-1])
                    elif "Absolute upper-left Y" in l:
                        plank_y = int(l.split()[-1])
                return True
        plank_id = None
    except Exception:
        pass
    return True


def dock_zone():
    """Persegi zona sentuh Plank saat ini: (kiri, kanan, atas) di koordinat layar."""
    fallback_left = geo.x + (geo.width - FALLBACK_SPAN) // 2
    fallback = (fallback_left, fallback_left + FALLBACK_SPAN, geo.y + geo.height - ZONE_H)
    if plank_id is None:
        return fallback
    try:
        n, order = ctypes.c_int(), ctypes.c_int()
        r = _xext.XShapeGetRectangles(_dpy, plank_id, 2, ctypes.byref(n), ctypes.byref(order))
        if n.value < 1:
            return fallback
        left = min(r[i].x for i in range(n.value))
        right = max(r[i].x + r[i].width for i in range(n.value))
        top = min(r[i].y for i in range(n.value))
        if right - left < 20:
            return fallback
        return (plank_x + left, plank_x + right, plank_y + top)
    except Exception:
        return fallback


def poll():
    _screen, x, y = pointer.get_position()
    left, right, top = dock_zone()
    # zona sembunyi: setinggi garis saat dock tertutup, setinggi dock saat dock terbuka
    zone_top = min(top, geo.y + geo.height - ZONE_H)
    near = (y >= zone_top) and (left <= x <= right)
    win.set_opacity(0.0 if near else 1.0)
    return True


find_plank()
GLib.timeout_add(2000, find_plank)
GLib.timeout_add(100, poll)
Gtk.main()
