; z80dasm 1.1.3
; command line: z80dasm --origin=32768 --address --labels --output=prep-hardbox-configure.asm prep-hardbox-configure.bin

pio2:       equ 68h     ;Z80 PIO #2 (U44)
pio2_dra:   equ pio2+0  ;  Data Register A
pio2_drb:   equ pio2+1  ;  Data Register B
pio2_cra:   equ pio2+2  ;  Control Register A
pio2_crb:   equ pio2+3  ;  Control Register B

hsxclr:     equ 74h     ;/HSXCLR

ctc:        equ 7ch     ;Z80 CTC
ctc_ch0:    equ ctc+0   ;  Channel 0 Register
ctc_ch1:    equ ctc+1   ;  Channel 1 Register
ctc_ch2:    equ ctc+2   ;  Channel 2 Register
ctc_ch3:    equ ctc+3   ;  Channel 3 Register

format:          equ 003dh  ;ROM Format the drive
hostread:        equ 007dh  ;ROM Read BC bytes from the host

cmd_reset:       equ 00h  ;Reset drive (exit prep mode)
cmd_format_drv:  equ 01h  ;Format drive
cmd_verify_drv:  equ 07h  ;Verify drive
cmd_read_firm:   equ 32h  ;Read a firmware block
cmd_writ_firm:   equ 33h  ;Write a firmare block

    org 8000h

    ld a,03h            ;8000 3e 03
    out (pio2_cra),a    ;8002 d3 6a
    out (pio2_crb),a    ;8004 d3 6b

                        ;The host is still waiting for a response
                        ;to the "enter prep mode" command.  Send
                        ;the "OK" result byte to the host to
                        ;finish the "enter prep mode" command.

    ld hl,0000h         ;8006 21 00 00
    ld (6012h),hl       ;8009 22 12 60
    call 0074h          ;800c cd 74 00

cmd_loop:
    ld a,03h            ;800f 3e 03
    out (ctc_ch2),a     ;8011 d3 7e

                        ;Read a command byte from the host:
    ld bc,0001h         ;  BC = 1 byte to read from the host
    call hostread       ;  Read BC bytes from the host
    ld a,(hl)           ;  A = command byte

    or a
    jr z,reset_drive    ;Reset drive (exit prep mode)

    cp cmd_format_drv
    jr z,format_drive   ;Format drive

    cp cmd_read_firm
    jr z,read_firm_blk  ;Read a firmware block

    cp cmd_writ_firm
    jr z,writ_firm_blk  ;Write a firmware block

    cp cmd_verify_drv
    jr z,verify_drive   ;Verify drive

                        ;Unrecognized command
                        ;Fall through into reset_drive

reset_drive:
;Reset drive (exit prep mode)
;
;Command byte (0x00) has already been read
;No bytes left to read
;
    call 00a7h          ;802d cd a7 00
    ld hl,0000h         ;8030 21 00 00
    ld (6012h),hl       ;8033 22 12 60
    call 0074h          ;8036 cd 74 00
    jp 0000h            ;8039 c3 00 00

format_drive:
;Format drive
;
;Command byte (0x01) has already been read
;512 bytes left to read: format pattern
;
    ld bc,0200h         ;803c 01 00 02
    call hostread       ;803f cd 7d 00
    ld de,l8200h        ;8042 11 00 82
    ldir                ;Copy BC bytes from (HL) to (DE)
    call format         ;8047 cd 3d 00
    ld hl,0000h         ;804a 21 00 00
    ld (6012h),hl       ;804d 22 12 60
    jp finish_cmd       ;8050 c3 8a 81

read_firm_blk:
;Read a block of Corvus firmware
;
;Command byte (0x32) has already been read
;1 byte left to read: head/sector: head (bits 7-5), sector (bits 4-0)
;
    ld bc,0001h         ;8053 01 01 00
    call hostread       ;8056 cd 7d 00
    ld a,(hl)           ;8059 7e
    ld b,04h            ;805a 06 04
    ld c,a              ;805c 4f
    ld de,l8061h        ;805d 11 61 80
    rst 28h             ;8060 ef
l8061h:
    ld hl,0b600h        ;8061 21 00 b6
    ld (6012h),hl       ;8064 22 12 60
    jp finish_cmd       ;8067 c3 8a 81

writ_firm_blk:
;Write a block of Corvus firmware
;
;Command byte (0x33) has already been read
;513 bytes left to read:
;  1 byte head/sector: head (bits 7-5), sector (bits 4-0)
;  512 bytes data
;
    ld bc,0201h         ;806a 01 01 02
    call hostread       ;806d cd 7d 00
    ld a,(hl)           ;8070 7e
    ld (head_sec),a     ;8071 32 fd 81
    ld hl,0000h         ;8074 21 00 00
    ld (cylinder),hl    ;8077 22 fe 81
    rst 20h             ;807a e7
    jp nz,finish_cmd    ;807b c2 8a 81
    ld hl,0001h         ;807e 21 01 00
    ld (cylinder),hl    ;8081 22 fe 81
    rst 20h             ;8084 e7
    ld hl,0000h         ;8085 21 00 00
    ld (6012h),hl       ;8088 22 12 60
    jp finish_cmd       ;808b c3 8a 81

verify_drive:
;Verify drive
;
;Command byte (0x07) has already been read
;No more left bytes to read
;
    ld hl,0a201h        ;808e 21 01 a2
    ld (6012h),hl       ;8091 22 12 60
    ld a,00h            ;8094 3e 00
    ld (0a200h),a       ;8096 32 00 a2
    xor a               ;8099 af
    ld (head_sec),a     ;809a 32 fd 81
    ld hl,0000h         ;809d 21 00 00
    ld (cylinder),hl    ;80a0 22 fe 81
l80a3h:
    call sub_80cah      ;80a3 cd ca 80
    call sub_80e8h      ;80a6 cd e8 80
    jr z,l80a3h         ;80a9 28 f8
l80abh:
    ld hl,0a400h        ;80ab 21 00 a4
    ld bc,(0a200h)      ;80ae ed 4b 00 a2
    ld b,00h            ;80b2 06 00
    inc bc              ;80b4 03
    or a                ;80b5 b7
    sbc hl,bc           ;80b6 ed 42
    ex de,hl            ;80b8 eb
    push de             ;80b9 d5
    ld hl,0a200h        ;80ba 21 00 a2
    ldir                ;80bd ed b0
    pop hl              ;80bf e1
    ld de,1400h         ;80c0 11 00 14
    add hl,de           ;80c3 19
    ld (6012h),hl       ;80c4 22 12 60
    jp finish_cmd       ;80c7 c3 8a 81
sub_80cah:
    call 000bh          ;80ca cd 0b 00
    call sub_8193h      ;80cd cd 93 81
    ret nz              ;80d0 c0
    ld a,(head_sec)     ;80d1 3a fd 81
    and 0e0h            ;80d4 e6 e0
    ld c,00h            ;80d6 0e 00
    call sub_8116h      ;80d8 cd 16 81
    ld a,(head_sec)     ;80db 3a fd 81
    and 0e0h            ;80de e6 e0
    add a,01h           ;80e0 c6 01
    call sub_8116h      ;80e2 cd 16 81
    jp sub_8193h        ;80e5 c3 93 81
sub_80e8h:
    ld a,(6009h)        ;80e8 3a 09 60
    rrca                ;80eb 0f
    rrca                ;80ec 0f
    rrca                ;80ed 0f
    ld b,a              ;80ee 47
    ld a,(head_sec)     ;80ef 3a fd 81
    and 0e0h            ;80f2 e6 e0
    add a,20h           ;80f4 c6 20
    ld (head_sec),a     ;80f6 32 fd 81
    cp b                ;80f9 b8
    jr c,l8113h         ;80fa 38 17
    xor a               ;80fc af
    ld (head_sec),a     ;80fd 32 fd 81
    ld hl,(cylinder)    ;8100 2a fe 81
    inc hl              ;8103 23
    ld (cylinder),hl    ;8104 22 fe 81
    ex de,hl            ;8107 eb
    ld hl,(6002h)       ;8108 2a 02 60
    or a                ;810b b7
    sbc hl,de           ;810c ed 52
    jr nc,l8113h        ;810e 30 03
    or 0ffh             ;8110 f6 ff
    ret                 ;8112 c9
l8113h:
    jp 00a4h            ;8113 c3 a4 00
sub_8116h:
    ld hl,60cah         ;8116 21 ca 60
    ld b,a              ;8119 47
    ld a,14h            ;811a 3e 14
    srl a               ;811c cb 3f
    ld (hl),a           ;811e 77
    ld a,b              ;811f 78
l8120h:
    ld (head_sec),a     ;8120 32 fd 81
    rst 30h             ;8123 f7
    call 0013h          ;8124 cd 13 00
    jr nc,l817dh        ;8127 30 54
    rst 10h             ;8129 d7
    ld hl,(6012h)       ;812a 2a 12 60
    ld a,(head_sec)     ;812d 3a fd 81
    rlc a               ;8130 cb 07
    rlc a               ;8132 cb 07
    rlc a               ;8134 cb 07
    and 07h             ;8136 e6 07
    ld (hl),a           ;8138 77
    inc hl              ;8139 23
    ld bc,(cylinder)    ;813a ed 4b fe 81
    ld (hl),c           ;813e 71
    inc hl              ;813f 23
    ld (hl),b           ;8140 70
    inc hl              ;8141 23
    ld a,(head_sec)     ;8142 3a fd 81
    and 1fh             ;8145 e6 1f
    ld (hl),a           ;8147 77
    inc hl              ;8148 23
    ld (6012h),hl       ;8149 22 12 60
    ld a,(0a200h)       ;814c 3a 00 a2
    add a,04h           ;814f c6 04
    jr nc,l8158h        ;8151 30 05
    pop hl              ;8153 e1
    pop hl              ;8154 e1
    jp l80abh           ;8155 c3 ab 80

l8158h:
    ld (0a200h),a       ;8158 32 00 a2
    ld hl,6200h         ;815b 21 00 62
    ld de,l8200h        ;815e 11 00 82
    ld bc,0200h         ;8161 01 00 02
    ldir                ;Copy BC bytes from (HL) to (DE)
    rst 18h             ;8166 df
    call 00a7h          ;8167 cd a7 00
    ld a,(head_sec)     ;816a 3a fd 81
    add a,02h           ;816d c6 02
    ld (head_sec),a     ;816f 32 fd 81
    ld hl,60cah         ;8172 21 ca 60
    dec (hl)            ;8175 35
    ret z               ;8176 c8
    ld a,(head_sec)     ;8177 3a fd 81
    jp l8120h           ;817a c3 20 81

l817dh:
    ld a,(head_sec)     ;817d 3a fd 81
    add a,02h           ;8180 c6 02
    ld hl,60cah         ;8182 21 ca 60
    dec (hl)            ;8185 35
    jp nz,l8120h        ;8186 c2 20 81
    ret                 ;8189 c9

finish_cmd:
    ld sp,61edh         ;818a 31 ed 61
    call 0074h          ;818d cd 74 00
    jp cmd_loop         ;8190 c3 0f 80

sub_8193h:
    ld a,(6014h)        ;8193 3a 14 60
    cp 0ffh             ;8196 fe ff
    ret                 ;8198 c9

unused:
    db 0,0,0,0,0,0,0,0,0,0a2h,1,0,0,2,0,1,1,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0

;The locations below are accessed by the ROM and can't be moved.

l81f7h:
    db 0                ;used by ROM at 046eh
l81f8h:
    db 0
l81f9h:
    db 0
l81fah:
    dw 0                ;used by ROM at 0c69h
l81fch:
    db 0                ;used by ROM at 0847h
head_sec:
    db 0                ;head/sector: head (bits 7-5), sector (bits 4-0)
                        ;used by ROM at 0afbh, 0b68h, 0b81h, ...
cylinder:
    dw 0                ;cylinder (word)
                        ;used by ROM at 01f4h, 0711h, 0719h, ...
l8200h:
    ;512-byte buffer used to store the format pattern
    ;and for an unknown purpose in the verify command
