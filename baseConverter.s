*----------------------------------------------------------------------
*
        ORG     $0
        DC.L    $3000           * Stack pointer value after a reset
        DC.L    start           * Program counter value after a reset
        ORG     $3000           * Start at location 3000 Hex
*
*----------------------------------------------------------------------
*
#minclude /home/ma/cs237/bsvc/iomacs.s
#minclude /home/ma/cs237/bsvc/evtmacs.s
*
*----------------------------------------------------------------------
*
* Register use
* D1 = LENGTH OF BUFFER 1
* D2 = NUMBER TO CONVERT IN ASCII, THEN QUOTIENT
* D3 = LENGTH OF BUFF 2, THEN REMAINDER
* D4 = TWOS COMPLIMENT NUMBER TO CONVERT
* D5 = ASCII BASE
* D6 = BASE
*
*----------------------------------------------------------------------
*
start:  initIO                  * Initialize (required for I/O)
    setEVT            * Error handling routines
*    initF            * For floating point macros only    

    lineout title
    lineout skipln
    lineout p1
in1:    linein    buff1        * Read what number we need to convert to the base
                * we don't need to convert it yet
                * because we can test things with ascii
                
    move.l    D0,D1        * Put the length into D1 so we can save it for later
    tst.l    D1        
    BEQ    eb1        * Jump to error if D1 is zero
    subq    #1,D1
    lea    buff1,A1
    
                *Now we need to check if all the digits are in base
                *10 and if they aren't we need to return an error
                *We can cycle through the addresses of each ascii
                *character and compare it to the imediate values
                *of ascii characters 0-9 if not return error
        
check1:    move.b    (A1)+,D2    * start cycle check if above 30
    cmpi.b    #$30,D2
    BLT    eb1    
check2:    cmpi.b    #$39,D2        * check if below 39
    BGT    eb1
    dbra    D1,check1
    addq    #1,D1
                *At this point we know there are digits in the buffer
                *and they are in base 10, now we need to check
                *if the input is in the correct range max number
                *we can convert is 65536 in base 10

check3:    cvta2    buff1,D0    * lets put it in twos compliment
    move.l    D0,D4        * lets save the value for future use in D4    
    cmpi.l    #0,D0        
    BLT    eb5        *if value is less than 0 then we need to go to error
    cmpi.l    #65535,D0
    BGT    eb5        *if over 2^16 then we need to go to error
    
                *Finished checking if the first input is correct
                *We can now move onto the second input    

    lineout p2
in2:    linein    buff2
    move.w    D0,D3
    tst.w    D3
    BEQ    eb2
    subq.w    #1,D3
    lea    buff2,A2
    
check1a:move.b (A2)+,D5        *Same checks as the first check
    cmpi.b    #$30,D5
    BLT    eb2
check1b:cmpi.b    #$39,D5
    BGT    eb2
    dbra    D3,check1a
    addq    #1,D3
                *Now instead we need to check for 2-16 rather than
                *0-2^16
                
check1c:cvta2    buff2,D0
    move.l    D0,D6
    cmpi.w    #2,D0        * check if base is in 2-16
    BLT    eb2
    cmpi.w    #16,D0         
    BGT    eb2
    
    lea    temp,A5        *We have to load this now because
    clr.l    D1        *We can't have it being in the loop
    BRA    go        *Gotta skip the carry the first time we run it
    
    
carry:    move.l    D2,D4
go:    divu.w    D6,D4        *Store quotient and remainder in D4
    clr.l    D2        *get rid of any junk in D2 we don't need it
    move.w    D4,D2        *put quotient in D2
    swap    D4
    cmpi.w    #10,D4        
    BGE    great        *branch if greater than or = 10 else go to less
    
less:    addi.w    #$30,D4
    move.b    D4,(A5)+
    addi.w    #1,D1
    tst.l    D2
    BNE    carry
    BEQ    reverse
    
great:    addi.w    #$37,D4
    move.b    D4,(A5)+
    addi.w    #1,D1
    tst.l    D2
    BNE    carry
    BEQ    reverse
    
    
reverse:lea    ans,A6
reverse2:subq    #1,D1
    move.b    -(A5),(A6)+
    cmpi.w    #0,D1
    BNE    reverse2
    move.b    #0,(A6)        *null terminate string
    BRA    answer
    
    
eb1:    lineout e1
    BRA    in1
eb2:    lineout    e3
    BRA    in2
eb3:    lineout    e2
    BRA    in2
eb4:    lineout    e3
    BRA    in2
eb5:    lineout e2
    BRA    in1
    
answer:lineout    anstxt


        break                   * Terminate execution
*
*----------------------------------------------------------------------
*       Storage declarations

title:    dc.b    'Base Converter, Michael Green',0
skipln:    dc.b    0
buff1:  ds.b    80
buff2:    ds.b    80
bufft:    ds.b    80
p1:    dc.b    'Enter a base 10 number:',0
p2:    dc.b    'Enter the base to convert to:',0
anstxt:    dc.b    'The answer is: '
ans:    ds.b    20
temp:    ds.b    20
e1:    dc.b    'Error: Enter a number that is in base ten.',0
e2:    dc.b    'Error: Only input a number between 0 and 65535',0
e3:    dc.b    'Error: Only input a base ten number between 2 and 16.',0


        end


