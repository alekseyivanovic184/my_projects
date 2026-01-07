; --- Constants for SysTick Timer ---
STCTRL      EQU     0xE000E010      ; Address of the SysTick Control Register
STRELOAD    EQU     0xE000E014      ; Address of the SysTick Reload Value Register
STCURRENT   EQU     0xE000E018      ; Address of the SysTick Current Value Register

; Calculation for 1 Second Delay:
; Processor Clock = 10 MHz (10,000,000 cycles per second)
; Formula: (Clock_Frequency * Time) - 1
; (10,000,000 * 1) - 1 = 9,999,999
; 9,999,999 in Hexadecimal is 0x0098967F
RELOAD_VAL  EQU     0x0098967F      ; The value to load into the timer for 1 sec delay

; --- Memory Address for the Canvas ---
CANVAS_ADDR EQU     0x20001000      ; The starting memory address for our drawing screen

        AREA    |.text|, CODE, READONLY ; Define the code section
        THUMB                           ; Use the Thumb instruction set
        EXPORT  __main                  ; Make the main function visible to the linker
        EXPORT  SysTick_Handler         ; Make the Interrupt Handler visible to the hardware
        EXPORT  __initial_sp            ; Export the Stack Pointer location

__main
        ; --- Part 1: Setup the SysTick Timer ---
        
        ; Step 1: Set the Reload Value
        LDR     R0, =STRELOAD           ; Load the address of the Reload Register into R0
        LDR     R1, =RELOAD_VAL         ; Load our calculated value (9,999,999) into R1
        STR     R1, [R0]                ; Write R1 into the Reload Register to set the time

        ; Step 2: Clear the Current Counter
        LDR     R0, =STCURRENT          ; Load the address of the Current Value Register
        MOVS    R1, #0                  ; Prepare the value 0 in R1
        STR     R1, [R0]                ; Write 0 to clear the counter and start fresh

        ; Step 3: Enable the Timer
        ; We need to set 3 bits: Enable(0), Interrupt(1), Clock Source(2).
        ; Binary 111 equals Decimal 7.
        LDR     R0, =STCTRL             ; Load the address of the Control Register
        MOVS    R1, #7                  ; Prepare the configuration value (Enable + Int + Clk)
        STR     R1, [R0]                ; Write it to start the timer running

main_loop
        ; --- Part 2: Wait for the Timer Interrupt ---
        
        ; We check the variable 'varb'. The Interrupt Handler will set it to 1 every second.
        LDR     R0, =varb               ; Load the address of the 'varb' flag
        LDR     R1, [R0]                ; Read the value of 'varb' into R1
        CMP     R1, #1                  ; Compare 'varb' with 1
        BNE     main_loop               ; If it is NOT 1, jump back to main_loop (wait)

        ; If we get here, 1 second has passed.
        ; Reset the flag to 0 so we can wait again next time.
        MOVS    R1, #0                  ; Prepare 0
        STR     R1, [R0]                ; Write 0 back to 'varb'

        ; --- Part 3 & 4: Process the Logic ---
        ; Now we call our function to read the inputs and draw on the canvas.
        BL      process_next_input      ; Branch with Link to the processing function
        
        B       main_loop               ; Jump back to the start to wait for the next second

;---------------------------------------------------------
; FUNCTION: process_next_input
; Description: Reads the next byte from the array, parses it,
; and decides if it is a Color Change or a Move command.
;---------------------------------------------------------
process_next_input PROC
        PUSH    {LR}                    ; Save the Link Register (return address) to Stack

        ; 1. Get the current index (vari)
        LDR     R0, =vari               ; Load address of the index variable 'vari'
        LDR     R1, [R0]                ; Read the current index value into R1

        ; 2. Read the command from the Array: arr[vari]
        LDR     R0, =arr                ; Load the starting address of the array 'arr'
        LSLS    R1, R1, #2              ; Multiply index by 4 (Shift Left 2) because each entry is 4 bytes
        ADDS    R0, R0, R1              ; Add offset to base address to get the specific element address
        LDR     R1, [R0]                ; Load the command (e.g., 0xA8) into R1

        ; 3. Update the index for next time (vari = vari + 1)
        PUSH    {R1}                    ; Save the command (R1) onto Stack because we need to use R1
        LDR     R0, =vari               ; Load address of 'vari' again
        LDR     R1, [R0]                ; Load current value
        ADDS    R1, R1, #1              ; Increment value by 1
        STR     R1, [R0]                ; Save the new index back to memory
        POP     {R1}                    ; Restore the command back into R1 from Stack

        ; 4. Check for End of Array (0xFF)
        CMP     R1, #0xFF               ; Compare the command with 0xFF (End Signal)
        BEQ     stop_program            ; If equal, jump to stop_program to end execution

        ; 5. Parse the Command (Split the Nibbles)
        ; The command has two parts: High Nibble (Type) and Low Nibble (Value).
        MOVS    R0, R1                  ; Copy the command to R0 so we can manipulate it
        LSRS    R0, R0, #4              ; Shift Right by 4 bits to isolate the High Nibble
        
        CMP     R0, #0xA                ; Check if the High Nibble is 0xA (Color Command)
        BEQ     handle_color            ; If yes, jump to handle_color code block
        
        ; If it is not 'A', it must be a Move Command (0, 1, 2, or 3)
        B       handle_move             ; Jump to handle_move code block

stop_program
        B       stop_program            ; Infinite loop to freeze the program when done

handle_color
        ; Logic: We need to extract the color number and save it to 'varc'.
        ; R1 currently holds the full byte (e.g., 0xA8). We want the '8'.
        MOVS    R0, #0x0F               ; Prepare a mask (0000 1111) in R0
        ANDS    R1, R1, R0              ; AND R1 with mask to clear the top bits. R1 is now just the color.
        
        LDR     R0, =varc               ; Load address of the color variable 'varc'
        STRB    R1, [R0]                ; Store the color byte into memory
        POP     {PC}                    ; Return from function (Pop LR into PC)

handle_move
        ; Logic: Move the cursor N times in a specific direction.
        ; R1 has the full byte (e.g., 0x14).
        ; High Nibble (1) is Direction. Low Nibble (4) is Length.
        
        ; We need to save R0 because we are restricted to only R0 and R1 (Part 4 requirement).
        PUSH    {R0}                    ; Save R0 to Stack
        
        MOVS    R0, R1                  ; Copy command to R0
        LSRS    R0, R0, #4              ; Shift Right 4 bits to get Direction
        PUSH    {R0}                    ; Save the Direction onto the Stack (Stack Top = Direction)
        
        MOVS    R0, #0x0F               ; Prepare mask
        ANDS    R1, R1, R0              ; Mask R1 to get Length (Loop Counter). R1 is now the Length.

move_loop
        CMP     R1, #0                  ; Check if the loop counter (Length) is 0
        BEQ     move_done               ; If 0, we are finished moving. Jump to done.
        
        PUSH    {R1}                    ; Save the loop counter to Stack before calling functions
        
        LDR     R1, [SP, #4]            ; Peek inside Stack to get Direction back (SP+4 because counter is on top)
        
        BL      move_step               ; Call function to move the coordinate 1 step
        BL      paint_pixel             ; Call function to paint the pixel at the new coordinate
        
        POP     {R1}                    ; Restore the loop counter from Stack
        SUBS    R1, R1, #1              ; Decrement the counter by 1
        B       move_loop               ; Jump back to start of loop

move_done
        POP     {R0}                    ; Remove the Direction from the Stack (Clean up)
        POP     {R0}                    ; Restore the original R0 value we saved at the start
        POP     {PC}                    ; Return from function
        ENDP

;---------------------------------------------------------
; FUNCTION: move_step
; Description: Updates X or Y coordinates based on Direction.
; Constraints: Uses Stack heavily to save registers to meet Part 4 requirements.
;---------------------------------------------------------
move_step PROC
        PUSH    {LR}                    ; Save return address
        
        ; We need to manipulate X and Y, but we only have R0/R1.
        ; Solution: Save current X and Y onto the Stack.
        LDR     R0, =varx               ; Load address of X
        LDR     R0, [R0]                ; Load value of X
        PUSH    {R0}                    ; Push X to Stack. Stack: [X]
        
        LDR     R0, =vary               ; Load address of Y
        LDR     R0, [R0]                ; Load value of Y
        PUSH    {R0}                    ; Push Y to Stack. Stack: [Y, X]
        
        ; R1 contains the Direction. We check which way to go.
        CMP     R1, #0                  ; Is Direction 0? (Up)
        BEQ     do_up                   ; Jump to Up logic
        CMP     R1, #1                  ; Is Direction 1? (Right)
        BEQ     do_right                ; Jump to Right logic
        CMP     R1, #2                  ; Is Direction 2? (Down)
        BEQ     do_down                 ; Jump to Down logic
        CMP     R1, #3                  ; Is Direction 3? (Left)
        BEQ     do_left                 ; Jump to Left logic
        B       move_step_end           ; Safety: If unknown, just exit

do_up
        POP     {R0}                    ; Pop Y from Stack into R0
        SUBS    R0, R0, #1              ; Decrement Y (Up means Y gets smaller)
        CMP     R0, #0                  ; Check boundary: Is Y < 0?
        BLT     restore_y               ; If yes (Limit exceeded), jump to restore old Y
        PUSH    {R0}                    ; If valid, Push new Y back to Stack
        B       check_save              ; Go to save section

do_down
        POP     {R0}                    ; Pop Y from Stack
        ADDS    R0, R0, #1              ; Increment Y (Down means Y gets bigger)
        CMP     R0, #8                  ; Check boundary: Is Y >= 8? (Height is 8)
        BGE     restore_y               ; If yes, jump to restore old Y
        PUSH    {R0}                    ; If valid, Push new Y back to Stack
        B       check_save              ; Go to save section

restore_y
        ; If a move was invalid, we ignore the change.
        LDR     R0, =vary               ; Load address of Y variable
        LDR     R0, [R0]                ; Load the OLD Y value from memory
        PUSH    {R0}                    ; Push old Y onto Stack (pretend nothing happened)
        B       check_save              ; Go to save section

do_right
        POP     {R0}                    ; Pop Y (we don't need Y for right move)
        PUSH    {R0}                    ; Put Y back immediately to keep Stack order
        LDR     R0, [SP, #4]            ; Load X from Stack (it is below Y)
        ADDS    R0, R0, #1              ; Increment X (Right means X gets bigger)
        CMP     R0, #32                 ; Check boundary: Is X >= 32? (Width is 32)
        BGE     move_step_end           ; If yes, exit without saving
        STR     R0, [SP, #4]            ; If valid, overwrite X in the Stack with new value
        B       check_save              ; Go to save section

do_left
        POP     {R0}                    ; Pop Y
        PUSH    {R0}                    ; Put Y back
        LDR     R0, [SP, #4]            ; Load X from Stack
        SUBS    R0, R0, #1              ; Decrement X (Left means X gets smaller)
        CMP     R0, #0                  ; Check boundary: Is X < 0?
        BLT     move_step_end           ; If yes, exit without saving
        STR     R0, [SP, #4]            ; If valid, overwrite X in the Stack
        B       check_save              ; Go to save section

check_save
        ; Now the Stack contains the valid New Y and New X.
        ; We pop them and save to actual memory variables.
        POP     {R1}                    ; Pop New Y into R1
        LDR     R0, =vary               ; Load address of Y variable
        STR     R1, [R0]                ; Save New Y to memory
        
        POP     {R1}                    ; Pop New X into R1
        LDR     R0, =varx               ; Load address of X variable
        STR     R1, [R0]                ; Save New X to memory
        B       final_exit              ; Finished saving

move_step_end
        POP     {R0, R1}                ; If we cancelled, just clear the Stack (Pop X and Y)
final_exit
        POP     {PC}                    ; Return from function
        ENDP

;---------------------------------------------------------
; FUNCTION: paint_pixel
; Description: Calculates memory address and writes color.
; Formula: Address = Base + (Y * 32) + X
;---------------------------------------------------------
paint_pixel PROC
        PUSH    {LR}                    ; Save return address
        
        ; Calculate Offset for Y (Row)
        LDR     R0, =vary               ; Load address of Y
        LDR     R0, [R0]                ; Load value of Y
        LSLS    R0, R0, #5              ; Shift Left 5 bits (Multiply by 32). R0 = Y * 32
        
        ; Add X (Column)
        LDR     R1, =varx               ; Load address of X
        LDR     R1, [R1]                ; Load value of X
        ADDS    R0, R0, R1              ; Add X to the row offset. R0 = (Y*32) + X
        
        ; Add Base Address
        LDR     R1, =CANVAS_ADDR        ; Load the canvas starting address
        ADDS    R0, R0, R1              ; Add Base to Offset. R0 is now the final physical address
        
        ; Get the current color
        LDR     R1, =varc               ; Load address of color variable
        LDRB    R1, [R1]                ; Read the color byte
        
        ; Paint the pixel!
        STRB    R1, [R0]                ; Write the color to the calculated memory address
        
        POP     {PC}                    ; Return from function
        ENDP

;---------------------------------------------------------
; INTERRUPT HANDLER: SysTick_Handler
; Description: Called automatically every 1 second.
;---------------------------------------------------------
SysTick_Handler
        PUSH    {R0, R1, LR}            ; Save registers to protect main program context
        LDR     R0, =varb               ; Load address of the flag 'varb'
        MOVS    R1, #1                  ; Prepare value 1
        STR     R1, [R0]                ; Set 'varb' to 1 (Signal that time is up)
        POP     {R0, R1, PC}            ; Restore registers and return

;---------------------------------------------------------
; DATA SECTION
; Description: Defines variables and arrays used in program.
;---------------------------------------------------------
        AREA    myData, DATA, READONLY  ; Define Read-Only Data Section
        ; The "Shorter Example" Array
arr     DCD     0xA8, 0x14, 0x24, 0x32, 0x02, 0xFF

        AREA    myDataRW, DATA, READWRITE ; Define Read-Write Data Section
        ALIGN                           ; Align memory to 4-byte boundaries
varx    DCD     0                       ; Variable for X Position
vary    DCD     0                       ; Variable for Y Position
varc    DCB     0                       ; Variable for Current Color (1 Byte)
        ALIGN                           ; Re-align after a Byte definition
vari    DCD     0                       ; Variable for Array Index
varb    DCD     0                       ; Variable for Timer Flag

;---------------------------------------------------------
; STACK DEFINITION
; Description: Manually defines Stack space to fix Linker errors.
;---------------------------------------------------------
        AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   0x00000200      ; Reserve 512 Bytes for Stack memory
__initial_sp                            ; Label for stack pointer top
        EXPORT  __initial_sp            ; Export label for the Linker to see
        
        END                             ; End of the assembly file