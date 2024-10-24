# Introduction to ZK Bulletproofs

Bulletproofs are a zero knowledge inner product argument, which enable a prover to convince a verifier that they correctly computed an inner product. That is, the prover has two vectors $\mathbf{a} = [a_1, a_2, \dots, a_n]$ and $\mathbf{b} = [b_1, b_2, \dots, b_n]$ and they computed $v = \langle\mathbf{a},\mathbf{b}\rangle=a_1b_1+a_2b_2 + \dots +a_nb_n$. The prover can optionally hide or reveal the vectors or the inner product result, but still convince the verifier they did the calculation honestly.

The verifier doesn't receive vectors $\mathbf{a}$, $\mathbf{b}$, and scalar $v$ but rather *commitments* to these values. Very roughly, one could think of the verifier receiving a "hash" $h$ where $h = \mathsf{hash}([a_1, a_2, \dots, a_n],[b_1, b_2, \dots, b_n],v)$, then receiving a proof (which we call $\pi$) that the hash actually contains two vectors and their inner product. In other words, the verifier receives $(h, \pi)$ and is convinced that the prover carried out an inner product operation correctly on the hashed values -- but doesn't learn anything about the "contents" of the hash.

Over the course of executing the verification portion of the Bulletproof, the verifier will reconstruct the hash and thus be convinced the prover evaluated the inner product as claimed.

Of course, it is not possible to reconstruct a traditional hash without knowing the input, so Bulletproofs use a special kind of hash called a "Pedersen Commitment," which is the subject of the first chapter in this tutorial. Pedersen Commitments are a special kind of "hash" based on elliptic curves; Pedersen Commitments can be reconstructed without knowing the original input.

*Some engineers recognize the operation of combining vectors in the manner of $a_1b_1+a_2b_2 + \dots +a_nb_n$ as a "dot product." Technically, a dot product refers to the operation on vectors in a Cartesian plane, but the inner product refers to the operation for arbitrary vectors. Therefore, we will refer to this operation as the inner product. We use bold letters such as $\mathbf{a}$ to denote a vector, lower case letters such as $v$ to denote a [finite field](https://www.rareskills.io/post/finite-fields) element (roughly, a "scalar" in modular arithmetic), and angled brackets $\langle\mathbf{a},\mathbf{b}\rangle$ to denote an inner product of two vectors, which always results in a finite field element.*

To prove zero knowledge in general, the prover must show that they know an assignment to an [arithmetic circuit](https://www.rareskills.io/post/arithmetic-circuit) (a witness) that satisfies the circuit's constraints. However, SNARKs, particularly [Groth16](https://www.rareskills.io/post/groth16) do not accept arbitrary circuits -- the circuits must be in a particular format, the [Rank One Constraint system](https://www.rareskills.io/post/rank-1-constraint-system). From there, the R1CS is converted to a [Quadratic Arithmetic Program](https://www.rareskills.io/post/quadratic-arithmetic-program) (QAP) using [Lagrange interpolation](https://www.rareskills.io/post/python-lagrange-interpolation) and polynomial division.

The additional overhead of interpolating polynomials and polynomial division increases the work significantly for the prover.

Bulletproofs on the other hand, allow us to create a proof for the R1CS directly, without a QAP. Consider that the following matrix operation on the left and inner product computations on the right are equivalent:

$$
\begin{bmatrix}
l_{11}, l_{12}, l_{13}\\
l_{21}, l_{22}, l_{23}\\
l_{31}, l_{32}, l_{33}\\
l_{41}, l_{42}, l_{43}\\
\end{bmatrix}
\begin{bmatrix}
a_1\\a_2\\a_3
\end{bmatrix}=
\begin{matrix}
\langle [l_{11}, l_{12}, l_{13}],[a_1,a_2,a_3]\rangle\\
\langle [l_{21}, l_{22}, l_{23}],[a_1,a_2,a_3]\rangle\\
\langle [l_{31}, l_{32}, l_{33}],[a_1,a_2,a_3]\rangle\\
\langle [l_{41}, l_{42}, l_{43}],[a_1,a_2,a_3]\rangle\\
\end{matrix}
$$

In other words, multiplying an $n \times m$ matrix by a $n$ dimensional vector is the same as computing $n$ inner products. So if we can directly prove an inner product was computed correctly, then we don't need the additional steps of creating a Quadratic Arithmetic Program.

Furthermore, Bulletproofs do not use [pairings](https://www.rareskills.io/post/bilinear-pairing) (only basic [elliptic curve addition](https://www.rareskills.io/post/elliptic-curve-addition)) and do not require a [trusted setup](https://www.rareskills.io/post/trusted-setup).

## Drawbacks of Bulletproofs
The size of the proof is logarithmic in the number of multiplications, unlike the ZK-SNARK proof which is constant size.

The primary drawback of Bulletproofs is that the runtime of the verifier is linear in the size of the circuit. This is because the work that would have been accomplished by the trusted setup now has to be done by the verifier.

## ZK without arithmetic circuits
One major advantage of inner products is that they can model some problems "directly" -- i.e. -- they don't need an arithmetic circuit.

For example, proving that a number $v$ is less than $2^n$ can be done by showing that $v$ has a binary representation of $\mathbf{b}$, and the inner product of $\mathbf{b}$ and the vector $[1,2,4,8,...,2^{n-1}]$ is $v$. This directly implies that $v < 2^n$. For example, if the vector of powers of 2 is $[1,2,4,8,16,32,64,128]$, then we know that $v$ must be less than 256, for the same reason that a `uint8` cannot hold values larger than 255. But since $\mathbf{b}$ is hidden, we don't know the actual value of $v$. This is called a *range proof* because we know $v$ is in the range $[0,255]$ without knowing the actual value.

If we were instead to create an arithmetic circuit for the range proof, this would introduce substantial computational overhead.

*For readers familiar with NP-Completeness, the Subset Sum problem can also be modeled directly with an inner product argument. Any problem in NP can be reduced to a Subset Sum instance and the solution can be proven with an inner product argument. In some cases, that reduction may be more efficient than an arithmetic circuit.*

## Bulletproofs in practice
The privarcy blockchain Monero uses the range proof described above to ensure that transactions do not have negative values in the input (i.e. an overflow in the finite field). ZCash uses Bulletproofs as a replacement for the SNARK polynomial commitment using a PLONKish circuit.

The linear runtime of Bulletproofs make them unsuitable for use in smart contracts on Ethereum mainnet. However, for protocols that need a fast proof generation and verification of a small problem -- such as a range proof, Bulletproofs are hard to beat.

## The RareSkills ZK Book on Bulletproofs
Our walkthrough of Bulletproofs is based on the original [Bulletproofs paper](https://eprint.iacr.org/2017/1066.pdf). The paper is very well organized, but it is extremely dense as it is targeted to professional cryptography researchers and assumes considerable background knowledge. Our collection of Bulletproof tutorials is largely a translation of the paper to a version senior web3 developers can understand. We create entire tutorials for the prerequisites the paper implicitly assumes the reader has.

As usual, we strive to provide an intuitive mental model of the algorithm, and not simply recite the steps the algorithm takes. Where suited, we include mathematical animations to make the explanation more efficient. At all costs, we avoid oversimplification so that you have a full intuition of what each step of the algorithm accomplishes.

### Reading this work
We assume the reader has read and understood the first nine chapters of our [ZK Book](https://www.rareskills.io/zk-book). Familiarity with Groth16 or other ZK algorithms is not expected.

We include accompanying "fill in the blank" Python coding exercises so that you can practice what you learn.

**For the reader with the right prerequisites, it is possible, with a modicum of discipline, to code the Bulletproofs algorithm from scratch while setting aside not more than three hours per day for two weeks.** This treatment of Bulletproofs provides a framework for how to do so without excessive hand-holding.

Bulletproofs are in a sense, "simpler" than SNARKs, so they are a great way to build confidence in understanding the field of ZK.

## Table of Contents
Chapters 1 introduces the Pedersen Commitment, which is the foundational building block of Bulletproofs. Chapters 2-4 show how to accomplish an inner product proof with zero knowledge, but not succinctness (the proof size is $\mathcal{O}(n)$ where $n$ is the size of the vectors). Chapters 5-6 show how to prove knowledge of an inner product without ZK, but with a proof size logarithmic in the number the size of $n$. Chapter 7 shows the core Bulletproofs algorithm. Chapter 8 and 9 are prerequisites for chapter 10 where we show how to construct a range proof without the use of an arithmetic circuit.

1. [Pedersen Commitments](https://www.rareskills.io/post/pedersen-commitment) Pedersen Commitments are what we called the "hash" at the beginning of this article. They are more composable than traditional hash functions however, as they are additively homomorphic. That is, we can commit 2 to $A$ and 5 to $B$ and "reveal" 7 to $A + B$.
(to be continued!)

### Acknowledgements
The excellent [documentation of the Rust Bulletproofs crate](https://doc-internal.dalek.rs/bulletproofs/) by Henry de Valence, Cathie Yun, and Oleg Andreev provided helpful pointers where the paper was unclear and we sometimes use their notation, which in some cases is more intuitive than the original paper. The reader may find that resource useful as an alternative angle on Bulletproofs.
