* Please forgive the lack of comments in this program, they were stripped out
ORG $8000

binSearch: link A6,#0
    movem.l    A1-A3/D1/D2/D2,-(SP)
    move.w    8(A6),D1    *KEY
    movea.l    10(A6),A1    *LO
    movea.l    14(A6),A2    *HI
    cmpa.l    A1,A2
    BHS    next
    move    #2,CCR
    BRA    out

    

next:    move.l    A1,D2
    add.l    A2,D2
    lsr.l    #1,D2
    andi.b    #$FE,D2
    movea.l    D2,A3
    cmp.w    (A3),D1
    BNE    continue
    move.l    A3,D0
    BRA    out

    

continue: BGT    right
    subq.l    #2,A3
    pea    (A3)
    pea    (A1)
    move.w    D1,-(SP)
    JSR    binSearch
    adda.l    #10,SP    *pop garbage
    BRA    out

    

right:    pea    (A2)
    addq    #2,A3
    pea    (A3)
    move.w    D1,-(SP)
    JSR    binSearch
    adda.l    #10,SP    *pop garbage
    bra    out

    

out:    movem.l    (SP)+,A1-A3/D1/D2
    unlk    A6
    rts
    end
