# GMMK Pro ANSI บน QMK ล่าสุด — วิจัยว่าต้อง mod อะไรเพิ่ม / เปลี่ยน / เอาออก

ฐาน: `qmk_firmware/` = upstream HEAD `f5db9621` (2026-10-29), `team_old/` = ฟอร์ก Apr 2023 (`ba8e53e`),
`teamvia-rev1-ansi/keymap.c` + `rules.mk` = keymap ใหม่ (สำเนาอยู่ใน
`qmk_firmware/keyboards/gmmk/pro/rev1/ansi/keymaps/teamvia/` — diff แล้วเหมือนกันทุกตัวอักษร).
สมมติฐาน: บอร์ดเป็น **rev1 (STM32F303)** — ยืนยันแล้วจาก USB ของเครื่อง (`REV_0001`)

> หมายเหตุสำคัญ: HEAD `f5db9621` ("Fix incorrect index of RGB underglow LED…", #26541)
> **ไม่ได้แตะ `keyboards/gmmk/pro/` เลย** — diff ของ PR นั้นแก้ `keyboards/keebio/sinc/rev4/keyboard.json`
> ([patch](https://api.github.com/repos/qmk/qmk_firmware/pulls/26541)) ประวัติจริงของ `gmmk/pro`
> ดึงจาก [commits API](https://api.github.com/repos/qmk/qmk_firmware/commits?path=keyboards/gmmk/pro&per_page=40)
> ได้ ~40 commits หลัง Apr 2023 สรุปเฉพาะที่กระทบ keymap นี้ด้านล่าง

## (a) Upstream เปลี่ยนอะไร (Apr 2023 → ปัจจุบัน)

1. **Keycode RGB เปลี่ยนชื่อยกชุด — ของเก่าคอมไพล์ไม่ผ่าน** เก่า `RGB_TOG/RGB_VAI/RGB_HUD…`
   ไม่มีใน `quantum/keycodes.h` อีกแล้ว (grep เจอ 0 จุด; ที่ `0x7820` คือ `QK_UNDERGLOW_TOGGLE`,
   ที่ `0x7842` คือ `QK_RGB_MATRIX_TOGGLE`) ต้องใช้ `RM_TOGG/RM_NEXT/RM_VALU/RM_VALD/RM_HUEU/RM_SPDD…`
   (`= QK_RGB_MATRIX_*`, `quantum/keycodes.h:1549-1562`) หรือ `UG_*` (rgblight) / `QK_BOOT`
   (`= QK_BOOTLOADER`) แทน — keymap เก่า `via`/`default`/`andrewcharnley` ที่ใช้ `RGB_*` คือซากใช้ไม่ได้
   หลักฐานการ migrate: PR #24484 "Update keycodes for keyboards with RGB Matrix" (2024-11-24,
   อยู่ในประวัติ `keyboards/gmmk/pro`) และ default ปัจจุบันใช้ `RM_*` หมดแล้ว
   (`qmk_firmware/keyboards/gmmk/pro/rev1/ansi/keymaps/default/keymap.c`)
2. **`via` keymap ถูกลบออกจาก upstream** — PR #24322 "Remove all via-enabled keymaps" (2024-08-25;
   [body](https://api.github.com/repos/qmk/qmk_firmware/pulls/24322)): via keymap ย้ายไปอยู่ในความดูแลของทีม VIA
   ที่ [the-via/qmk_userspace_via](https://github.com/the-via/qmk_userspace_via) (ดู
   `docs/ChangeLog/20240526.md:77-81` ในโคลนนี้) วิธีที่ถูกวันนี้คือ keymap ปกติ + `VIA_ENABLE = yes`
   ใน `rules.mk` ระดับ keymap — ซึ่ง `teamvia/rules.mk` ทำถูกต้องแล้ว และ `usevia.app` ยังมี
   `gmmk_pro_rev1_ansi_via.bin` / `rev2` ให้โหลด ([download_firmware](https://www.caniusevia.com/docs/download_firmware))
3. **ทุกอย่างย้ายจาก `config.h`/`rules.mk` ไป data-driven (`keyboard.json`)** —
   `LAYOUT` (#20365), `RGB_MATRIX_DRIVER` (#20350), `TAP_CODE_DELAY`→`qmk.tap_keycode_delay` (#21363),
   `LOCKING_*`→`qmk.locking` (#23758, ดู `"qmk": {"locking": …}` ใน `keyboards/gmmk/pro/info.json`),
   features จาก rules.mk (#23248), `WEAR_LEVELING_*`→info.json (#22010/#21978),
   `g_led_config`→`rgb_matrix.layout` (#25598), ลบ `console/command:false` (#25190/#25193) และ
   SPI config ซ้ำ (#25266) ผล: `rev1/ansi/rules.mk` + `config.h` เก่าที่เคยต้องมี (`DRIVER_1_CS`,
   `DRIVER_1_LED_TOTAL`, `ENABLE_RGB_MATRIX_*` …) ไม่ต้องมีอีก — upstream ปัจจุบันทั้งบอร์ดเหลือแค่
   `config.h` (SPI pins), `info.json` (animations+driver+sleep), `rev1/config.h` (`SPI_DRIVER SPID1`)
4. **Encoder**: มีพฤติกรรม default ใน core (หมุน = VOLU/VOLD ถ้าไม่ override ใดๆ — #20320
   "Add core/fallback encoder behaviour"; [docs](https://docs.qmk.fm/features/encoders)) และ
   `ENCODER_CCW_CW(ccw, cw)` + ตาราง `encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS]` (#20454, #20847)
   default ปัจจุบันใช้ฟอร์มนี contribution (`…/default/keymap.c:63-68`) — `teamvia` ตรงแล้ว
   (ต่างจากของเก่าที่ใช้ `[2]` ดิบ)
5. **LED driver**: ชื่อ driver เป็น lowercase `aw20216s` (`pro/info.json:54`), รวมขา EN
   (#23067: `AW20216S_CS_PIN_1/2` + `AW20216S_EN_PIN` ใน `pro/config.h`), rename `DRIVER_ADDR_n`
   (#22200), ตัด `DRIVER_COUNT` ที่ไม่จำเป็น (#22435) — `team_old/.../pro/config.h`
   (`DRIVER_1_CS`, `DRIVER_1_EN`…) คือของตาย
6. **RGB sleep**: `dd164a05` "Turn off RGB when suspended" + rename
   `RGB_DISABLE_WHEN_USB_SUSPENDED`→`RGB_MATRIX_SLEEP` (#22682) — ปัจจุบันคือ `"sleep": true`
   ใน `pro/info.json:55` ได้มาฟรี ไม่ต้องเขียนโค้ด
7. **rev1 vs rev2 ต่างกันที่ MCU/bootloader/EEPROM** (เทียบ `rev1/ansi/keyboard.json` vs
   `rev2/ansi/keyboard.json`): rev1 = `STM32F303` + `stm32-dfu`, rev2 = `WB32F3G71` + `wb32-dfu`
   และ rev2 ระบุ `eeprom.wear_leveling` (spi_flash, backing 2048) ส่วน rev1 ไม่มี = default
   ของ platform; `device_version` ต่างกัน (0.0.1 vs 0.0.2) แต่ VID/PID เดียวกัน (`320F:5044`)
   → **flash ผิด rev = เข้า bootloader ผิดวิธี/บริกได้** ต้องยืนยัน rev ที่ตัว MCU ก่อน flash เสมอ
8. **Debounce**: บอร์ดนี้ไม่มี override → ใช้ default ของอัลกอริทึม (`DEBOUNCE 5`,
   `quantum/debounce/sym_defer_g.c:12`, `asym_eager_defer_pk.c:15`) ไม่ต้องแตะ
   (รายละเอียดอัลกอริทึมดู `docs/feature_debounce_type.md`)
9. **ของที่ลบแล้วไม่เกี่ยว**: user keymaps/userspace (#22544/#23104/#23081 — ลบ `gigahawk`?
   ไม่: ที่ลบคือ userspace/personal keymaps จำนวนมาก; แต่ `andrewcharnley`/`gigahawk` ยังอยู่ใน
   `team_old` เพราะฟอร์กเก่า), ปรับ alignment รอบ `QK_BOOT` (#23697 — `QK_BOOT` ยังใช้ได้เหมือนเดิม)

## (b) ของเก่าอันไหนตาย / ซ้ำซ้อนแล้ว

- `team_old/.../pro/pro.c` (hardcode หมุน=volume ผ่าน `encoder_update_kb`) — ตาย:
  upstream ไม่มี `pro.c` แล้ว; core fallback + `encoder_map` คุมแทน ([docs](https://docs.qmk.fm/features/encoders))
- `RGB_*` ทุกตัวใน keymap เก่า (`RGB_TOG/VAI/VAD/HUI/MOD/RMOD/SPD/SPI`) — ตาย (คอมไพล์ไม่ผ่าน, ดู (a) ข้อ 1)
- `team_old/.../rev1/ansi/keymaps/via/keymap.c` encoder ใส่ทิศสลับ
  (`ENCODER_CCW_CW(KC_VOLU, KC_VOLD)`) เทียบกับ default เก่าที่ถูก (`…(KC_VOLD, KC_VOLU)`) —
  macro แปล `(ccw, cw)` เหมือนกันทั้งเก่าใหม่ (`team_old/quantum/encoder.h:60` vs
  `qmk_firmware/quantum/encoder.h:114`) ดังนั้น via เก่าหมุนกลับด้านจริง — `teamvia` แก้แล้ว
- `andrewcharnley` caps-indicator แบบ force ขาวทั้งบอร์ดตอน caps off (`else rgb_matrix_set_color_all(val,val,val)`)
  — ฆ่า effect ที่กำลังรัน; `teamvia` ใช้แบบ "แตะเฉพาะตอน caps on" ตาม pattern ทางการ
  (`docs/features/rgb_matrix.md:662-676` — ตัวอย่าง Caps Lock indicator) ถูกต้องกว่า
- `rules.mk` ระดับบอร์ดแบบเก่า (`BOOTMAGIC/MOUSEKEY/NKRO/RGB_MATRIX_DRIVER/ENCODER_ENABLE…`) —
  ย้ายลง `keyboard.json` `"features"` หมดแล้ว (`rev1/ansi/keyboard.json:11-18` มีครบ
  bootmagic/encoder/extrakey/mousekey/nkro/rgb_matrix) เหลือแค่ `VIA_ENABLE` + `ENCODER_MAP_ENABLE`
  ระดับ keymap (เหมือน upstream default `rules.mk`)
- `keymaps/via` + `default` แบบเก่า (RGB_*, encoder `[2]`, 2 layers) — แทนด้วย `teamvia` หมดแล้ว
  (4 layers ว่างเผื่อ VIA remap + `RM_*` + encoder `[NUM_DIRECTIONS]`)

## (c) Mod ที่คุ้มทำต่อ (คอมมูนิตี้ยอดนิยม, ประเมินบน 75% + VIA-first)

1. **Caps indicator แบบไม่ฆ่า effect — ทำแล้ว, ปรับได้นิดเดียว**: `teamvia` ใช้
   `rgb_matrix_indicators_advanced_user` + `set_color_all(แดง)` ตาม docs pattern
   (`docs/features/rgb_matrix.md:640-676`) ถ้าอยากให้ side LEDs ไม่แดงตาม (แบบ `gigahawk` เก่า
   ที่เช็ก `LED_FLAG_UNDERGLOW`) ให้ลูปเฉพาะ `LED_FLAG_KEYLIGHT` แทน `set_color_all` —
   1 if + 1 loop จบ, ไม่กระทบ VIA
2. **Encoder หลายโหมดตาม layer (แทน callback แบบ `andrewcharnley`)**: `encoder_map` มี 4 layers
   แต่ layer 1-3 เป็น `KC_TRNS` หมด — ใส่เช่น layer1 = `RM_VALU/RM_VALD` หรือ `RM_HUEU/RM_HUED`
   ได้ทันทีโดยไม่เพิ่มโค้ด และ **VIA แก้ encoder_map ได้** (ต่างจาก `encoder_update_user`
   callback ที่ VIA แตะไม่ได้) — นี่คือเหตุผลหลักที่ควรใช้ `encoder_map` อย่างเดียวแล้วลบ callback ทิ้ง
3. **FN shortcuts มีครบแล้ว ไม่ต้องเพิ่ม**: `QK_BOOT` (FN+\\), `NK_TOGG` (FN+N, default 6KRO
   ตามคอมเมนต์ใน default keymap — อ่อนโยนต่อ KVM/BIOS), ชุด `RM_*` ครบ (TOGG/NEXT/PREV/HUE/VAL/SPD)
   บน FN layer — ตรงกับ default upstream ทุกตัว
4. **NKRO / bootmagic / `QK_BOOT` ไม่ต้อง mod**: `nkro:true` + `bootmagic:true (matrix [1,3])`
   อยู่ใน `keyboard.json` แล้ว; `QK_BOOT` ผ่าน FN ไม่ต้องแกะเคส (default keymap คอมเมนต์บรรทัด 30-36)
5. **Combos / tap-dance / oneshot-mod / caps-word บน 75%**: มีประโยชน์จริงแต่ต้องเลือก —
   `docs/features/combo.md`, `tap_dance.md`, `caps_word.md` (และ oneshot ใน `docs/feature_layers.md`
   หัวข้อ oneshot modifiers) จุดคุ้มสุดคือ **combos** (เช่น JK→ESC, ไม่เปลืองปุ่ม) กับ **caps_word**
   (double-tap Shift) เพราะไม่เพิ่ม layer; tap-dance เพิ่ม latency การตัดสินใจทุกครั้งที่กด —
   ข้อจำกัดสำคัญ: ฟีเจอร์พวกนี้ compile ลง firmware **VIA แก้ live ไม่ได้** (ต้อง reflash หรือย้ายไป Vial)
   ถ้าจะเอา เริ่มจาก combos + caps_word ก่อน tap-dance
6. **Layer indicator แบบ `gigahawk` (ย้อมทั้งบอร์ดตาม layer) — ไม่แนะนำ**: ทับ effect หลักตลอดเวลา
   ขัดกับปรัชญา "indicator แตะเฉพาะตอน active" ของ (c) ข้อ 1; ถ้าอยากได้ ใช้ `LED_FLAG_UNDERGLOW`
   กับ side LEDs อย่างเดียวพอ

## (d) VIA vs Vial — สถานะปัจจุบัน + คำแนะนำ

- **VIA ยังรองรับทางการ**: `usevia.app` คือแอป, `caniusevia.com` คือเจ้าของสเปก/เฟิร์มแวร์ —
  หน้ารายการเฟิร์มแวร์ยังมี `gmmk_pro_rev1_ansi_via.bin` และ `rev2` ครบทั้ง ANSI/ISO
  ([download_firmware](https://www.caniusevia.com/docs/download_firmware)) QMK แค่ย้าย `via` keymap
  ออกจาก repo หลักไป [qmk_userspace_via](https://github.com/the-via/qmk_userspace_via) (#24322,
  `docs/ChangeLog/20240526.md:77-81`) ไม่ได้เลิกสนับสนุน — `VIA_ENABLE = yes` ใน `teamvia/rules.mk`
  คือวิธีที่ถูกต้องปัจจุบัน
- **Vial = ฟอร์กแยก ([vial-kb/vial-qmk](https://github.com/vial-kb/vial-qmk))**: จุดขายคือปรับ
  **tap-dance / combos / macros / encoder / QMK settings / RGB** ได้จาก GUI แบบ live
  ([docs](https://get.vial.today/docs/) — หน้า User manual มีหัวข้อ Layers, Tap Dance, Combos,
  QMK Settings ชัดเจน) แลกกับ: ต้อง port เอง (`VIAL_ENABLE` + `vial.json` + UID),
  firmware หลุดจาก upstream (ตาม patch QMK ช้า/ต้อง maintain เอง), และฟีเจอร์ Vial บางตัวกิน
  เฟิร์มแวร์ size บน STM32F303 (rev1 flash 256KB — พอ แต่ต้องเลือก GUI features, ดูหัวข้อ
  "Select Vial GUI features (for size)" ใน docs เดียวกัน)
- **คำแนะนำ (ใช้ VIA เป็นหลัก)**: อยู่ VIA + `teamvia` ต่อ — ได้ upstream ตรงๆ, VIA ทางการยังมี
  binary ให้, 4 layers ว่างเผื่อ remap เพียงพอต่อ 75% ย้ายไป Vial ก็ต่อเมื่อต้องการข้อใดข้อหนึ่ง:
  (1) แก้ tap-dance/combos โดยไม่ reflash, (2) ตั้ง QMK settings (เช่น tap timing) จาก GUI —
  มิฉะนั้นต้นทุน maintain fork ไม่คุ้ม อนึ่ง VIA กับ Vial อยู่ร่วมบอร์ดเดียวไม่ได้
  (VIA ใช้ `VIA_ENABLE`, Vial ใช้ `VIAL_ENABLE` + UID ของตัวเอง)

## เช็กก่อน flash (rev1 ที่สงสัย)

1. เปิดเคสดูตัว MCU: `STM32F303` = rev1 (`stm32-dfu`), `WB32F3G71` = rev2 (`wb32-dfu`)
   (หลักฐาน: `"processor"`/`"bootloader"` ใน `rev1/ansi/keyboard.json:35-36` vs `rev2/ansi/keyboard.json:42-43`)
2. ใช้ target ให้ตรง: `gmmk/pro/rev1/ansi:teamvia` เท่านั้น อย่าใช้ rev2 (VID/PID เดียวกัน
   `320F:5044` แยกกันที่ `device_version` 0.0.1/0.0.2 เท่านั้น — flash ข้าม rev เสี่ยงบริก)
3. `QK_BOOT` ผ่าน FN+\ มีใน layer 1 แล้ว — ไม่ต้องแกะเคสกดปุ่ม DFU ที่ PCB (คอมเมนต์ default keymap บรรทัด 30-36)
