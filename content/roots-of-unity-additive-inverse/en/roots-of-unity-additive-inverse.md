# Roots of unity ω have the property ω^(k/2) ≡ −1

In previous articles, we established that in the [finite field](https://rareskills.io/post/finite-fields) $\mathbb{F}_q$, if $k$ divides $q-1$:

- **There exists a unique subgroup of order $k$ - the $k$-th roots of unity.**
- **A generator $\omega$  of this subgroup is a primitive $k$-th root of unity and is given by $\omega = g^{\frac{q-1}{k}}$, where $g$ is a generator of $\mathbb{F}_q^*$.**
- **$k$ is the smallest positive integer for which $\omega^k\equiv 1$.**

In this article, we explore a key property of a [primitive root of unity](https://rareskills.io/post/roots-of-unity-finite-field) $\omega$ in $\mathbb{F}_q$: **As long as $k$ is even, $\omega^{\frac{k}{2}}$ is congruent to** $-1$. 

## Motivation

For some applications, we want to find relationships among different $k$-th roots of unity for some $k$. More precisely, we want to determine which roots of unity are additive inverses of others.

In a field $\mathbb{F}_q$, if $k$ divides $q-1$, the $k$-th roots of unity can be written as 

$$
\{ 1, \omega, \omega^2, ..., \omega^{k-1} \}
$$

where $\omega$ is a primitive $k$-th root of unity.

One might ask: can we easily find $-\omega$ or $- \omega^2$? Yes, we can. Let's take the following fact, which we will prove shortly: If $k$ is even, then $\omega^\frac{k}{2} \equiv -1$. 

Let us use this fact. Since $-\omega$ is the same as $(-1) \omega$, knowing that $-1 \equiv \omega^\frac{k}{2}$, we have that

$$
-\omega = (-1) \omega = \omega^\frac{k}{2} \omega = \omega^{\frac{k}{2} + 1}
$$

The same can be used to find $- \omega^2$. We have that

$$
-\omega^2 = (-1) \omega^2 = \omega^\frac{k}{2} \omega^2 = \omega^{\frac{k}{2} + 2}
$$

This can be generalized by any $i$ as

$$
- \omega^i = \omega^{\frac{k}{2} + i}
$$

This establishes a relationship between the $k$-th roots of unity. 

As an example, let us consider the 8th roots of unity,

$$
\{ 1, \omega, \omega^2, \omega^3, \omega^4, \omega^5, \omega^6, \omega^7 \}
$$

Using the relationship obtained, the 8th roots of unity can be written as

$$
\{ 1, \omega, \omega^2, \omega^3, -1, -\omega, - \omega^2, -\omega^3\}
$$

For this to hold, we just need to show that $\omega^\frac{k}{2} \equiv -1$ for any $k$. Let's proceed to do that now.

## What is the meaning of $-1$ in a finite field $\mathbb{F}_q$

In $\mathbb{F}_q$, the notation $-a$ denotes the **additive inverse** of $a$, satisfying $a + (-a) = 0$.

For example, in $\mathbb{F}_7$, since $6+1 = 7\equiv 0\pmod{7}$, we say $6$ is the additive inverse of $1$, and write

$$
-1 \equiv 6\pmod{7}.
$$

For any finite field $\mathbb{F}_q$, since $(q-1) + 1 = q \equiv 0\pmod{q}$, the additive inverse of $1$ is always $q-1$:

$$
-1 \equiv q-1\pmod{q}.
$$

Let’s now look at examples of $\omega^{\frac{k}{2}}$.

## Example of $\omega^{\frac{k}{2}}$ among the $k$-th roots of unity in $\mathbb{F}_{17}$

In the following examples, we use the generator $g =3$ for the multiplicative group $\mathbb{F}_{17}^*$. Since $16$ is the additive inverse of $1$ in $\mathbb{F}_{17}$, we have:

$$
-1 \equiv 16\pmod{17}
$$

### Case $k=4$

A **primitive 4th root of unity** is $\omega = g^{\frac{q-1}{k}} = g^{\frac{16}{4}} = 3^4 \equiv 13\pmod{17}$.

Here, $\omega^{\frac{k}{2}} = \omega^{\frac{4}{2}} = \omega^2 = 13^2\equiv 16 \equiv -1$.

**Thus, we conclude that $\omega^{\frac{k}{2}} \equiv -1$ for $k=4$.**

### Case $k = 8$

Now $\omega = g^{\frac{q-1}{k}} = g^{\frac{16}{8}} = 3^2 \equiv 9\pmod{17}$ is a **primitive 8th root of unity.**

For $k=8$,  $\frac{k}{2} = 4$, and we have $\omega^{\frac{k}{2}} = 9^4\equiv 16 \equiv -1$.

## Example of $\omega^{\frac{k}{2}}$ among the $k$-th roots of unity in $\mathbb{F}_{97}$

In the finite field $\mathbb{F}_{97}$, we have $q-1 = 97-1 = 96$. The additive inverse of $1$ is:

$$
-1\equiv 96\pmod{97}
$$

The element $g = 5$ is a generator of the multiplicative group $\mathbb{F}_{97}^* = \{1,2,\dots,96\}$. The `galois` library provides a convenient way to find this generator using the `primitive_element` property, as shown below:

```python
import galois
GF = galois.GF(97) # Define the field
GF.primitive_element # Returns GF(5, order=97)
```

For $k=32$, we obtain $\omega$ as

$$
\omega = g^{\frac{q-1}{k}} = g^{\frac{96}{32}} = 5^3 = 125 \equiv 28\pmod{97}.
$$

Letting $\frac{k}{2} = 16$, we calculate $\omega^{\frac{k}{2}} = 28^{16}$ with the following Python code:

```python
result = 28**16 % 97
print(f"28^16 % 97 = {result}")  # Output: 96
```

Thus:

$$
\omega^{16} = 28^{16} \equiv 96 \equiv -1\pmod{97}.
$$

We conclude that, for $k = 32$, $\omega^{\frac{k}{2}} \equiv -1$ in $\mathbb{F}_{97}$.

## Python code

The following Python code checks if $\omega^\frac{k}{2} \equiv - 1$ for a field $\mathbb{F}_q$. It is used to test this property in $\mathbb{F}_{17}$ for $k = 8$ and $\omega = 9$. You can test it for $k = 32$ with $\omega = 28$ in $\mathbb{F}_{97}$ or another valid combination of your choice.

```python
import galois

def check_omega_half_is_minus_one(q, omega, k):
	GF = galois.GF(q)
	if k % 2 != 0:
		raise ValueError("k must be even")

	omega_half = GF(omega) ** (k // 2)

	return omega_half == GF(q-1)

# Example usage:
q = 17
k = 8
omega = 9
result = check_omega_half_is_minus_one(q, omega, k)
print(f"For ω={omega} and k={k}: ω^(k/2) == -1 is {result} in F_{q}")
```

## **The mathematical proof**

Let $g$ be a generator of $\mathbb{F}_q^*$. This equivalently means that $g$ is a **primitive $(q-1)$-th root of unity**.

Let $\omega=g^\frac{q-1}{k}$ be a primitive $k$-th root of unity in the finite field $\mathbb{F}_q$. We will prove that $\omega^{\frac{k}{2}} \equiv -1$.

The idea of the proof is to show that $\omega^\frac{k}{2}$ can only be $1$ or $−1$. We will exclude the possibility that $\omega^\frac{k}{2}$ is $1$, leaving $−1$ as the only option.

**Proof**:

Let's take the square of $\omega^\frac{k}{2}$. It is given by

$$
\left(\omega^\frac{k}{2} \right)^2 =  \omega^k \equiv 1
$$

The last equality follows from the fact that $\omega$ is a primitive $k$-th root of unity. 

Since the square of $\omega^\frac{k}{2}$ is $1$, that is, $\left(\omega^\frac{k}{2} \right)^2 \equiv 1$, then $\omega^\frac{k}{2}$ can only be $1$ or $-1$, because only $1^2$ or $(-1)^2$ is equal to $1$.

Let us show that it cannot be $1$.

Replace $\omega = g^{\frac{q-1}{k}}$ into $\omega^{\frac{k}{2}}$. This gives us that

$$
\omega^{\frac{k}{2}} = \left(g^{\frac{q-1}{k}}\right)^{\frac{k}{2}} = g^{\frac{q-1}{2}}
$$

Since $g$ is a **primitive** $(q-1)$-th root of unity, the smallest positive integer $r$ for which $g^r\equiv 1$ is $r=q−1$. 

In other words, there is no integer $r$ smaller than $q-1$ such that $g^{r} \equiv 1$.  Since $\frac{q-1}{2} < q-1$, $g^{\frac{q-1}{2}}$ cannot be $1$. Therefore, the only possibility is that $\omega^\frac{k}{2}$ is equal to $-1$.

## Summary

- If $\omega$ is a primitive $k$-th root of unity in a finite field $\mathbb{F}_q$, then $\omega^{\frac{k}{2}} \equiv -1$ for even $k$.
- Using this property, we have that $- \omega^i = \omega^{\frac{k}{2}+i}$  or stated equivalently, $\omega^i$ is the additive inverse of $\omega^{k/2+i}$.

The [following chapter](https://rareskills.io/posts/roots-of-unity-unit-circle) will introduce a visualization that makes these points easier to remember.
