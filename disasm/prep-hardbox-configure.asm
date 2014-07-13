; z80dasm 1.1.3
; command line: z80dasm --origin=256 --address --labels --output=prep-hardbox-configure.asm prep-hardbox-configure.bin

cmd_reset:       equ 00h  ;Reset (exit prep mode)
cmd_format_drv:  equ 01h  ;Format drive
cmd_verify_drv:  equ 07h  ;Verify drive
cmd_read_firm:   equ 32h  ;Read a firmware block
cmd_writ_firm:   equ 33h  ;Write a firmare block

    org 0100h

    ld a,03h            ;0100 3e 03
    out (6ah),a         ;0102 d3 6a
    out (6bh),a         ;0104 d3 6b
    ld hl,0000h         ;0106 21 00 00
    ld (6012h),hl       ;0109 22 12 60
    call 0074h          ;010c cd 74 00
    ld a,03h            ;010f 3e 03
    out (7eh),a         ;0111 d3 7e
    ld bc,0001h         ;0113 01 01 00
    call 007dh          ;0116 cd 7d 00
    ld a,(hl)           ;0119 7e

    or a
    jr z,reset_drive    ;Reset drive (exit prep mode)

    cp cmd_format_drv
    jr z,format_drive   ;Format drive

    cp cmd_read_firm
    jr z,read_firm_blk  ;Read firmware block

    cp cmd_writ_firm
    jr z,writ_firm_blk  ;Write firmware block

    cp cmd_verify_drv
    jr z,verify_drive   ;Verify drive

reset_drive:
    call 00a7h          ;012d cd a7 00
    ld hl,0000h         ;0130 21 00 00
    ld (6012h),hl       ;0133 22 12 60
    call 0074h          ;0136 cd 74 00
    jp 0000h            ;0139 c3 00 00

format_drive:
    ld bc,l0200h        ;013c 01 00 02
    call 007dh          ;013f cd 7d 00
    ld de,8200h         ;0142 11 00 82
    ldir                ;0145 ed b0
    call 003dh          ;0147 cd 3d 00
    ld hl,0000h         ;014a 21 00 00
    ld (6012h),hl       ;014d 22 12 60
    jp 818ah            ;0150 c3 8a 81

read_firm_blk:
    ld bc,0001h         ;0153 01 01 00
    call 007dh          ;0156 cd 7d 00
    ld a,(hl)           ;0159 7e
    ld b,04h            ;015a 06 04
    ld c,a              ;015c 4f
    ld de,8061h         ;015d 11 61 80
    rst 28h             ;0160 ef
    ld hl,0b600h        ;0161 21 00 b6
    ld (6012h),hl       ;0164 22 12 60
    jp 818ah            ;0167 c3 8a 81

writ_firm_blk:
    ld bc,l0200h+1      ;016a 01 01 02
    call 007dh          ;016d cd 7d 00
    ld a,(hl)           ;0170 7e
    ld (81fdh),a        ;0171 32 fd 81
    ld hl,0000h         ;0174 21 00 00
    ld (81feh),hl       ;0177 22 fe 81
    rst 20h             ;017a e7
    jp nz,818ah         ;017b c2 8a 81
    ld hl,0001h         ;017e 21 01 00
    ld (81feh),hl       ;0181 22 fe 81
    rst 20h             ;0184 e7
    ld hl,0000h         ;0185 21 00 00
    ld (6012h),hl       ;0188 22 12 60
    jp 818ah            ;018b c3 8a 81

verify_drive:
    ld hl,0a201h        ;018e 21 01 a2
    ld (6012h),hl       ;0191 22 12 60
    ld a,00h            ;0194 3e 00
    ld (0a200h),a       ;0196 32 00 a2
    xor a               ;0199 af
    ld (81fdh),a        ;019a 32 fd 81
    ld hl,0000h         ;019d 21 00 00
    ld (81feh),hl       ;01a0 22 fe 81
l01a3h:
    call 80cah          ;01a3 cd ca 80
    call 80e8h          ;01a6 cd e8 80
    jr z,l01a3h         ;01a9 28 f8
    ld hl,0a400h        ;01ab 21 00 a4
    ld bc,(0a200h)      ;01ae ed 4b 00 a2
    ld b,00h            ;01b2 06 00
    inc bc              ;01b4 03
    or a                ;01b5 b7
    sbc hl,bc           ;01b6 ed 42
    ex de,hl            ;01b8 eb
    push de             ;01b9 d5
    ld hl,0a200h        ;01ba 21 00 a2
    ldir                ;01bd ed b0
    pop hl              ;01bf e1
    ld de,1400h         ;01c0 11 00 14
    add hl,de           ;01c3 19
    ld (6012h),hl       ;01c4 22 12 60
    jp 818ah            ;01c7 c3 8a 81
    call 000bh          ;01ca cd 0b 00
    call 8193h          ;01cd cd 93 81
    ret nz              ;01d0 c0
    ld a,(81fdh)        ;01d1 3a fd 81
    and 0e0h            ;01d4 e6 e0
    ld c,00h            ;01d6 0e 00
    call 8116h          ;01d8 cd 16 81
    ld a,(81fdh)        ;01db 3a fd 81
    and 0e0h            ;01de e6 e0
    add a,01h           ;01e0 c6 01
    call 8116h          ;01e2 cd 16 81
    jp 8193h            ;01e5 c3 93 81
    ld a,(6009h)        ;01e8 3a 09 60
    rrca                ;01eb 0f
    rrca                ;01ec 0f
    rrca                ;01ed 0f
    ld b,a              ;01ee 47
    ld a,(81fdh)        ;01ef 3a fd 81
    and 0e0h            ;01f2 e6 e0
    add a,20h           ;01f4 c6 20
    ld (81fdh),a        ;01f6 32 fd 81
    cp b                ;01f9 b8
    jr c,l0213h         ;01fa 38 17
    xor a               ;01fc af
    ld (81fdh),a        ;01fd 32 fd 81
l0200h:
    ld hl,(81feh)       ;0200 2a fe 81
    inc hl              ;0203 23
    ld (81feh),hl       ;0204 22 fe 81
    ex de,hl            ;0207 eb
    ld hl,(6002h)       ;0208 2a 02 60
    or a                ;020b b7
    sbc hl,de           ;020c ed 52
    jr nc,l0213h        ;020e 30 03
    or 0ffh             ;0210 f6 ff
    ret                 ;0212 c9
l0213h:
    jp 00a4h            ;0213 c3 a4 00
    ld hl,60cah         ;0216 21 ca 60
    ld b,a              ;0219 47
    ld a,14h            ;021a 3e 14
    srl a               ;021c cb 3f
    ld (hl),a           ;021e 77
    ld a,b              ;021f 78
    ld (81fdh),a        ;0220 32 fd 81
    rst 30h             ;0223 f7
    call 0013h          ;0224 cd 13 00
    jr nc,l027dh        ;0227 30 54
    rst 10h             ;0229 d7
    ld hl,(6012h)       ;022a 2a 12 60
    ld a,(81fdh)        ;022d 3a fd 81
    rlc a               ;0230 cb 07
    rlc a               ;0232 cb 07
    rlc a               ;0234 cb 07
    and 07h             ;0236 e6 07
    ld (hl),a           ;0238 77
    inc hl              ;0239 23
    ld bc,(81feh)       ;023a ed 4b fe 81
    ld (hl),c           ;023e 71
    inc hl              ;023f 23
    ld (hl),b           ;0240 70
    inc hl              ;0241 23
    ld a,(81fdh)        ;0242 3a fd 81
    and 1fh             ;0245 e6 1f
    ld (hl),a           ;0247 77
    inc hl              ;0248 23
    ld (6012h),hl       ;0249 22 12 60
    ld a,(0a200h)       ;024c 3a 00 a2
    add a,04h           ;024f c6 04
    jr nc,l0258h        ;0251 30 05
    pop hl              ;0253 e1
    pop hl              ;0254 e1
    jp 80abh            ;0255 c3 ab 80
l0258h:
    ld (0a200h),a       ;0258 32 00 a2
    ld hl,6200h         ;025b 21 00 62
    ld de,8200h         ;025e 11 00 82
    ld bc,l0200h        ;0261 01 00 02
    ldir                ;0264 ed b0
    rst 18h             ;0266 df
    call 00a7h          ;0267 cd a7 00
    ld a,(81fdh)        ;026a 3a fd 81
    add a,02h           ;026d c6 02
    ld (81fdh),a        ;026f 32 fd 81
    ld hl,60cah         ;0272 21 ca 60
    dec (hl)            ;0275 35
    ret z               ;0276 c8
    ld a,(81fdh)        ;0277 3a fd 81
    jp 8120h            ;027a c3 20 81
l027dh:
    ld a,(81fdh)        ;027d 3a fd 81
    add a,02h           ;0280 c6 02
    ld hl,60cah         ;0282 21 ca 60
    dec (hl)            ;0285 35
    jp nz,8120h         ;0286 c2 20 81
    ret                 ;0289 c9
    ld sp,61edh         ;028a 31 ed 61
    call 0074h          ;028d cd 74 00
    jp 800fh            ;0290 c3 0f 80
    ld a,(6014h)        ;0293 3a 14 60
    cp 0ffh             ;0296 fe ff
    ret                 ;0298 c9

    nop                 ;0299 00
    nop                 ;029a 00
    nop                 ;029b 00
    nop                 ;029c 00
    nop                 ;029d 00
    nop                 ;029e 00
    nop                 ;029f 00
    nop                 ;02a0 00
    nop                 ;02a1 00
    and d               ;02a2 a2
    ld bc,0000h         ;02a3 01 00 00
    ld (bc),a           ;02a6 02
    nop                 ;02a7 00
    ld bc,0001h         ;02a8 01 01 00
    nop                 ;02ab 00
    nop                 ;02ac 00
    nop                 ;02ad 00
    nop                 ;02ae 00
    nop                 ;02af 00
    nop                 ;02b0 00
    nop                 ;02b1 00
    nop                 ;02b2 00
    nop                 ;02b3 00
    nop                 ;02b4 00
    nop                 ;02b5 00
    nop                 ;02b6 00
    nop                 ;02b7 00
    nop                 ;02b8 00
    nop                 ;02b9 00
    nop                 ;02ba 00
    nop                 ;02bb 00
    nop                 ;02bc 00
    nop                 ;02bd 00
    nop                 ;02be 00
    nop                 ;02bf 00
    nop                 ;02c0 00
    nop                 ;02c1 00
    nop                 ;02c2 00
    nop                 ;02c3 00
    nop                 ;02c4 00
    nop                 ;02c5 00
    nop                 ;02c6 00
    nop                 ;02c7 00
    nop                 ;02c8 00
    nop                 ;02c9 00
    nop                 ;02ca 00
    nop                 ;02cb 00
    nop                 ;02cc 00
    nop                 ;02cd 00
    nop                 ;02ce 00
    nop                 ;02cf 00
    nop                 ;02d0 00
    nop                 ;02d1 00
    nop                 ;02d2 00
    nop                 ;02d3 00
    nop                 ;02d4 00
    nop                 ;02d5 00
    nop                 ;02d6 00
    nop                 ;02d7 00
    nop                 ;02d8 00
    nop                 ;02d9 00
    nop                 ;02da 00
    nop                 ;02db 00
    nop                 ;02dc 00
    nop                 ;02dd 00
    nop                 ;02de 00
    nop                 ;02df 00
    nop                 ;02e0 00
    nop                 ;02e1 00
    nop                 ;02e2 00
    nop                 ;02e3 00
    nop                 ;02e4 00
    nop                 ;02e5 00
    nop                 ;02e6 00
    nop                 ;02e7 00
    nop                 ;02e8 00
    nop                 ;02e9 00
    nop                 ;02ea 00
    nop                 ;02eb 00
    nop                 ;02ec 00
    nop                 ;02ed 00
    nop                 ;02ee 00
    nop                 ;02ef 00
    nop                 ;02f0 00
    nop                 ;02f1 00
    nop                 ;02f2 00
    nop                 ;02f3 00
    nop                 ;02f4 00
    nop                 ;02f5 00
    nop                 ;02f6 00
    nop                 ;02f7 00
    nop                 ;02f8 00
    nop                 ;02f9 00
    nop                 ;02fa 00
    nop                 ;02fb 00
    nop                 ;02fc 00
    nop                 ;02fd 00
    nop                 ;02fe 00
    nop                 ;02ff 00
