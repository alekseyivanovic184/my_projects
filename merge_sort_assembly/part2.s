		AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY

        EXPORT main
        EXPORT my_MergeSort
        EXPORT my_Merge

main    PROC
    ; ---------------------------------------------------------
    ; STEP 1: We manually place our array into Memory (RAM).
    ; Since we cannot use DCD, we write values one by one to address 0x20000000.
    ; Array: 13, 27, 10, 7, 22, 56, 28, 2
    ; ---------------------------------------------------------
    
    LDR     R7, =0x20000000 ; We load the starting memory address for our array

    MOVS    R0, #13
    STR     R0, [R7, #0]    ; We put 13 at index 0

    MOVS    R0, #27
    STR     R0, [R7, #4]    ; We put 27 at index 1

    MOVS    R0, #10
    STR     R0, [R7, #8]    ; We put 10 at index 2

    MOVS    R0, #7
    STR     R0, [R7, #12]   ; We put 7 at index 3

    MOVS    R0, #22
    STR     R0, [R7, #16]   ; We put 22 at index 4

    MOVS    R0, #56
    STR     R0, [R7, #20]   ; We put 56 at index 5

    MOVS    R0, #28
    STR     R0, [R7, #24]   ; We put 28 at index 6

    MOVS    R0, #2
    STR     R0, [R7, #28]   ; We put 2 at index 7

    ; ---------------------------------------------------------
    ; STEP 2: Call MergeSort
    ; ---------------------------------------------------------
    MOV     R0, R7          ; We set R0 as the Base Address
    MOVS    R1, #0          ; We set the Left Index to 0
    MOVS    R2, #7          ; We set the Right Index to 7 (Array Size - 1)

    BL      my_MergeSort    ; We call our recursive sort function

    ; ---------------------------------------------------------
    ; STEP 3: Verify Results
    ; We load the sorted values back into registers to check if it worked.
    ; ---------------------------------------------------------
    LDR     R0, [R7, #0]    ; Expected: 2
    LDR     R1, [R7, #4]    ; Expected: 7
    LDR     R2, [R7, #8]    ; Expected: 10
    LDR     R3, [R7, #12]   ; Expected: 13
    LDR     R4, [R7, #16]   ; Expected: 22
    LDR     R5, [R7, #20]   ; Expected: 27
    LDR     R6, [R7, #24]   ; Expected: 28
    LDR     R7, [R7, #28]   ; Expected: 56

stop    B       stop            ; Infinite loop to end the program
    ENDP


my_MergeSort PROC
    PUSH    {R3-R7, LR}     ; We save our registers and return address

    ; Base Case: We check if Left >= Right.
    ; If so, the array has 1 element and is already sorted.
    CMP     R1, R2
    BGE     sort_exit

    ; We calculate Mid = (Left + Right) / 2
    ; We do this in two steps because Cortex-M0+ can't add 3 registers at once.
    MOV     R3, R1          ; R3 = Left
    ADD     R3, R3, R2      ; R3 = Left + Right
    LSRS    R3, R3, #1      ; R3 = (Left + Right) / 2

    ; --- Sort Left Half ---
    PUSH    {R0-R3}         ; We save current parameters before recursion
    MOV     R2, R3          ; We set Right = Mid
    BL      my_MergeSort    ; We sort the left side
    POP     {R0-R3}         ; We restore parameters

    ; --- Sort Right Half ---
    PUSH    {R0-R3}         ; We save parameters again
    MOVS    R4, R3          ; We copy Mid to R4
    ADDS    R4, R4, #1      ; We calculate Mid + 1
    MOV     R1, R4          ; We set Left = Mid + 1
    BL      my_MergeSort    ; We sort the right side
    POP     {R0-R3}         ; We restore parameters

    ; --- Merge ---
    ; Now that both sides are sorted, we merge them.
    BL      my_Merge

sort_exit
    POP     {R3-R7, PC}     ; We return to where we were called
    ENDP


my_Merge PROC
    PUSH    {R4-R7, LR}     ; We save registers used in this function

    MOV     R7, R1          ; We save the Original Left index in R7 to use it later

    ; We recalculate Mid: R3 = (Left + Right) / 2
    MOV     R3, R1
    ADD     R3, R3, R2
    LSRS    R3, R3, #1

    ; We calculate the size of the buffer needed.
    ; Size = (Right - Left + 1) * 4 bytes
    MOV     R6, R2          ; R6 = Right
    SUBS    R6, R6, R1      ; R6 = Right - Left
    ADDS    R6, R6, #1      ; R6 = Element Count
    LSLS    R6, R6, #2      ; R6 = Total Bytes needed

    ; We allocate space on the Stack for our temporary buffer.
    ; We use R5 temporarily because M0+ can't subtract register from SP directly.
    MOV     R5, SP          ; We copy Stack Pointer to R5
    SUBS    R5, R5, R6      ; We move the pointer down by 'Size' bytes
    MOV     SP, R5          ; We update the Stack Pointer
    
    MOV     R4, SP          ; R4 is now the start of our Buffer

    ; We set up our loop pointers:
    ; R1 is for Left side, R5 is for Right side (starts at Mid + 1)
    MOV     R5, R3
    ADDS    R5, R5, #1      ; j = Mid + 1

merge_loop
    ; Check if Left side is finished
    CMP     R1, R3
    BGT     fill_right
    ; Check if Right side is finished
    CMP     R5, R2
    BGT     fill_left

    ; We load values to compare
    PUSH    {R2, R3}        ; We temporarily save Right and Mid
    
    LSLS    R2, R1, #2      ; Calculate offset for Left
    LDR     R2, [R0, R2]    ; Load Value from Left

    LSLS    R3, R5, #2      ; Calculate offset for Right
    LDR     R3, [R0, R3]    ; Load Value from Right

    ; We compare the two values
    CMP     R2, R3
    BLE     take_left       ; If Left <= Right, we pick Left

    ; We take the value from the Right side
    STR     R3, [R4]        ; Store it in Buffer
    ADDS    R4, R4, #4      ; Move Buffer pointer forward
    ADDS    R5, R5, #1      ; Move Right index forward
    POP     {R2, R3}        ; Restore Right and Mid
    B       merge_loop

take_left
    ; We take the value from the Left side
    STR     R2, [R4]        ; Store it in Buffer
    ADDS    R4, R4, #4      ; Move Buffer pointer forward
    ADDS    R1, R1, #1      ; Move Left index forward
    POP     {R2, R3}        ; Restore Right and Mid
    B       merge_loop

fill_left
    ; we check if there are items left on the left side
    CMP     R1, R3
    BGT     do_writeback    ; If left side is empty, we go to write back
    
    PUSH    {R2}            ; We save r2 to use it as temp
    LSLS    R2, R1, #2      ; We calculate the address offset for left item
    LDR     R2, [R0, R2]    ; We load the value from the main array
    STR     R2, [R4]        ; We write the value into our buffer
    POP     {R2}            ; We restore r2
    
    ADDS    R4, R4, #4      ; We move the buffer pointer forward
    ADDS    R1, R1, #1      ; We increase the left index counter
    B       fill_left       ; We loop back to check next item

fill_right
    ; we check if there are items left on the right side
    CMP     R5, R2
    BGT     do_writeback    ; If right side is empty, we go to write back
    
    PUSH    {R3}            ; We save r3 to use it as temp
    LSLS    R3, R5, #2      ; We calculate the address offset for right item
    LDR     R3, [R0, R3]    ; We load the value from the main array
    STR     R3, [R4]        ; We write the value into our buffer
    POP     {R3}            ; We restore r3
    
    ADDS    R4, R4, #4      ; We move the buffer pointer forward
    ADDS    R5, R5, #1      ; We increase the right index counter
    B       fill_right     ; We loop back to check next item

do_writeback
    ; Now we copy the sorted buffer back to the main Array.
    ; We calculate how many bytes to copy.
    MOV     R6, R4          ; Buffer End Address
    MOV     R5, SP          ; Buffer Start Address
    SUBS    R6, R6, R5      ; Total Bytes
    LSRS    R6, R6, #2      ; Convert to Element Count

    MOV     R1, SP          ; Source is Stack (Buffer)
    LSLS    R2, R7, #2      ; Offset = Original Left * 4 (We use saved R7 here)
    ADD     R2, R0, R2      ; Destination is Array Start + Offset

wb_loop
    CMP     R6, #0          ; Check if we are done
    BEQ     cleanup
    
    LDR     R3, [R1]        ; Read from Buffer
    STR     R3, [R2]        ; Write to Array
    
    ADDS    R1, R1, #4      ; Next Source
    ADDS    R2, R2, #4      ; Next Destination
    SUBS    R6, R6, #1      ; Decrement counter
    B       wb_loop

cleanup
    ; We free the memory we allocated on the Stack
    MOV     SP, R4          ; Restore Stack Pointer

    POP     {R4-R7, PC}     ; Return to caller
    ENDP

    END