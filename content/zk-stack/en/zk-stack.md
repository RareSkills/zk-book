# Modeling the Stack Data Structure in ZK

This tutorial shows how to create a stack in Circom.

Be warned — this chapter is long.

However, the strategy for creating ZK proofs about stacks will be essential when we create a simple ZK Virtual Machine (ZKVM) in the next chapter. Most of the work for understanding how a ZKVM works has been front-loaded to this chapter.

The stack is able to **push** a number to the top of the stack, **pop** the top of the stack, or make **no changes**.

Stacks are inherently mutable, but in Circom, we are only allowed to use an immutable array. Therefore, a stack must be modeled with an immutable array. Each time the stack changes (via pop or push), we create a new array that represents the new stack state.

This might seem inefficient, but there is no way around this as signals in ZK are immutable (more advanced ZK techniques have ways of optimizing this, but that discussion is outside the scope of this article).

The first requirement is that the stack has a fixed “maximum height” — which is how long the immutable array is. To track how much of the stack is “used,” we employ a separate variable called a “stack pointer,” which is a zero-based index and tells us where to push the next item. `sp` points to an unused placed in the array where a new value should be pushed, which is one index above the top of the stack. The diagram below illustrates a stack with three items, 10, 16, and 20:

$$
\begin{align*}\texttt{sp}=3\\
\begin{array}{|c|c|c|c|c|c|c|}
\hline
\text{array}&10 & 16 & 20 & \circ &  \space &  \space \\ \hline
\text{index}&0 & 1 &2 &3 &4 &5\\
\hline
\end{array}
\end{align*}
$$

The stack pointer `sp` is pointing to index 3, which is empty and denoted with $\circ$. The stack ignores any value at index 3 (the current `sp`) or greater. They could have non-zero values, but the circuit would not consider them.

Suppose we push the item `21` onto the stack. This means we increment the stack pointer and copy all the previous values. The updated stack now has `sp` = 4.

$$
\begin{align*}\texttt{sp}=4\\
\begin{array}{|c|c|c|c|c|c|}
\hline
10& 16 & 20 &  \circ &  \space \\ \hline
10 & 16 & 20 & 21&  \circ &  \space \\ \hline
\end{array}
\end{align*}
$$

If we pop from the stack, the `sp` is decremented and we do not copy the value `21` into the next stack:

$$
\begin{align*}\texttt{sp}=3\\
\begin{array}{|c|c|c|c|c|c|}
\hline
10 & 16 & 20 &  \circ &  \space \\ \hline
10 & 16 & 20 & 21&  \circ &  \space \\ \hline
10 & 16 & 20 & \circ&  \space &  \space \\ \hline
\end{array}
\end{align*}
$$

If no changes happen to the stack, we still go through some kind of computation step, where we simply copy all the previous values to the next stack.

$$
\begin{align*}\texttt{sp}=3\\
\begin{array}{|c|c|c|c|c|c|}
\hline
10 & 16 & 20 &  \circ &  \space \\ \hline
10 & 16 & 20 & 21&  \circ &  \space \\ \hline
10 & 16 & 20 & \circ&  \space &  \space \\ \hline
10 & 16 & 20 & \circ&  \space &  \space \\ \hline
\end{array}
\end{align*}
$$

Since `sp` changes with each iteration, we need to store the new value in a new signal each time because the value of a signal can’t be updated once assigned. Therefore, we use an array to track the value of `sp` on each iteration:

$$

\begin{array}{|c||c|c|c|c|c|c|}
\hline
\texttt{sp}\downarrow & \\
\hline
3 & 10 & 16 & 20 &  \circ &  \space \\ \hline
4 & 10 & 16 & 20 & 21&  \circ &  \space \\ \hline
3 &10 & 16 & 20 & \circ&  \space &  \space \\ \hline
3 &10 & 16 & 20 & \circ&  \space &  \space \\ \hline
\end{array}
$$

Just as there is a maximum height of the stack, there is also a maximum number of times we can update it, as the table modeling the stack (a 2D Circom array under the hood) must be of fixed size.

The maximum size depends on our application. In a blockchain setting, it is very unlikely 1 million instructions can be executed, but when creating circuits for more intensive applications we may need to allocate a larger circuit to accommodate potential stack sizes.

### Constraints for the stack

Regardless of whether we push, pop, or do nothing, the items from 0 to `sp - 2` inclusive need to be copied (and constrained to be equal) to the next stack. In the example below, the stack pointer was at 4, then we executed a pop operation, and the stack pointer became 3. The items at stack pointer index 0, 1, 2 (in orange) were copied.

$$
\begin{array}{|c||c|c|c|c|c|c|}
\hline
\texttt{sp} & 0 & 1 & 2 &3 & 4 & 5\\
\hline
4 & \color{orange}{10} & \color{orange}{16} & \color{orange}{20} & 21&  \circ &  \space \\ \hline
3 &\color{orange}{10} & \color{orange}{16} & \color{orange}{20} & \circ&  \space &  \space \space \\ \hline
\end{array}
$$

If the instruction is pop, then we also require that the new stack pointer is 1 less than the previous.

### Constraints for push

During a push, all the values up to `sp - 1` must be copied into the new stack (note that the stack pointer points to an empty region, so there is no need to copy it). The value at `sp - 1` must be constrained to be the value pushed.

$$
\begin{array}{|c||c|c|c|c|c|c|}
\hline
\texttt{sp} & 0 & 1 & 2 &3 & 4 & 5\\
\hline
3 &\color{orange}{10} & \color{orange}{16} & \color{orange}{20} & \circ&  \space &  \space 
\space \\ \hline
4 & \color{orange}{10} & \color{orange}{16} & \color{orange}{20} & 24&  \circ &  \space \\ \hline
\end{array}
$$

In the example above, the stack pointer was 3, and we copied the items in 0, 1, 2. We also constrain that the stack pointer increments by 1. We must also constrain the stack pointer to be one larger than it was previously.

### Constraints for pop

During a pop, all values up to `sp - 2` must be copied into the new stack. We constrain the stack pointer to decrement by one.

$$
\begin{array}{|c||c|c|c|c|c|c|}
\hline
\texttt{sp} & 0 & 1 & 2 &3 & 4 & 5\\
\hline
3 &\color{orange}{10} & \color{orange}{16} & \color{orange}{20} & \circ&  \space &  \space 
\space \\ \hline
2 & \color{orange}{10} & \color{orange}{16} & \circ & &  &  \space \\ \hline
\end{array}
$$

### Constraints for nop (do nothing)

All values up to `sp - 1` must be constrained to be the same. The `sp` must be constrained to equal the previous iteration’s value.

$$
\begin{array}{|c||c|c|c|c|c|c|}
\hline
\texttt{sp} & 0 & 1 & 2 &3 & 4 & 5\\
\hline
3 &\color{orange}{10} & \color{orange}{16} & \color{orange}{20} & \circ&  \space &  \space 
\space \\ \hline
3 & \color{orange}{10} & \color{orange}{16} & \color{orange}{20} & \circ& &  \space \\ \hline
\end{array}
$$

## Updating a stack per a set of instructions

At each iteration of the instructions, we need to know if we are going to push a number, pop the top, or do nothing, which we will denote with “opcodes” or “instructions” PUSH, POP, or NOP.

For example, suppose we are given the instructions `PUSH 10 POP PUSH 16 PUSH 15 PUSH 4 NOP POP`. We could represent this set of instructions as an array:

[PUSH, 10, POP, 0, PUSH, 16, PUSH, 15, PUSH, 4, NOP, 0, POP, 0]

Without loss of generality, we could refer to PUSH as the number 1, POP as 2, and NOP as 0, so the instructions could be encoded as follows.

$$
\begin{matrix}
1 & 10 & 2 & 0 & 1 & 16 & 1 & 15 & 1 & 4 & 0 & 0 & 2&  0\\
\texttt{PUSH}&&\texttt{POP}&&\texttt{PUSH}&&\texttt{PUSH}&&\texttt{PUSH}&&\texttt{NOP}&&\texttt{POP}
\end{matrix}
$$

Note that each instruction always has a constant after it. For PUSH, this is the value to push, but for POP and NOP, the constant afterward is ignored. Putting the instruction at indexes 0,2,4,… etc., allows us to iterate through the instructions in steps of two. In other words, if the instructions could have an argument or not, then we would need to change the step size depending on whether there is an argument. This conditional step size increases the complexity of our example, so we put the opcodes at even intervals so we can always make a step of two.

Now, let’s generate a “metaTable” which tells us which operation will happen at each row of the execution. If we add columns `is_push`, `is_pop`, or `is_nop` which indicate which instruction is active, then we get the following table.

<video src="https://r2media.rareskills.io/ZkStack/stack.mp4" type="video/mp4" autoplay loop muted controls></video>

The final result would look like the following, but we will reconstruct this table step-by-step in the upcoming section:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 10 & - & - & - \\\hline0 & \color{orange}{1} & 0 & - & 1 & - & - & - & - \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 16 & - & - & - \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & 16 & 15 & - & - \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & 16 & 15 & 4 & - \\\hline0 & 0 & \color{orange}{1} & - & 3 & 16 & 15 & 4 & - \\\hline0 & \color{orange}{1} & 0 & - & 3 & 16 & 15 & - & - \\\hline\end{array}
$$

The interpretation of `sp` is where the next value should be written if the current instruction is push. If the instruction is `pop`, then `sp - 1` is the item that should not be copied.

## Populating the table

To populate the table from `is_push` to `arg`, we can simply copy the instructions in a loop and set `is_push` to 1 if the current instruction is PUSH, and so forth for the other instructions. We would get the following result:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & & & & & \\\hline0 & \color{orange}{1} & 0 & - & & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 4 & & & & & \\\hline0 & 0 & \color{orange}{1} & - & & & & & \\\hline0 & \color{orange}{1} & 0 & - & & & & & \\\hline\end{array}
$$

The stack pointer must always start at zero, so we can simply hardcode that:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_apop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & \boxed{0}& & & & \\\hline0 & \color{orange}{1} & 0 & - & & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 4 & & & & & \\\hline0 & 0 & \color{orange}{1} & - & & & & & \\\hline0 & \color{orange}{1} & 0 & - & & & & & \\\hline\end{array}
$$

We can populate the remainder of the stack pointer column by incrementing if the instruction is PUSH, decrementing for POP, and keeping it the same for NOP. Note that we update the *next* for `sp` based on the current row. Therefore, on iteration 0, we update row 1 as follows:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_apop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & \boxed{0}& & & & \\\hline0 & \color{orange}{1} & 0 & - & \boxed{1}& & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & & & & & \\\hline\color{orange}{1} & 0 & 0 & 4 & & & & & \\\hline0 & 0 & \color{orange}{1} & - & & & & & \\\hline0 & \color{orange}{1} & 0 & - & & & & & \\\hline\end{array}
$$

That is, because the current `is_push` is 1, and the current `sp` is 0, we write 0 + 1 to the next cell. We then fill up the rest of the `sp` column as follows:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & \\\hline0 & \color{orange}{1} & 0 & - & 3 & & & & \\\hline\end{array}
$$

We then write the push values to the appropriate cell simply by using the `sp` and `arg` columns conditioned on if `is_push` is 1. Note that only rows where `is_push == 1` are populated in this step:

$$
\begin{array}{|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & \\\hline0 & \color{orange}{1} & 0 & - & 3 & & & & \\\hline\end{array}
$$

Note that the previous values are not copied over — we will fix that in a later section.

### Handling the zeroth row

The zeroth row is unique because it doesn’t copy and values from the row above it. To avoid having to branch on the basis of whether we are in the zeroth row or not, we make the table one row larger than it needs to be, and then we start building our constraints at row 1. That way, each row always copies the row above it.

In the upcoming code demo, we hardwire the constraints in the 0th row because later, it will be inconvenient to treat the 0th row as a corner case for whether or not we copy the previous row’s values.

## Copying the previous row

Now, we need to ensure that values from one row to the next are copied properly. A cell copies the value above it up to the next row’s stack pointer minus 1. Remember, `sp` points to the empty space above the stack, so `sp - 1` points to the top of the stack.

### Column and Stack Terminology

Because we are storing the stack “sideways” in a table, we will refer to the bottom of the stack as column 0, the item on top of that column (if it exists) column 1, and so forth. When we say “column” we mean the “index” of the stack if the bottom one is zero.

### Constraints for copying

1. if `is_push = 1`, then all the items of the stack `0..sp - 1` inclusive must be copied. The cell at `sp` will contain the new incremented value. This copies the entire stack.
2. if `is_nop = 1`, then all the items of the stack `0..sp - 1` inclusive must be copied. Nothing is written to the cell at `sp`. This copies the entire stack.
3. if `is_pop = 1`, then all the items of the stack `0..sp - 2` inclusive must be copied. Remember, `sp` points to an empty cell above the stack, so `sp - 1` is the value that will be popped. Everything `sp - 2` and below must be copied. This copies everything except the top of the stack.

The conditions at 2 and 3 have corner cases if the stack pointer is 0 or 1, respectively, because an underflow would happen. Therefore, we need special columns that indicate if `sp` is less than 2 or 1, and we need to handle the copying differently. Specifically:

- if `sp = 0`, nothing will be copied
- if `sp = 1`, we will copy the cell at column 0 only if the instruction is NOP or PUSH

We create additional columns (`copy0`, `copy1`, `copy2`, `copy3`) that serve as flags to indicate if the value for (`column0`, `column1`, `column2`, `column3`) respectively will be copied to the next row.

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & & & & & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & & & & & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & & & & & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

### Handling initial conditions

We have another corner case when creating constraints for the 0th row — if we try to copy the values from the previous row, we will underflow the array. Therefore, we need to treat this row differently — we populate the value of the first row in a more “hardcoded” manner and then iteratively create the constraints starting at row 1.

### Determining if `copy` should be zero or one

Recall the constraints from earlier:

1. if `is_push = 1`, then all the values `0..sp - 1` inclusive must be copied. The cell at `sp` will contain the new value.
2. if `is_nop = 1`, then all the values `0..sp - 1` inclusive must be copied. Nothing is written to the cell at `sp`.
3. if `is_pop = 1`, then all the values `0..sp - 2` inclusive must be copied. Remember, `sp` points to an empty cell above the stack, so `sp - 1` is the value that will be popped. Everything `sp - 2` and below must be copied.

We can summarize those into two conditions A and B:

A. if the `sp` is 1 or greater, and our column is 1 index below `sp`, and the current instruction is PUSH or NOP, we should copy

B. if the `sp` is 2 or greater, and our column is 2 indexes below `sp`, and the current instruction is POP, we should copy

If our column does not meet any of the above conditions, we do not copy. These include:

- the current column is at or above the stack pointer
- the current column is 1 below the stack pointer, and the current instruction is pop
- stack pointer = 0

Using the rules above, let’s populate the table. At the 0th row, `sp = 0`, so all the copy columns will be 0:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & & & & & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & & & & & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

At the 1st indexed row, `sp` is 1 or greater, but the instruction is POP, but neither condition A or B are met for any column, so we do not copy:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & & & & & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & & & & & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

On the 2nd row, `sp` is 0, so nothing gets copied:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 0 & 0 & 0 & 0 & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & & & & & & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

On the 3rd row, `sp` is 1 and the instruction is PUSH, so column0 meets condition A:

“if the `sp` is 1 or greater, and our column is 1 indexes below `sp`, and the current instruction is PUSH or NOP, we should copy”

and `copy0` is set to 1:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 0 & 0 & 0 & 0 & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & \boxed{1} & 0 & 0 & 0 & 16 & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & & & & & & & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

On the 4th row, `sp` is 2 and the instruction is PUSH, so column 0 and column 1 meet condition A:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 0 & 0 & 0 & 0 & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & 1 & 0 & 0 & 0 & 16 & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & \boxed{1} & \boxed{1} & 0 & 0 & 16 & 15 & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & & & & & & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & & & & & & & & \\\hline\end{array}
$$

On the 5th row, `sp` is 3 and the instruction is NOP, so column 0, 1, and 2 meet condition A, which is ”if the `sp` is 1 or greater, and our column is 1 index below `sp`, and the current instruction is PUSH or NOP, we should copy”:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} & & & & \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 &0 & 0& 0&0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0& & & & \\\hline\color{orange}{1} & 0 & 0 & \texttt{16} & 0 & 0 & 0& 0& 0& 16 & & & \\\hline\color{orange}{1} & 0 & 0 & \texttt{15} & 1 & 1& 0& 0& 0& 16& 15 & & \\\hline\color{orange}{1} & 0 & 0 & \texttt{4} & 2 & 1& 1& 0& 0&16 &15 & 4 & \\\hline0 & 0 & \color{orange}{1} & \texttt{-} & 3 &\boxed{1} &\boxed{1} & \boxed{1}&0 & 16& 15& 4& \\\hline0 & \color{orange}{1} & 0 & \texttt{-} & 1 & & & & & & & & \\\hline\end{array}
$$

On the 6th row, `sp` is 1 and the instruction is POP, so we use condition B:

“if the `sp` is 2 or greater, and our column is 2 indexes below `sp`, and the current instruction is POP, we should copy”

This means that columns 0 and 1 will be copied:

$$
\begin{array}{|c|c|c|c|c|c|c|c|c||c|c|c|c|}\hline\texttt{is\_push} & \texttt{is\_pop} & \texttt{is\_nop} & \texttt{arg} & \texttt{sp} & \texttt{copy0} & \texttt{copy1} & \texttt{copy2} & \texttt{copy3} \\\hline\color{orange}{1} & 0 & 0 & 10 & 0 & 0 & 0 & 0 & 0 & 10 & & & \\\hline0 & \color{orange}{1} & 0 & - & 1 & 0 & 0 & 0 & 0 & & & & \\\hline\color{orange}{1} & 0 & 0 & 16 & 0 & 0 & 0 & 0 & 0 & 16 & & & \\\hline\color{orange}{1} & 0 & 0 & 15 & 1 & 1 & 0 & 0 & 0 & 16 & 15 & & \\\hline\color{orange}{1} & 0 & 0 & 4 & 2 & 1 & 1 & 0 & 0 & 16 & 15 & 4 & \\\hline0 & 0 & \color{orange}{1} & - & 3 & 1 & 1 & 1 & 0 & 16 & 15 & 4 & \\\hline0 & \color{orange}{1} & 0 & - & 1 & \boxed{1}&\boxed{1} & 0& 0& & & & \\\hline\end{array}
$$

### Circom implementation of copy conditions

We can create a specialized component in Circom to determine if a value should be copied from above. 

- A. if the `sp` is 1 or greater, and our column is 1 indexes below `sp`, and the current instruction is PUSH or NOP, we should copy
- B. if the `sp` is 2 or greater, and our column is 2 indexes below `sp`, and the current instruction is POP, we should copy

This component will be used in a loop to determine if a particular column `j` should be copied. It sets `out = 1` if a particular column should be copied. This component is applied to each column for each row.

```jsx
include "circomlib/comparators.circom";
include "circomlib/gates.circom";

// RETURNS 1 IF ALL THE INPUTS ARE 1
template AND3() {
  signal input in[3];
  signal output out;
  
  signal temp;
  temp <== in[0] * in[1];
  out <== temp * in[2];
}

// j is the column number
// bits is how many bits we need
// for the LessEqThan component
template ShouldCopy(j, bits) {
  signal input sp;
  signal input is_pop;
  signal input is_push;
  signal input is_nop;
  
  // out = 1 if should copy
  signal output out;
  
  // sanity checks
  is_pop + is_push + is_nop === 1;
  is_nop * (1 - is_nop) === 0;
  is_push * (1 - is_push) === 0;
  is_pop * (1 - is_pop) === 0;
  
  // it's cheaper to compute ≠ 0 than > 0 to avoid
  // converting the number to binary
  signal spEqZero;
  signal spGteOne;
  spEqZero <== IsZero()(sp);
  spGteOne <== 1 - spEqZero;
  
  // it's cheaper to compute ≠ 0 and ≠ 1 than ≥ 2
  signal spEqOne;
  signal spGteTwo;
  spEqOne <== IsEqual()([sp, 1]);
  spGteTwo <== 1 - spEqOne * spEqZero;
  
  // the current column is 1 or more 
  // below the stack pointer
  signal oneBelowSp <== LessEqThan(bits)([j, sp - 1]);
  
  // the current column is 2 or more
  // below the stack pointer
  signal twoBelowSP <== LessEqThan(bits)([j, sp - 2]);
  
  // condition A
  component a3A = AND3();
  a3A.in[0] <== spGteOne;
  a3A.in[1] <== oneBelowSp;
  a3A.in[2] <== is_push + is_nop;
  
  // condition B
  component a3B = AND3();
  a3B.in[0] <== spGteTwo;
  a3B.in[1] <== twoBelowSP;
  a3B.in[2] <== is_pop;
  
  component or = OR();
  or.a <== a3A.out;
  or.b <== a3B.out;  
  out <== or.out;
}
```

We can use the above component in a loop to determine which parts of the previous stack should be copied to the new one. The following template returns an array of 0 or 1 to determine which columns should be copied. For example, if there are 4 columns and the first 2 columns should be copied, then it returns `[1, 1, 0, 0]`:

```jsx
template CopyStack(m) {
  var nBits = 4;
    signal output out[m];
    signal input sp;
    signal input is_pop;
    signal input is_push;
    signal input is_nop;

    component ShouldCopys[m];
    
    // loop over the columns
    for (var j = 0; j < m; j++) {
        ShouldCopys[j] = ShouldCopy(j, nBits);
        ShouldCopys[j].sp <== sp;
        ShouldCopys[j].is_pop <== is_pop;
        ShouldCopys[j].is_push <== is_push;
        ShouldCopys[j].is_nop <== is_nop;
        out[j] <== ShouldCopys[j].out;
    }
}
```

## Final Stack

The following code is the final implementation of our stack, which combines all the components together. Since we have already shown the components for `ShouldCopy` and `CopyStack`, the reader can jump down to the final component `StackBuilder`. The previous components are from the earlier sections. We put it into a single file so the reader can conveniently copy and paste this into [zkrepl](https://zkrepl.dev) to test it:

```jsx
include "circomlib/comparators.circom";
include "circomlib/gates.circom";

template AND3() {
  signal input in[3];
  signal output out;
  
  signal temp;
  temp <== in[0] * in[1];
  out <== temp * in[2];
}

// j is the column number
// bits is how many bits we need
// for the LessEqThan component
template ShouldCopy(j, bits) {
  signal input sp;
  signal input is_pop;
  signal input is_push;
  signal input is_nop;
  
  // out = 1 if should copy
  signal output out;
  
  // sanity checks
  is_pop + is_push + is_nop === 1;
  is_nop * (1 - is_nop) === 0;
  is_push * (1 - is_push) === 0;
  is_pop * (1 - is_pop) === 0;
  
  // it's cheaper to compute ≠ 0 than > 0 to avoid
  // converting the number to binary
  signal spEqZero;
  signal spGteOne;
  spEqZero <== IsZero()(sp);
  spGteOne <== 1 - spEqZero;
  
  // it's cheaper to compute ≠ 0 and ≠ 1 than ≥ 2
  signal spEqOne;
  signal spGteTwo;
  spEqOne <== IsEqual()([sp, 1]);
  spGteTwo <== 1 - spEqOne * spEqZero;
  
  // the current column is 1 or more 
  // below the stack pointer
  signal oneBelowSp <== LessEqThan(bits)([j, sp - 1]);
  
  // the current column is 2 or more
  // below the stack pointer
  signal twoBelowSP <== LessEqThan(bits)([j, sp - 2]);
  
  // condition A
  component a3A = AND3();
  a3A.in[0] <== spGteOne;
  a3A.in[1] <== oneBelowSp;
  a3A.in[2] <== is_push + is_nop;
  
  // condition B
  component a3B = AND3();
  a3B.in[0] <== spGteTwo;
  a3B.in[1] <== twoBelowSP;
  a3B.in[2] <== is_pop;
  
  component or = OR();
  or.a <== a3A.out;
  or.b <== a3B.out;  
  out <== or.out;
}

template CopyStack(m) {
  var nBits = 4;
    signal output out[m];
    signal input sp;
    signal input is_pop;
    signal input is_push;
    signal input is_nop;

    component ShouldCopys[m];
    signal copy[m];
    
    // loop over the columns
  for (var j = 0; j < m; j++) {
    ShouldCopys[j] = ShouldCopy(j, nBits);
    ShouldCopys[j].sp <== sp;
    ShouldCopys[j].is_pop <== is_pop;
    ShouldCopys[j].is_push <== is_push;
    ShouldCopys[j].is_nop <== is_nop;
    out[j] <== ShouldCopys[j].out;
  }
}

// n is how many instructions we can handle
// since all the instructions might be push,
// our stack needs capacity of up to n
template StackBuilder(n) {
  var NOP = 0;
  var PUSH = 1;
  var POP = 2;

  signal input instr[2 * n];
  
  // we add one extra row for sp because
  // our algorithm always writes to the
  // next row and we don't want to conditionally
  // check for an array-out-of-bounds
  signal output sp[n + 1];

  signal output stack[n][n];

  var IS_NOP = 0;
  var IS_PUSH = 1;
  var IS_POP = 2;
  var ARG = 3;
  
  // metaTable is the columns IS_NOP, IS_PUSH, IS_POP, ARG
  signal metaTable[n][4];

  // first instruction must be PUSH or NOP
  (instr[0] - PUSH) * (instr[0] - NOP) === 0;

  signal first_op_is_push;
  first_op_is_push <== IsEqual()([instr[0], PUSH]);

  // if the first op is NOP, we are forcing the first
  // value to be zero, but this is where the stack
  // pointer is, so it doesn't matter
  stack[0][0] <== first_op_is_push * instr[1];

  // initialize the rest of the first stack to be zero
  for (var i = 1; i < n; i++) {
      stack[0][i] <== 0;
  }

  // we fill out the 0th elements to avoid
  // uninitialzed signals. For a particular
  // execution, we only want one possible witness
  // to correspond to a particular execution
  sp[0] <== 0;
  sp[1] <== first_op_is_push;
  metaTable[0][IS_PUSH] <== first_op_is_push;
  metaTable[0][IS_POP] <== 0;
  metaTable[0][IS_NOP] <== 1 - first_op_is_push;
  metaTable[0][ARG] <== instr[1];

  // spBranch is what we add to the previous
  // stack pointer based on the opcode.
  // Could be 1, 0, or -1 depending on the
  // opcode. Since the first opcode
  // cannot be POP, -1 is not an option here.
  var SAME = 0;
  var INC = 1;
  var DEC = 2;
  signal spBranch[n][3];
  spBranch[0][INC] <== first_op_is_push * 1;
  spBranch[0][SAME] <== (1 - first_op_is_push) * 0;
  spBranch[0][DEC] <== 0;

  // populate the first row of the metaTable
  // and the stack pointer
  component EqPush[n];
  component EqNop[n];
  component EqPop[n];

  component eqSP[n][n];
  signal eqSPAndIsPush[n][n];
  for (var i = 0; i < n; i++) {
      eqSPAndIsPush[0][i] <== 0;
  }

  // signals and components for copying
  component CopyStack[n];
  signal previousCellIfShouldCopy[n][n];
  for (var i = 0; i < n; i++) {
    previousCellIfShouldCopy[0][i] <== 0;
  }
  for (var i = 1; i < n; i++) {
    // check which opcode we are executing
    EqPush[i] = IsEqual();
    EqPush[i].in[0] <== instr[2 * i];
    EqPush[i].in[1] <== PUSH;
    metaTable[i][IS_PUSH] <== EqPush[i].out;

    EqNop[i] = IsEqual();
    EqNop[i].in[0] <== instr[2 * i];
    EqNop[i].in[1] <== NOP;
    metaTable[i][IS_NOP] <== EqNop[i].out;

    EqPop[i] = IsEqual();
    EqPop[i].in[0] <== instr[2 * i];
    EqPop[i].in[1] <== POP;
    metaTable[i][IS_POP] <== EqPop[i].out;

    // get the instruction argument
    metaTable[i][ARG] <== instr[2 * i + 1];

    // if it is a push, write to the stack
    // if it is a copy, write to the stack
    CopyStack[i] = CopyStack(n);
    CopyStack[i].sp <== sp[i];
    CopyStack[i].is_push <== metaTable[i][IS_PUSH];
    CopyStack[i].is_nop <== metaTable[i][IS_NOP];
    CopyStack[i].is_pop <== metaTable[i][IS_POP];
    for (var j = 0; j < n; j++) {
      previousCellIfShouldCopy[i][j] <== CopyStack[i].out[j] * stack[i - 1][j];

      eqSP[i][j] = IsEqual();
      eqSP[i][j].in[0] <== j;
      eqSP[i][j].in[1] <== sp[i];
      eqSPAndIsPush[i][j] <== eqSP[i][j].out * metaTable[i][IS_PUSH];

      // we will either PUSH or COPY or implicilty assign 0
      stack[i][j] <== eqSPAndIsPush[i][j] * metaTable[i][ARG] + previousCellIfShouldCopy[i][j];
    }

    // write to the next row's stack pointer
    spBranch[i][INC] <== metaTable[i][IS_PUSH] * (sp[i] + 1);
    spBranch[i][SAME] <== metaTable[i][IS_NOP] * (sp[i]);
    spBranch[i][DEC] <== metaTable[i][IS_POP] * (sp[i] - 1);
    sp[i + 1] <== spBranch[i][INC] + spBranch[i][SAME] + spBranch[i][DEC];
  }
}

component main = StackBuilder(3);

/* INPUT = {
  "instr": [1, 16, 1, 20, 1, 22]
} */
```

## Summary

To model a data structure that changes over time, we write constraints for all possible state transitions, then activate those state transitions based on flags. The flags are constrained to match the instruction for that particular state transition.

Although understanding the arithmetization of the stack data structure may be intimidating, we now know nearly everything we need to know to understand how to build a stack-based ZKVM, which we cover in the next chapter. To create a stack-based ZKVM, we simply modify the instructions and their respective constraints introduced in this chapter to match the opcode for the ZKVM.

In general, most meaningful computations can be modeled as an initial state that gets updated incrementally until a final result is reach. The stack we showed in this chapter is just a special case of this.
