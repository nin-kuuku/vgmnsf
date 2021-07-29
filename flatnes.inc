;=============================================================================
;       65xx flatassemblermacroinferno v2 by nin-kuuku 2015
;=============================================================================
immediate    = $100000000
indexed_x    = $200000000
indexed_y    = $300000000
indirect_x   = $400000000
indexed_zy   = $500000000
absolute_zp  = $600000000

! = immediate
x = indexed_x
y = indexed_y
zy = indexed_zy
zx = indirect_x
zp = absolute_zp

@   fix @@:

macro .ram address { virtual at address}
macro .endram { end virtual }

macro dbw [byte,word] {db byte
                       dw word}
.dbw fix dbw

macro dwb [word,byte] {dw word
                       db byte}
.dwb fix dwb

macro dl  [byte] {db (byte) and $ff }
macro dh  [byte] {db (byte) shr 8 }
macro lohi name,[word] {common
                       l_#name:
                       forward
                       dl word
                       common
                       h_#name:
                       forward
                       dh word       }

macro lohihx name,[word] {common
                       l_#name:
                       forward
                       dl $#word
                       common
                       h_#name:
                       forward
                       dh $#word       }

macro dt [data] {
if data > $ffffff
        db data shr 24
        db (data shr 16) and $ff
        db (data shr 8) and $ff
        db data and $ff
else if data > $ffff
        db data shr 16
        db (data shr 8) and $ff
        db data and $ff
else if data > $ff
        db data shr 8
        db data and $ff
else
        db data
end if          }

macro .hex [byte] {db $#byte}
.hx fix .hex
hx fix .hex

.dt      fix dt
.db      fix db
.d8      fix db
.dw      fix dw
.d16     fix dw
.dl      fix dl
.dh      fix dh
.lohi    fix lohi
.lohihx  fix lohihx
.include fix include
incbin   fix file
.incbin  fix file
.org     fix org
.bin     fix file

.endif fix end if
eif fix end if
eif fix end if
.else fix else
.if fix if

macro opcodes6502 [mnem,opcode]
{ macro mnem  \{ db opcode \} }
opcodes6502 sec,$38, clc,$18, sed,$f8, cld,$d8
opcodes6502 clv,$b8, cli,$58, sei,$78, nop,$ea
opcodes6502 tax,$aa, tay,$a8, tsx,$ba, txa,$8a
opcodes6502 txs,$9a, tya,$98, php,$08, plp,$28
opcodes6502 inx,$e8, iny,$c8, dex,$ca, dey,$88
opcodes6502 rts,$60, rti,$40

macro bpl  op1  {db $10,(op1)-1-$}
macro jpl  op1  {db $10,(op1)-1-$}
macro bmi  op1  {db $30,(op1)-1-$}
macro jmi  op1  {db $30,(op1)-1-$}
macro bvc  op1  {db $50,(op1)-1-$}
macro jvc  op1  {db $50,(op1)-1-$}
macro bvs  op1  {db $70,(op1)-1-$}
macro jvs  op1  {db $70,(op1)-1-$}
macro bcc  op1  {db $90,(op1)-1-$}
macro jcc  op1  {db $90,(op1)-1-$}
macro blo  op1  {db $90,(op1)-1-$}
macro jlo  op1  {db $90,(op1)-1-$}
macro bcs  op1  {db $b0,(op1)-1-$}
macro jcs  op1  {db $b0,(op1)-1-$}
macro bhs  op1  {db $b0,(op1)-1-$}
macro jhs  op1  {db $b0,(op1)-1-$}
macro bne  op1  {db $d0,(op1)-1-$}
macro jne  op1  {db $d0,(op1)-1-$}
macro bnz  op1  {db $d0,(op1)-1-$}
macro jnz  op1  {db $d0,(op1)-1-$}
macro beq  op1  {db $f0,(op1)-1-$}
macro jeq  op1  {db $f0,(op1)-1-$}
macro bze  op1  {db $f0,(op1)-1-$}
macro jze  op1  {db $f0,(op1)-1-$}
macro bhi  op1  {db $f0,$02,$b0,(op1)-1-$}
macro bls  op1  {db $f0,(op1)-1-$,$90,(op1)-1-$}
macro jmp  op1,op2,op3  {dbw $4c,op1}
macro ijmp op1,op2,op3  {dbw $6c,op1}
macro jsr  op1,op2,op3  {dbw $20,op1}
macro brk  op1=0  {db $00,op1}
;=============================================================================
;       instruction macro
;-----------------------------------------------------------------------------
macro instru6502 mnem ,impl ,reg_a, reg_x, reg_y, zepa ,abbs ,imme ,zepx ,abbx ,zepy ,abby ,indx
    { macro mnem op1  \{
                 if op1 eq                      ;standard      flat6502.inc
                   db  impl                     ;mne           mne
                 else if op1 eq a
                   db  reg_a
                 else if op1 eq x
                   db  reg_x
                 else if op1 eq y
                   db  reg_y
                 else if op1 <= $ff
                   db  zepa,op1                 ;mne $65       mne $65
                 else if op1 <= $ffff
                   dbw abbs,op1                 ;mne $6502     mne $6502
                 else if op1 <= $ff+immediate
                   db  imme,op1-immediate       ;mne #$65      mne !+$65
                 else if op1 <= $ff+indexed_x
                   db  zepx,op1-indexed_x       ;mne $65,x     mne $65+x
                 else if op1 <= $ffff+indexed_x
                   dbw abbx,op1-indexed_x       ;mne $6502,x   mne $6502+x
                 else if op1 <= $ff+indexed_y
                   db  zepy,op1-indexed_y       ;mne ($65),y   mne ($65)+y
                 else if op1 <= $ffff+indexed_y
                   dbw abby,op1-indexed_y       ;mne $6502,y   mne $6502+y
                 else if op1 <= $ff+indirect_x
                   db  indx,op1-indirect_x      ;mne ($65,x)   mne ($6502+zx)
                 else if op1 <= $ff+indexed_zy
                   dbw abby,op1-indexed_zy      ;mne $65,y     mne $65+zy
                 else if op1 <= $ffff+absolute_zp
                   dbw abbs,op1-absolute_zp     ;              mne zp+$6502
                 end if \} }
;-----------------------------------------------------------------------------
_typo_ = 8086  ;16-bit number to generate error message
;          mne,impl  ,reg_a ,reg_x ,reg_y ,zp    ,abb   ,imm   ,zp+x  ,abb+x ,zp+y  ,abb+y ,ind+x
instru6502 lda,_typo_,_typo_,$8a   ,$98   ,$a5   ,$ad   ,$a9   ,$b5   ,$bd   ,$b1   ,$b9   ,$a1
instru6502 sta,_typo_,_typo_,$aa   ,$a8   ,$85   ,$8d   ,_typo_,$95   ,$9d   ,$91   ,$99   ,$81
instru6502 ldx,_typo_,$aa   ,_typo_,_typo_,$a6   ,$ae   ,$a2   ,_typo_,_typo_,$b6   ,$be   ,_typo_
instru6502 stx,_typo_,$8a   ,_typo_,_typo_,$86   ,$8e   ,_typo_,_typo_,_typo_,$96   ,_typo_,_typo_
instru6502 ldy,_typo_,$a8   ,_typo_,_typo_,$a4   ,$ac   ,$a0   ,$b4   ,$bc   ,_typo_,_typo_,_typo_
instru6502 sty,_typo_,$98   ,_typo_,_typo_,$84   ,$8c   ,_typo_,$94   ,_typo_,_typo_,_typo_,_typo_
instru6502 adc,_typo_,_typo_,_typo_,_typo_,$65   ,$6d   ,$69   ,$75   ,$7d   ,$71   ,$79   ,$61
instru6502 sbc,_typo_,_typo_,_typo_,_typo_,$e5   ,$ed   ,$e9   ,$f5   ,$fd   ,$f1   ,$f9   ,$e1
instru6502 and,_typo_,_typo_,_typo_,_typo_,$25   ,$2d   ,$29   ,$35   ,$3d   ,$31   ,$39   ,$21
instru6502 ora,_typo_,_typo_,_typo_,_typo_,$05   ,$0d   ,$09   ,$15   ,$1d   ,$11   ,$19   ,$01
instru6502 or ,_typo_,_typo_,_typo_,_typo_,$05   ,$0d   ,$09   ,$15   ,$1d   ,$11   ,$19   ,$01
instru6502 eor,_typo_,_typo_,_typo_,_typo_,$45   ,$4d   ,$49   ,$55   ,$5d   ,$51   ,$59   ,$41
instru6502 xor,_typo_,_typo_,_typo_,_typo_,$45   ,$4d   ,$49   ,$55   ,$5d   ,$51   ,$59   ,$41
instru6502 inc,_typo_,_typo_,_typo_,_typo_,$e6   ,$ee   ,_typo_,$f6   ,$fe   ,_typo_,_typo_,_typo_
instru6502 dec,_typo_,_typo_,_typo_,_typo_,$c6   ,$ce   ,_typo_,$d6   ,$de   ,_typo_,_typo_,_typo_
instru6502 cmp,_typo_,_typo_,_typo_,_typo_,$c5   ,$cd   ,$c9   ,$d5   ,$dd   ,$d1   ,$d9   ,$c1
instru6502 cpx,_typo_,_typo_,_typo_,_typo_,$e4   ,$ec   ,$e0   ,_typo_,_typo_,_typo_,_typo_,_typo_
instru6502 cpy,_typo_,_typo_,_typo_,_typo_,$c4   ,$cc   ,$c0   ,_typo_,_typo_,_typo_,_typo_,_typo_
instru6502 asl,$0a   ,$0a   ,_typo_,_typo_,$06   ,$0e   ,_typo_,$16   ,$1e   ,_typo_,_typo_,_typo_
instru6502 shl,$0a   ,$0a   ,_typo_,_typo_,$06   ,$0e   ,_typo_,$16   ,$1e   ,_typo_,_typo_,_typo_
instru6502 sl, $0a   ,$0a   ,_typo_,_typo_,$06   ,$0e   ,_typo_,$16   ,$1e   ,_typo_,_typo_,_typo_
instru6502 lsr,$4a   ,$4a   ,_typo_,_typo_,$46   ,$4e   ,_typo_,$56   ,$5e   ,_typo_,_typo_,_typo_
instru6502 shr,$4a   ,$4a   ,_typo_,_typo_,$46   ,$4e   ,_typo_,$56   ,$5e   ,_typo_,_typo_,_typo_
instru6502 sr ,$4a   ,$4a   ,_typo_,_typo_,$46   ,$4e   ,_typo_,$56   ,$5e   ,_typo_,_typo_,_typo_
instru6502 rol,$2a   ,$2a   ,_typo_,_typo_,$26   ,$2e   ,_typo_,$36   ,$3e   ,_typo_,_typo_,_typo_
instru6502 rl ,$2a   ,$2a   ,_typo_,_typo_,$26   ,$2e   ,_typo_,$36   ,$3e   ,_typo_,_typo_,_typo_
instru6502 ror,$6a   ,$6a   ,_typo_,_typo_,$66   ,$6e   ,_typo_,$76   ,$7e   ,_typo_,_typo_,_typo_
instru6502 rr ,$6a   ,$6a   ,_typo_,_typo_,$66   ,$6e   ,_typo_,$76   ,$7e   ,_typo_,_typo_,_typo_
instru6502 bit,_typo_,_typo_,_typo_,_typo_,$24   ,$2c   ,_typo_,_typo_,_typo_,_typo_,_typo_,_typo_

;immediate synonyms
macro lda!  op1  {db $a9,op1}
macro ldx!  op1  {db $a2,op1}
macro ldy!  op1  {db $a0,op1}
macro adc!  op1  {db $69,op1}
macro sbc!  op1  {db $e9,op1}
macro and!  op1  {db $29,op1}
macro ora!  op1  {db $09,op1}
macro or!   op1  {db $09,op1}
macro eor!  op1  {db $49,op1}
macro xor!  op1  {db $49,op1}
macro cmp!  op1  {db $c9,op1}
macro cpx!  op1  {db $e0,op1}
macro cpy!  op1  {db $c0,op1}
macro add!  op1  {db $18,$69,op1}
macro sub!  op1  {db $38,$e9,op1}
;immediate lo byte
macro ldal! op1  {db $a9,(op1) and $ff}
macro ldxl! op1  {db $a2,(op1) and $ff}
macro ldyl! op1  {db $a0,(op1) and $ff}
macro andl! op1  {db $29,(op1) and $ff}
macro oral! op1  {db $09,(op1) and $ff}
macro orl!  op1  {db $09,(op1) and $ff}
macro eorl! op1  {db $49,(op1) and $ff}
macro xorl! op1  {db $49,(op1) and $ff}
macro adcl! op1  {db $69,(op1) and $ff}
macro sbcl! op1  {db $e9,(op1) and $ff}
macro addl! op1  {db $18,$69,(op1) and $ff}
macro subl! op1  {db $38,$e9,(op1) and $ff}
macro cmpl! op1  {db $c9,(op1) and $ff}
macro cpxl! op1  {db $e0,(op1) and $ff}
macro cpyl! op1  {db $c0,(op1) and $ff}

;immediate hi byte
macro ldah! op1  {db $a9,(op1) shr 8}
macro ldxh! op1  {db $a2,(op1) shr 8}
macro ldyh! op1  {db $a0,(op1) shr 8}
macro andh! op1  {db $29,(op1) shr 8}
macro orah! op1  {db $09,(op1) shr 8}
macro orh!  op1  {db $09,(op1) shr 8}
macro eorh! op1  {db $49,(op1) shr 8}
macro xorh! op1  {db $49,(op1) shr 8}
macro adch! op1  {db $69,(op1) shr 8}
macro sbch! op1  {db $e9,(op1) shr 8}
macro addh! op1  {db $18,$69,(op1) shr 8}
macro subh! op1  {db $38,$e9,(op1) shr 8}
macro cmph! op1  {db $c9,(op1) shr 8}
macro cpxh! op1  {db $e0,(op1) shr 8}
macro cpyh! op1  {db $c0,(op1) shr 8}

macro lda op1, op2, op3 {
if op1 eq a
else
lda op1
#op2
#op3
end if                  }
;=============================================================================
;       8-bit moves
;-----------------------------------------------------------------------------
macro   mov op1,op2,[op3] {
        lda op2
        sta op1
        #op3        }
macro   mov! op1,op2,op3 {
        lda immediate+(op2)
        sta op1
        #op3            }

mva fix mov
mva! fix mov!

macro   mvx op1,op2,op3 {
        ldx op2
        stx op1
        #op3            }
macro   mvx! op1,op2,op3 {
        ldx immediate+(op2)
        stx op1
        #op3            }

macro   mvy op1,op2,op3 {
        ldy op2
        sty op1
        #op3            }
macro   mvy! op1,op2,op3 {
        ldy immediate+(op2)
        sty op1
        #op3            }
;-----------------------------------------------------------------------------
macro   add op1 {
        clc
        adc op1 }

macro   sub op1 {
        sec
        sbc op1 }

macro   pha     [op1]  {
if op1 eq
        db $48  ;pha
else
        lda     op1
        db $48  ;pha
end if               }

macro   sta     [op1]   {
if op1 eq a
else
        sta     op1
end if                  }

macro   sty     [op1]   {
        sty     op1     }

macro   stx     [op1]   {
        stx     op1     }

macro   pla     [op1]  {
if op1 eq
        db $68  ;pla
else
        db $68  ;pla
        sta     op1
end if              }
;=============================================================================
macro   macroconditional0 cond,mnem,inst
{ macro mnem                       \{   ;0 ops
\local .skipinst
        #cond .skipinst
        #inst                           ;0 ops
.skipinst:
                                \} }

macro   macroconditional1 cond,mnem,inst
{ macro mnem  op1                  \{   ;1 ops
\local .skipinst
        #cond .skipinst
        #inst     op1                   ;1 ops
.skipinst:
                                \} }

macro   macroconditional2 cond,mnem,inst
{ macro mnem  op1,op2              \{   ;2 ops
\local .skipinst
        #cond .skipinst
        #inst     op1,op2               ;2 ops
.skipinst:
                                \} }

macro   macroconditional3 cond,mnem,inst
{ macro mnem  op1,op2,op3          \{   ;3 ops
\local .skipinst
        #cond .skipinst
        #inst     op1,op2,op3           ;3 ops
.skipinst:
                                \} }

macro   macroconditional4 cond,mnem,inst
{ macro mnem  op1,op2,op3,op4      \{   ;4 ops
\local .skipinst
        #cond .skipinst
        #inst     op1,op2,op3,op4       ;4 ops
.skipinst:
                                \} }

macro conditional number, [mnem] {
macroconditional#number bpl,#mnem#mi ,#mnem
macroconditional#number bmi,#mnem#pl ,#mnem
macroconditional#number bvc,#mnem#vs ,#mnem
macroconditional#number bvs,#mnem#vc ,#mnem
macroconditional#number bcc,#mnem#cs ,#mnem
macroconditional#number blo,#mnem#hs ,#mnem
macroconditional#number bcs,#mnem#cc ,#mnem
macroconditional#number bhs,#mnem#lo ,#mnem
macroconditional#number bne,#mnem#eq ,#mnem
macroconditional#number bnz,#mnem#ze ,#mnem
macroconditional#number beq,#mnem#ne ,#mnem
macroconditional#number bze,#mnem#nz ,#mnem
macroconditional#number bhi,#mnem#ls ,#mnem
macroconditional#number bls,#mnem#hi ,#mnem }

conditional 2, mov,mov!,mva,mva!, mvx,mvx!,mvy,mvy!,movw,movw!,movlh,movlh!,mvaw,mvaw!,mvalh,mvalh!
conditional 0, inx,iny,dex,dey,rts,sec,clc,sed,cld,clv,cli,sei,nop
conditional 0, dex2,dex3,dex4,inx2,inx3,inx4,dey2,dey3,dey4,iny2,iny3,iny4
conditional 0, asl2,asl3,asl4,lsr2,lsr3,lsr4,ror2,ror3,ror4,rol2,rol3,rol4
conditional 0, shl2,shl3,shl4,shr2,shr3,shr4
conditional 0, tya,tay,txa,tax
conditional 1, inc,dec,jmp,ijmp,jsr,asl,lsr,shl,shr,ror,rol,bit,brk,incw,decw
conditional 1, lda,lda!,ldx,ldx!,ldy,ldy!,sta,stx,sty
conditional 1, ldxy,ldyx,ldxy!,ldyx!,styx,stxy
conditional 2, and,and!,eor,eor!,xor,xor!,ora,ora!,or,or!
conditional 2, add,add!,adc,adc!,sub,sub!,sbc,sbc!
conditional 3, addb,addb!,adcb,adcb!,subb,subb!,sbcb,sbcb!
conditional 3, andb,andb!,eorb,eorb!,xorb,xorb!,orab,orab!,orb,orb!
conditional 3, addw,addw!,subw,subw!
conditional 3, addlh,addlh!,sublh,sublh!
conditional 4, mv
;-----------------------------------------------------------------------------
macro stane [op1] {
common
local .skip
        beq .skip
forward
        sta op1
common
.skip:            }
;=============================================================================
;       block moves
;-----------------------------------------------------------------------------
macro   xcopy dst*,src*,len       {
local .xcopyloop
if len eq
        db $a2,(len_#src)-1
else
        db $a2,len  ;ldx! op3
end if
.xcopyloop:
        lda (src)+x
        sta (dst)+x
        dex
        bpl .xcopyloop      }
;=============================================================================
;       16-bit stuff
;-----------------------------------------------------------------------------
macro   movw    dest*,src*                {
        lda     src
        sta     dest
        lda     src+1
        sta     dest+1                    }
macro   movw!   dest*,src*                {
        lda     immediate+((src) and $ff)
        sta     dest
        lda     immediate+((src) shr 8)
        sta     dest+1                    }
mvaw  fix movw
mvaw! fix movw!
;-----------------------------------------------------------------------------
macro   movlh   dest*,src*                {
        lda     l_#src
        sta     l_#dest
        lda     h_#src
        sta     h_#dest                  }
macro   movlh!  dest*,src*                {
        lda     immediate+((src) and $ff)
        sta     l_#dest
        lda     immediate+((src) shr 8)
        sta     h_#dest                  }
mvalh fix movlh
mvalh! fix movlh!
;-----------------------------------------------------------------------------
macro   ldxy    src       {
        ldx     src
        ldy     src+1     }
macro   ldyx    src       {
        ldy     src
        ldx     src+1     }
macro   ldxy!   src                       {
        ldx     immediate+((src) and $ff)
        ldy     immediate+((src) shr 8)   }
macro   ldyx!   src                       {
        ldy     immediate+((src) and $ff)
        ldx     immediate+((src) shr 8)   }
macro   styx    dst       {
        sty     dst
        stx     dst+1     }
macro   stxy    dst       {
        stx     dst
        sty     dst+1     }
;-----------------------------------------------------------------------------
macro   incw  op1*      {
local .skipinchi
        inc op1
        bne .skipinchi
        inc op1+1
.skipinchi:             }
macro   inclh  op1*     {
local .skipinchi
        inc l_#op1
        bne .skipinchi
        inc h_#op1
.skipinchi:             }
macro   decw  op1*      {
local .skipdechi
        lda op1
        bne .skipdechi
        dec op1+1
.skipdechi:
        dec op1         }
macro   declh  op1*     {
local .skipdechi
        lda h_#op1
        bne .skipdechi
        dec l_#op1
.skipdechi:
        dec l_#op1     }

macro   inyx  {db $c8,$e8}
macro   inxy  {db $e8,$c8}
macro   deyx  {db $88,$ca}
macro   dexy  {db $ca,$88}
;-----------------------------------------------------------------------------
macro   cmpw op1*,op2*                  {
local .compdone
        lda op1+1
        cmp op2+1
        bcc .compdone
        bne .compdone
        lda op1
        cmp op2
.compdone:                              }
macro   cmpw! op1*,op2*                 {
local .compdone
        lda op1+1
        cmp immediate+((op2) shr 8)
        bcc .compdone
        bne .compdone
        lda op1
        cmp immediate+((op2) and $ff)
.compdone:                              }
macro   cmplh op1*,op2*                 {
local .compdone
        lda h_#op1
        cmp h_#op2
        bcc .compdone
        bne .compdone
        lda l_#op1
        cmp l_#op2
.compdone:                              }
macro   cmplh! op1*,op2*                {
local .compdone
        lda h_#op1
        cmp immediate+((op2) shr 8)
        bcc .compdone
        bne .compdone
        lda l_#op1
        cmp immediate+((op2) and $ff)
.compdone:                              }
;-----------------------------------------------------------------------------
macro   ldacombo mnem
{ macro mnem op1,op2,op3   \{
if op2 eq
        #mnem op1
else if op3 eq
        lda op1
        #mnem op2
else
        lda op2
        #mnem op3
        sta op1
end if                  \} }

macro   ldastacombo [mnem] {
ldacombo mnem            }
;--------------------------------------
ldastacombo and,ora,or,eor,xor,adc,add,sbc,sub,cmp
ldastacombo and!,ora!,or!,eor!,xor!,adc!,add!,sbc!,sub!,cmp!
ldastacombo andl!,oral!,eorl!,adcl!,addl!,sbcl!,subl!,cmpl!
ldastacombo andh!,orah!,eorh!,adch!,addh!,sbch!,subh!,cmph!
;-----------------------------------------------------------------------------
macro   writeback mnem,inst
{macro mnem op1,op2,op3        \{
if op3 eq
        lda op1
        #inst op2
        sta op1
else
        lda op2
        #inst op3
        sta op1
end if                          \} }
writeback andb,and
writeback andb!,and!
writeback orab,ora
writeback orab!,ora!
writeback orb,or
writeback orb!,or!
writeback eorb,eor
writeback eorb!,eor!
writeback xorb,xor
writeback xorb!,xor!
writeback adcb,adc
writeback adcb!,adc!
writeback addb,add
writeback addb!,add!
writeback sbcb,sbc
writeback sbcb!,sbc!
writeback subb,sub
writeback subb!,sub!
;-----------------------------------------------------------------------------

macro   writebackword mnem,inst1,inst2,val=0
{macro mnem op1,op2,op3        \{
if op3 eq
        lda op1
        #inst1 op2
        sta op1
        lda op1+1
        #inst2 op2+val
        sta op1+1
else
        lda op2
        #inst1 op3
        sta op1
        lda op2+1
        #inst2 op3+val
        sta op1+1
end if                          \} }
writebackword andw,and,and,1
writebackword andw!,andl!,andh!
writebackword oraw,ora,ora,1
writebackword oraw!,oral!,orah!
writebackword orw,or,or,1
writebackword orw!,orl!,orh!
writebackword eorw,eor,eor,1
writebackword eorw!,eorl!,eorh!
writebackword xorw,xor,xor,1
writebackword xorw!,xorl!,xorh!
writebackword addw,add,adc,1
writebackword subw,sub,sbc,1
;-----------------------------------------------------------------------------
macro macroaddsubw! mnem,inst1,inst2,inst3,inst4
{ macro   mnem op1,op2,op3 \{
if op3 eq
if op2 < $100
\local .skip
        lda op1
        #inst1 immediate+(op2)
        sta op1
        #inst4 .skip
        #inst3 op1+1
.skip:
else
        lda op1
        #inst1 immediate+((op2) and $ff)
        sta op1
        lda op1+1
        #inst2 immediate+((op2) shr 8)
        sta op1+1
end if
else
        lda op2
        #inst1 immediate+((op3) and $ff)
        sta op1
        lda op2+1
        #inst2 immediate+((op3) shr 8)
        sta op1+1
end if                  \} }

macroaddsubw! addw!,add,adc,inc,bcc
macroaddsubw! subw!,sub,sbc,dec,bcs
;-----------------------------------------------------------------------------
macro macroaddsublh! mnem,inst1,inst2,inst3
{ macro   mnem op1,op2,op3 \{
if op3 eq
if op2 < $100
\local .skip
        lda l_#op1
        #inst1 immediate+(op2)
        sta l_#op1
        bcc .skip
        #inst3 h_#op1
.skip:
else
        lda l_#op1
        #inst1 immediate+((op2) and $ff)
        sta l_#op1
        lda h_#op1
        #inst2 immediate+((op2) shr 8)
        sta h_#op1
end if
else
        lda l_#op2
        #inst1 immediate+((op3) and $ff)
        sta l_#op1
        lda h_#op2
        #inst2 immediate+((op3) shr 8)
        sta h_#op1
end if                          \} }
macroaddsublh! addlh!,add,adc,inc
macroaddsublh! sublh!,sub,sbc,dec
;-----------------------------------------------------------------------------
macro   addlh op1,op2,op3  {
if op3 eq
        lda l_#op1
        add l_#op2
        sta l_#op1
        lda h_#op1
        adc h_#op2
        sta h_#op1
else
        lda l_#op2
        add l_#op3
        sta l_#op1
        lda h_#op2
        adc h_#op3
        sta h_#op1
end if                     }
macro   sublh op1*,op2*,op3  {
if op3 eq
        lda l_#op1
        sub l_#op2
        sta l_#op1
        lda h_#op1
        sbc h_#op2
        sta h_#op1
else
        lda l_#op2
        sub l_#op3
        sta l_#op1
        lda h_#op2
        sbc h_#op3
        sta h_#op1
end if                     }
;-----------------------------------------------------------------------------
macro   aslw op1 {
        asl op1
        rol op1+1 }
macro   lsrw op1 {
        lsr op1+1
        ror op1   }
macro   asllh op1 {
        asl l_#op1
        rol h_#op1 }
macro   lsrlh op1 {
        lsr h_#op1
        ror l_#op1 }
macro   shlw op1 {
        asl op1
        rol op1+1 }
macro   shrw op1 {
        lsr op1+1
        ror op1   }
macro   shllh op1 {
        asl l_#op1
        rol h_#op1 }
macro   shrlh op1 {
        lsr h_#op1
        ror l_#op1 }
;-----------------------------------------------------------------------------
macro   xloop op1*,op2=.loop      {
        inx
        cpx op1
        bne op2             }

macro   xloop! op1*,op2=.loop     {
        inx
        cpx immediate+(op1)
        bne op2             }

macro   xcount op1*,op2=.done     {
        inx
        cpx op1
        beq op2             }

macro   xcount! op1*,op2=.done    {
        inx
        cpx immediate+(op1)
        beq op2             }
;-----------------------------------------------------------------------------
macro   ror8 op1 {
if op1 eq
        cmp immediate+$80
        ror
else
        lda op1
        cmp immediate+$80
        ror op1
end if         }

macro   rol8 op1 {
if op1 eq
        cmp immediate+$80
        rol
else
        lda op1
        cmp immediate+$80
        rol op1
end if         }

macro   swap {
        asl
        adc immediate+$80
        rol
        asl
        adc immediate+$80
        rol       }

macro multimacro inst   {
 macro  inst#2         \{
        #inst
        #inst
                        \}
 macro  inst#3         \{
        #inst
        #inst
        #inst
                        \}
 macro  inst#4         \{
        #inst
        #inst
        #inst
        #inst
                        \}
 macro  inst#5         \{
        #inst
        #inst
        #inst
        #inst
        #inst
                        \} }

multimacro lsr
multimacro shr
multimacro asl
multimacro shl
multimacro iny
multimacro inx
multimacro dey
multimacro dex
multimacro ror
multimacro rol
multimacro nop
multimacro pla

macro mv  op1,op2,op3,op4  {
lda op2
#op3
#op4
sta op1                }

ld  fix mv

macro ifelsemacro [cond] {
macro if#cond op1,op2,op3 \{
\local .skip1
\local .skip2
b#cond .skip1
#op2
if op3 eq
jmp   .skip2
else
#op3  .skip2
end if
.skip1:
#op1
.skip2:            \} }

ifelsemacro pl,mi,vc,vs,cc,lo,cs,hs,ne,nz,eq,ze,hi,ls

macro st  op1, [op2] {
common
      lda op1
forward
      sta op2      }

;=============================================================================
macro .orgpad op1,op2 {if op2 eq
                          db (op1-$) dup $00
                      else
                          db (op1-$) dup op2
                      end if
                      org op1}
macro .pad op1,op2    {if op2 eq
                          db (op1-$) dup $00
                      else
                          db (op1-$) dup op2
                      end if }
;=============================================================================
;       macro data
;-----------------------------------------------------------------------------
macro lendata op1* { macro end#op1 \{ end#op1: \}
#op1:
len_#op1 = end#op1 - #op1 }

macro lenbin op1*,[op2*] {
common
#op1:
len_#op1 = end#op1 - #op1
forward
.incbin #op2
common
end#op1:               }

macro len tablename*,datatype*,[data*] {
common
#tablename:
len_#tablename = end#tablename - #tablename
forward
#datatype data
common
end#tablename:               }
;----------------------------------------
macro .rts_table tablename*,subname*,subnumber*,filler*,tablesize*, [word*] {
number = subnumber
common
#tablename:
forward
dw word-1
#subname#word   =  number
number = number + 1
common
dw (tablesize-($-tablename))/2 dup filler           }
;-----------------------------------------------------------------
macro .word_table tablename*,subname*,subnumber*,filler*,tablesize*, [word*] {
number = subnumber
common
#tablename:
forward
dw word
#subname#word   =  number
number = number + 1
common
dw (tablesize-($-tablename))/2 dup filler           }
;-----------------------------------------------------------------
macro .nametable tablename*,subname*,[word*] {
number = 0
common
l_#tablename:
forward
dl word
common
h_#tablename:
forward
dh word
#subname#word   =  number
number = number + 1    }
;-----------------------------------------------------------------
macro lhequ op1,op2     {
#op1    = (op2)
l_#op1  = (op2)
h_#op1  = (op2)+1
lo_#op1  = ((op2) and $ff)
hi_#op1  = (((op2)+1) shr 8)    }
;-----------------------------------------------------------------
macro address message=" " {
    bits = 16
    display message
    repeat bits/4
        d = '0' + $ shr (bits-%*4) and $0f
        if d > '9'
            d = d + 'a'-'9'-1
        end if
        display d
    end repeat
    display 13,10  }

macro ldaccu arg {
 match [[a]],arg \{
 db  a
 \}
}

macro la opr               {
 match  =s,opr            \{
 lda! 1                   \}
 match  (s),opr           \{
 lda! 2                   \}
 match  [s],opr           \{
 lda! 3                   \}
 match  [s]+o, opr        \{
 lda! 4                   \}
                           }
;-----------------------------------------------------------------
macro ldb op1,op2,op3=0   {
if op2 eqtype ""
        virtual at 0
        file #op2 : op3,1
        load op1 byte from 0
        end virtual
else
        load op1 byte from op2
end if                  }

macro ldw op1,op2,op3=0   {
if op2 eqtype ""
        virtual at 0
        file #op2 : op3,2
        load op1 word from 0
        end virtual
else
        load op1 word from op2
end if                  }

macro lddw op1,op2,op3=0   {
if op2 eqtype ""
        virtual at 0
        file #op2 : op3,4
        load op1 dword from 0
        end virtual
else
        load op1 dword from op2
end if          }

macro stb op1,op2 {
if op2 eq
        db 0
        store byte op1 at $-1
else
        store byte op1 at op2
end if          }

macro stw op1,op2 {
if op2 eq
        dw 0
        store word op1 at $-2
else
        store word op1 at op2
end if          }

macro stdw op1,op2 {
if op2 eq
        dd 0
        store dword op1 at $-4
else
        store dword op1 at op2
end if          }




;-----------------------------------------------------------------
;immediates
rept 10 n:0 {!#n   = (n   +$00)+immediate} ;
!a = ($0a)+immediate                       ;
!b = ($0b)+immediate                       ;
!c = ($0c)+immediate                       ;
!d = ($0d)+immediate                       ;
!e = ($0e)+immediate                       ;
!f = ($0f)+immediate                       ;
rept 10 n:0 {!0#n  = (n   +$00)+immediate} ;
rept 10 n:0 {!1#n  = (n   +$10)+immediate} ;
rept 10 n:0 {!2#n  = (n   +$20)+immediate} ;
rept 10 n:0 {!3#n  = (n   +$30)+immediate} ;
rept 10 n:0 {!4#n  = (n   +$40)+immediate} ;
rept 10 n:0 {!5#n  = (n   +$50)+immediate} ;
rept 10 n:0 {!6#n  = (n   +$60)+immediate} ;
rept 10 n:0 {!7#n  = (n   +$70)+immediate} ;
rept 10 n:0 {!8#n  = (n   +$80)+immediate} ;
rept 10 n:0 {!9#n  = (n   +$90)+immediate} ;
rept 10 n:0 {!a#n  = (n   +$a0)+immediate} ;
rept 10 n:0 {!b#n  = (n   +$b0)+immediate} ;
rept 10 n:0 {!c#n  = (n   +$c0)+immediate} ;
rept 10 n:0 {!d#n  = (n   +$d0)+immediate} ;
rept 10 n:0 {!e#n  = (n   +$e0)+immediate} ;
rept 10 n:0 {!f#n  = (n   +$f0)+immediate} ;
rept 10 n:0 {!#n#a = (n*16+$0a)+immediate} ;
rept 10 n:0 {!#n#b = (n*16+$0b)+immediate} ;
rept 10 n:0 {!#n#c = (n*16+$0c)+immediate} ;
rept 10 n:0 {!#n#d = (n*16+$0d)+immediate} ;
rept 10 n:0 {!#n#e = (n*16+$0e)+immediate} ;
rept 10 n:0 {!#n#f = (n*16+$0f)+immediate} ;
!aa                = (     $aa)+immediate  ;
!ab                = (     $ab)+immediate  ;
!ac                = (     $ac)+immediate  ;
!ad                = (     $ad)+immediate  ;
!ae                = (     $ae)+immediate  ;
!af                = (     $af)+immediate  ;
!ba                = (     $ba)+immediate  ;
!bb                = (     $bb)+immediate  ;
!bc                = (     $bc)+immediate  ;
!bd                = (     $bd)+immediate  ;
!be                = (     $be)+immediate  ;
!bf                = (     $bf)+immediate  ;
!ca                = (     $ca)+immediate  ;
!cb                = (     $cb)+immediate  ;
!cc                = (     $cc)+immediate  ;
!cd                = (     $cd)+immediate  ;
!ce                = (     $ce)+immediate  ;
!cf                = (     $cf)+immediate  ;
!da                = (     $da)+immediate  ;
!db                = (     $db)+immediate  ;
!dc                = (     $dc)+immediate  ;
!dd                = (     $dd)+immediate  ;
!de                = (     $de)+immediate  ;
!df                = (     $df)+immediate  ;
!ea                = (     $ea)+immediate  ;
!eb                = (     $eb)+immediate  ;
!ec                = (     $ec)+immediate  ;
!ed                = (     $ed)+immediate  ;
!ee                = (     $ee)+immediate  ;
!ef                = (     $ef)+immediate  ;
!fa                = (     $fa)+immediate  ;
!fb                = (     $fb)+immediate  ;
!fc                = (     $fc)+immediate  ;
!fd                = (     $fd)+immediate  ;
!fe                = (     $fe)+immediate  ;
!ff                = (     $ff)+immediate  ;

turbografx=0
discsystem=0
;=============================================================================
;       headers
;-----------------------------------------------------------------------------
nrom_v  = $0000
nrom_h  = $0001
uxrom_v = $0020
uxrom_h = $0021
axrom   = $0070
mmc1    = $0011
mmc2    = $0090
mmc3    = $0040
mmc5    = $0050
vrc6    = $1080
vrc7    = $5050
fme7    = $4050
n106    = $1030
pinbot  = $7070
nsfmap  = $10f0
macro inesheader prg=32,chr=8,board=nrom_h,batt=0,four=0 {
      format binary as "nes"
         db $4e,$45,$53,$1a
         db prg shr 4,chr shr 3
         dw board or (batt shl 1) or (four shl 4)
         dw 0,0,0,0
         discsystem=0           }
.inesheader fix inesheader
;-----------------------------------------------------------------------------
macro nsfheader title="mystic",artist="nkuu",copyright="2013",songs=1,\
      ntsc_pal=2,load=$8000,init=init_nsf,play=play_nsf,nsf_mapper=0 {
      format binary as "nsf"
         nsfheader::
         db $4e,$45,$53,$4d,$1a,$01  ;nsf file
         db songs,1                  ;total songs/starting song
.if discsystem=1
         dw 6000h
.else
         dw load
.endif
         dw init,play
      t.:db `title,0     ,$20-($-t.) dup 0
      a.:db `artist,0    ,$20-($-a.) dup 0
      c.:db `copyright,0 ,$20-($-c.) dup 0
         dw $40ff                            ;ntsc speed
.if discsystem=1
         db $02,$03,$04,$05,$06,$07,$00,$01  ;bankswitch init values
.else
         db $00,$01,$02,$03,$04,$05,$06,$07
.endif
         dw $4e1d                            ;pal speed
         db ntsc_pal and $03                 ;ntsc/pal
         db nsf_mapper or (discsystem shl 2)
         dd 0   ;pad
.if discsystem=1
.org 6000h
.else
.org 8000h
.endif                }
.nsfheader fix nsfheader
;=============================================================================
;       data
;-----------------------------------------------------------------------------
macro dmcfile [op1] {
align 64
dmc_start#op1:
file `op1
dmc_end#op1:
adr_#op1 = (dmc_start#op1 shr 6) and $00ff
len_#op1 = (((dmc_end#op1 - dmc_start#op1) shr 4 )-1) and $00ff }
;-----------------------------------------------------------------------------
macro dmcfile_table tablename*, [dmcfile*] {
number = 0
common
#tablename:

forward
.db adr_#dmcfile,len_#dmcfile
dmc_#dmcfile   =  number
number = number + 1

forward
align 64
dmc_start#dmcfile:
file `dmcfile
dmc_end#dmcfile:
adr_#dmcfile = (dmc_start#dmcfile shr 6) and $00ff
len_#dmcfile = (((dmc_end#dmcfile - dmc_start#dmcfile) shr 4 )-1) and $00ff   }
;=============================================================================
macro print_h cordx,cordy,data {
common
db (( .e - .s )-1) and $3f
dh $2000 + ((cordy * 32) + cordx)
dl $2000 + ((cordy * 32) + cordx)
.s:
forward
db data
common                                             
.e:                                        }
;-----------------------------------------------------------------------------
macro chrfile_mono op1*, op2* {
count = 0
rept op2 \{ file op1:count,8
         count = count+16 \} }
;-----------------------------------------------------------------------------
macro palettefile op1,op2   {
@
if op2 eq
count = 1
repeat 4
         file op1:count,3
         count = count+4
end repeat

else
count = 1
repeat 4
         file op1:count,3
         count = count+4
end repeat
count = 1
repeat 4
         file op2:count,3
         count = count+4
end repeat
          file op1:0,1
end if

repeat $ - @b
load a from @b+%-1
        if a = $00
        store $10 at @b+%-1
   else if a = $10
        store $20 at @b+%-1
   else if a = $20
        store $40 at @b+%-1
   else if a = $30
        store $40 at @b+%-1
   else if a = $0f
        store $f0 at @b+%-1
   else if a = $2d
        store $1d at @b+%-1
   else if a = $3d
        store $2d at @b+%-1
else
store a at @b+%-1
end if
end repeat      }
;-----------------------------------------------------------------------------
macro .nescii [op1]  {
common
@
forward
db op1
common
repeat $ - @b
load a from @b+%-1
        if a < $20
        store a at @b+%-1
   else if a = "."
        store $24 at @b+%-1
   else if a = ","
        store $25 at @b+%-1
   else if a = ":"
        store $26 at @b+%-1
   else if a = "-"
        store $27 at @b+%-1
   else if a = "/"
        store $28 at @b+%-1
   else if a = "="
        store $29 at @b+%-1
   else if a = "!"
        store $2a at @b+%-1
   else if a = "?"
        store $2b at @b+%-1
   else if a = "'"
        store $2c at @b+%-1
   else if a = "("
        store $2d at @b+%-1
   else if a = ")"
        store $2e at @b+%-1
   else if a = " "
        store $2f at @b+%-1
   else if a < ":"
        store a-$30 at @b+%-1
   else if a < "["
        store a-$37 at @b+%-1
   else if a < "{"
        store a-$57 at @b+%-1
else
store a at @b+%-1
end if
end repeat      }
