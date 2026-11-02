# ⌨️ GMMK Pro ANSI — teamvia firmware

![rev1](https://img.shields.io/badge/rev1-STM32F303-blue) ![VIA](https://img.shields.io/badge/VIA-ready-green) ![QMK](https://img.shields.io/badge/QMK-latest-orange) ![license](https://img.shields.io/badge/license-GPL--2.0-lightgrey)

A custom VIA keymap for the Glorious GMMK Pro (ANSI, rev1) — knob, Caps Word, mouse layer, layer LEDs, extra effects + PaletteFx.
เฟิร์มแวร์ VIA สำหรับ GMMK Pro ANSI rev1 — ปุ่มหมุน, Caps Word, ชั้นเมาส์, ไฟบอกสถานะ, เอฟเฟกต์เพิ่ม

---

## ✨ Features | ฟังก์ชัน

| EN | TH |
|---|---|
| 🔊 Knob: turn = volume, press = mute | หมุน = เสียง กด = ปิดเสียง |
| 🎨 FN + knob = change light color | FN + หมุน = เปลี่ยนสีไฟ |
| ⌨️ `~` key: tap = Esc, hold = `~` | แตะ = Esc กดค้าง = `~` |
| 🔴 Caps Lock = whole board turns red | Caps แล้วไฟแดงทั้งบอร์ด |
| 💡 Side LEDs show layer (FN = blue, mouse = green) | แถบข้างบอก layer |
| 🔠 Double-tap Shift = Caps Word | แตะ Shift 2 ที พิมพ์ตัวใหญ่ยาวๆ |
| 🖱️ FN + PScr = mouse layer (WASD move, Q/E click) | ชั้นเมาส์ กันเมาส์ตาย |
| ⚙️ FN + \ = bootloader (no disassembly) | เข้าโหมดแฟลชไม่ต้องแกะเคส |
| 🌈 Extra effects + PaletteFx (16 palettes × 6 effects) | เอฟเฟกต์เพิ่มเพียบ |
| 🌐 VIA support — remap in browser, no reflash | เปลี่ยนปุ่มผ่านเว็บได้เลย |

## 📁 What's inside | ของในนี้

| Path | EN | TH |
|---|---|---|
| `keymap/` | All our source (4 files) — drop into any fresh QMK | source ทั้งหมดของเรา 4 ไฟล์ |
| `firmware/*.bin` | Ready-to-flash firmware | ไฟล์พร้อมแฟลช |
| `build.bat` | One-step build (needs git + Docker Desktop) | สั่ง build ขั้นเดียว |
| `MANUAL-cute.pdf` | Illustrated manual 🇹🇭 | คู่มือฉบับน่ารัก |

## 🔨 Build

**Easy way | วิธีง่าย:** double-click `build.bat` (first run downloads QMK, ~10 min) → firmware appears in `firmware/`

**Bring your own QMK | ใส่ QMK ของตัวเอง:**

1. Clone QMK + submodules as usual
2. Copy folder `keymap/` → `keyboards/gmmk/pro/rev1/ansi/keymaps/teamvia/`
3. For PaletteFx: `git clone https://github.com/getreuer/qmk-modules.git modules/getreuer`
4. `qmk compile -kb gmmk/pro/rev1/ansi -km teamvia` — then hack away!

## ⚡ Flash | แฟลช

1. Open QMK Toolbox → Open → pick the `.bin` → MCU: **STM32**
2. Enter bootloader: <kbd>FN</kbd> + <kbd>\</kbd> — or unplug → hold <kbd>Esc</kbd> → plug in → release
3. Flash → replug the cable
4. ⚠️ **After every flash:** unplug → hold <kbd>Esc</kbd> → plug in → release (clears old settings, otherwise new keys may not work)
   ⚠️ **หลังแฟลชทุกครั้งต้องล้างค่าจำเก่า** ไม่งั้นปุ่มใหม่อาจไม่ทำงาน

> ⛔ **rev1 only** (STM32F303). Do NOT flash on rev2 — different bootloader, will brick.
> ⛔ **ใช้กับ rev1 เท่านั้น** ห้ามแฟลชลง rev2

## 🌐 VIA

Open [usevia.app](https://usevia.app), connect, remap anything — no reflash needed. Custom behaviors (caps LED, layer LEDs, Caps Word) live in firmware.
เปิด usevia.app เสียบแล้วตั้งปุ่มได้เลย

## 🙏 Credits

- [QMK Firmware](https://github.com/qmk/qmk_firmware) (GPL-2.0-or-later — this keymap too)
- [PaletteFx](https://getreuer.info/posts/keyboards/palettefx) by getreuer
- Board: [Glorious GMMK Pro](https://www.pcgamingrace.com/)
