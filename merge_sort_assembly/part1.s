	AREA MergeSort_M0, CODE, READONLY
	THUMB
	ENTRY

	EXPORT main
	EXPORT my_MergeSort
	EXPORT my_Merge

; MAIN FUNCTION
; We set up the initial values here and start the sorting process.
; ----------------------------------------------------------------------------
main PROC
    ; First, we load the specific unsorted numbers given in the assignment
    MOVS R0, #38        ; Loading 38 into R0
    MOVS R1, #27        ; Loading 27 into R1
    MOVS R2, #43        ; Loading 43 into R2
    MOVS R3, #10        ; Loading 10 into R3
    MOVS R4, #55        ; Loading 55 into R4

    ; We can't do merge sort inside registers, so we push them to the stack
    ; This basically creates our array in memory
    PUSH {R0-R4}        ; SP (Stack Pointer) now points to the start of our array
    
    ; Now we prepare the arguments for our function: my_MergeSort(Arr, Left, Right)
    MOV R0, SP          ; Arg1: The base address of our array (Stack Pointer)
    MOVS R1, #0         ; Arg2: Starting index (Left) is 0
    MOVS R2, #4         ; Arg3: Ending index (Right) is 4 (since we have 5 elements)

    ; We call the recursive sort function here
    BL my_MergeSort     ; Branch with Link to my_MergeSort

    ; The assignment requires the final sorted result to be in R0-R4
    ; So we pop the sorted values back from the stack into registers
    POP {R0-R4}         

stop
    B stop              ; We loop here forever because the program is done
    ENDP



; R0: Base Address, R1: Left Index, R2: Right Index
; We split the array into halves until we can't split anymore.
; ----------------------------------------------------------------------------
my_MergeSort PROC
    ; We need to save R4-R6 and the Return Address (LR)
    ; If we don't save LR, we can't return from the recursive calls!
    PUSH {R4-R6, LR}    

    ; Base Case Check: If Left >= Right, there's nothing to split
    CMP R1, R2          
    BGE ms_end          ; If true, we just jump to the end

    ; We calculate the Middle Index: Mid = (Left + Right) / 2
    ADDS R3, R1, R2      
    ASRS R3, R3, #1      ; Shifting right by 1 is the same as dividing by 2

    ; We need to save our current Left, Right, and Mid values
    ; because the recursive calls will mess up R1, R2, and R3
    MOV R4, R1          ; Storing Left in R4
    MOV R5, R2          ; Storing Right in R5
    MOV R6, R3          ; Storing Mid in R6

    ; Recursive Call 1: Sort the Left Half -> (Left to Mid)
    MOV R2, R6          ; Setting the new Right limit to Mid
    BL my_MergeSort     ; Calling function for the left side

    ; Recursive Call 2: Sort the Right Half -> (Mid+1 to Right)
    MOV R1, R6          
    ADDS R1, R1, #1     ; Setting the new Left limit to Mid + 1
    MOV R2, R5          ; Restoring the original Right limit
    BL my_MergeSort     ; Calling function for the right side

    ; Now that both halves are sorted, we merge them together
    ; Arguments: my_Merge(Arr, Left, Mid, Right)
    MOV R1, R4          ; Restore original Left
    MOV R2, R6          ; Restore original Mid
    MOV R3, R5          ; Restore original Right
    BL my_Merge         ; Jump to the merge logic

ms_end
    ; We are done here, so we restore the registers and return
    POP {R4-R6, PC}     ; Popping PC makes us return to the caller
    ENDP


; R0: Base, R1: Left, R2: Mid, R3: Right
; We merge two sorted subarrays into one sorted array using a temp buffer.
; ----------------------------------------------------------------------------
my_Merge PROC
    ; Saving working registers so we don't overwrite important stuff
    PUSH {R4-R7, LR}    

    ; We need a temporary array (buffer) on the stack
    ; Calculation: Size = (Right - Left + 1) * 4 bytes
    SUBS R6, R3, R1     ; R6 = Right - Left
    ADDS R6, R6, #1     ; R6 = Count (Number of elements)
    LSLS R6, R6, #2     ; R6 = Count * 4 (Total bytes needed)

    ; We allocate space on the Stack (Dynamic Allocation)
    ; Note: In Thumb-1, we can't do 'SUB SP, SP, R6' directly.
    ; So we use R5 as a helper register.
    MOV R5, SP          ; Copy Stack Pointer to R5
    SUBS R5, R5, R6     ; Subtract the size from R5
    MOV SP, R5          ; Update SP (Now we have space allocated)
    ; R5 now points to the start of our Temporary Buffer

    ; Setting up our loop pointers:
    ; i = Left (R1 is already Left)
    ; j = Mid + 1
    MOV R4, R2          ; Copy Mid to R4
    ADDS R4, R4, #1     ; R4 becomes 'j' (Start of the right half)

    ; The Merge Loop: We run this while both sides still have elements
merge_loop
    CMP R1, R2          ; Check if left side is finished (i > Mid)
    BGT copy_right_rem  ; If yes, we just copy the rest of the right side
    
    CMP R4, R3          ; Check if right side is finished (j > Right)
    BGT copy_left_rem   ; If yes, we just copy the rest of the left side

    ; We load Arr[i] into R6
    LSLS R6, R1, #2     ; Calculate offset: i * 4
    LDR R6, [R0, R6]    ; Load the value from memory

    ; We load Arr[j] into R7
    LSLS R7, R4, #2     ; Calculate offset: j * 4
    LDR R7, [R0, R7]    ; Load the value from memory

    ; We compare the two values: Arr[i] vs Arr[j]
    CMP R6, R7          
    BLE pick_left       ; If Arr[i] is smaller or equal, we pick it

    ; Otherwise, we pick the Right one (Arr[j] is smaller)
    STM R5!, {R7}       ; Store Arr[j] into Temp Buffer and increment ptr
    ADDS R4, R4, #1     ; Increment j
    B merge_loop        ; Go back to start of loop

pick_left
    STM R5!, {R6}       ; Store Arr[i] into Temp Buffer and increment ptr
    ADDS R1, R1, #1     ; Increment i
    B merge_loop        ; Go back to start of loop

;If there are leftovers in the Left side, copy them
copy_left_rem
    CMP R1, R2          ; Are we done with left side?
    BGT end_merge       ; If yes, go to end
    LSLS R6, R1, #2     ; Calculate offset
    LDR R6, [R0, R6]    ; Load value
    STM R5!, {R6}       ; Store to temp
    ADDS R1, R1, #1     ; i++
    B copy_left_rem

;If there are leftovers in the Right side, copy them
copy_right_rem
    CMP R4, R3          ; Are we done with right side?
    BGT end_merge       ; If yes, go to end
    LSLS R7, R4, #2     ; Calculate offset
    LDR R7, [R0, R7]    ; Load value
    STM R5!, {R7}       ; Store to temp
    ADDS R4, R4, #1     ; j++
    B copy_right_rem

end_merge
    ; Now we have the sorted list in the Temp Buffer.
    ; We need to copy it BACK to the original array.
    ; We modified 'Left' (R1), so we need to calculate it again.
    ; Formula: Original Left = Right - (Total Items - 1)
    
    MOV R6, SP          ; R6 points to start of Temp Buffer
    SUBS R4, R5, R6     ; R4 = Total bytes written (End Ptr - Start Ptr)
    LSRS R4, R4, #2     ; R4 = Total item count (Bytes / 4)

    SUBS R1, R3, R4     ; Right - Count
    ADDS R1, R1, #1     ; Add 1 to get Original Left Index

    ; Loop to copy data back to original array
copy_back
    CMP R4, #0          ; Check if we copied everything
    BEQ finish_func     ; If count is 0, we are done
    
    LDM R6!, {R7}       ; Load from Temp Buffer, increment R6
    LSLS R2, R1, #2     ; Calculate target offset
    STR R7, [R0, R2]    ; Store value back into Original Array
    
    ADDS R1, R1, #1     ; Increment target index (i++)
    SUBS R4, R4, #1     ; Decrement counter
    B copy_back

finish_func
    ; We must clean up the Stack (Memory Management)
    ; We need to restore SP to where it was before we allocated the buffer
    MOV R6, SP          ; Current SP
    SUBS R4, R5, R6     ; Calculate the size we used
    ADD SP, SP, R4      ; Add that size back to SP (Deallocation)

    POP {R4-R7, PC}     ; Restore saved registers and return
    ENDP

    ALIGN
    END