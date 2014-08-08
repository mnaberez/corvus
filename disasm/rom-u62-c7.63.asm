; z80dasm 1.1.3
; command line: z80dasm --origin=0 --address --labels --output=rom-u62-c7.63.asm rom-u62-c7.63.bin

pio0:       equ 60h     ;Z80 PIO #0 (U45)
pio0_dra:   equ pio0+0  ;  Data Register A:
                        ;    A7: [Panel]  ACTIVITY LED ("BUSY")
                        ;    A6: [ST-412] -INDEX SEL
                        ;    A5: [ST-412] WRITE FAULT
                        ;    A4: [ST-412] CRC ERROR
                        ;    A3:          -SECTOR SEL
                        ;    A2:          -SECTOR SIZE 1 (UB4:1)
                        ;    A1:          -SECTOR SIZE 2 (UB4:4)
                        ;    A0: [ST-412] -SEEK COMPLETE
pio0_drb:   equ pio0+1  ;  Data Register B:
                        ;    B7: [ST-412] REDUCE WR CURRENT
                        ;    B6: [ST-412] HEAD SEL 2^2
                        ;    B5: [ST-412] HEAD SEL 2^1
                        ;    B4: [ST-412] HEAD SEL 2^0
                        ;    B3: [ST-412] STEP
                        ;    B2:          -HSXSTB
                        ;    B1: [ST-412] DIRECTION IN
                        ;    B0: [ST-412] -READY
pio0_cra:   equ pio0+2  ;  Control Register A
pio0_crb:   equ pio0+3  ;  Control Register B

pio1:       equ 64h     ;Z80 PIO #1 (Unpopulated)

pio2:       equ 68h     ;Z80 PIO #2 (U44)
pio2_dra:   equ pio2+0  ;  Data Register A
                        ;    A7:           -DRV.ACK
                        ;    A6:           -SYNC
                        ;    A5:           -COMPL
                        ;    A4:           PIO RDY
                        ;    A3:           -HSXFER
                        ;    A2:           -ALT SEL
                        ;    A1:           -DRV.ACK
                        ;    A0: [Host]    BUS DIR
pio2_drb:   equ pio2+1  ;  Data Register B
                        ;    B7: [Host]    Data Bit 7
                        ;    B6: [Host]    Data Bit 6
                        ;    B5: [Host]    Data Bit 5
                        ;    B4: [Host]    Data Bit 4
                        ;    B3: [Host]    Data Bit 3
                        ;    B2: [Host]    Data Bit 2
                        ;    B1: [Host]    Data Bit 1
                        ;    B0: [Host]    Data Bit 0
pio2_cra:   equ pio2+2  ;  Control Register A
pio2_crb:   equ pio2+3  ;  Control Register B

pio3:       equ 6ch     ;Z80 PIO #3 (U46)
pio3_dra:   equ pio3+0  ;  Data Register A
                        ;    A7: [ST-412] -WRITE DISABLE
                        ;    A6: [ST-412] -TRACK 00
                        ;    A5: [ST-412] TXD
                        ;    A4: [ST-412] -RXD
                        ;    A3:          SYSTEM/-DIAG (UB4:5)
                        ;    A2:          -UNIT SELECT 2 (UB4:6)
                        ;    A1:          -UNIT SELECT 1 (UB4:7)
                        ;    A0:          -TIMEOUT DISABLE (UB4:8)
pio3_drb:   equ pio3+1  ;  Data Register B
                        ;    B7:          12MB2
                        ;    B6:          12MB1
                        ;    B5:          6MB2
                        ;    B4: [Panel]  -FORMAT ENABLE
                        ;    B3: [Panel]  -WRITE PROTECT (W2)
                        ;    B2:          6MB1
                        ;    B1:          -DRV 2 SEL
                        ;    B0:          -DRV 1 SEL
pio3_cra:   equ pio3+2  ;  Control Register A
pio3_crb:   equ pio3+3  ;  Control Register B

begrdy:     equ 70h     ;/BEGRDY
hsxclr:     equ 74h     ;/HSXCLR
xferstb:    equ 78h     ;/XFERSTB

ctc:        equ 7ch     ;Z80 CTC (U45)
ctc_ch0:    equ ctc+0   ;  Channel 0 Register
ctc_ch1:    equ ctc+1   ;  Channel 1 Register
ctc_ch2:    equ ctc+2   ;  Channel 2 Register
ctc_ch3:    equ ctc+3   ;  Channel 3 Register

last_cyl:   equ 6002h   ;Number of heads (byte)
heads:      equ 6009h   ;Last cylinder number (word)
tracks:     equ 600ah   ;Number of tracks (word)
cylinders:  equ 600eh   ;Number of cylinders (word)
capacity:   equ 606dh   ;Capacity in 512-byte blocks (word)
reserved:   equ 60aeh   ;Number of tracks reserved for firmware (byte)
spares:     equ 61fdh   ;Number of tracks reserved for spares (byte)
head_sec:   equ 81fdh   ;Head/sector: head (bits 7-5), sector (bits 4-0)
cylinder:   equ 81feh   ;Cylinder (word)

    org 0000h

;called from prep code in reset_drive only
l0000h:
    jp e_00             ;0000 c3 df 00
    jp e_03             ;0003 c3 c1 0b
    nop                 ;0006 00
    nop                 ;0007 00
l0008h:
    jp e_08             ;0008 c3 cc 0d
;called from prep code
    jp e_0b             ;000b c3 43 0a
    ld b,48h            ;000e 06 48
;called from prep code (via rst 10h)
    jp e_10             ;0010 c3 1f 07
;called from prep code
    jp e_13             ;0013 c3 6f 08
    cp d                ;0016 ba
    dec b               ;0017 05
;called from prep code (via rst 18h)
    jp e_18             ;0018 c3 99 07
    jp e_1b             ;001b c3 3f 08
    nop                 ;001e 00
    nop                 ;001f 00
;called from prep code (via rst 20h)
    jp e_20             ;0020 c3 c1 07
    jp e_23             ;0023 c3 c7 0a
    or l                ;0026 b5
    dec b               ;0027 05
    jp e_28             ;0028 c3 00 0c
    jp e_2b             ;002b c3 1c 0d
    db 0cch, 05h        ;002e cc 05
;called from prep code (via rst 30h)
    jp e_30             ;0030 c3 dd 06
    jp e_33             ;0033 c3 0a 02
    rst 20h             ;0036 e7
    dec b               ;0037 05
    jp e_38             ;0038 c3 c6 00
    nop                 ;003b 00
    nop                 ;003c 00
;called from prep code
format:
    jp format_          ;Format the drive
    adc a,d             ;0040 8a
    ex af,af'           ;0041 08
    add hl,bc           ;0042 09
    ld c,b              ;0043 48
    inc c               ;0044 0c
    ld c,b              ;0045 48
    jp l0008h           ;0046 c3 08 00
    nop                 ;0049 00
    or h                ;004a b4
    inc b               ;004b 04
    nop                 ;004c 00
    nop                 ;004d 00
    ld l,c              ;004e 69
    ld b,0c5h           ;004f 06 c5
    add hl,bc           ;0051 09
    nop                 ;0052 00
    nop                 ;0053 00
    add hl,de           ;0054 19
    ld b,0c3h           ;0055 06 c3
    ex af,af'           ;0057 08
    nop                 ;0058 00
    nop                 ;0059 00
    nop                 ;005a 00
    nop                 ;005b 00
    nop                 ;005c 00
    nop                 ;005d 00
    nop                 ;005e 00
    nop                 ;005f 00
    nop                 ;0060 00
    nop                 ;0061 00
    nop                 ;0062 00
    nop                 ;0063 00
    nop                 ;0064 00
    nop                 ;0065 00

    jp e_38             ;0066 c3 c6 00
    ld c,06h            ;0069 0e 06
    jp e_6b             ;006b c3 0e 03
hostloop:
    jp hostloop_        ;Wait for a command from the host and process it
    jp e_71             ;0071 c3 d4 03
;called from prep code after every command
    jp e_74             ;0074 TODO Send response buffer to host?
;called from prep code in _read_byte only
    jp e_77             ;0077 TODO sets up PIO2 CRB (host data bus port)
    jp e_7a             ;007a c3 40 04
;called from prep code
hostread:
    jp hostread_        ;Read BC bytes of data from the host
    jp e_80             ;TODO Pulse -HSXFER?
    jp e_83             ;TODO HSXCLR then -HSXFER=0?
    jp e_86             ;0086 c3 89 04
    jp e_89             ;0089 c3 1c 05
    jp e_8c             ;TODO "BUSY" LED on, then HSXCLR, then pio2_dra?
    jp e_8f             ;TODO "BUSY" LED off, then set pio2_dra?
    jp e_92             ;0092 c3 6a 05
fatal:
    jp fatal_           ;Fatal error has occurred.  Halt until reset.
    jp e_98             ;0098 c3 9b 05
    jp e_9b             ;009b c3 87 05
    jp e_9e             ;009e TODO Disable interrupts, Swap 6070h/6071h,
                        ;          do something with ctc_ch2
    jp e_a1             ;00a1 c3 65 0c
    jp e_a4             ;00a4 c3 41 0c
;called from prep code
    jp e_a7             ;00a7 TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    jp e_aa             ;00aa c3 02 09
    jp e_ad             ;00ad c3 24 09
    jp e_b0             ;00b0 c3 39 0d
    jp e_b3             ;00b3 c3 7d 0d

    nop                 ;00b6 00
    nop                 ;00b7 00
    ld c,(hl)           ;00b8 4e
    ex af,af'           ;00b9 08
    nop                 ;00ba 00
    nop                 ;00bb 00
    nop                 ;00bc 00
    nop                 ;00bd 00
    rst 0               ;00be c7
    ex af,af'           ;00bf 08
    jp e_c0             ;00c0 c3 e6 04
    jp e_c3             ;00c3 c3 84 0a

e_38:
    in a,(pio3_dra)     ;00c6 db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;00ca d3 6c

    in a,(pio3_dra)     ;00cc db 6c
    bit 1,a             ;Bit 1 = -UNIT SELECT 1 (UB4:7)
    jr nz,l00d8h        ;00d0 20 06

    ld hl,6996h         ;00d2 21 96 69
    ld (6070h),hl       ;00d5 22 70 60

l00d8h:
    call 8ffch          ;00d8 cd fc 8f
    ld d,0fdh           ;00db 16 fd
    jr l00e1h           ;00dd 18 02

e_00:
;called from prep code in reset_drive only
;
    ld d,0fch           ;00df 16 fc
l00e1h:
    ld sp,61edh         ;00e1 31 ed 61
    di                  ;00e4 f3
    ld a,(7000h)        ;00e5 3a 00 70

                        ;Initialize a list of I/O ports to 0:
    xor a               ;  A = 0
    ld hl,table_0       ;  HL = address of table (02c9h)
    ld b,0ah            ;  B = number of table entries to read
l00eeh:
    ld c,(hl)           ;  C = value at HL in table
    out (c),a           ;  Write A (always 0) to port (C)
    inc hl              ;  HL=HL+1
    djnz l00eeh         ;  Decrement B, loop until B=0

                        ;Initialize CTC Channel 0:
                        ;  HL now contains 02d3h
    ld c,ctc_ch0        ;  C = address of CTC Channel 0 (ctc_ch0)
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B

                        ;Initialize CTC Channel 1:
                        ;  HL now contains 02d5h
    inc c               ;  Increment C to address of CTC Channel 1 (ctc_ch1)
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B

                        ;Initialize CTC Channel 2:
                        ;  HL now contains 02d7h
    inc c               ;  Increment C to address of CTC Channel 2 (ctc_ch2)
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B

                        ;Initialize CTC Channel 3:
                        ;  HL now contains 02d9h
    inc c               ;  Increment C to address of CTC Channel 3 (ctc_ch3)
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B
    outi                ;  Copy (HL) to port (C), Increment HL, Decrement B

                        ;Initialize port A and port B of each PIO:
                        ;  HL now contains 02dbh
    ld e,06h            ;  E = 6 table blocks to read (2 for each of the 3 PIOs)
l010bh:                 ;
    ld c,(hl)           ;  C = port number from table (a PIO CRx)
    inc hl              ;  Increment HL to first byte of table
                        ;  Write two bytes to a PIO CRx:
    outi                ;    Copy (HL) to port (C), Increment HL, Decrement B
    outi                ;    Copy (HL) to port (C), Increment HL, Decrement B
                        ;  Back up to point to a PIO DRx:
    dec c               ;    Decrement C
    dec c               ;    Decrement C
                        ;  Write a byte to a PIO DRx:
    outi                ;    Copy (HL) to port (C), Increment HL, Decrement B
    dec e               ;  Decrement E
    jr nz,l010bh        ;  Loop until E=0

                        ;D contains 0fch (set at e_00)
    ld a,d              ;0118 7a
    out (pio3_dra),a    ;0119 d3 6c

    in a,(begrdy)       ;011b db 70
    ld de,(6070h)       ;011d ed 5b 70 60

    ld hl,5aa5h         ;0121 21 a5 5a
    or a                ;0124 b7
    sbc hl,de           ;0125 ed 52
    jr z,l012fh         ;0127 28 06

    ld hl,0a55ah        ;0129 21 5a a5
    or a                ;012c b7
    sbc hl,de           ;012d ed 52
l012fh:
    jp z,spin_up        ;012f ca be 01

                        ;Long delay by counting in HL from 0000-FFFF:
    ld hl,0             ;  HL = 0 (seed value)
ld1:                    ;
    inc hl              ;  Increment HL
    ld a,h              ;  A = H | L
    or l                ;
    jr nz,ld1           ;  Loop until HL=0

                        ;Fill 6000-63ffh with 01h:
    ld a,01h            ;  A = 01h (fill byte)
l013ch:                 ;
    ld hl,6000h         ;  HL = 6000h (source address)
    ld de,6001h         ;  DE = 6001h (target address)
    ld bc,03ffh         ;  BC = 1023 bytes to copy
    ld (hl),a           ;  Store fill byte (01h) in 6000h
    ldir                ;  Copy BC bytes from (HL) to (DE)

;TODO Does this test 6xxx?
    ld hl,6000h         ;0148 21 00 60
    ld b,04h            ;014b 06 04
l014dh:
    cpi                 ;CP (HL), INC HL, DEC BC
    jr nz,l0194h        ;014f 20 43
    jp pe,l014dh        ;0151 ea 4d 01

;TODO Does this fill 8xxx?
    ld h,80h            ;0154 26 80
    ld de,8001h         ;0156 11 01 80
    ld bc,03ffh         ;0159 01 ff 03
    ld (hl),a           ;015c 77
    ldir                ;Copy BC bytes from (HL) to (DE)

;TODO Does this test 8xxx?
    ld hl,8000h         ;015f 21 00 80
    ld b,04h            ;0162 06 04
l0164h:
    cpi                 ;CP (HL), INC HL, DEC BC
    jr nz,l0194h        ;0166 20 2c
    jp pe,l0164h        ;0168 ea 64 01

;TODO Does this fill Axxx?
    ld h,0a0h           ;016b 26 a0
    ld de,0a001h        ;016d 11 01 a0
    ld bc,03ffh         ;0170 01 ff 03
    ld (hl),a           ;0173 77
    ldir                ;Copy BC bytes from (HL) to (DE)

;TODO Does this test Axxx?
    ld hl,0a000h        ;0176 21 00 a0
    ld b,04h            ;0179 06 04
l017bh:
    cpi                 ;CP (HL), INC HL, DEC BC
    jr nz,l0194h        ;017d 20 15
    jp pe,l017bh        ;017f ea 7b 01

;TODO Does this fill 48xx?
    ld h,48h            ;0182 26 48
    ld de,4801h         ;0184 11 01 48
    ld bc,03ffh         ;0187 01 ff 03
    ld (hl),a           ;018a 77
    ldir                ;Copy BC bytes from (HL) to (DE)

;TODO Does this test 48xx?
    ld hl,4800h         ;018d 21 00 48
    ld b,04h            ;0190 06 04
l0192h:
    cpi                 ;CP (HL), INC HL, DEC BC
l0194h:
    jp nz,fatal_        ;Fatal error has occurred.  Halt until reset.
    jp pe,l0192h        ;0197 ea 92 01

    rla                 ;019a 17
    cp 01h              ;019b fe 01
    jr nz,l013ch        ;019d 20 9d
    jr l01a3h           ;019f 18 02

do_reti:
    reti

l01a3h:
    ld h,00h            ;01a3 26 00
    ld de,10ffh         ;01a5 11 ff 10
    xor a               ;01a8 af
l01a9h:
    add a,(hl)          ;01a9 86
    inc hl              ;01aa 23
    dec e               ;01ab 1d
    jr nz,l01a9h        ;01ac 20 fb
    dec d               ;01ae 15
    jr nz,l01a9h        ;01af 20 f8

    add a,(hl)          ;01b1 86
    jr nz,l0194h        ;01b2 20 e0

;TODO Is this drive type detection?
    in a,(pio3_drb)     ;01b4 db 6d
    and 01000100b       ;Bit 6 = 12MB1, Bit 2 = 6MB1
    ld (6104h),a        ;01b8 32 04 61

    call e_33           ;01bb cd 0a 02

spin_up:
;Wait for the mechanism to spin up.  This may take 15 seconds or so.
;Blink the "BUSY" LED on the front panel until the mechanism is ready.
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    call blink          ;Blink the "BUSY" LED on the front panel

    in a,(pio0_drb)
    bit 0,a             ;Bit 0 = ST-412 -READY
    jr nz,spin_up       ;Loop until the mechanism is ready

l01cah:
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2

    in a,(pio0_dra)
    bit 0,a             ;Bit 0 = ST-412 -SEEK COMPLETE
    jr nz,l01cah        ;Loop until -SEEK COMPLETE goes low

    call e_23           ;01d3 cd c7 0a
    di                  ;01d6 f3
    ld sp,61edh         ;01d7 31 ed 61
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2

    in a,(pio3_dra)     ;01dd db 6c
    set 0,a             ;Bit 0 = -TIMEOUT DISABLE (UB4:8)
    set 1,a             ;Bit 1 = -UNIT SELECT 1 (UB4:7)
    out (pio3_dra),a    ;01e3 d3 6c

                        ;Turn the "BUSY" LED on:
    in a,(pio0_dra)     ;  A = read port state
    res 7,a             ;  Turn off bit 7 (low state turns LED on)
    out (pio0_dra),a    ;  Write new port state

    call e_33           ;01eb cd 0a 02
    call e_77           ;TODO sets up PIO2 CRB (host data bus port)
    ld hl,0             ;01f1 21 00 00
    ld (cylinder),hl    ;01f4 22 fe 81
    ld (600ch),hl       ;01f7 22 0c 60
    ld (6004h),hl       ;01fa 22 04 60
    xor a               ;01fd af
    ld (head_sec),a     ;01fe 32 fd 81
    ld hl,5aa5h         ;0201 21 a5 5a
    ld (6070h),hl       ;0204 22 70 60
    jp e_6b             ;0207 c3 0e 03

e_33:
    ld b,0ch            ;020a 06 0c
l020ch:
    call do_reti        ;Performs RETI only
    djnz l020ch         ;020f 10 fb
    xor a               ;0211 af
    ld i,a              ;0212 ed 47
    im 2                ;0214 ed 5e
    ld hl,61edh         ;0216 21 ed 61
l0219h:
    ld (hl),a           ;0219 77
    inc l               ;021a 2c
    jr nz,l0219h        ;021b 20 fc

    ld a,14h            ;TODO: sectors per track?
    ld (6017h),a        ;021f 32 17 60

    ld a,(6104h)        ;0222 3a 04 61

    cp 04h              ;Is it 4?
    jr nz,not_6mb       ;  No: it's not a 6MB, so jump.

                        ;Set params for 6MB:
    ld hl,drive_6mb     ;  HL = address of params table for 6MB
    jr set_drive_params ;  Set params for 6MB drive

not_6mb:
    cp 40h              ;Is it 40h?
    jr nz,not_11mb      ;  No: It's not an 11MB, so jump.

                        ;Set drive params for 11MB:
    ld hl,drive_11mb    ;  HL = address of params table for 11MB
    jr set_drive_params ;  Set params for 11MB drive

not_11mb:
                        ;Set drive params for 20MB:
    ld hl,drive_20mb    ;  HL = address of params table for 20MB
                        ;  Fall through to set params for 20MB drive

set_drive_params:
;Set the drive parameters by copying from one of the three
;tables in this ROM into the RAM locations.
;
;HL = address of table for the mechanism
;
                        ;Copy number of heads to (heads):
    ld a,(hl)           ;  A = byte from table
    ld (heads),a        ;  Store A in (heads)

                        ;Copy last cylinder number to (last_cyl):
    inc hl              ;  Increment table pointer
    ld c,(hl)           ;  C = byte from table
    inc hl              ;  Increment table pointer
    ld b,(hl)           ;  B = byte from table
    ld (last_cyl),bc    ;  Store BC in (last_cyl)

                        ;Copy number of cylinders to (cylinders):
    inc hl              ;  Increment table pointer
    ld c,(hl)           ;  C = byte from table
    inc hl              ;  Increment table pointer
    ld b,(hl)           ;  B = byte from table
    ld (cylinders),bc   ;  Store BC in (cylinders)

                        ;Copy number of tracks to (tracks):
    inc hl              ;  Increment table pointer
    ld c,(hl)           ;  C = byte from table
    inc hl              ;  Increment table pointer
    ld b,(hl)           ;  B = byte from table
    ld (tracks),bc      ;  Store BC in (tracks)

                        ;Copy capacity in 512-byte blocks to (capacity):
    inc hl              ;  Increment table pointer
    ld c,(hl)           ;  C = byte from table
    inc hl              ;  Increment table pointer
    ld b,(hl)           ;  B = byte from table
    ld (capacity),bc    ;  Store BC in (capacity)

                        ;Compute number of tracks reserved for firmware:
    ld a,(heads)        ;  A = (number of heads * 2) - 1
    add a,a             ;
    dec a               ;
    ld (reserved),a     ;  Save A in (reserved)

                        ;Fall through into set_spares

set_spares:
;Set the number of tracks reserved for spares to 31
;
    ld a,31             ;A = 31
    ld (spares),a       ;Store A in (spares)
    ret

l02ch:
    ld d,1eh            ;026c 16 1e
l026eh:
    call e_a7           ;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    in a,(ctc_ch0)      ;0271 db 7c
    ld c,a              ;0273 4f
l0274h:
    in a,(ctc_ch0)      ;0274 db 7c
    cp c                ;0276 b9
    jr z,l0274h         ;0277 28 fb
    call e_13           ;0279 cd 6f 08
    call sub_0c49h      ;027c cd 49 0c
    ret z               ;027f c8
    dec d               ;0280 15
    jr nz,l026eh        ;0281 20 eb
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    or 0ffh             ;0286 f6 ff
    ret                 ;0288 c9

e_9e:
;Disable interrupts, Swap 6070h/6071h, do something with ctc_ch2
;
    di                  ;Disable Interrupts

                        ;Swap 6070h and 6071h:
    ld hl,(6070h)       ;  HL = (6070h)
    ld a,h              ;  A = H
    ld h,l              ;  H = L
    ld l,a              ;  L = A
    ld (6070h),hl       ;  (6070h) = HL

    in a,(pio3_drb)     ;0293 db 6d
    bit 4,a             ;Bit 4 = Panel -FORMAT ENABLE
    ld a,43h            ;0297 3e 43
    jr z,l02a1h         ;0299 28 06

    ld a,47h            ;029b 3e 47
    out (ctc_ch2),a     ;029d d3 7e
    ld a,0ffh           ;029f 3e ff
l02a1h:
    out (ctc_ch2),a     ;02a1 d3 7e
    ret                 ;02a3 c9

wait_ready:
;Do ??? and wait until READY goes low
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2

    in a,(pio0_drb)     ;02a7 db 61
    bit 0,a             ;Bit 0 = ST-412 -READY
    jr nz,wait_ready    ;02ab 20 f7

    ret                 ;02ad c9

blink:
;Blink the "BUSY" LED
;
                        ;Turn the "BUSY" LED on:
    in a,(pio0_dra)     ;  A = read port state
    res 7,a             ;  Turn off bit 7 (low state turns LED on)
    out (pio0_dra),a    ;  Write new port state

    call delay          ;Delay

                        ;Turn the "BUSY" LED off:
    in a,(pio0_dra)     ;  A = read port state
    set 7,a             ;  Turn on bit 7 (high state turns LED off)
    out (pio0_dra),a    ;  Write new port state

    call delay          ;Delay
    ret

delay:
;Long delay, only used when blinking the "BUSY" LED
;
    xor a               ;A=0
    ld b,a              ;B=0
dly1:
    djnz dly1           ;Decrement B, loop until B=0
    dec a               ;Decrement A
    jr nz,dly1          ;Loop until A=0
    ret

table_0:
    ;I/O ports that are initialized with 0
    db ctc_ch0, ctc_ch1, ctc_ch2, ctc_ch3
    db pio0_cra, pio0_crb
    db pio2_cra, pio2_crb
    db pio3_cra, pio3_crb

    ;Bytes written to CTC Channel 0 (ctc_ch0)
    db 47h, 14h

    ;Bytes written to CTC Channel 1 (ctc_ch1)
    db 47h, 01h

    ;Bytes written to CTC Channel 2 (ctc_ch2)
    db 47h, 0ffh

    ;Bytes written to CTC Channel 3 (ctc_ch3)
    db 47h, 1eh

    ;Init sequence for PIO0 Port A
    db pio0_cra         ;Address of PIO0 Control Register A
    db 0cfh             ;First byte to write to pio0_cra
    db 7fh              ;Second byte to write to pio0_cra
    db 00h              ;Byte to write to pio0_dra

    ;Init sequence for PIO0 Port B
    db pio0_crb         ;Address of PIO0 Control Register B
    db 0cfh             ;First byte to write to pio0_crb
    db 05h              ;Second byte to write to pio0_crb
    db 82h              ;Byte to write to pio0_drb

    ;Init sequence for PIO2 Port A
    db pio2_cra         ;Address of PIO2 Control Register A
    db 0cfh             ;First byte to write to pio2_cra
    db 0c0h             ;Second byte to write to pio2_cra
    db 0ddh             ;Byte to write to pio0_dra

    ;Init sequence for PIO2 Port B
    db pio2_crb         ;Address of PIO2 Control Register B
    db 04fh             ;First byte to write to pio2_crb
    db 03h              ;Second byte to write to pio2_crb
    db 0ffh             ;Byte to write to pio2_drb

    ;Init sequence for PIO3 Port A
    db pio3_cra         ;Address of PIO3 Control Register A
    db 0cfh             ;First byte to write to pio3_cra
    db 5ch              ;Second byte to write to pio3_cra
    db 7ch              ;Byte to write to pio3_dra

    ;Init sequence for PIO3 Port B
    db pio3_crb         ;Address of PIO3 Control Register B
    db 0cfh             ;First byte to write to pio3_crb
    db 0fch             ;Second byte to write to pio3_crb
    db 0feh             ;Byte to write to pio3_drb

drive_6mb:
;Drive parameters for 6MB mechanism
;
    db 2                ;Number of surfaces (heads)
    dw 305              ;Last cylinder number (last_cyl)
    dw 306              ;Number of cylinders (cylinders)
    dw 612              ;Number of tracks (tracks)
    dw 11540            ;Capacity in 512-byte blocks (capacity)

drive_11mb:
;Drive parameters for 11MB mechanism
;
    db 4                ;Number of surfaces (heads)
    dw 305              ;Last cylinder number (last_cyl)
    dw 306              ;Number of cylinders (cylinders)
    dw 1224             ;Number of tracks (tracks)
    dw 23700            ;Capacity in 512-byte blocks (capacity)

drive_20mb:
;Drive parameters for 20MB mechanism
;
    db 6                ;Number of surfaces (heads)
    dw 305              ;Last cylinder number (last_cyl)
    dw 306              ;Number of cylinders (cylinders)
    dw 1836             ;Number of tracks (tracks)
    dw 35860            ;Capacity in 512-byte blocks (capacity)

e_6b:
    in a,(pio0_dra)     ;030e db 60
    ld b,a              ;0310 47
    ld a,01h            ;0311 3e 01
    bit 1,b             ;Bit 1 = -SECTOR SIZE 2 (UB4:4)
    jr z,l0318h         ;0315 28 01
    inc a               ;0317 3c
l0318h:
    bit 2,b             ;Bit 2 = -SECTOR SIZE 1 (UB4:1)
    jr z,l031eh         ;031a 28 02
    inc a               ;031c 3c
    inc a               ;031d 3c
l031eh:
    ld (606fh),a        ;031e 32 6f 60

    ld a,11011111b      ;Bit 5 = -COMPL
    out (pio2_dra),a    ;0323 d3 68

w_drv_ack_lo:
;Wait until -DRV.ACK is low
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    ei

    in a,(pio2_dra)
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr z,w_drv_ack_lo  ;Loop if -DRV.ACK is high

    in a,(pio2_dra)
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr z,w_drv_ack_lo  ;Loop if -DRV.ACK is high

    ld a,(606fh)        ;0335 3a 6f 60
    dec a               ;0338 3d
    jr z,l0341h         ;0339 28 06
    xor a               ;033b af
    call e_89           ;033c cd 1c 05
    jr l035ah           ;033f 18 19

l0341h:
    ld b,a              ;0341 47
    ld d,a              ;0342 57
    ld e,a              ;0343 5f
l0344h:
    djnz l0344h         ;0344 10 fe
    call e_8c           ;TODO "BUSY" LED on, then HSXCLR, then set pio2_dra?
l0349h:
    djnz l0349h         ;0349 10 fe
    ld a,60h            ;034b 3e 60
    call e_98           ;034d cd 9b 05

    in a,(pio3_dra)     ;0350 db 6c
    bit 3,a             ;Bit 3 = SYSTEM/-DIAG (UB4:5)
    call z,e_9b         ;0354 cc 87 05

    call e_8f           ;TODO "BUSY" LED off, then set pio2_dra?
l035ah:
    in a,(pio3_drb)     ;035a db 6d
    bit 4,a             ;Bit 4 = Panel -FORMAT ENABLE
    jr z,hostloop_      ;Jump to host command loop

    ld de,8006h
    ld bc,2000h
    rst 28h             ;TODO: does this load the firmware from the drive?

hostloop_:
;Wait for a command from the host and process it
;
    call e_a7           ;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    ld hl,60bdh         ;036a 21 bd 60
    ld (hl),a           ;036d 77

    in a,(pio3_dra)     ;036e db 6c
    bit 2,a             ;Bit 2 = -ALT SEL
    jr z,l0375h         ;0372 28 01

    inc (hl)            ;0374 34
l0375h:
    call e_86           ;0375 cd 89 04

    ld (6010h),a        ;0378 32 10 60
    cp 11h              ;Is it the command to enter prep mode?
    jr z,l03a0h         ;037d 28 21

    ld a,0fh            ;037f 3e 0f
    ld (6015h),a        ;0381 32 15 60
    ld a,(606fh)        ;0384 3a 6f 60
    dec a               ;0387 3d
    jr z,l0390h         ;0388 28 06
    xor a               ;038a af
    call e_89           ;038b cd 1c 05
    jr hostloop_        ;Jump to host command loop

l0390h:
    ld h,a              ;0390 67
    ld l,a              ;0391 6f
    ld (6012h),hl       ;0392 22 12 60
    call e_8c           ;TODO "BUSY" LED on, then HSXCLR, then set pio2_dra?
    call e_74           ;TODO Send response buffer to host?
    call e_8f           ;TODO "BUSY" LED off, then set pio2_dra?
    jr hostloop_        ;Jump to host command loop

l03a0h:
    call e_86           ;03a0 cd 89 04
    ld hl,606fh         ;03a3 21 6f 60
    cp (hl)             ;03a6 be
    jr z,l03c3h         ;03a7 28 1a
    ld a,01h            ;03a9 3e 01
    call e_89           ;03ab cd 1c 05
    jr nz,hostloop_     ;Jump to host command loop

    ld a,07h            ;03b0 3e 07
    ld (6015h),a        ;03b2 32 15 60
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    call e_8c           ;TODO "BUSY" LED on, then HSXCLR, then set pio2_dra?
    call e_74           ;TODO Send response buffer to host?
    call e_8f           ;TODO "BUSY" LED off, then set pio2_dra?
    jr hostloop_        ;Jump to host command loop

l03c3h:
    call e_8c           ;TODO "BUSY" LED on, then HSXCLR, then set pio2_dra?
    ld bc,0200h         ;03c6 01 00 02
    call hostread_      ;03c9 cd 49 04
    ld de,8000h         ;03cc 11 00 80
    ldir                ;03cf ed b0
    jp 8001h            ;Jump to the prep block code

e_71:
    ld a,(6011h)        ;03d4 3a 11 60
    or 10000000b        ;03d7 f6 80
    ld b,a              ;03d9 47
    ld a,(6015h)        ;03da 3a 15 60
    cp 0ffh             ;03dd fe ff
    ret z               ;03df c8
    or b                ;03e0 b0
    ld (6011h),a        ;03e1 32 11 60

    ld a,0fdh           ;03e4 3e fd
    out (pio3_dra),a    ;03e6 d3 6c

    ld hl,0             ;03e8 21 00 00
    ld (6012h),hl       ;03eb 22 12 60
    jp l06d5h           ;03ee c3 d5 06

e_74:
;called from prep code after every command
;TODO Send response buffer to host?
;
    call e_71           ;03f1 cd d4 03
    ld hl,(6012h)       ;03f4 2a 12 60
    ld a,(60bdh)        ;03f7 3a bd 60
    or a                ;03fa b7
    jr nz,l0416h        ;03fb 20 19
    call e_7a           ;03fd cd 40 04
    ld a,(7411h)        ;0400 3a 11 74
    ld a,l              ;0403 7d
    or h                ;0404 b4
    call nz,jp_hl       ;0405 c4 38 04
l0408h:
    in a,(pio0_drb)     ;0408 db 61
    bit 2,a             ;Bit 2 = -HSXSTB
    jr z,l0408h         ;040c 28 fa
l040eh:
    xor a               ;040e af
    ld (6011h),a        ;040f 32 11 60
    ld a,0d5h           ;0412 3e d5
    jr out_pio2_dra2    ;out (pio2_dra),a then ret
l0416h:
    ld a,03h            ;0416 3e 03
    call sub_04eah      ;0418 cd ea 04
    ld a,h              ;041b 7c
    or l                ;041c b5
    jr z,l040eh         ;041d 28 ef
    ld bc,0ec00h        ;041f 01 00 ec
    add hl,bc           ;0422 09
l0423h:
    ld a,h              ;0423 7c
    cp 0a4h             ;0424 fe a4
    jr z,l040eh         ;0426 28 e6
    cp 64h              ;0428 fe 64
    jr z,l040eh         ;042a 28 e2
    ld a,(hl)           ;042c 7e
    ld (6011h),a        ;042d 32 11 60
    ld a,04h            ;0430 3e 04
    call sub_04eah      ;0432 cd ea 04
    inc hl              ;0435 23
    jr l0423h           ;0436 18 eb

jp_hl:
    jp (hl)             ;0438 e9

e_77:
;called from prep code in _read_byte only
;TODO sets up PIO2 CRB (host data bus port)
;
    ld a,00010111b
    out (pio2_crb),a    ;PIO2 Port B = Host data bus port
    out (pio2_crb),a
    ret

e_7a:
    ld a,(7000h)        ;0440 3a 00 70

sub_0443h:
    in a,(xferstb)      ;0443 db 78

    ld a,11110100b      ;Byte to write to pio2_dra:
                        ;  Bit 7 -DRV.ACK = 1
                        ;  Bit 6 -SYNC    = 1
                        ;  Bit 5 -COMPL   = 1
                        ;  Bit 4 PIO RDY  = 1
                        ;  Bit 3 -HSXFER  = 0
                        ;  Bit 2 -ALT SEL = 1
                        ;  Bit 1 -DRV.ACK = 0
                        ;  Bit 0 BUS DIR  = 0
    jr out_pio2_dra2    ;out (pio2_dra),a then ret

hostread_:
;Read BC bytes of data from the host
;Returns a pointer to the data read in HL
;
    ld hl,8400h         ;0449 21 00 84
    or a                ;044c b7
    sbc hl,bc           ;044d ed 42
    push hl             ;044f e5
    ld a,(60bdh)        ;0450 3a bd 60
    or a                ;0453 b7
    jr nz,l0469h        ;0454 20 13
    ld de,1400h         ;0456 11 00 14
    add hl,de           ;0459 19
    in a,(hsxclr)       ;045a db 74

    ld a,11110101b      ;Bit 3 = -HSXFER
                        ;Bit 1 = -DRV.ACK
    out (pio2_dra),a    ;045e d3 68

    ld a,0d5h           ;0460 3e d5
    call jp_hl          ;0462 cd 38 04
    out (pio2_dra),a    ;0465 d3 68
    pop hl              ;0467 e1
    ret                 ;0468 c9

l0469h:
    ld a,02h            ;0469 3e 02
    call sub_04eah      ;046b cd ea 04
    ld a,(81f7h)        ;046e 3a f7 81
    ld (hl),a           ;0471 77
    inc hl              ;0472 23
    ld a,84h            ;0473 3e 84
    cp h                ;0475 bc
    jr nz,l0469h        ;0476 20 f1
    pop hl              ;0478 e1
    ret                 ;0479 c9

e_80:
;TODO Pulse -HSXFER?
;
    ld a,11000101b      ;Byte to write to pio2_dra:
                        ;  Bit 7 -DRV.ACK = 1
                        ;  Bit 6 -SYNC    = 1
                        ;  Bit 5 -COMPL   = 0
                        ;  Bit 4 PIO RDY  = 0
                        ;  Bit 3 -HSXFER  = 0
                        ;  Bit 2 -ALT SEL = 1
                        ;  Bit 1 -DRV.ACK = 0
                        ;  Bit 0 BUS DIR  = 1
    out (pio2_dra),a

    ld a,11001101b      ;Byte to write to pio2_dra:
                        ;  Bit 7 -DRV.ACK = 1
                        ;  Bit 6 -SYNC    = 1
                        ;  Bit 5 -COMPL   = 0
                        ;  Bit 4 PIO RDY  = 0
                        ;  Bit 3 -HSXFER  = 1
                        ;  Bit 2 -ALT SEL = 1
                        ;  Bit 1 -DRV.ACK = 0
                        ;  Bit 0 BUS DIR  = 1
    jr out_pio2_dra2

e_83:
;TODO HSXCLR then -HSXFER=0?
;
    in a,(hsxclr)

    ld a,11010111b      ;Byte to write to pio2_dra:
                        ;  Bit 7 -DRV.ACK = 1
                        ;  Bit 6 -SYNC    = 1
                        ;  Bit 5 -COMPL   = 0
                        ;  Bit 4 PIO RDY  = 1
                        ;  Bit 3 -HSXFER  = 0
                        ;  Bit 2 -ALT SEL = 1
                        ;  Bit 1 -DRV.ACK = 1
                        ;  Bit 0 BUS DIR  = 1

out_pio2_dra2:
;Writes A to pio2_dra and returns
;
    out (pio2_dra),a
    ret

e_86:
    di                  ;0489 f3

    ld a,11111111b      ;048a 3e ff
    out (pio0_dra),a    ;048c d3 60

    ld a,11111110b      ;Bit 0 = -TIMEOUT DISABLE (UB4:8)
    out (pio3_dra),a    ;0490 d3 6c

    in a,(hsxclr)       ;0492 db 74
    call e_77           ;TODO sets up PIO2 CRB (host data bus port)
    ld a,4fh            ;0497 3e 4f
    out (pio2_crb),a    ;0499 d3 6b
    in a,(pio2_drb)     ;Read data byte from host
    ld a,4ah            ;049d 3e 4a
    out (pio2_crb),a    ;049f d3 6b
    ld a,83h            ;04a1 3e 83
    out (pio2_crb),a    ;04a3 d3 6b
    ld a,11101111b      ;Bit 4 = PIO RDY
    out (pio2_dra),a    ;04a7 d3 68
l04a9h:
    di                  ;04a9 f3
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    ei                  ;04ad fb
    ld b,80h            ;04ae 06 80
l04b0h:
    djnz l04b0h         ;04b0 10 fe
    jr l04a9h           ;04b2 18 f5

    ld a,11001111b      ;Bit 5 = -COMPL
                        ;Bit 4 = PIO RDY
    out (pio2_dra),a    ;04b6 d3 68

    ld a,11111111b      ;04b8 3e ff
    out (pio3_dra),a    ;04ba d3 6c

    ld a,03h            ;04bc 3e 03
    out (pio2_crb),a    ;04be d3 6b
    out (pio2_cra),a    ;04c0 d3 6a
    out (ctc_ch3),a     ;04c2 d3 7f
    in a,(pio2_drb)     ;Read data byte from host
    pop hl              ;04c6 e1
    ei                  ;04c7 fb
    ld hl,60bdh         ;04c8 21 bd 60
    bit 7,(hl)          ;04cb cb 7e
    jr z,l04e4h         ;04cd 28 15
    cp 0ffh             ;04cf fe ff
    jr nz,l04dfh        ;04d1 20 0c
    ld hl,hostloop_     ;TODO Host command loop?
    ex (sp),hl          ;04d6 e3
    call e_7a           ;04d7 cd 40 04
    call sub_0506h      ;04da cd 06 05
    jr l04e4h           ;04dd 18 05
l04dfh:
    push af             ;04df f5
    call e_c0           ;04e0 cd e6 04
    pop af              ;04e3 f1
l04e4h:
    reti                ;04e4 ed 4d

e_c0:
    ld a,01h            ;04e6 3e 01
    jr l04f8h           ;04e8 18 0e
sub_04eah:
    push af             ;04ea f5
    in a,(hsxclr)       ;04eb db 74

    ld a,11110101b      ;Bit 1 = -DRV.ACK
                        ;Bit 3 = -HSXFER
    out (pio2_dra),a    ;04ef d3 68

    ld a,(95f7h)        ;04f1 3a f7 95
    ld a,(7000h)        ;04f4 3a 00 70
    pop af              ;04f7 f1
l04f8h:
    ld (6076h),a        ;04f8 32 76 60
    ld a,0f4h           ;04fb 3e f4
    call e_98           ;04fd cd 9b 05
    call sub_0443h      ;0500 cd 43 04
    ld a,(7411h)        ;0503 3a 11 74
sub_0506h:
    ld a,(7476h)        ;0506 3a 76 74
    ld a,0ffh           ;0509 3e ff
    ld (6077h),a        ;050b 32 77 60
    push bc             ;050e c5
    ld b,06h            ;050f 06 06
l0511h:
    ld a,(7477h)        ;0511 3a 77 74
    djnz l0511h         ;0514 10 fb
    pop bc              ;0516 c1
    ld a,0f0h           ;0517 3e f0
    jp e_98             ;0519 c3 9b 05

e_89:
    or a                ;051c b7
    jr z,w_drv_ack_hi   ;051d 28 18
    cp 02h              ;051f fe 02
    jr z,l0529h         ;0521 28 06
    ld a,(606fh)        ;0523 3a 6f 60
    dec a               ;0526 3d
    jr nz,w_drv_ack_hi  ;0527 20 0e

l0529h:
    ld h,04h            ;0529 26 04
l052bh:
    in a,(pio2_dra)     ;052b db 68
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr z,drv_ack_is_hi  ;Jump if -DRV.ACK is high

    dec hl              ;0531 2b
    ld a,h              ;0532 7c
    or l                ;0533 b5
    jr nz,l052bh        ;0534 20 f5
    ret                 ;0536 c9

w_drv_ack_hi:
;Wait until -DRV.ACK is high
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    in a,(pio2_dra)
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr nz,w_drv_ack_hi  ;Loop if -DRV.ACK is low

drv_ack_is_hi:
    ld a,11111111b      ;0540 3e ff
    out (pio2_dra),a    ;0542 d3 68

w_drv_ack_lo1:
;Wait until -DRV.ACK is low
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2

    in a,(pio2_dra)
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr z,w_drv_ack_lo1   ;Loop if -DRV.ACK is high

                        ;Check it again to be sure it's stable.

    in a,(pio2_dra)
    bit 7,a             ;Z flag = opposite of Bit 7 = -DRV.ACK
    jr z,w_drv_ack_lo1   ;Loop if -DRV.ACK is high

    ld a,0cfh           ;0553 3e cf
    jr out_pio2_dra1    ;out (pio2_dra),a then ret

e_8c:
;TODO "BUSY" LED on, then HSXCLR, then set pio2_dra?
    ld a,01111111b      ;Bit 7 = ACTIVITY LED ("BUSY")
    out (pio0_dra),a    ;0559 d3 60

    in a,(hsxclr)       ;055b db 74

    ld a,11010101b      ;055d 3e d5

out_pio2_dra1:
;Writes A to pio2_dra and returns
;
    out (pio2_dra),a
    ret

e_8f:
;TODO "BUSY" LED off, then set pio2_dra?
    ld a,11111111b      ;Bit 7 = ACTIVITY LED ("BUSY")
    out (pio0_dra),a    ;0564 d3 60

    ld a,0dfh           ;0566 3e df
    jr out_pio2_dra1    ;out (pio2_dra),a then ret

e_92:
    di                  ;056a f3
    ld a,b              ;056b 78
    or a                ;056c b7
    ld a,01h            ;056d 3e 01
    jr z,l0579h         ;056f 28 08
    ld a,0eh            ;0571 3e 0e
    out (ctc_ch0),a     ;0573 d3 7c
    ld a,c              ;0575 79
    out (ctc_ch3),a     ;0576 d3 7f
    ld a,b              ;0578 78
l0579h:
    out (ctc_ch3),a     ;0579 d3 7f
    ei                  ;057b fb
    ret                 ;057c c9

fatal_:
;Fatal error has occurred.  Halt until reset.
;
    di                  ;Disable Interrupts

    ld a,11111101b      ;Bit 1 = -UNIT SELECT 1 (UB4:7)
    out (pio3_dra),a

    ld a,11011111b      ;Bit 5 = -COMPL
    out (pio2_dra),a

    halt                ;Halt until reset (interrupts are disabled)

e_9b:
    ld a,d              ;0587 7a
    cp 0ffh             ;0588 fe ff
    jr z,l0593h         ;058a 28 07
    and 00000111b       ;058c e6 07
    or 11010000b        ;058e f6 d0
    call e_98           ;0590 cd 9b 05
l0593h:
    ld a,e              ;0593 7b
    cp 0ffh             ;0594 fe ff
    ret z               ;0596 c8
    and 00000111b       ;0597 e6 07
    or 0e0h             ;0599 f6 e0

e_98:
    ld (6075h),a        ;059b 32 75 60
    ld a,(7000h)        ;059e 3a 00 70
    in a,(xferstb)      ;05a1 db 78
    ld a,11010000b      ;05a3 3e d0
    out (pio2_dra),a    ;05a5 d3 68
    ld a,(7475h)        ;05a7 3a 75 74
    ld a,11110000b      ;05aa 3e f0
    out (pio2_dra),a    ;05ac d3 68
    ld a,11010000b      ;05ae 3e d0
    out (pio2_dra),a    ;05b0 d3 68
    in a,(hsxclr)       ;05b2 db 74
    ret                 ;05b4 c9

    djnz l05c9h         ;05b5 10 12
    pop bc              ;05b7 c1
    jr l05c5h           ;05b8 18 0b
    ld b,05h            ;05ba 06 05
l05bch:
    in a,(pio2_dra)     ;05bc db 68
    bit 6,a             ;Bit 6 = -SYNC
    jr nz,l05c9h        ;05c0 20 07

    djnz l05bch         ;05c2 10 f8
    pop af              ;05c4 f1
l05c5h:
    ld a,03h            ;05c5 3e 03
    out (pio2_cra),a    ;05c7 d3 6a
l05c9h:
    ei                  ;05c9 fb
    reti                ;05ca ed 4d

    in a,(pio2_drb)     ;Read data byte from host
    cp d                ;05ce ba
    jp nz,l0608h        ;05cf c2 08 06

    call sub_06bch      ;05d2 cd bc 06
    ld c,pio2_drb       ;05d5 0e 69
    ei                  ;05d7 fb
    in a,(pio2_drb)     ;Read data byte from host
    ld (hl),a           ;05da 77
    cpl                 ;05db 2f
    or 00h              ;05dc f6 00
    or 00h              ;05de f6 00
    in b,(c)            ;05e0 ed 40
    cp b                ;05e2 b8
    jr z,l0601h         ;05e3 28 1c
    jr l0608h           ;05e5 18 21
    in a,(pio2_drb)     ;Read data byte from host
    cp d                ;05e9 ba
    jp nz,l0608h        ;05ea c2 08 06
    nop                 ;05ed 00
    nop                 ;05ee 00
    ei                  ;05ef fb
    call sub_06bch      ;05f0 cd bc 06
    in a,(pio2_drb)     ;Read data byte from host
    cp c                ;05f5 b9
    jr nz,l0608h        ;05f6 20 10
    or 00h              ;05f8 f6 00
    or 00h              ;05fa f6 00
    in a,(pio2_drb)     ;Read data byte from host
    cp b                ;05fe b8
    jr nz,l0608h        ;05ff 20 07
l0601h:
    exx                 ;0601 d9
    ld a,54h            ;0602 3e 54
    out (pio2_cra),a    ;0604 d3 6a
    reti                ;0606 ed 4d
l0608h:
    dec e               ;0608 1d
    jr z,l060eh         ;0609 28 03
    ei                  ;060b fb
    reti                ;060c ed 4d
l060eh:
    pop af              ;060e f1
    ld a,03h            ;060f 3e 03
    out (pio2_cra),a    ;0611 d3 6a
    out (ctc_ch3),a     ;0613 d3 7f
    dec a               ;0615 3d
    ei                  ;0616 fb
    reti                ;0617 ed 4d
    ini                 ;0619 ed a2
    call sub_06bdh      ;061b cd bd 06
    jp z,l063ch         ;061e ca 3c 06
    pop af              ;0621 f1
    nop                 ;0622 00
    ini                 ;0623 ed a2
    nop                 ;0625 00
    or 00h              ;0626 f6 00
    push de             ;0628 d5
    ini                 ;0629 ed a2
    or 00h              ;062b f6 00
    or 00h              ;062d f6 00
    or 00h              ;062f f6 00
    ini                 ;0631 ed a2
    or 00h              ;0633 f6 00
    or 00h              ;0635 f6 00
    ei                  ;0637 fb
    ini                 ;0638 ed a2
    reti                ;063a ed 4d
l063ch:
    in d,(c)            ;063c ed 50
    nop                 ;063e 00
    nop                 ;063f 00
    nop                 ;0640 00
    nop                 ;0641 00
    nop                 ;0642 00
    nop                 ;0643 00
    nop                 ;0644 00
    in e,(c)            ;0645 ed 58
    ld a,0e9h           ;0647 3e e9
    out (pio2_dra),a    ;0649 d3 68
    in b,(c)            ;064b ed 40
    in b,(c)            ;064d ed 40
    ld a,0edh           ;064f 3e ed
    out (pio2_dra),a    ;0651 d3 68
    ld a,03h            ;0653 3e 03
    out (pio2_cra),a    ;0655 d3 6a
    out (ctc_ch3),a     ;0657 d3 7f
    pop af              ;0659 f1
    ld (ix-09h),d       ;065a dd 72 f7
    ld (ix-08h),e       ;065d dd 73 f8
    ld a,b              ;0660 78
    and 00000001b       ;0661 e6 01
    ld (ix-06h),a       ;0663 dd 77 fa
    ei                  ;0666 fb
    reti                ;0667 ed 4d
    or 00h              ;0669 f6 00
    or 00h              ;066b f6 00
    or 00h              ;066d f6 00
    outi                ;066f ed a3
    nop                 ;0671 00
    nop                 ;0672 00
    outi                ;0673 ed a3
    or 00h              ;0675 f6 00
    or 00h              ;0677 f6 00
    outi                ;0679 ed a3
    nop                 ;067b 00
    nop                 ;067c 00
    or 00h              ;067d f6 00
    or 00h              ;067f f6 00
    outi                ;0681 ed a3
    nop                 ;0683 00
    nop                 ;0684 00
    nop                 ;0685 00
    ei                  ;0686 fb
    outi                ;0687 ed a3
    jr z,l068dh         ;0689 28 02
    reti                ;068b ed 4d
l068dh:
    call sub_06bch      ;068d cd bc 06
    ld a,0e8h           ;0690 3e e8
    out (pio2_dra),a    ;0692 d3 68
    out (c),d           ;0694 ed 51
    ld a,0ech           ;0696 3e ec
    out (pio2_dra),a    ;0698 d3 68
    nop                 ;069a 00
    nop                 ;069b 00
    nop                 ;069c 00
    out (c),a           ;069d ed 79
    nop                 ;069f 00
    nop                 ;06a0 00
    out (c),a           ;06a1 ed 79
    ld a,03h            ;06a3 3e 03
    out (pio2_cra),a    ;06a5 d3 6a
    ld a,0e8h           ;06a7 3e e8
    out (pio2_dra),a    ;06a9 d3 68
    out (c),e           ;06ab ed 59
    ld a,0ech           ;06ad 3e ec
    out (pio2_dra),a    ;06af d3 68
    call sub_06bch      ;06b1 cd bc 06
    nop                 ;06b4 00
    nop                 ;06b5 00
    out (c),a           ;06b6 ed 79
    pop bc              ;06b8 c1
    ei                  ;06b9 fb
    reti                ;06ba ed 4d
sub_06bch:
    nop                 ;06bc 00
sub_06bdh:
    nop                 ;06bd 00
    nop                 ;06be 00
    ret                 ;06bf c9

sub_06c0h:
;called from e_10, e_18, e_20
;
    ld hl,6011h         ;06c0 21 11 60
    set 5,(hl)          ;06c3 cb ee
    ld a,(6014h)        ;06c5 3a 14 60
    ld hl,6050h         ;06c8 21 50 60
l06cbh:
    rlca                ;06cb 07
    ld c,a              ;06cc 4f
    ld b,00h            ;06cd 06 00
    add hl,bc           ;06cf 09
    inc (hl)            ;06d0 34
    ret nz              ;06d1 c0
    inc hl              ;06d2 23
    inc (hl)            ;06d3 34
    ret                 ;06d4 c9
l06d5h:
    ld a,(6015h)        ;06d5 3a 15 60
    ld hl,6028h         ;06d8 21 28 60
    jr l06cbh           ;06db 18 ee

e_30:
;called from prep code in verify_drive only
    ld a,(head_sec)     ;06dd 3a fd 81
    ld b,a              ;06e0 47
    in a,(pio0_drb)     ;06e1 db 61
    and 10001111b       ;06e3 e6 8f
    bit 5,b             ;Bit 5 = ST-412 HEAD SEL 2^1
    jr z,l06ebh         ;06e7 28 02
    set 4,a             ;Bit 4 = ST-412 HEAD SEL 2^0
l06ebh:
    bit 6,b             ;Bit 6 = ST-412 HEAD SEL 2^2
    jr z,l06f1h         ;06ed 28 02
    set 5,a             ;Bit 5 = ST-412 HEAD SEL 2^1
l06f1h:
    bit 7,b             ;Bit 7 = ST-412 REDUCE WR CURRENT
    jr z,l06f7h         ;06f3 28 02
    set 6,a             ;Bit 6 = ST-412 HEAD SEL 2^2
l06f7h:
    out (pio0_drb),a    ;06f7 d3 61

    ld a,b              ;06f9 78
    and 00011111b       ;Bit 7 = ST-412 REDUCE WR CURRENT
                        ;Bit 6 = ST-412 HEAD SEL 2^2
                        ;Bit 5 = ST-412 HEAD SEL 2^1
    ld b,a              ;06fc 47
    ld a,14h            ;06fd 3e 14
    sub b               ;06ff 90
    ld b,a              ;0700 47
l0701h:
    in a,(ctc_ch0)      ;0701 db 7c
    cp b                ;0703 b8
    jr z,l0701h         ;0704 28 fb
l0706h:
    in a,(ctc_ch0)      ;0706 db 7c
    cp b                ;0708 b8
    jr nz,l0706h        ;0709 20 fb
    ld a,0ffh           ;070b 3e ff
l070dh:
    ld (6014h),a        ;070d 32 14 60
    ret                 ;0710 c9

sub_0711h:
    ld hl,(cylinder)    ;0711 2a fe 81
    push hl             ;0714 e5
    call e_23           ;0715 cd c7 0a
    pop hl              ;0718 e1
    ld (cylinder),hl    ;0719 22 fe 81
    jp e_a4             ;071c c3 41 0c

e_10:
;called from prep code in verify_drive only
;
;Sets Z flag on success, clears Z flag on failure
;
    xor a               ;071f af
    ld (60b9h),a        ;0720 32 b9 60
    ld a,03h            ;0723 3e 03
    ld (6026h),a        ;0725 32 26 60
    ld a,10h            ;0728 3e 10
    ld (6027h),a        ;072a 32 27 60
l072dh:
    ld hl,l073bh        ;072d 21 3b 07
    ld (6102h),hl       ;0730 22 02 61
    ld (6100h),sp       ;0733 ed 73 00 61
    call sub_0771h      ;0737 cd 71 07
    ret z               ;073a c8
l073bh:
    call sub_06c0h      ;073b cd c0 06
    cp 08h              ;073e fe 08
    jr z,l075fh         ;0740 28 1d
    cp 0ah              ;0742 fe 0a
    jr nz,l074ch        ;0744 20 06
    ld hl,(61feh)       ;0746 2a fe 61
    ld (600ch),hl       ;0749 22 0c 60
l074ch:
    ld hl,6026h         ;074c 21 26 60
    dec (hl)            ;074f 35
    jr z,l0757h         ;0750 28 05
    call sub_0711h      ;0752 cd 11 07
    jr l072dh           ;0755 18 d6
l0757h:
    call e_a4           ;0757 cd 41 0c
    ret nz              ;075a c0
    ld a,0ah            ;075b 3e 0a
    jr l0767h           ;075d 18 08
l075fh:
    ld hl,6027h         ;075f 21 27 60
    dec (hl)            ;0762 35
    jr nz,l072dh        ;0763 20 c8
    ld a,0bh            ;0765 3e 0b
l0767h:
    ld (6015h),a        ;0767 32 15 60
    or a                ;076a b7
l076bh:
    ld hl,6006h         ;076b 21 06 60
    res 7,(hl)          ;076e cb be
    ret                 ;0770 c9
sub_0771h:
    call sub_0976h      ;0771 cd 76 09
    call e_a7           ;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    bit 7,(hl)          ;0777 cb 7e
    call z,e_0b         ;0779 cc 43 0a
    call e_a4           ;077c cd 41 0c
    ret nz              ;077f c0
    rst 30h             ;0780 f7
    call e_13           ;0781 cd 6f 08
    call sub_0c49h      ;0784 cd 49 0c
    ret nz              ;0787 c0
    call sub_0993h      ;0788 cd 93 09
    ret nz              ;078b c0
    call sub_0987h      ;078c cd 87 09
    ld a,0ch            ;078f 3e 0c
    jr nz,l0767h        ;0791 20 d4
sub_0793h:
    ld hl,6006h         ;0793 21 06 60
    set 7,(hl)          ;0796 cb fe
    ret                 ;0798 c9

e_18:
;called from prep code in verify_drive only
;
;Sets Z flag on success, clears Z flag on failure
;
    ld a,03h            ;0799 3e 03
    ld (6024h),a        ;079b 32 24 60
l079eh:
    ld hl,l07afh        ;079e 21 af 07
    ld (6102h),hl       ;07a1 22 02 61
    ld (6100h),sp       ;07a4 ed 73 00 61
    call sub_07e8h      ;07a8 cd e8 07
    call sub_0c49h      ;07ab cd 49 0c
    ret z               ;07ae c8
l07afh:
    call sub_06c0h      ;07af cd c0 06
    ld hl,6024h         ;07b2 21 24 60
    dec (hl)            ;07b5 35
    jr nz,l079eh        ;07b6 20 e6
    call e_a4           ;07b8 cd 41 0c
    jr nz,l076bh        ;07bb 20 ae
    ld a,08h            ;07bd 3e 08
    jr l0767h           ;07bf 18 a6

e_20:
;called from prep code in writ_firm_blk only
;
    ld a,03h            ;07c1 3e 03
    ld (6025h),a        ;07c3 32 25 60
l07c6h:
    call e_18           ;07c6 cd 99 07
    call e_a4           ;07c9 cd 41 0c
    ret nz              ;07cc c0
    call e_10           ;07cd cd 1f 07
    call e_a4           ;07d0 cd 41 0c
    ret z               ;07d3 c8
    ld a,06h            ;07d4 3e 06
    ld (6014h),a        ;07d6 32 14 60
    call sub_06c0h      ;07d9 cd c0 06
    ld hl,6025h         ;07dc 21 25 60
    dec (hl)            ;07df 35
    jr nz,l07c6h        ;07e0 20 e4
    ld hl,6011h         ;07e2 21 11 60
    set 6,(hl)          ;07e5 cb f6
    ret                 ;07e7 c9
sub_07e8h:
    call sub_0976h      ;07e8 cd 76 09
    bit 7,(hl)          ;07eb cb 7e
    jr nz,l083bh        ;07ed 20 4c
    ld a,03h            ;07ef 3e 03
    ld (601ch),a        ;07f1 32 1c 60
    ld a,03h            ;07f4 3e 03
    ld (6021h),a        ;07f6 32 21 60
l07f9h:
    call sub_0a0dh      ;07f9 cd 0d 0a
    call e_a4           ;07fc cd 41 0c
    jr nz,l0811h        ;07ff 20 10
    call sub_09a4h      ;0801 cd a4 09
    call sub_0c49h      ;0804 cd 49 0c
    jr z,l081ch         ;0807 28 13
    ld hl,601ch         ;0809 21 1c 60
    dec (hl)            ;080c 35
    jr z,l0835h         ;080d 28 26
    jr l0816h           ;080f 18 05
l0811h:
    ld hl,6021h         ;0811 21 21 60
    dec (hl)            ;0814 35
    ret z               ;0815 c8
l0816h:
    call sub_0711h      ;0816 cd 11 07
    ret nz              ;0819 c0
    jr l07f9h           ;081a 18 dd
l081ch:
    call sub_0993h      ;081c cd 93 09
    jr z,l0838h         ;081f 28 17
    call sub_06c0h      ;0821 cd c0 06
    ld hl,(61feh)       ;0824 2a fe 61
    ld (600ch),hl       ;0827 22 0c 60
    ld hl,6021h         ;082a 21 21 60
    dec (hl)            ;082d 35
    jr nz,l0816h        ;082e 20 e6
    ld a,03h            ;0830 3e 03
l0832h:
    ld (6015h),a        ;0832 32 15 60
l0835h:
    jp e_a4             ;0835 c3 41 0c
l0838h:
    call sub_0793h      ;0838 cd 93 07
l083bh:
    call set_spares     ;083b cd 66 02
    rst 30h             ;083e f7

e_1b:
    in a,(pio3_dra)     ;083f db 6c
    set 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;0843 d3 6c

    ld a,02h            ;0845 3e 02
    ld (81fch),a        ;0847 32 fc 81
    ld a,0b8h           ;084a 3e b8
    jr l0871h           ;084c 18 23
    call sub_08f7h      ;TODO turn "BUSY" LED on, pio0_cra, ei, reti
    pop af              ;0851 f1
    call 8dfch          ;0852 cd fc 8d

    ld a,11111111b      ;0855 3e ff
    out (pio0_dra),a    ;0857 d3 60

    in a,(pio3_dra)     ;0859 db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;085d d3 6c

    ld a,23h            ;085f 3e 23
    out (ctc_ch3),a     ;0861 d3 7f
    ld hl,0             ;0863 21 00 00
    ld (6100h),hl       ;0866 22 00 61
    call sub_0c49h      ;0869 cd 49 0c
    ret z               ;086c c8
    scf                 ;086d 37
    ret                 ;086e c9

e_13:
;called from prep code in verify_drive only
;
    ld a,40h            ;086f 3e 40
l0871h:
    di                  ;0871 f3
    out (pio0_cra),a    ;0872 d3 62
    out (ctc_ch0),a     ;0874 d3 7c
    ld a,0a7h           ;0876 3e a7
    out (ctc_ch3),a     ;0878 d3 7f
    ld a,4eh            ;087a 3e 4e
    out (ctc_ch3),a     ;087c d3 7f
    ld a,97h            ;087e 3e 97
    out (pio0_cra),a    ;0880 d3 62
    ld a,0f7h           ;0882 3e f7
    out (pio0_cra),a    ;0884 d3 62
    ei                  ;0886 fb
l0887h:
    halt                ;0887 76

    jr l0887h           ;0888 18 fd
    call sub_08f7h      ;TODO turn "BUSY" LED on, pio0_cra, ei, reti
    pop af              ;088d f1

    in a,(pio3_dra)     ;088e db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;0892 d3 6c

    nop                 ;0894 00
    nop                 ;0895 00
    nop                 ;0896 00
    nop                 ;0897 00
    nop                 ;0898 00
    call 6dfdh          ;0899 cd fd 6d
    ld a,(6014h)        ;089c 3a 14 60
    cp 0ffh             ;089f fe ff
    jr nz,l08a7h        ;08a1 20 04

    in a,(pio0_dra)     ;08a3 db 60
    and 00010000b       ;Bit 4 = ST-412 CRC ERROR

l08a7h:
    ld a,11111111b      ;08a7 3e ff
    out (pio0_dra),a    ;08a9 d3 60

    ld a,23h            ;08ab 3e 23
    out (ctc_ch3),a     ;08ad d3 7f

    ld hl,0             ;08af 21 00 00
    ld (6100h),hl       ;08b2 22 00 61
    ret z               ;08b5 c8
    call set_spares     ;08b6 cd 66 02
    call sub_0c49h      ;08b9 cd 49 0c
    scf                 ;08bc 37
    ret nz              ;08bd c0
    ld a,04h            ;08be 3e 04
    jp l070dh           ;08c0 c3 0d 07
    ld a,08h            ;08c3 3e 08
    jr l08c9h           ;08c5 18 02
    ld a,09h            ;08c7 3e 09
l08c9h:
    ld (6014h),a        ;08c9 32 14 60
    pop af              ;08cc f1
    scf                 ;08cd 37

    in a,(pio3_dra)     ;08ce db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;08d2 d3 6c

    ld a,11111111b      ;08d4 3e ff
    out (pio0_dra),a    ;08d6 d3 60

    call sub_0b0ah      ;08d8 cd 0a 0b
    push hl             ;08db e5
    ld hl,(6100h)       ;08dc 2a 00 61
    ld a,h              ;08df 7c
    or l                ;08e0 b5
    pop hl              ;08e1 e1
    jr z,l08ffh         ;08e2 28 1b
    call 8ffch          ;08e4 cd fc 8f
    ld sp,(6100h)       ;08e7 ed 7b 00 61
    ld hl,(6102h)       ;08eb 2a 02 61
    push hl             ;08ee e5
    ld hl,0             ;08ef 21 00 00
    ld (6100h),hl       ;08f2 22 00 61
    jr l08ffh           ;08f5 18 08

sub_08f7h:
;TODO turn "BUSY" LED on, pio0_cra, ei, reti
;
    ld a,01111111b      ;Bit 7 = ACTIVITY LED ("BUSY")
    out (pio0_dra),a    ;Turn "BUSY" on (low state turns LED on)
                        ;  Set other bits to ??

    ld a,03h            ;08fb 3e 03
    out (pio0_cra),a    ;08fd d3 62
l08ffh:
    ei                  ;08ff fb
    reti                ;0900 ed 4d

e_aa:
    ld a,(60b6h)        ;0902 3a b6 60
    ld (head_sec),a     ;0905 32 fd 81
    ld hl,(60b7h)       ;0908 2a b7 60
    ld (cylinder),hl    ;090b 22 fe 81

    rst 10h             ;Read the sector
    ret nz              ;Failed?  Return.
    call sub_0944h      ;0910 cd 44 09
    ldir                ;copy using hl/de/bc set up sub_0944h
    ret z               ;Return if 60bbh is zero

    rst 10h             ;Read the sector
    ret nz              ;Failed?  Return.
    call sub_0944h      ;0918 cd 44 09
    ld d,0a2h           ;091b 16 a2
    ldir                ;copy using hl/de/bc set up sub_0944h
    ret z               ;091f c8

    rst 10h             ;Read the sector
    ret nz              ;Failed?  Return.
    jr sub_0944h        ;0922 18 20

e_ad:
    ld a,(60b6h)        ;0924 3a b6 60
    ld (head_sec),a     ;0927 32 fd 81
    ld hl,(60b7h)       ;092a 2a b7 60
    ld (cylinder),hl    ;092d 22 fe 81

    rst 18h             ;0930 df
    ret nz              ;Failed?  Return.
    call sub_0944h      ;0932 cd 44 09
    ret z               ;Return if 60bbh is zero

    ld h,0a2h           ;0936 26 a2
    ldir                ;copy using hl/de/bc set up sub_0944h
    rst 18h             ;093a df
    ret nz              ;Failed?  Return.

    call sub_0944h      ;093c cd 44 09
    ret z               ;Return if 60bbh is zero
    ldir                ;copy using hl/de/bc set up sub_0944h

    rst 18h             ;0942 df
    ret nz              ;Failed?  Return.
                        ;Fall through into sub_0944h

sub_0944h:
;called from e_aa, e_ad
;
;calls e_b0, decrements 60bbh, sets hl/de/bc for ldir,
;sets a with 60bbh
;
    call e_b0           ;TOOD e_b0?

                        ;Decrement 60bbh:
    ld a,(60bbh)        ;  A = value at 60bbh
    dec a               ;  Decrement A
    ld (60bbh),a        ;  Save A in 60bbh

                        ;Set up registers for LDIR instruction:
    ld hl,6200h         ;  HL = start address
    ld de,8200h         ;  DE = destination address
    ld bc,0200h         ;  BC = number of bytes to copy
    ret

sub_0958h:
    ld hl,6017h         ;0958 21 17 60
    ld a,(head_sec)     ;095b 3a fd 81
    and 00011111b       ;095e e6 1f
    cp (hl)             ;0960 be
    jr nc,l096fh        ;0961 30 0c
    ld de,(cylinder)    ;0963 ed 5b fe 81
    ld hl,(last_cyl)    ;0967 2a 02 60
    or a                ;096a b7
    sbc hl,de           ;096b ed 52
    ex de,hl            ;096d eb
    ret nc              ;096e d0
l096fh:
    ld a,0eh            ;096f 3e 0e
    ld (6015h),a        ;0971 32 15 60
    scf                 ;0974 37
    ret                 ;0975 c9
sub_0976h:
    ld hl,(cylinder)    ;0976 2a fe 81
    ld bc,(600ch)       ;0979 ed 4b 0c 60
    or a                ;097d b7
    sbc hl,bc           ;097e ed 42
    ld hl,6006h         ;0980 21 06 60
    ret z               ;0983 c8
    res 7,(hl)          ;0984 cb be
    ret                 ;0986 c9
sub_0987h:
    ld hl,head_sec      ;0987 21 fd 81
    ld a,(spares)       ;098a 3a fd 61
    cp (hl)             ;098d be
    ret z               ;098e c8
    ld a,0bh            ;098f 3e 0b
    jr l09a0h           ;0991 18 0d
sub_0993h:
    ld hl,(cylinder)    ;0993 2a fe 81
    ld de,(61feh)       ;0996 ed 5b fe 61
    or a                ;099a b7
    sbc hl,de           ;099b ed 52
    ret z               ;099d c8
    ld a,05h            ;099e 3e 05
l09a0h:
    ld (6014h),a        ;09a0 32 14 60
    ret                 ;09a3 c9
sub_09a4h:
    ld a,1eh            ;09a4 3e 1e
    ld (6020h),a        ;09a6 32 20 60
l09a9h:
    call e_a7           ;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    in a,(ctc_ch0)      ;09ac db 7c
    ld c,a              ;09ae 4f
l09afh:
    in a,(ctc_ch0)      ;09af db 7c
    cp c                ;09b1 b9
    jr z,l09afh         ;09b2 28 fb
    in a,(ctc_ch0)      ;09b4 db 7c
    ld e,a              ;09b6 5f
    exx                 ;09b7 d9
    ld bc,(63fdh)       ;09b8 ed 4b fd 63
    ld de,(63feh)       ;09bc ed 5b fe 63
    ld a,50h            ;09c0 3e 50
    jp l0871h           ;09c2 c3 71 08
    call sub_08f7h      ;TODO turn "BUSY" LED on, pio0_cra, ei, reti
    pop af              ;09c8 f1

    in a,(pio3_dra)     ;09c9 db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;09cd d3 6c

    nop                 ;09cf 00
    nop                 ;09d0 00
    nop                 ;09d1 00
    nop                 ;09d2 00
    nop                 ;09d3 00
    call 6ffdh          ;09d4 cd fd 6f

    ld a,11111111b      ;09d7 3e ff
    out (pio0_dra),a    ;09d9 d3 60

    ld a,23h            ;09db 3e 23
    out (ctc_ch3),a     ;09dd d3 7f
    ld a,(63fdh)        ;09df 3a fd 63
    ld (spares),a       ;09e2 32 fd 61
    ld hl,(63feh)       ;09e5 2a fe 63
    ld (61feh),hl       ;09e8 22 fe 61
    ld (63fdh),bc       ;09eb ed 43 fd 63
    ld (63feh),de       ;09ef ed 53 fe 63
    exx                 ;09f3 d9
    ld a,14h            ;09f4 3e 14
    sub e               ;09f6 93
    ld e,a              ;09f7 5f
    ld a,(spares)       ;09f8 3a fd 61
    and 00011111b       ;09fb e6 1f
    cp e                ;09fd bb
    ret z               ;09fe c8
    ld hl,6020h         ;09ff 21 20 60
    dec (hl)            ;0a02 35
    jr nz,l09a9h        ;0a03 20 a4
    ld a,0bh            ;0a05 3e 0b
    ld (6014h),a        ;0a07 32 14 60
    jp sub_06c0h        ;0a0a c3 c0 06
sub_0a0dh:
    ld a,03h            ;0a0d 3e 03
    ld (601dh),a        ;0a0f 32 1d 60
    ld a,03h            ;0a12 3e 03
    ld (601eh),a        ;0a14 32 1e 60
l0a17h:
    call e_0b           ;0a17 cd 43 0a
    call sub_0c49h      ;0a1a cd 49 0c
    ret z               ;0a1d c8
    call sub_06c0h      ;0a1e cd c0 06
    cp 04h              ;0a21 fe 04
    jr nz,l0a37h        ;0a23 20 12
    ld hl,601dh         ;0a25 21 1d 60
    dec (hl)            ;0a28 35
    jr nz,l0a31h        ;0a29 20 06
    ld a,01h            ;0a2b 3e 01
    ld (6015h),a        ;0a2d 32 15 60
    ret                 ;0a30 c9
l0a31h:
    call sub_0711h      ;0a31 cd 11 07
    ret nz              ;0a34 c0
    jr l0a17h           ;0a35 18 e0
l0a37h:
    ld hl,601eh         ;0a37 21 1e 60
    dec (hl)            ;0a3a 35
    jr nz,l0a31h        ;0a3b 20 f4
    ld a,02h            ;0a3d 3e 02
l0a3fh:
    ld (6015h),a        ;0a3f 32 15 60
    ret                 ;0a42 c9

e_0b:
;called from prep code in verify_drive only
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    call e_a7           ;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
    call sub_0958h      ;0a49 cd 58 09
    ret c               ;0a4c d8
    ld hl,(cylinder)    ;0a4d 2a fe 81
    ld (6004h),hl       ;0a50 22 04 60
sub_0a53h:
    in a,(pio3_dra)     ;0a53 db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;0a57 d3 6c

    ld de,(600ch)       ;0a59 ed 5b 0c 60
    ld hl,(6004h)       ;0a5d 2a 04 60
    or a                ;0a60 b7
    sbc hl,de           ;0a61 ed 52
    ret z               ;0a63 c8
    jp m,l0a6dh         ;0a64 fa 6d 0a
    in a,(pio0_drb)     ;0a67 db 61
    set 1,a             ;Bit 1 = ST-412 DIRECTION IN
    jr l0a78h           ;0a6b 18 0b
l0a6dh:
    in a,(pio0_drb)     ;0a6d db 61
    res 1,a             ;Bit 1 = ST-412 DIRECTION IN
    ex de,hl            ;0a71 eb
    ld hl,0             ;0a72 21 00 00
    or a                ;0a75 b7
    sbc hl,de           ;0a76 ed 52
l0a78h:
    out (pio0_drb),a    ;Write data byte to host
    call sub_0b17h      ;0a7a cd 17 0b
    ld hl,(6004h)       ;0a7d 2a 04 60
    ld (600ch),hl       ;0a80 22 0c 60
    ret                 ;0a83 c9

e_c3:
    ld a,03h            ;0a84 3e 03
    out (pio2_cra),a    ;0a86 d3 6a
    out (pio2_crb),a    ;0a88 d3 6b

    xor a               ;0a8a af
    ld (6011h),a        ;0a8b 32 11 60
    ld hl,0             ;0a8e 21 00 00
    ld (6012h),hl       ;0a91 22 12 60

    call e_74           ;TODO Send response buffer to host?
    in a,(hsxclr)       ;0a97 db 74
    call e_77           ;TODO sets up PIO2 CRB (host data bus port)
    ld a,4fh            ;0a9c 3e 4f
    out (pio2_crb),a    ;0a9e d3 6b
    in a,(pio2_drb)     ;Read data byte from host
    ld a,83h            ;0aa2 3e 83
    out (pio2_crb),a    ;0aa4 d3 6b
    ld a,0efh           ;0aa6 3e ef
    out (pio2_dra),a    ;0aa8 d3 68
    call e_8f           ;TODO "BUSY" LED off, then set pio2_dra?
    ld hl,0149h         ;0aad 21 49 01
    ld (6004h),hl       ;0ab0 22 04 60
    call sub_0a53h      ;0ab3 cd 53 0a
    ld a,03h            ;0ab6 3e 03
    out (ctc_ch2),a     ;0ab8 d3 7e

    in a,(pio3_dra)     ;0aba db 6c
    set 0,a             ;Bit 0 = -TIMEOUT DISABLE (UB4:8)
    out (pio3_dra),a    ;0abe d3 6c

                        ;Turn the "BUSY" LED off:
    in a,(pio0_dra)     ;  A = read port state
    set 7,a             ;  Turn on bit 7 (high state turns LED off)
    out (pio0_dra),a    ;  Write new port state

    halt                ;0ac6 76

e_23:
    call wait_ready     ;Do ??? and wait until READY goes low

    in a,(pio3_dra)     ;0aca db 6c
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;0ace d3 6c

    in a,(pio0_drb)     ;0ad0 db 61
    set 1,a             ;Bit 1 = ST-412 DIRECTION IN
    out (pio0_drb),a    ;0ad4 d3 61

    ld hl,000ch         ;0ad6 21 0c 00
    call sub_0b17h      ;0ad9 cd 17 0b

    in a,(pio0_drb)     ;0adc db 61
    res 1,a             ;Bit 1 = ST-412 DIRECTION IN
    out (pio0_drb),a    ;0ae0 d3 61

l0ae2h:
    in a,(pio3_dra)     ;0ae2 db 6c
    bit 6,a             ;Bit 6 = ST-412 -TRACK 00
    jr z,l0afah         ;0ae6 28 12

    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2

    in a,(pio0_drb)
    set 3,a             ;Bit 3 = ST-412 STEP
    out (pio0_drb),a
    res 3,a             ;Bit 3 = ST-412 STEP
    out (pio0_drb),a

    call wait_seek_cmpl ;0af5 cd 4e 0b
    jr l0ae2h           ;0af8 18 e8

l0afah:
    xor a               ;0afa af
    ld (head_sec),a     ;0afb 32 fd 81
    ld hl,0             ;0afe 21 00 00
    ld (600ch),hl       ;0b01 22 0c 60
    ret                 ;0b04 c9

l0b05:
    ld a,02h            ;0b05 3e 02
    ld (6014h),a        ;0b07 32 14 60
sub_0b0ah:
    ld a,01h            ;0b0a 3e 01
    out (ctc_ch3),a     ;0b0c d3 7f
    ld a,03h            ;0b0e 3e 03
    out (pio0_cra),a    ;0b10 d3 62
    xor a               ;0b12 af
    ld (6006h),a        ;0b13 32 06 60
    ret                 ;0b16 c9

sub_0b17h:
    ld a,h              ;0b17 7c
    or l                ;0b18 b5
    jr z,l0b33h         ;0b19 28 18
l0b1bh:
    push hl             ;0b1b e5
    ld bc,305           ;305 = Last cylinder number?
    or a                ;0b1f b7
    sbc hl,bc           ;0b20 ed 42
    jr z,l0b2fh         ;0b22 28 0b
    jp m,l0b2fh         ;0b24 fa 2f 0b
    pop de              ;0b27 d1
    push hl             ;0b28 e5
    call step_bc_times  ;0b29 cd 34 0b
    pop hl              ;0b2c e1
    jr l0b1bh           ;0b2d 18 ec
l0b2fh:
    pop bc              ;0b2f c1
    call step_bc_times  ;0b30 cd 34 0b
l0b33h:
    ret                 ;0b33 c9

step_bc_times:
;Pulse the STEP line BC times
;
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
l0b37h:
    in a,(pio0_drb)
    set 3,a             ;Bit 3 = ST-412 STEP
    out (pio0_drb),a
    res 3,a             ;Bit 3 = ST-412 STEP
    out (pio0_drb),a
    ex (sp),hl          ;Waste time
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    dec bc              ;Decrement BC
    ld a,b
    or c
    jr nz,l0b37h        ;Loop until BC=0
    call wait_seek_cmpl ;Wait until ST-412 -SEEK COMPLETE goes low
    ret

wait_seek_cmpl:
;Wait until ST-412 -SEEK COMPLETE goes low
;
    in a,(pio0_dra)     ;0b4e db 60
    bit 0,a             ;Bit 0 = ST-412 -SEEK COMPLETE
    jr nz,wait_seek_cmpl;0b52 20 fa
    ret                 ;0b54 c9

format_:
;Format the drive
;
    in a,(pio3_drb)     ;0b55 db 6d
    bit 4,a             ;Bit 4 = Panel -FORMAT ENABLE
    ld a,09h            ;0b59 3e 09
    jp nz,l0a3fh        ;0b5b c2 3f 0a

    call e_23           ;0b5e cd c7 0a
    ld hl,0             ;0b61 21 00 00
    ld (cylinder),hl    ;0b64 22 fe 81
    xor a               ;0b67 af
    ld (head_sec),a     ;0b68 32 fd 81
l0b6bh:
    call sub_0b75h      ;0b6b cd 75 0b
    ret nz              ;0b6e c0
    call e_03           ;0b6f cd c1 0b
    jr z,l0b6bh         ;0b72 28 f7
    ret                 ;0b74 c9
sub_0b75h:
    call sub_0a0dh      ;0b75 cd 0d 0a
    call e_a4           ;0b78 cd 41 0c
    ret nz              ;0b7b c0
    ld a,(head_sec)     ;0b7c 3a fd 81
    and 11100000b       ;0b7f e6 e0
    ld (head_sec),a     ;0b81 32 fd 81
    rst 30h             ;0b84 f7
    ld c,00h            ;0b85 0e 00
    call sub_0ba1h      ;0b87 cd a1 0b
    ld a,(head_sec)     ;0b8a 3a fd 81
    and 11100000b       ;0b8d e6 e0
    or 00000001b        ;0b8f f6 01
    ld (head_sec),a     ;0b91 32 fd 81
    rst 30h             ;0b94 f7
    call sub_0ba1h      ;0b95 cd a1 0b
    call sub_0c49h      ;0b98 cd 49 0c
    ret z               ;0b9b c8
    ld a,08h            ;0b9c 3e 08
    jp l0832h           ;0b9e c3 32 08
sub_0ba1h:
    ld hl,60cah         ;0ba1 21 ca 60
    ld (hl),0ah         ;0ba4 36 0a
    ld a,(head_sec)     ;0ba6 3a fd 81
l0ba9h:
    ld (head_sec),a     ;0ba9 32 fd 81
    call e_1b           ;0bac cd 3f 08
    rr c                ;0baf cb 19
    rr e                ;0bb1 cb 1b
    rr d                ;0bb3 cb 1a
    ld a,(head_sec)     ;0bb5 3a fd 81
    add a,02h           ;0bb8 c6 02
    ld hl,60cah         ;0bba 21 ca 60
    dec (hl)            ;0bbd 35
    jr nz,l0ba9h        ;0bbe 20 e9
    ret                 ;0bc0 c9

e_03:
    in a,(pio3_dra)     ;0bc1 db 6c
    bit 4,a             ;Bit 4 = -RXD
    ret nz              ;0bc5 c0

    ld a,(heads)        ;0bc6 3a 09 60
    rrca                ;0bc9 0f
    rrca                ;0bca 0f
    rrca                ;0bcb 0f
    ld b,a              ;0bcc 47
    ld a,(head_sec)     ;0bcd 3a fd 81
    and 11100000b       ;0bd0 e6 e0
    add a,20h           ;0bd2 c6 20
    ld (head_sec),a     ;0bd4 32 fd 81
    cp b                ;0bd7 b8
    jr c,l0bf1h         ;0bd8 38 17
    xor a               ;0bda af
    ld (head_sec),a     ;0bdb 32 fd 81
    ld hl,(cylinder)    ;0bde 2a fe 81
    inc hl              ;0be1 23
    ld (cylinder),hl    ;0be2 22 fe 81
    ex de,hl            ;0be5 eb
    ld hl,(last_cyl)    ;0be6 2a 02 60
    or a                ;0be9 b7
    sbc hl,de           ;0bea ed 52
    jr nc,l0bf1h        ;0bec 30 03
    or 0ffh             ;0bee f6 ff
    ret                 ;0bf0 c9
l0bf1h:
    jp e_a4             ;0bf1 c3 41 0c

table_1:
    dw 4800h            ;0bf4 00 48
    dw 4a00h            ;0bf6 00 4a
    dw 8000h            ;0bf8 00 80
    dw 8200h            ;0bfa 00 82
    dw 0a000h           ;0bfc 00 a0
    dw 0a200h           ;0bfe 00 a2

e_28:
;called from prep code in read_firm_blk only
;
    pop hl              ;0c00 e1
    push de             ;0c01 d5
    ld hl,table_1       ;0c02 21 f4 0b
l0c05h:
    ld (6069h),hl       ;0c05 22 69 60
    call e_9e           ;TODO Disable interrupts, Swap 6070h/6071h,
                        ;     do something with ctc_ch2
    ld a,b              ;0c0b 78
    or a                ;0c0c b7
    ret z               ;0c0d c8
    jp p,l0c38h         ;0c0e f2 38 0c
    push bc             ;0c11 c5
    ld a,c              ;0c12 79
    ld (head_sec),a     ;0c13 32 fd 81

                        ;Try to read the sector from the primary
                        ;copy of the firmware on cylinder 0.

    ld hl,0             ;Set cylinder number 0
    ld (cylinder),hl

    rst 10h             ;Read the sector
    jr z,l0c28h         ;Success? Jump to l0c28h

                        ;Reading the sector failed.  Try to read it
                        ;from the backup copy on cylinder 1.

    ld a,1              ;Set cylinder number 1
    ld (cylinder),a

    rst 10h             ;Read the sector
    jp nz,fatal_        ;Failed?  Jump to fatal error.  Halt until reset.

l0c28h:
    ld hl,(6069h)       ;0c28 2a 69 60
    ld e,(hl)           ;0c2b 5e
    inc hl              ;0c2c 23
    ld d,(hl)           ;0c2d 56
    ld hl,6200h         ;0c2e 21 00 62
    ld bc,0200h         ;0c31 01 00 02
    ldir                ;0c34 ed b0
    pop bc              ;0c36 c1
    inc c               ;0c37 0c
l0c38h:
    sla b               ;0c38 cb 20
    ld hl,(6069h)       ;0c3a 2a 69 60
    inc hl              ;0c3d 23
    inc hl              ;0c3e 23
    jr l0c05h           ;0c3f 18 c4

e_a4:
;called from prep code in verify_drive only
;
    ld a,(6015h)        ;0c41 3a 15 60
    cp 0ffh             ;0c44 fe ff
    ret z               ;0c46 c8
    jr l0c4fh           ;0c47 18 06
sub_0c49h:
    ld a,(6014h)        ;0c49 3a 14 60
    cp 0ffh             ;0c4c fe ff
    ret z               ;0c4e c8
l0c4fh:
    in a,(pio3_dra)     ;0c4f db 6c
    res 1,a             ;Bit 1 = -UNIT SELECT 1 (UB4:7)
    out (pio3_dra),a    ;0c53 d3 6c
    ret                 ;0c55 c9

e_a7:
;called from prep code in reset_drive only
;TODO -WRITE DISABLE=low, 6014h=0FFh, 6015h=0FFh?
;
    ld a,0ffh           ;0c56 3e ff
    res 7,a             ;Bit 7 = ST-412 -WRITE DISABLE
    out (pio3_dra),a    ;0c5a d3 6c

    ld a,0ffh           ;0c5c 3e ff
    ld (6014h),a        ;0c5e 32 14 60
    ld (6015h),a        ;0c61 32 15 60
    ret                 ;0c64 c9

e_a1:
    ld a,(601ah)        ;0c65 3a 1a 60
    ld b,a              ;0c68 47
    ld hl,(81fah)       ;0c69 2a fa 81
    ld a,(6075h)        ;0c6c 3a 75 60
    rrca                ;0c6f 0f
    rrca                ;0c70 0f
    rrca                ;0c71 0f
    rrca                ;0c72 0f
    and 00001111b       ;0c73 e6 0f
    ld c,l              ;0c75 4d
    bit 0,b             ;0c76 cb 40
    jr z,l0c80h         ;0c78 28 06
    bit 1,b             ;0c7a cb 48
    jr nz,l0c8eh        ;0c7c 20 10
    jr l0c84h           ;0c7e 18 04
l0c80h:
    res 1,c             ;0c80 cb 89
    jr l0c89h           ;0c82 18 05
l0c84h:
    rra                 ;0c84 1f
    rr h                ;0c85 cb 1c
    rr l                ;0c87 cb 1d
l0c89h:
    rra                 ;0c89 1f
    rr h                ;0c8a cb 1c
    rr l                ;0c8c cb 1d
l0c8eh:
    and 00001111b       ;0c8e e6 0f
    ld b,a              ;0c90 47
    ld a,c              ;0c91 79
    and 00000011b       ;0c92 e6 03
    ld (6016h),a        ;0c94 32 16 60
    ex de,hl            ;0c97 eb
    ld a,(60d3h)        ;0c98 3a d3 60
    ld hl,60c9h         ;0c9b 21 c9 60
    cp (hl)             ;0c9e be
    ld (hl),a           ;0c9f 77
    jr nz,l0cc6h        ;0ca0 20 24
    ld a,b              ;0ca2 78
    ld l,0b3h           ;0ca3 2e b3
    cp (hl)             ;0ca5 be
    jr nz,l0cc6h        ;0ca6 20 1e
    ld hl,(60b4h)       ;0ca8 2a b4 60
    sbc hl,de           ;0cab ed 52
    jr z,l0cb8h         ;0cad 28 09
    inc h               ;0caf 24
    jr nz,l0cc6h        ;0cb0 20 14
    inc l               ;0cb2 2c
    jr nz,l0cc6h        ;0cb3 20 11
    jp e_b0             ;0cb5 c3 39 0d
l0cb8h:
    ld a,(60b6h)        ;0cb8 3a b6 60
    ld (head_sec),a     ;0cbb 32 fd 81
    ld hl,(60b7h)       ;0cbe 2a b7 60
    ld (cylinder),hl    ;0cc1 22 fe 81
    jr l0d16h           ;0cc4 18 50
l0cc6h:
    ex de,hl            ;0cc6 eb
    ld (60b4h),hl       ;0cc7 22 b4 60
    ld a,b              ;0cca 78
    ld (60b3h),a        ;0ccb 32 b3 60
    ld de,0014h         ;0cce 11 14 00
    rst 8               ;0cd1 cf
    push de             ;0cd2 d5
    push hl             ;0cd3 e5
    ld hl,606fh         ;0cd4 21 6f 60
    ld a,(60d3h)        ;0cd7 3a d3 60
    sub (hl)            ;0cda 96
    add a,a             ;0cdb 87
    add a,0d4h          ;0cdc c6 d4
    ld l,a              ;0cde 6f
    ld e,(hl)           ;0cdf 5e
    inc hl              ;0ce0 23
    ld d,(hl)           ;0ce1 56
    pop hl              ;0ce2 e1
    call e_2b           ;0ce3 cd 1c 0d
    dec hl              ;0ce6 2b
    dec hl              ;0ce7 2b
    ld (60afh),hl       ;0ce8 22 af 60
    ex de,hl            ;0ceb eb
    ld (60b1h),hl       ;0cec 22 b1 60
    xor a               ;0cef af
    ld de,(heads)       ;0cf0 ed 5b 09 60
    ld d,a              ;0cf4 57
    rst 8               ;0cf5 cf
    ld (cylinder),hl    ;0cf6 22 fe 81
    pop bc              ;0cf9 c1
    ld a,c              ;0cfa 79
    ld (60bch),a        ;0cfb 32 bc 60
    ld hl,608bh         ;0cfe 21 8b 60
    add hl,bc           ;0d01 09
    ld a,e              ;0d02 7b
    rrca                ;0d03 0f
    rrca                ;0d04 0f
    rrca                ;0d05 0f
    or (hl)             ;0d06 b6
    ld (head_sec),a     ;0d07 32 fd 81
    ld a,(head_sec)     ;0d0a 3a fd 81
    ld (60b6h),a        ;0d0d 32 b6 60
    ld hl,(cylinder)    ;0d10 2a fe 81
    ld (60b7h),hl       ;0d13 22 b7 60
l0d16h:
    call sub_0958h      ;0d16 cd 58 09
    jp e_a4             ;0d19 c3 41 0c
e_2b:
    add hl,de           ;0d1c 19
    xor a               ;0d1d af
    ld (60b9h),a        ;0d1e 32 b9 60
    ld de,(reserved)    ;0d21 ed 5b ae 60
    ld d,a              ;0d25 57
    add hl,de           ;0d26 19
    ex de,hl            ;0d27 eb
    ld hl,6105h         ;0d28 21 05 61
l0d2bh:
    inc de              ;0d2b 13
    ld a,d              ;0d2c 7a
    ld c,(hl)           ;0d2d 4e
    inc hl              ;0d2e 23
    cp (hl)             ;0d2f be
    inc hl              ;0d30 23
    ret c               ;0d31 d8
    jr nz,l0d2bh        ;0d32 20 f7
    ld a,e              ;0d34 7b
    cp c                ;0d35 b9
    jr nc,l0d2bh        ;0d36 30 f3
    ret                 ;0d38 c9

e_b0:
    xor a               ;0d39 af
    ld (60b9h),a        ;0d3a 32 b9 60
    ld a,(60b6h)        ;0d3d 3a b6 60
    ld (head_sec),a     ;0d40 32 fd 81
    ld hl,(60b7h)       ;0d43 2a b7 60
    ld (cylinder),hl    ;0d46 22 fe 81
    ld hl,(60b4h)       ;0d49 2a b4 60
    inc hl              ;0d4c 23
    ld (60b4h),hl       ;0d4d 22 b4 60
    ld a,h              ;0d50 7c
    or l                ;0d51 b5
    jr nz,l0d58h        ;0d52 20 04
    ld hl,60b3h         ;0d54 21 b3 60
    inc (hl)            ;0d57 34
l0d58h:
    ld a,(60bch)        ;0d58 3a bc 60
    inc a               ;0d5b 3c
    cp 14h              ;0d5c fe 14
    call z,e_b3         ;0d5e cc 7d 0d
    ld (60bch),a        ;0d61 32 bc 60
    ld h,00h            ;0d64 26 00
    ld l,a              ;0d66 6f
    ld bc,608bh         ;0d67 01 8b 60
    add hl,bc           ;0d6a 09
    ld a,(head_sec)     ;0d6b 3a fd 81
    and 11100000b       ;0d6e e6 e0
    or (hl)             ;0d70 b6
    ld (head_sec),a     ;0d71 32 fd 81
    ld (60b6h),a        ;0d74 32 b6 60
    call sub_0958h      ;0d77 cd 58 09
    jp e_a4             ;0d7a c3 41 0c

e_b3:
    call sub_0d9eh      ;0d7d cd 9e 0d
    ld bc,(60b1h)       ;0d80 ed 4b b1 60
    inc bc              ;0d84 03
    ld (60b1h),bc       ;0d85 ed 43 b1 60
    ld hl,(60afh)       ;0d89 2a af 60
    ld e,(hl)           ;0d8c 5e
    inc hl              ;0d8d 23
    ld d,(hl)           ;0d8e 56
    inc hl              ;0d8f 23
    ex de,hl            ;0d90 eb
    or a                ;0d91 b7
    sbc hl,bc           ;0d92 ed 42
    jr nz,l0d9ch        ;0d94 20 06
    ld (60afh),de       ;0d96 ed 53 af 60
    jr e_b3             ;0d9a 18 e1
l0d9ch:
    xor a               ;0d9c af
    ret                 ;0d9d c9
sub_0d9eh:
    ld a,(heads)        ;0d9e 3a 09 60
    ld c,a              ;0da1 4f
    ld a,(head_sec)     ;0da2 3a fd 81
    add a,20h           ;0da5 c6 20
    ld b,a              ;0da7 47
    rlca                ;0da8 07
    rlca                ;0da9 07
    rlca                ;0daa 07
    and 00000111b       ;0dab e6 07
    cp c                ;0dad b9
    jr nz,l0dc4h        ;0dae 20 14
    ld a,b              ;0db0 78
    and 00011111b       ;0db1 e6 1f
    ld (head_sec),a     ;0db3 32 fd 81
    ld (60b6h),a        ;0db6 32 b6 60
    ld hl,(cylinder)    ;0db9 2a fe 81
    inc hl              ;0dbc 23
    ld (cylinder),hl    ;0dbd 22 fe 81
    ld (60b7h),hl       ;0dc0 22 b7 60
    ret                 ;0dc3 c9
l0dc4h:
    ld a,b              ;0dc4 78
    ld (head_sec),a     ;0dc5 32 fd 81
    ld (60b6h),a        ;0dc8 32 b6 60
    ret                 ;0dcb c9

e_08:
    push hl             ;0dcc e5
    ld hl,0             ;0dcd 21 00 00
    ld b,18h            ;0dd0 06 18
    or a                ;0dd2 b7
l0dd3h:
    ex (sp),hl          ;0dd3 e3
    adc hl,hl           ;0dd4 ed 6a
    ex (sp),hl          ;0dd6 e3
    rla                 ;0dd7 17
    adc hl,hl           ;0dd8 ed 6a
    sbc hl,de           ;0dda ed 52
    jr nc,l0ddfh        ;0ddc 30 01
    add hl,de           ;0dde 19
l0ddfh:
    ccf                 ;0ddf 3f
    djnz l0dd3h         ;0de0 10 f1
    ex de,hl            ;0de2 eb
    pop hl              ;0de3 e1
    adc hl,hl           ;0de4 ed 6a
    ret                 ;0de6 c9

    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    ret nz              ;0ffd c0
    ccf                 ;0ffe 3f
    ld d,d              ;0fff 52
