# GMMK Pro ANSI — teamvia firmware

QMK ล่าสุด + VIA + ปุ่มหมุนตั้งได้ + ไฟบอกสถานะ + Caps Word + ชั้นเมาส์ + PaletteFx

## ของในนี้

| ไฟล์ | คืออะไร |
|---|---|
| `keymap/` | source ทั้งหมดของเรา (`keymap.c`, `rules.mk`, `config.h`, `keymap.json`) — แค่นี้คือ custom ทั้งหมด |
| `firmware/*.bin` | firmware พร้อมแฟลช |
| `build.bat` | สั่ง build เองได้ในขั้นเดียว (ต้องมี git + Docker Desktop) |
| `MANUAL-cute.pdf` | คู่มือฉบับน่ารัก |
| `RESEARCH.md` / `FUNCTIONS.md` | โน้ตรีเสิร์ชว่าทำไมทำแบบนี้ |

## ฟังก์ชัน

- หมุน = เสียง, กด = ปิดเสียง / FN+หมุน = เปลี่ยนสีไฟ
- ปุ่ม `~` แตะ = Esc กดค้าง = `~` (Grave-Esc)
- Caps แดงทั้งบอร์ด / แถบข้างบอก layer (FN = น้ำเงิน, เมาส์ = เขียว)
- แตะ Shift 2 ที = Caps Word
- FN + PScr = ชั้นเมาส์ (WASD ขยับ, Q/E คลิก, ZXC สกรอลล์)
- FN + \ = เข้า bootloader / FN + N = สลับ 6KRO/NKRO
- เอฟเฟกต์ไฟเพิ่ม + PaletteFx (16 ชุดสี × 6 ลาย)
- VIA (usevia.app) เปลี่ยนปุ่มได้เลยไม่ต้องแฟลช

## Build เอง

ดับเบิลคลิก `build.bat` (ครั้งแรกโหลด QMK ~10 นาที) ได้ไฟล์ใน `firmware/`

## Flash

1. เปิด QMK Toolbox → Open → เลือก `.bin` → MCU: STM32
2. เข้า bootloader: FN + \ หรือถอดสาย → กด Esc ค้าง → เสียบสาย → ปล่อย
3. Flash → สำเร็จแล้ว **ล้างค่าจำเก่า: ถอดสาย กด Esc ค้าง เสียบสาย ปล่อย**

ใช้ได้เฉพาะ **rev1** (STM32F303) ห้ามแฟลชลง rev2

## เครดิต

- [QMK Firmware](https://github.com/qmk/qmk_firmware) (GPL-2.0-or-later — keymap นี้เช่นกัน)
- [PaletteFx](https://getreuer.info/posts/keyboards/palettefx) โดย getreuer
- บอร์ด [Glorious GMMK Pro](https://www.pcgamingrace.com/)
