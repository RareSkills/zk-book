# Inner Product Algebra

In this article, we give some useful algebraic tricks for inner products that will be useful in deriving range proofs (and encoding circuits as inner products) later. Each rule will be accompanied by a simple proof.

## Notation
Variables in bold, like $\mathbf{a}$,denote a vector. Variables not in bold, like $v$, denote a scalar. The operator $\circ$ is the Hadamard product (elementwise multiplication) of two vectors, i.e. $[a_1, \dots, a_n]\circ[b_1, \dots, b_n] = [a_1b_1, \dots, a_nb_n]$. We use the short hand "lhs" and "rhs" to refer to the "left-hand-side" and "right-hand-side" of an equation respectively. A "summand" is an element of an addition, e.g. if $a + b = c$, then $a$ and $b$ would be called summands. The $\mathbf{1}$ vector is a vector of all ones, i.e. $[1, 1, \dots, 1]$. All vectors are implied to be of the same length $n$ unless otherwise stated.

## Rule 1: An inner product where one of the vectors is a sum of vectors can be expanded
Suppose we're calculating an inner product where one of the vectors is a sum of two vectors - for example $\langle\mathbf{a} + \mathbf{b}, \mathbf{c}\rangle$. We can split this up into the sum of two inner products:
$\langle \mathbf{a} + \mathbf{b}, \mathbf{c} \rangle = \langle \mathbf{a}, \mathbf{c}\rangle + \langle \mathbf{b}, \mathbf{c} \rangle$

Proof:
The lhs can be written as
$$
\sum_{i=1}^n(a_i+b_i)c_i
$$

The rhs can be written as

$$
\begin{align*}
&=\sum_{i=1}^na_ic_i+\sum_{i=0}^mc_ib_i \\
&=\sum_{i=1}^n(a_ic_i+c_ib_i) \\
&=\sum_{i=1}^n(a_i+b_i)c_i
\end{align*}
$$

## Rule 2: Inner products with common terms can be combined
The two inner products on the lhs below have a common vector of $\mathbf{c}$, therefore they can be combined:
$$\langle \mathbf{a}, \mathbf{c}\rangle + \langle \mathbf{b}, \mathbf{c} \rangle = \langle \mathbf{a} + \mathbf{b}, \mathbf{c} \rangle$$

This is really Rule 1 with the lhs and the rhs swapped.

The proof is the same as Rule 1.

## Rule 3: Moving vectors to the other side of the inner product
An inner product can be re-written as the $\mathbf{1}$ vector with the Hadamard product of the original vectors:
$$\langle \mathbf{a}, \mathbf{b} \rangle= \langle \mathbf{1}, \mathbf{a\circ b} \rangle$$

Proof:

$$\begin{align*}
\langle \mathbf{a}, \mathbf{b} \rangle&=\sum_{i=1}^na_ib_i \\
\langle \mathbf{1}, \mathbf{a\circ b} \rangle&=\sum_{i=1}^n1*(a_ib_i)\\
\sum_{i=1}^na_ib_i &= \sum_{i=1}^n1*(a_ib_i)\\
\end{align*}$$

## Rule 4: We can add vectors to one of the terms of the inner product to force two inner products to have common terms.

Suppose we're adding a inner product $\langle\mathbf{x}, \mathbf{b}\rangle$ and with the inner product $\langle\mathbf{y}, \mathbf{b}+\mathbf{c}\rangle$, and the sum of the inner products is $v$. Note that they have different components, so we can't add them with rule 2. Nevertheless, the following equality:

$$\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{y}, \mathbf{b}\rangle = v$$

can be written as

$$\langle \mathbf{x} + \mathbf{y}, \mathbf{b} + \mathbf{c}\rangle = v + \langle\mathbf{y},\mathbf{c}\rangle$$

In the above scenario, we can add $\langle\mathbf{y},\mathbf{c}\rangle$ to both sides.

$$\begin{align*}
\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{y}, \mathbf{b}\rangle + \boxed{\langle\mathbf{y},\mathbf{c}\rangle}&= v + \boxed{\langle\mathbf{y},\mathbf{c}\rangle}\\
\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{y}, \mathbf{b}\rangle + \langle\mathbf{y},\mathbf{c}\rangle&= v + \langle\mathbf{y},\mathbf{c}\rangle
\end{align*}$$

We now have common $\mathbf{y}$ terms we can combine using Rule 2:

$$\begin{align*}
\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{\fbox{y}}, \mathbf{b}\rangle + \langle\mathbf{\fbox{y}},\mathbf{c}\rangle&= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{\fbox{y}}, \mathbf{b} + \mathbf{c}\rangle &= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{y}, \mathbf{b} + \mathbf{c}\rangle &= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\end{align*}$$

Now that we have forced the two inner products to have common term $\langle \mathbf{b} + \mathbf{c} \rangle$ on the lhs, we can combine them into one vector using Rule 2 again:

$$\begin{align*}
\langle \mathbf{x}, \boxed{\mathbf{b} + \mathbf{c}}\rangle + \langle \mathbf{y}, \boxed{\mathbf{b} + \mathbf{c}}\rangle &= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\langle \mathbf{x} + \mathbf{y}, \boxed{\mathbf{b} + \mathbf{c}}\rangle &= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\langle \mathbf{x} + \mathbf{y}, \mathbf{b} + \mathbf{c}\rangle &= v + \langle\mathbf{y},\mathbf{c}\rangle\\
\end{align*}$$

Therefore,

$$\langle \mathbf{x}, \mathbf{b} + \mathbf{c}\rangle + \langle \mathbf{y}, \mathbf{b}\rangle = v$$

can be rewritten as 

$$\langle \mathbf{x} + \mathbf{y}, \mathbf{b} + \mathbf{c}\rangle = v + \langle\mathbf{y},\mathbf{c}\rangle$$

## Rule 5: Adding two inner products with unrelated vectors
We can add $\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle$ (which have no vectors in common) and obtain:

$$\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle=\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_1+\mathbf{b}_2\rangle-\langle\mathbf{a_1},\mathbf{b_2}\rangle-\langle\mathbf{a_2},\mathbf{b_1}\rangle$$

Proof:

$$\begin{align*}
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle&=\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle&=\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle&&\text{add }\langle\mathbf{a}_1,\mathbf{b}_2\rangle \text{ to both sides}\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle&=\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_2\rangle&&\text{combine }\mathbf{b}_2 \text{ terms}\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle+\langle\mathbf{a}_2,\mathbf{b}_1\rangle&=\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_2,\mathbf{b}_1\rangle&&\text{add }\langle\mathbf{a}_2,\mathbf{b}_1\rangle\text{ to both sides}\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle+\langle\mathbf{a}_2,\mathbf{b}_1\rangle&=\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_1\rangle+\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_2\rangle&&\text{combine }\mathbf{b}_1\text{ terms}\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle+\langle\mathbf{a}_1,\mathbf{b}_2\rangle+\langle\mathbf{a}_2,\mathbf{b}_1\rangle&=\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_1+\mathbf{b}_2\rangle&&\text{combine right hand side}\\
\langle\mathbf{a}_1,\mathbf{b}_1\rangle+\langle\mathbf{a}_2,\mathbf{b}_2\rangle&=\langle\mathbf{a}_1+\mathbf{a}_2,\mathbf{b}_1+\mathbf{b}_2\rangle-\langle\mathbf{a}_1,\mathbf{b}_2\rangle-\langle\mathbf{a}_2,\mathbf{b}_1\rangle&&\text{subtract }\langle\mathbf{a}_1,\mathbf{b}_2\rangle+\langle\mathbf{a}_2,\mathbf{b}_1\rangle
\end{align*}$$

The proof illustrates that it may be handy sometimes to be creative about finding inner products to add to both sides of the equation.

## Rule 6: Scalars can be brought inside and outside of an inner product
$z\cdot\langle\mathbf{a},\mathbf{b}\rangle = \langle z\cdot\mathbf{a},\mathbf{b}\rangle = \langle\mathbf{a},z\cdot\mathbf{b}\rangle$

The proof for this statement is left as an exercise for the reader. As a hint, constant terms can be brought in and out of a summation.

This tutorial is part of our series on [ZK Bulletproofs](rareskills.io/post/bulletproofs-zk).
