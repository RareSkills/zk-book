# ZK Friendly Hash Functions

ZK-friendly hash functions are hash functions that require much fewer constraints to prove and verify than traditional cryptographic hash functions.

Hash functions such as SHA256 or keccak256 make heavy use of bitwise operators such as XOR or bit rotation. Proving the correct execution of XOR or bit rotation requires representing the number as 32 bits, which requires 32 separate signals. Since the default word size of traditional hash functions is 32 bits, operations on this data type require 32 signals.

A ZK-friendly hash function uses the native field element as the default data type and avoids operations that decompose the field element into bits. The native operations on field elements are only addition and multiplication, so ZK-friendly hash function operations must only use modular addition and multiplication.

The properties of a hash function that we care about are:

1. **Preimage resistance** — given the output of a hash, computing the input should be infeasible.
2. **Collision resistance** — given an input-output pair, it should be computationally infeasible to find another input that results in the same output.
3. **Pseudorandomness** — the output should appear to be random — there should be no statistical relationship between the input and output.

We will describe at a high level how two of the most popular ZK-friendly hash functions, Minimal Multiplicative Complexity (MiMC) and Poseidon, work. However, an analysis of why they are secure is outside the scope of this article. In fact, the security of these hash functions -- despite being the most battle-tested — is still somewhat of an open question.

## MiMC

The input to this hash function is a single field element and the output is a single field element.

MiMC initializes 91 random constants and stores them in an array C. These could be computed in a deterministic and transparent manner, such as taking the string "MiMC" and hashing it 91 times with SHA256, and each hash serves as the random number. These constants are fixed, public, and known to all parties. Conventionally, `C[0] = 0`. Then, MiMC takes a field element $t_0$ as its input and iteratively computes:

$$
\begin{align*}
\texttt{let } u &= k+t_i+C_i\\
t_{i+1} &= i\space<90\space\space?\space\space u^e : \space u^e + k
\end{align*}
$$

where $e$ is some fixed exponent, often 3 or 7. $k$ is a constant that is set to 0 (why we provide an input $k$ only to set it to zero will be discussed later).

For MiMC to be secure, it must be the case that `gcd(e, p - 1) == 1`, where `gcd` is the greatest common divisor. For Circom's default field size, `gcd(3, p - 1) ≠ 1` but `gcd(7, p - 1) = 1`.

```python
from math import gcd
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
gcd(3, p - 1)
# 3
gcd(7, p - 1)
# 1
```

Hence, Circomlib provides MiMC7 as a hash (where 7 is the exponent). Having said that, libraries using other field sizes might use `e = 3` (to understand why this is the case, please see the resource linked at the end of the article).

Below is a minimal example of using MiMC7 with a single input:

```jsx
include "circomlib/mimc.circom";

template ExampleMiMC() {
  signal input a;
  signal output out;

  component hash = MiMC7(91);

  hash.x_in <== a;
  hash.k <== 0;
  out <== hash.out;
}
```

If we wish to pass multiple field elements to the hash and output a single field element, we use the following approach:

1. We hash the first input element.
2. The output of that hash becomes the value for `k` of the next hash
3. The input of the next hash is the next part of the input.

This can be visualized as follows:

![multi mimc diagram](https://r2media.rareskills.io/ZKFriendlyHashFunction/multi-mimc.png)


The MultiMiMC7 template accomplishes this for us:

```jsx
include "circomlib/mimc.circom";

template ExampleMultiMiMC(n) {
  signal input in[n];
  signal output out;

  component hash = MultiMiMC7(n, 91);
  
  for (var i = 0; i < n; i++) {
    hash.in[i] <== in[i];
  }
  hash.k <== 0;

  out <== hash.out;
}
```

## Poseidon

Poseidon is similar to MiMC except that it adds a step of matrix multiplication. That is, if the input is a single element, it is expanded to `[0, input]`, and this vector is multiplied by a series of carefully tuned 2 x 2 matrices. “Careful tuning” here means it has a certain cryptographic property that we will not get into here.

Therefore, instead of a single element going through a series of additions and exponentiations (as in MiMC), a vector goes through a series of element-wise additions, matrix multiplications (which produces a vector of the same dimension) and exponentiations in Poseidon.

Although matrix multiplication adds more constraints, it creates more "dispersion" in the hash, so Poseidon does not need as many rounds as MiMC does.

Below is a minimal example of using Poseidon with a single input:

```jsx
include "circomlib/poseidon.circom";

template Example(n) {
  signal input in[n];
  signal output out;
  
  component hash = Poseidon(n);

  for (var i = 0; i < n; i++) {
    hash.inputs[0] <== in[i];
  }
  out <== hash.out;
}

component main = Example(1);

/* INPUT = {
  "in": [5]
} */
```

To use more than one input signal, we change the template argument `n` for Poseidon to the desired value and provide the correct sized array.

## Poseidon vs MiMC Performance

For hashes that take a single input, the underlying R1CS of MiMC has 364 constraints:

![mimc constraints](https://r2media.rareskills.io/ZKFriendlyHashFunction/mimc-constraints.png)

while Poseidon has 213:

![Poseidon constraints](https://r2media.rareskills.io/ZKFriendlyHashFunction/Poseidon-single.png)


Now, let’s compare the number of constraints generated when we have two inputs.

For MiMC7, the number of constraints doubles with two inputs:

![multi mimc constraints](https://r2media.rareskills.io/ZKFriendlyHashFunction/multi-mimc.png)

But for Poseidon, the number of constraints barely increases:

![multi poseidon constraints](https://r2media.rareskills.io/ZKFriendlyHashFunction/multi-poseidon.png)

The primary reason for this superior performance is that, unlike MiMC, Poseidon doesn’t redo the hash for each field element in the input. Instead, to hash a larger input, it uses a larger matrix to multiply the input vector with. Circomlib’s Poseidon doesn’t support inputs larger than 17 field elements. If we need to hash a large dataset, this can be problematic. However, if we are building a Merkle tree, we only need to hash two inputs.

## Seeking even more security

As mentioned previously, the security properties of Poseidon and MiMC are not as well understood as highly battle-hardened hash functions such as SHA-256.

There exists a ZK-friendly hash function with even stronger security assumptions than Poseidon and MiMC, which is based on elliptic curves. Computing the discrete log of elliptic curve points is widely believed to be infeasible without a quantum computer. The Pedersen hash is a ZK-friendly hash function that uses elliptic curve operations as the core subroutine for computing the hash. Doing elliptic curve arithmetic in a circuit will not be as efficient as Poseidon or MiMC, but it is more efficient than traditional cryptographic hashes.

## Bounties on MiMC and Poseidon Bugs

Currently, the Ethereum Foundation has a [$20,000 bounty](https://crypto.ethereum.org/bounties/mimc-hash-challenge) to find a hash collision on a variant of the MiMC hash described in this article.

The Ethereum Foundation is also currently financially supporting research into the security of Poseidon through the [Poseidon Cryptanalysis Initiative](https://www.poseidon-initiative.info). Ethereum’s founder has [indicated](https://x.com/VitalikButerin/status/1894681713613164888) that Ethereum may switch to using Poseidon as the hash function of choice for Ethereum to make the network state easier to prove using ZK.

## Acknowledgement

The following resource from [Risc Zero](https://risczero.com) was consulted while creating this article:

[https://www.youtube.com/watch?v=_MIxjDs70W8](https://www.youtube.com/watch?v=_MIxjDs70W8)
