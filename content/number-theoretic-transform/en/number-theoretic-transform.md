# Number Theoretic Transform (NTT)

The Number Theoretic Transform (NTT) is an algorithm for evaluating a polynomial in a finite field on *n* values in O(n log n) time.

Normally, evaluating a polynomial takes O(n) time, so evaluating the polynomial n times would take O(n²).

NTT reduces runtime by reusing work between polynomial evaluations. The NTT algorithm also enables speeding up polynomial multiplication and division. This tutorial series teaches how the NTT algorithm works and *why* it works. This article introduces the NTT tutorial series and provides a table of contents for the rest of the tutorials at the end.

## This is also a Fast Fourier Transform Tutorial Series

We agonized over whether to call this a “Fast Fourier Transform Tutorial Series” or a “Number Theoretic Transform Tutorial Series.” Functionally, the algorithms are *identical* — the only difference being whether we use a finite field or complex numbers.

Readers interested in learning how the Fast Fourier Transform works can also follow this series and come away understanding both.

## About this NTT tutorial series

While it is possible to *describe* the NTT algorithm succinctly (see the next section), *understanding how it works* is surprisingly hard. This tutorial series:

- incrementally introduces the bag of mathematical tricks NTT relies on
- guides the reader through a journey of rediscovering NTT from first principles
- provides optional mathematical proofs of correctness along the way for readers interested in rigor

The NTT algorithm is rather small and can be prompted in one shot by an AI. Consider the output from Gemini below. Don't worry about understanding the code yet; for now, just notice how short it is. We will build up to what it's doing over the course of this series.

```
Prompt: create the NTT algorithm in Python. Show it evaluates the polynomial f(x) = x^2 + 2x + 3 correctly. Use the finite field order 17.
```

Here is the resulting code (with very minor edits to improve readability and save space).

```python
def ntt(a, omega, q):
    """
    Performs the Number Theoretic Transform (NTT) on list 'a'
    over the finite field modulo 'q' using primitive root 'omega'.
    """
    N = len(a)
    if N == 1:
        return a

    # Split into even and odd coefficients
    a_even = ntt(a[0::2], (omega * omega) % q, q)
    a_odd = ntt(a[1::2], (omega * omega) % q, q)

    y = [0] * N
    w = 1
    for i in range(N // 2):
        w_a_odd = (w * a_odd[i]) % q
        y[i] = (a_even[i] + w_a_odd) % q
        y[i + N // 2] = (a_even[i] - w_a_odd) % q
        w = (w * omega) % q

    return y

def direct_evaluate(x, q):
    """Directly evaluates f(x) = x^2 + 2x + 3 mod q"""
    return (x**2 + 2 * x + 3) % q

# --- Configuration ---
q = 17  # Finite field order
omega = 4  # Primitive 4th root of unity mod 17
# f(x) = 3 + 2x + 1x^2 + 0x^3
coefficients = [3, 2, 1, 0]

# 1. Run NTT
ntt_result = ntt(coefficients, omega, q)

# 2. Run Direct Evaluation for Verification
evaluation_points = [(omega**k) % q for k in range(4)]
direct_result = [direct_evaluate(x, q) for x in evaluation_points]

assert (
    ntt_result == direct_result
), "Mismatch between NTT and direct evaluation!"
print("\nSuccess! The NTT evaluated the polynomial correctly.")

```

Almost all the work is being done in these 14 lines of code, excluding the blank lines:

```python
    N = len(a)
    if N == 1:
        return a

    # Split into even and odd coefficients
    a_even = ntt(a[0::2], (omega * omega) % q, q)
    a_odd = ntt(a[1::2], (omega * omega) % q, q)

    y = [0] * N
    w = 1
    for i in range(N // 2):
        w_a_odd = (w * a_odd[i]) % q
        y[i] = (a_even[i] + w_a_odd) % q
        y[i + N // 2] = (a_even[i] - w_a_odd) % q
        w = (w * omega) % q

    return y
```

However, the algorithm’s brevity hides its complexity.

### Where most tutorials on FFT / NTT get it wrong

Skimming the code above, the reader can see that the NTT algorithm, at its core, relies on splitting the polynomial coefficients into even and odd parts, and many tutorials on the subject (as well as AI explanations) attempt to explain NTT through the lens of even-odd splitting.

However, as we will learn, splitting coefficients by their even or oddness is incidental to deeper mathematical tricks that NTT relies on.

Fundamentally, rediscovering NTT requires answering “why is it possible to reuse calculations between polynomial evaluations?” not “what’s so special about even and odd splitting?”

Consider, for example, if we evaluate the polynomial $f(x)=2x^2+3x+6$ at the points $4$ and $7$. On the surface, $f(4)$ doesn’t tell us anything about what $f(7)$ should equal. For example, squaring $4$ gives you no information about what $7$ squared is.

It’s not immediately obvious that evaluating polynomials can be faster than $\mathcal{O}(n^2)$.

Our goal in this series is to rediscover, from first principles, how evaluating a polynomial at one point reduces the work required to evaluate it at another point.

The reader should go through the series in the order provided below. Each chapter introduces a small, digestible subconcept that must be internalized as later chapters build on one another.

### Motivation for this tutorial series

One would think that, given how fundamental the NTT algorithm is to modern engineering, there would be a plethora of tutorials that go beyond describing its mechanics and explain *why it works*. However, we found existing explanations to be insufficient, so we created this one. You will encounter many fresh perspectives in this series that you won’t find elsewhere. We strove to develop new, simplified mental models, not to summarize existing content.

Furthermore, the NTT algorithm structurally mirrors the FRI (Fast Reed-Solomon Interactive Oracle Proof of Proximity). Knowing at a visceral level why the NTT algorithm works makes the FRI algorithm easier to learn.

In fact, the term “Fast” in FRI comes from the fact that the FRI algorithm strongly resembles the Fast Fourier Transform (the NTT algorithm).

### Prerequisites to this tutorial series

We expect basic familiarity with [finite fields and modular arithmetic](https://rareskills.io/post/finite-fields). We will define a “subgroup” in this series, so the reader should already be familiar with the concept of a [group](https://rareskills.io/post/group-theory). Reading the first six chapters of the [ZK Book](https://rareskills.io/zk-book) should be sufficient.

We also expect basic knowledge of linear algebra, such as matrix inverses.

A deep understanding of abstract algebra is not required. We only need fluency with the basic vocabulary listed above.

### A motivated approach to abstract algebra

Many readers will find our treatment of subgroups and roots of unity in a finite field more engaging than a typical mathematical exposition because we present the concepts in the contexts where they appear “in the real world.”

We do not attempt to give a full treatment of abstract algebra topics we cover, only the parts that:

- appear in the real world (in this case, the NTT algorithm)
- are prerequisites for understanding real world applications
- provide simplifying frameworks for the real-world concepts

Everything else we ruthlessly cut or mark as optional reading for the more mathematically inclined readers. We wrote this series for software engineers, not mathematicians.

## Errata and Feedback

If you notice any mistakes or problems in the text, please open an issue or pull request at [https://github.com/RareSkills/zk-book/tree/prod](https://github.com/RareSkills/zk-book/tree/prod)

## Table of Contents

[Polynomial Multiplication in Point Form](https://rareskills.io/post/polynomial-multiplication-point-form). This chapter motivates the need to evaluate a polynomial in sub-quadratic time.

[Multiplicative Subgroups](https://rareskills.io/post/multiplicative-subgroups). Subgroups are a prerequisite to understanding roots of unity.

[Fundamental Theorem of Cyclic Groups](https://rareskills.io/post/fundamental-theorem-cyclic-groups). Roots of unity form a cyclic subgroup, and this theorem illustrates how they behave.

[Roots of Unity in Finite Fields](https://rareskills.io/post/roots-of-unity-finite-field). The NTT algorithm only works if we evaluate a polynomial on the “roots of unity,” which this chapter introduces. For those reading this series to understand the Fast Fourier Transform, the roots of unity in a finite field behave identically to roots of unity in complex numbers, i.e. $e^{i\frac{2\pi k}{n}}$.

[Roots of Unity Congruent to -1](https://rareskills.io/post/roots-of-unity-additive-inverse). Since roots of unity form a subgroup, each root of unity has an inverse (which can be computed efficiently).

[Visualizing Roots of Unity on the Unit Circle](https://rareskills.io/post/roots-of-unity-unit-circle). This chapter shows how to plot roots of unity in a finite field on a unit circle and how to easily visualize additive inverses in the subgroup of the roots of unity.

[Vandermonde Matrices](https://rareskills.io/post/vandermonde-matrix). Vandermonde matrices represent polynomial evaluation as the multiplication of polynomial coefficients and the points on which they are evaluated.

[Squaring Roots of Unity](https://rareskills.io/post/roots-of-unity-squared). This chapter is a prerequisite to the Image Preservation Theorem chapter.

[Roots of Unity Raised to k/2](https://rareskills.io/post/roots-of-unity-raised-k-over-2). This chapter is (also) a prerequisite to the Image Preservation Theorem chapter.

[Square Roots of Roots of Unity](https://rareskills.io/post/roots-of-unity-square-roots). This chapter is (yet another) prerequisite to the Image Preservation Theorem chapter.

[Image Preservation Theorem](https://rareskills.io/post/image-preservation-theorem). The key idea that NTT relies on, oddly enough, doesn’t have a formal name, so we invented the name “image preservation theorem.” This chapter introduces the idea that evaluating a polynomial on a small domain allows for computation reuse in a larger domain.

[Square Root Multivalued Functions](https://rareskills.io/post/square-root-multivalued-functions). A multivalued function returns a set of values instead of a single value. This gives us “two evaluations for the price of one.”

[NTT By Hand](https://rareskills.io/post/ntt-by-hand). The NTT algorithm has several implementation variants. We created our own implementation that lends itself well to being calculated on a pen and paper so learners can viscerally experience the algorithm.

[FFT Friendly Finite Fields](https://rareskills.io/post/fft-friendly-finite-fields). This article lists finite fields that are used in practice for NTT and zero knowledge proofs.

[Orthogonality of the Roots of Unity](https://rareskills.io/post/orthogonality-of-roots-of-unity). This chapter is a prerequisite to the Inverse Number Theoretic Transform and the Inverse of a Vandermonde Matrix.

[Inverse Number Theoretic Transform](https://rareskills.io/post/inverse-number-theoretic-transform). The Inverse Number Theoretic Transform “undoes” the Number Theoretic Transform. It takes a set of points and returns a polynomial in coefficient form.

[Inverse of a Vandermonde Matrix](https://rareskills.io/post/inverse-of-vandermonde-matrix). This chapter proves that the matrix inverse of a Vandermonde matrix is another Vandermonde matrix. This fact makes proving the correctness of Inverse Number Theoretic Transform algorithm trivial.

[Inverse Number Theoretic Transform by Hand](https://rareskills.io/post/intt-by-hand). The previous three chapters establish that the inverse of a Vandermonde matrix is also a Vandermonde matrix. Therefore, we can re-use the Number Theoretic Transform algorithm as the Inverse Number Theoretic Transform with only a tiny change.

[Convolution Theorem](https://rareskills.io/post/convolution-theorem) (Optional). The convolution theorem allows us to create an elegant proof that elementary polynomial multiplication is equivalent to performing NTT, pointwise multiplication, and then INTT.

[Signal Flow Graphs](https://rareskills.io/post/signal-flow-graphs). NTT is frequently modeled with signal flow graphs. This chapter is a quick refresher on the topic.

Signal Flow Graphs in NTT. Here, we construct the signal flow graph for the algorithm presented in *NTT by Hand*. The resulting graph will be used to reason about the algorithm.

Decimation in Time and Decimation in Frequency. The algorithm we used to compute the NTT by hand is functionally equivalent to production NTT algorithm implementations, but there are some minor variations. In this chapter, we show actual NTT implementations used in production.

Radix-2 DIT Algorithm in Python. The NTT has several algorithmic variations, two of which are DIF (Decimation in Frequency) and DIT (Decimation in Time). The former was explained in the previous chapter; in this chapter, we explain the latter.

NTT, INTT, and Fast Polynomial Multiplication in Python. Here, we implement both NTT and INTT in Python and use these algorithms to perform polynomial multiplication in O(n log n) time.

*This article is part of a series on the Number Theoretic Transform in our [**ZK Book**](https://rareskills.io/zk-book)*
