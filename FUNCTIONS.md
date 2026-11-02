# ฟังก์ชัน QMK ที่น่าใส่เพิ่ม — GMMK Pro ANSI rev1 (keymap `teamvia`)

> บริบท: `teamvia-rev1-ansi/keymap.c` = VIA 4 layers (layer0 volume, layer1 hue, FN มี `RM_*`/`QK_BOOT`/`NK_TOGG`, caps แดงทั้งบอร์ด).
> ไฟล์ `.bin` ปัจจุบัน ~52KB / flash 256KB (STM32F303) → **เหลือ ~200KB** ใส่ฟีเจอร์ได้สบาย.
> ผู้ใช้ VIA (`usevia.app`) เป็นหลัก → แยกชัดว่าอันไหนแก้ใน VIA ได้เลย อันไหนต้อง reflash.

## กติกาสั้นๆ: อะไร VIA แก้ live ได้ / อะไรต้อง reflash

**VIA ทำ live ได้เลย (ไม่ต้อง compile):** เปลี่ยน keycode ทุกปุ่มทุก layer —
รวม `LT/MT/OSM/OSL/MO/TT`, media keys, `RM_*`, `MS_*`, `DM_*`, `CW_TOGG` (**ถ้า firmware เปิดฟีเจอร์นั้นไว้แล้ว**),
`encoder_map` (VIA แก้ได้), ไฟ RGB (tab Lighting), มาโครข้อความ (tab Macros)
— ที่มา: [VIA Usage Guide](https://docs.keeb.io/via) ("remap keys on-the-fly… programming macros, controlling lighting"),
[Using VIA](https://www.caniusevia.com/docs/using_via)

**ต้องแก้โค้ด + reflash:** เปิดฟีเจอร์ใหม่ใน `rules.mk`, นิยาม combos / tap-dance / leader sequences,
จูน timing (`TAPPING_TERM`, `COMBO_TERM`, `MOUSEKEY_*`), โค้ด RGB indicator, autocorrect dictionary.
(Vial แก้พวกนี้จาก GUI ได้ แต่ต้องย้ายไป fork `vial-kbd/vial-qmk` + เสีย upstream ตรง — ดู `RESEARCH.md` ข้อ (d))

## จัดอันดับ: คุ้มค่า (ประโยชน์ vs เสียอะไร)

| # | ฟีเจอร์ | ต้อง reflash? | กิน flash/RAM | latency | หมายเหตุไทย |
|---|---|---|---|---|---|
| 1 | **Encoder หลายโหมด** (layer1 = `RM_VALU/VALD` หรือ hue, FN+หมุน = scroll `MS_WHLU/WHLD`, layer ว่าง = media/brightness) | ❌ VIA remap `encoder_map` ได้เลย | 0 | 0 | คุ้มสุด ได้ "ปุ่มเพิ่ม" โดยไม่เสียปุ่ม ชุมชนทำกัน (`gati3478/gmmk-pro-qmk` ทำ modal knob scroll↔undo — [PLAN.md](https://github.com/gati3478/gmmk-pro-qmk/blob/main/docs/PLAN.md)) |
| 2 | **Space-FN / Layer-Tap (`LT`) + One-shot (`OSM`/`OSL`)** เช่น `LT(1,KC_SPC)`, `OS_LSFT` | ❌ ใส่ keycode ใน VIA ได้ทันที (keycode มาตรฐานอยู่แล้ว) | 0 | ⚠️ ปุ่มที่เป็น `LT/MT` ตัดสินใจช้าลง ~`TAPPING_TERM` (default 200ms) เฉพาะปุ่มนั้น | จูน `TAPPING_TERM`/`PERMISSIVE_HOLD`/`HOLD_ON_OTHER_KEY_PRESS` ต้อง reflash — ที่มา: `docs/tap_hold.md`, `docs/one_shot_keys.md` |
| 3 | **Caps Word** (`CW_TOGG` / ดับเบิลแทป Shift) — พิมพ์ตัวย่อ/โค้ด `LIKE_THIS` แล้วหลุดเอง | ✅ ครั้งเดียว (`CAPS_WORD_ENABLE = yes` ใน `rules.mk` ระดับ keymap) | น้อย (~1–2KB) | 0 | เข้ากับ caps แดงเดิมได้ (คนละเรื่องกัน) — ที่มา: `docs/features/caps_word.md:1-65` |
| 4 | **Combos** (เช่น `J+K → Esc`, `U+I → Enter`) — ได้ปุ่มลัดโดยไม่เสียปุ่ม เหมาะ 75% | ✅ (`COMBO_ENABLE = yes` + ตาราง combos, ~ปุ่มละไม่กี่บรรทัด) | น้อย (~1KB + ต่อ combo นิดหน่อย, ปรับ buffer ได้) | เฉพาะปุ่มใน combo รอ `COMBO_TERM` (default 50ms) ปุ่มอื่นไม่กระทบ | VIA แก้ไม่ได้ (Vial ได้) — ที่มา: `docs/features/combo.md:1-120` (`COMBO_TERM`, `COMBO_ENABLE`) |
| 5 | **Mouse keys** (`MS_UP/DOWN/LEFT/RGHT`, scroll, click) | ❌ เปิดอยู่แล้ว (`"mousekey": true` ใน `keyboards/gmmk/pro/rev1/ansi/keyboard.json:15`) แค่ map `MS_*` ใน VIA | 0 (เปิดอยู่แล้ว) | 0 | จูนความเร็ว (`MOUSEKEY_DELAY/INTERVAL/MAX_SPEED`) ต้อง reflash — ที่มา: `docs/features/mouse_keys.md`, `quantum/mousekey.h:47-67` |
| 6 | **มาโคร** — มี 2 ทาง: (ก) VIA Macros tab (พิมพ์ข้อความอังกฤษ/ช็อตคัต, ไม่ต้อง reflash) / (ข) Dynamic macros (`DM_REC1/PLY1`, กดอัดบนบอร์ดได้) | (ก) ❌ / (ข) ✅ (`DYNAMIC_MACRO_ENABLE = yes`, buffer รวม 128 ปุ่ม กิน RAM/EEPROM) | (ข) เล็กน้อย + RAM | 0 | `SEND_STRING`/มาโครพิมพ์ได้เฉพาะ keycode ฝั่ง US — **ภาษาไทยต้องผ่าน OS layout อยู่ดี** อย่าหวังพิมพ์ไทยจากมาโคร — ที่มา: `docs/features/dynamic_macros.md:1-44`, `docs/feature_macros.md` |
| 7 | **Tap dance** (ปุ่มเดียว: แตะ 1/2/3 ครั้ง = คนละหน้าที่) | ✅ (`TAP_DANCE_ENABLE = yes` + ตาราง actions) | <1KB (docs ระบุชัด) | ⚠️ สูงสุดในลิสต์ — ทุกครั้งที่กดต้องรอ `TAPPING_TERM` ตัดสินก่อน | เอาไว้หลัง combos; ถ้าปุ่มเดียวต้อง 2 หน้าที่จริงๆ ค่อยใช้ — ที่มา: `docs/features/tap_dance.md:1-12` |
| 8 | **Leader key** (กด leader แล้วตามด้วย sequence 2–5 ปุ่ม) | ✅ (`LEADER_ENABLE = yes` + `leader_end_user()` เขียน C) | เล็กน้อย | รอ `LEADER_TIMEOUT` (default 300ms) | เก่ง sequence ยาว แต่ช้ากว่า combos; เหมาะสาย Vim — ที่มา: `docs/features/leader_key.md:1-60` |
| 9 | **RGB: layer indicator ที่ side LEDs + heatmap/breathing** | ครึ่งๆ: `typing_heatmap`/`breathing` เปิดอยู่แล้วใน `keyboards/gmmk/pro/info.json` → เลือกใน VIA ได้เลย / layer indicator ต้องเพิ่มโค้ด ~10 บรรทัด (ลูปเฉพาะ `LED_FLAG_UNDERGLOW` ไม่ฆ่า effect หลัก) | 0 / เล็กน้อย | 0 | pattern ทางการ: `docs/features/rgb_matrix.md:640-690` (ตัวอย่าง caps + layer indicator), flags `docs/features/rgb_matrix.md:125-130`. side strips ของ rev1 คือ entries `flags: 2` ใน `rev1/ansi/keyboard.json` |
| 10 | **Autocorrect** | ✅ (`AUTOCORRECT_ENABLE` + generate dictionary) | ตามขนาด trie (พจนานุกรมใหญ่ = ใหญ่) | 0 | **ไม่แนะนำ** — typo ต้องเป็น `a–z` เท่านั้น (`docs/features/autocorrect.md:39`) **ใช้กับภาษาไทยไม่ได้** แถมแก้คำทีต้อง reflash |
| 11 | **USB polling / NKRO** | ไม่ต้องทำ | 0 | 0 | default 1kHz อยู่แล้ว ([ChangeLog 20220226 #15352](https://docs.qmk.fm/ChangeLog/20220226)); `NK_TOGG` (FN+N) มีแล้ว จำค่าใน EEPROM; ค้าง 6KRO ไว้ถ้าใช้ KVM/BIOS (คอมเมนต์ใน `keymaps/default/keymap.c:36-39`) — อย่าปรับ polling เอง ไม่รู้สึกต่างแต่เสี่ยงเสถียรภาพ |
| 12 | **Power-saving** | ไม่ต้องทำ | 0 | 0 | ได้ฟรีแล้ว: `"sleep": true` ใน `keyboards/gmmk/pro/info.json:55` (ดับ RGB ตอน suspend); บอร์ดมีสายไม่มีแบต — ที่มา: `docs/config_options.md:95-96` (`USB_POLLING_INTERVAL_MS`) |
| 13 | **ของเล็กอื่นๆ**: **Grave-Esc** (`QK_GESC`, ❌ VIA ได้เลย ไม่ต้องเปิดฟีเจอร์), **Repeat key** (`RPT`, ✅ เปิด `REPEAT_KEY_ENABLE` แล้ว map ใน VIA), **Layer lock** (`QK_LAYER_LOCK`, ✅ เปิดแล้ว map ใน VIA), **Key overrides** (✅ + เขียน C นิดหน่อย), **Unicode/Thai** (❌ ไม่แนะนำ — พิมพ์ไทยผ่าน OS layout, QMK unicode ผูกกับ OS layout เสี่ยง) | ผสม | เล็กน้อย | 0 | ที่มา: `docs/features/grave_esc.md`, `docs/features/repeat_key.md:17-20`, `docs/features/layer_lock.md:22-25`, `docs/features/key_overrides.md:15`, `docs/features/unicode.md:106` |

> ตัดทิ้ง: **stellaris** (ไม่เกี่ยว — เป็น EC ของ Framework laptop ไม่ใช่ QMK feature),
> **live-train** (ไม่เกี่ยว — เป็นเรื่อง ML ไม่ใช่คีย์บอร์ด)

## แผน reflash เดียวจบ (ถ้าจะทำ)

รวมของที่ต้อง reflash ทั้งหมดในครั้งเดียว: `CAPS_WORD_ENABLE` + `COMBO_ENABLE` (+ `TAP_DANCE_ENABLE` ถ้าเอา)
+ `DYNAMIC_MACRO_ENABLE` (ถ้าเอา) + โค้ด layer indicator (side LEDs) + จูน `TAPPING_TERM`/
`PERMISSIVE_HOLD`/`MOUSEKEY_*` ทีเดียว → ที่เหลือ (keymap, encoder, ไฟ, มาโครข้อความ) ปรับใน VIA ต่อได้ตลอด
โดยไม่ต้อง flash อีก

## แหล่งอ้างอิง (primary sources)

**ซอร์สในเครื่อง (`C:/Users/TEAM/Desktop/GMMK_FIRMWARE/qmk_firmware/`, HEAD `f5db9621`):**

- `keyboards/gmmk/pro/rev1/ansi/keyboard.json` — features (`bootmagic/encoder/extrakey/mousekey/nkro/rgb_matrix`),
  `processor STM32F303`, `bootloader stm32-dfu`, side-LED entries (`flags: 2` = `LED_FLAG_UNDERGLOW`)
- `keyboards/gmmk/pro/info.json` — animations (`breathing`, `typing_heatmap: true`), `driver aw20216s`, `"sleep": true`
- `keyboards/gmmk/pro/rev1/ansi/keymaps/default/keymap.c` — upstream default (`RM_*`, `QK_BOOT`, `NK_TOGG`, `encoder_map`)
- `keyboards/gmmk/pro/rev1/ansi/keymaps/teamvia/{keymap.c,rules.mk}` — keymap ปัจจุบัน (`VIA_ENABLE`, `ENCODER_MAP_ENABLE`)
- `docs/features/{combo,tap_dance,caps_word,leader_key,autocorrect,mouse_keys,dynamic_macros,rgb_matrix,encoders}.md`,
  `docs/{one_shot_keys,tap_hold,feature_macros}.md`, `docs/features/{repeat_key,layer_lock,key_overrides,grave_esc,unicode}.md`
- `quantum/mousekey.h:47-67` (defaults), `quantum/keycodes.h:1549-1562` (`RM_*` = `QK_RGB_MATRIX_*`)

**นอกเครื่อง:**

- VIA: [Using VIA](https://www.caniusevia.com/docs/using_via), [VIA Usage Guide](https://docs.keeb.io/via),
  [download_firmware](https://www.caniusevia.com/docs/download_firmware) (ยังมี `gmmk_pro_rev1_ansi_via.bin`)
- คอมมูนิตี้: [jcf-junior/qmk-gmmk-pro](https://github.com/jcf-junior/qmk-gmmk-pro) (caps indicator + VIA),
  [gati3478/gmmk-pro-qmk PLAN.md](https://github.com/gati3478/gmmk-pro-qmk/blob/main/docs/PLAN.md)
  (modal knob, layer-tap caps, FN shortcuts — ต้นแบบ encoder หลายโหมด), QMK default keymaps ข้างต้น
