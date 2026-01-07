\# ARM Cortex-M Drawing Engine with SysTick Interrupts



This project implements a low-level drawing engine using \*\*ARM Assembly (Thumb instruction set)\*\* for Cortex-M processors. It utilizes the \*\*SysTick Timer\*\* to process drawing commands periodically via interrupts, simulating a "cursor" moving and painting on a memory-mapped canvas.



\## 🚀 Features



\* \*\*SysTick Timer Interrupts:\*\* Configured to trigger an interrupt every \*\*1 second\*\* (based on a 10 MHz clock) to fetch the next instruction.

\* \*\*Command Parsing:\*\* Reads byte-codes from an array, splitting them into high/low nibbles to determine the operation type (Move vs. Color Change).

\* \*\*Stack Manipulation:\*\* Demonstrates advanced stack usage (PUSH/POP) to preserve register states (`R0`, `R1`) and pass arguments between subroutines under strict register constraints.

\* \*\*Memory Mapped I/O:\*\* Simulates a 32x8 pixel canvas starting at memory address `0x20001000`.



\## 🛠 Command Structure



The engine parses 1-byte commands (`0xXY`):



| Command Type | High Nibble (X) | Low Nibble (Y) | Description |

| :--- | :--- | :--- | :--- |

| \*\*Color Change\*\* | `0xA` | `0x0 - 0xF` | Updates the drawing brush color. (e.g., `0xA8` sets color to 8). |

| \*\*Move Up\*\* | `0x0` | Length | Moves cursor UP by Y steps. |

| \*\*Move Right\*\* | `0x1` | Length | Moves cursor RIGHT by Y steps. |

| \*\*Move Down\*\* | `0x2` | Length | Moves cursor DOWN by Y steps. |

| \*\*Move Left\*\* | `0x3` | Length | Moves cursor LEFT by Y steps. |



\*Example:\* `0x14` -> Move \*\*Right\*\* (1) by \*\*4\*\* steps.



\## ⚙️ Technical Details



\* \*\*Processor Mode:\*\* Thread Mode \& Handler Mode (for ISR).

\* \*\*Clock Frequency:\*\* Assumed 10 MHz.

\* \*\*Reload Value:\*\* `0x0098967F` (for 1-second delay).

\* \*\*Canvas Resolution:\*\* 32 columns x 8 rows.



\## 📂 File Structure



\* `main.s`: Contains the interrupt handler, main logic loop, and drawing subroutines.



\## 🔧 How to Run



1\.  Open the project in \*\*Keil µVision\*\* or similar ARM IDE.

2\.  Build the target for a Cortex-M0+ / M3 / M4 processor.

3\.  Run the \*\*Simulation\*\*.

4\.  Monitor the Memory Window at `0x20001000` to see the "painting" occur in real-time.

