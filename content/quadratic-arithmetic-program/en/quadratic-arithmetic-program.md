# Quadratic Arithmetic Programs

A Quadratic Arithmetic Program (QAP) is a system of equations where the coefficients are monovariate polynomials and a valid solution results in a single polynomial equality. They are quadratic because they have exactly one polynomial multiplication.

QAPs are the primary reason ZK-Snarks are able to be succinct.

An [arithmetic circuit](https://www.rareskills.io/post/arithmetic-circuit) can be represented as an [R1CS](https://www.rareskills.io/post/rank-1-constraint-system), but evaluating it is not succinct since the witness vector has $m$ entries.

Polynomials allow us to make statements succinctly due to the Schwartz-Zippel Lemma – in a sense, we can compress a polynomial down to a single point.

The key idea behind creating a Quadratic Arithmetic Program is as follows:

A vector can be represented as a polynomial, and a polynomial can be probabilistically identified *with a single point* per the Schwartz-Zippel Lemma.


*Originally published August 23, 2023*