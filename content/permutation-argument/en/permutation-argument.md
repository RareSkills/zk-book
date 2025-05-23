# The Permutation Argument

A permutation argument is a proof that two lists hold the same elements, but possibly in a different order. For example, `[2,3,1]` is a permutation of `[1,2,3]` and vice-versa.

The permutation argument is useful for proving one list is a sorted version of another. That is, if list B has the same elements of list A and the elements of B are sorted, then we know the prover correctly sorted A.

To determine if two lists are the same, we typically sort them and compare them element-wise.

However, to know that a list is sorted, we need to check that 1) the elements are in order and 2) the output of the sorting algorithm contains the same elements as the inputs.

This creates a circular dependency -- to know that one list is a permutation of the other, we have to know their sorted versions are identical. But to know that the sorting algorithms were executed properly, we have to know the output of the sort is a permutation of the input.

This isn't a problem in regular code, but in ZK we must constrain every step of the computation.

We’ve already shown how to prove a list is sorted. This chapter focuses on proving two lists are permutations of each other.

## Option 1: Writing constraints for a sorting algorithm

In an earlier chapter, we showed how to write constraints for the Selection Sort algorithm. The Selection Sort algorithm runs in $\mathcal{O}(n^2)$ time, so it will have $\mathcal{O}(n^2)$ constraints. We could use a more efficient algorithm like merge sort to accomplish the same thing in $\mathcal{O}(n \log n)$ constraints, but better solutions exist as we will soon see.

## Option 2: Attempt to constrain a 1-to-1 mapping directly

One can try to directly write a circuit that is satisfied if and only if one list is a permutation of the other. In other words, each element in one list has a matching element in the other list and vice-versa.

For example, to prove that `[a1, a2, a3]` is a permutation of `[b1, b2, b3]`, we need to show a mapping between the two, it is sufficient to prove that each `a_i` maps to *some* element in the `b` list and each `b_i` maps to *some* element in the `a` list.

To create a circuit to prove the dual mapping, we create a matrix of `s` signals defined as follows:

```

               b1             b2             b3
    --------------------------------------------
a1 | s11 = (a1-b1)  s12 = (a1-b2)  s12 = (a1-b3)
a2 | s21 = (a2-b1)  s22 = (a2-b2)  s23 = (a2-b3)
a3 | s31 = (a3-b1)  s32 = (a3-b2)  s33 = (a3-b3)
```

Note that if an `s` signal is 0, then the corresponding `a` element and `b` element are equal. For example, if `a3 == b1`, then `s31` will be `0`.

If we then multiply the `s` signals row-wise and column-wise and constrain their products to be `o` signals as shown below, then the `o` signals will be zero if there is at least one matching element.

```
     b1      b2      b3
a1  s11  ×  s12  ×  s13   =  o_row1
     ×       ×       ×
a2  s21  ×  s22  ×  s23   =  o_row2
     ×       ×       ×
a3  s31  ×  s32  ×  s33   =  o_row3
    ||      ||       ||
    o_col1  o_col2   o_col3
```

If we constrain each of the `o` signals to be zero, then that also constrains that each element in a has at least one matching element in b and vice-versa. Consider the interpretation of the output signals:

- `o_row1` is zero if-and-only-if `a1` matches an element in `b`.
- `o_row2` is zero if-and-only-if `a2` matches an element in `b`.
- `o_row3` is zero if-and-only-if `a3` matches an element in `b`.
- `o_col1` is zero if-and-only-if `b1` matches an element in `a`.
- `o_col2` is zero if-and-only-if `b2` matches an element in `a`.
- `o_col3` is zero if-and-only-if `b3` matches an element in `a`.

Therefore, if all of the `o` signals are zero, then each element of each list has a matching element in the other list.

The drawback of this approach is that the number of constraints grows quadratically with the length of the list.

Instead, we show a method to prove one list is a permutation of the other in time linear to the length of the list.

**Credit:** The rest of this article is heavily based on this [documentation of the Triton VM](https://triton-vm.org/spec/permutation-argument.html), we simply show a Circom implementation and add some more beginner-friendly explanations.

## How the permutation argument works

Consider a polynomial written in the form:

$$
(x-a)(x-b)(x-c)
$$

Its value does not change if the order of the multiplication changes:

$$
(x-b)(x-a)(x-c)
$$

In other words, permuting the multiplication of the [*linear factors*](https://www.notion.so/The-Permutation-Argument-14709cb3e96280489504de20d5f93804?pvs=21) of the polynomial does not change the value of the polynomial. (A linear factor is a term of the form $(x - a)$).

We do not check if the polynomials are equivalent by algebraically multiplying the terms. Rather, we can use a much more efficient polynomial equality test called the [Schwartz-Zippel lemma](https://www.rareskills.io/post/schwartz-zippel-lemma).

This test samples a random point for $x$ and plugs it into the two polynomials. If they have the same evaluation, then with extremely high probability, they are the same polynomial (to understand why this test is secure, please see the linked article above).

This technique can be used to prove that the arrays $[a,b,c]$ and $[b,c,a]$ are permutations of each other. We create a circuit that takes two arrays $c_1,c_2,c_3,...,c_n$ and $d_1,d_2,d_3,...,d_n$ as input and then constructs polynomials:

$$
\begin{align*}
(x - c_1)(x - c_2)...(x - c_n)\\
(x - d_1)(x - d_2)...(x - d_n)
\end{align*}
$$

Finally, it picks a random point for $x$, evaluates the two polynomials, and constrains the products to be the same.

To generate the random point, let's call it $r$, we use the hash of the inputs, i.e., hashing the concatenation of the arrays:

$$
r=\mathsf{hash}([a,b,c,b,c,a])
$$

This way, the prover cannot try to “cheat” by picking a value for $r$ where the polynomials intersect. Once the prover has provided the polynomials, they cannot control the value $r$ at which these polynomials are evaluated.

If the prover changes the polynomials, the value $r$ they are tested at will also change.

The circuit below takes two lists and checks if they are permutations of each other. The array signal `prodA`  holds the terms:

- $\texttt{prodA[0] = } r - a_0$
- $\texttt{prodA[1] = prodA[0]} \cdot(r - a_1)$
- $\texttt{prodA[2] = prodA[1]} \cdot(r - a_2)$
- $\texttt{prodA[n - 1] = prodA[n - 2]}\cdot(r -a_{n-1})$

Thus, the final entry `prodA[n - 1]` holds the evaluation of the polynomial at `r`. Here, `r` is `hash.out`, which is the Poseidon hash of all the entries of arrays `a` and `b`.

```jsx

include "circomlib/poseidon.circom";

template IsPermutation(n) {
  signal input a[n];
  signal input b[n];

  // the random point will be the hash
  // of the concatenation of the arrays
  component hash = Poseidon(2 * n);
  for (var i = 0; i < n; i++) {
    hash.inputs[i] <== a[i];
    hash.inputs[i + n] <== b[i];
  }

  signal prodA[n];
  signal prodB[n];

  prodA[0] <== hash.out - a[0];
  prodB[0] <== hash.out - b[0];

  for (var i = 1; i < n; i++) {
    prodA[i] <== (hash.out - a[i]) * prodA[i - 1];
    prodB[i] <== (hash.out - b[i]) * prodB[i - 1];
  }

  // the evaluation of the polynomials at r = hash.out
  prodA[n - 1] === prodB[n - 1];
}

component main = IsPermutation(3);

/* INPUT = {
  "a": [1,2,3,4,5,6],
  "b": [1,2,3,4,6,5]
}
*/
```

## Vulnerability: Not Hashing All Elements

When generating random points in this manner, the hash must depend on all the inputs to the computation. Otherwise, a malicious prover can keep the hash value fixed, and tweak the values of the output array until they find an intersection point of the polynomial.

## A note about safety

This algorithm relies on non-equal polynomials only intersecting in at most $d$ points where $d$ is the maximum degree of the two polynomials. If the size of the finite field is much greater than $d$, then we can assume that in practice, $p(r)\neq q(r)$ if $p$ and $q$ are non-equal polynomials and $r$ is a random point. Circom uses a finite field size that is slightly larger than $2^{253}$. If the polynomials have degree one million, then the probability that $r$ is an intersection point is approximately $2^{20}/2^{253}$ or $1/2^{233}$ or $1$ out of $10^{70}$. This is nearly on the same order of magnitude of the number of atoms in the universe.

If we used a very small finite field, however, say on the order of 31 bits, then the probability of $p(r)=q(r), q \ne p$ for a random $r$ is not negligible.