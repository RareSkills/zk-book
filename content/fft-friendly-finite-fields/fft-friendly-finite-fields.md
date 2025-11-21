# FFT Friendly Finite Fields

In order to carry out the FFT algorithm in a finite field, there needs to be $k$-th roots of unity such that $k$ is a power of 2.

Ideally, we want a large power of 2 so that we can multiply large polynomials. There are several commonly used finite fields (almost all of which have a catchy name associated with them). This article lists some of the more common ones.

As a quick definition, the *characteristic* of a field is the prime number we take the modulus with, so in the finite field $\mathbb{F}_q$, $q$ is the characteristic. (There are some nuances with this definition if we consider finite field extensions, but we do not want to get into that right now. For our purposes, $q$ is a prime number and the characteristic of the finite field).

As we saw in the [Fundamental Theorem of Finite Cyclic Groups](https://rareskills.io/post/fundamental-theorem-cyclic-groups), a subgroup exists if the order of the subgroup divides the order of the group.

Therefore, the field is FFT-friendly, then there exists some $k$ such that $k|(q-1)$ and $k$ is a large power of 2. In other words, $q-1$ is divisible by a large power of 2.

The list here is not complete — we only include relatively well-known ones as of the time of publication.

## List of FFT-friendly fields

### Goldilocks Field

The Goldilocks field has characteristic $q=2^{64}-2^{32}+1$ and a $2^{32}$-th root of unity.

The following Python code asserts that a [multiplicative subgroup](https://rareskills.io/post/multiplicative-subgroups) of order $2^{32}$ exists in this field.

```python
q = 2**64 - 2**32 + 1
k = 2**32
assert (q - 1) % k == 0
```

Since the characteristic is smaller than 64 bits, the elements can be stored in a single word on most modern hardware (which is usually 64 bits).

However, multiplying two 64-bit numbers together temporarily requires 128 bits, which necessitates an additional register for multiplication.

This motivates the use of a smaller field that uses only 32 bits.

### Baby Bear Field

The Baby Bear field uses a characteristic $2^{31} - 2^{27} + 1$. It has a $2^{27}$-th root of unity.

```python
q = 2**31 - 2**27 + 1
k = 2**27
assert (q - 1) % k == 0
```

The name “Baby Bear” is a riff off of [Goldilocks’ fairytale](https://en.wikipedia.org/wiki/Goldilocks_and_the_Three_Bears), where the story emphasizes the Baby Bear’s small size compared to the main character of the story (Goldilocks).

Since the field fits in 32 bits, a 64-bit computer can multiply two elements together in a single word.

### Teddy Bear Field

The Teddy Bear Field uses a characteristic $2^{32}-2^{30}+1$ and has a $2^{30}$-th root of unity.

```python
q = 2**32 - 2**30 + 1
k = 2**30
assert (q - 1) % k == 0
```

Compared to the Baby Bear field, it fits inside 32 bits, but has a larger multiplicative subgroup that is eight times as large.

The Teddy Bear field was introduced by Ingonyama in this [paper](https://cdn.prod.website-files.com/63970f25aa7b42e284492d52/6841984a01eabc37a492624c_polar_bear_teddy_bear_prime_fields.pdf).

### Koala Bear Field

The Koala Bear Field is another field whose characteristic $2^{31} - 2^{24} + 1$ fits in 32 bits and has a $2^{24}$-th root of unity.

```python
q = 2**31 - 2**24 + 1
k = 2**24
assert (q - 1) % k == 0
```

### BN-128 field

The BN-128 field is used for its support of [elliptic curve pairings](https://rareskills.io/post/bilinear-pairing), but it also has a relatively large multiplicative subgroup that is of order $2^{28}$.

```python
# curve_order = 21888242871839275222246405745257275088548364400416034343698204186575808495617
from py_ecc.bn128 import curve_order
k = 2**28
assert (curve_order - 1) % k == 0
```

### The STARK Field

The Cairo VM used by [Starknet](https://rareskills.io/cairo-tutorial) has a characteristic $2^{251}+17\cdot2^{192}+1$ and has a very large $2^{192}$-th root of unity. 

```python
q = 2**251 + 17*2**192 + 1
k = 2**192
assert (q - 1) % k == 0
```

### The BLS12-381

The BLS12-381 is another pairing-friendly elliptic curve whose curve order has a $2^{32}$-th root of unity. 

```python
# curve_order = 52435875175126190479447740508185965837690552500527637822603658699938581184513
from py_ecc.bls12_381 import curve_order
k = 2**32
assert (curve_order - 1) % k == 0
```

## Library Support

The [Plonky3 library](https://github.com/Plonky3/Plonky3) has libraries for Goldilocks, Baby Bear, and Koala Bear.
