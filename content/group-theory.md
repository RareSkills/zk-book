# Elementary Group Theory for Programmers

![Group Theory Hero Image](https://static.wixstatic.com/media/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png/v1/fill/w_1000,h_1000,al_c,q_90,enc_auto/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png)

This article provides several examples of groups so that you can build an intuition for them.

A group is a set with:
- a closed binary operator
- the binary operator is also associative
- an identity element
- every element having an inverse

We also discussed abelian groups. An abelian group has the additional requirement that the binary operator is commutative

Now it’s time to discuss groups as a mathematical structure.

One confusing aspect about using integers under addition as an example of a group is students commonly respond with “but can’t you also multiply integers?”

Admittedly, this is confusing. There are other algebraic structures later that expect two binary operators (rings and fields), but for now think of a group under one fixed and unchanging binary operator and from the group’s perspective, any other possible binary operator does not exist or isn’t a concern.

Here’s where it gets even more confusing. Sometimes binary operators are other binary operators in disguise.

For example, when dealing with groups that only have addition, sometimes writers casually refer to multiplication even though the group does not have that binary operator. What multiplication is in this context is really shorthand for repeating an addition operation a certain number of times.

## Examples of groups
The best way to get a feel for a group is to see a lot of them. Let’s do that.

### 1. The trivial group
Let our group be a set consisting of the number 0 with the binary operator of addition. It is clear that the binary operator is closed and associative

$$
(0 + 0) + 0 = (0 + 0) + 0
$$

and each element has an identity and inverse.

This is not an interesting group, but it is the smallest valid you can create.

Note that a group cannot be empty because by definition it must contain an identity element.

### 2. Real numbers are not a group under multiplication
Although reals ($\mathbb{R}$) under multiplication has an identity (the number 1) and is closed and associative, they do not all have an inverse.

Real numbers are invertible by taking the inverse (1 / n), but zero is a real number and it cannot be inverted because $1/0$ is not a real number. In general, you cannot multiply zero by something and get the identity element of 1.

Positive real numbers excluding zero are a group under multiplication however. Every element has an inverse ($1/n$), and the identity element is 1.

Exercise:  Integers (positive and negative) are not a group under multiplication. Explain why.

### 3. $n \times m$ matrices of real numbers are a group under addition

Let’s work it out:

Matrix addition is closed and associative. If you add an $n × m$ matrix of real numbers with another $n × m$ matrix of real numbers, you get an $n × m$ matrix of real numbers.
the identity matrix is an $n × m$ matrix of all zeros
the inverse of a matrix is that matrix multiplied by -1.
Hey wait, we aren’t allowed to multiply by -1 right?

A group doesn’t require the inverse to be “computable by group laws” only to exist. The group of $n × m$ matrices of real numbers contains inverses for every element, and that’s what matters.

If we define our operator to be the Hadamard product, that is, element-wise multiplication, this cannot be a group for the same reason discussed above.

If we define our operator to be traditional matrix multiplication over square matrices, this may or may not be a group depending on the set definition, as we will see in section example 5.

### 4. The set of 2D points on an euclidean plane under element-wiseaddition is a group

This is actually a special case of the above example, but let’s look at it through a different angle.

Consider our set to be the set of all real-valued $(x, y)$ points on a typical plot.

Our binary operator is adding points together, for example $(1,1) + (2,2) = (3,3)$.

Our identity element is the origin, because adding with that will result in the same location of the other point.

The inverse is simply the “mirror image” over the origin (the $x$ and $y$ flipped) because when you add them together, they result in the origin.

### 5. $n \times n$ matrices of non-zero determinant under multiplication are a group
By way of review, if a matrix has a non-zero determinant, then it is invertible. When a matrix of non-zero determinant is multiplied by another matrix of non-zero determinant, then the product also has a non-zero determinant. Actually, we can be more specific, if $A$, $B$, and $C$ are square matrices, and $AB = C$, then $\det(a) \times \det(b) = \det(c)$.

Let’s work through the definitions

- Multiplication of non-zero determinant matrices is closed because you cannot “leave the group” as the product will always have non-zero determinant. Matrix multiplication is associative.
- The identity element is the identity matrix (all zeros, except the main diagonal is one).
- The inverse is simply the matrix inverse, and matrices with determinant of non-zero are invertible.

### 6. $n \times n$ matrices of zero determinant under multiplication are a not group
Remember, a matrix with zero determinant cannot be inverted, so this set cannot have an inverse. In this case, we do not have an identity element because the identity matrix has determinant one. Since we have no identity element, this set and binary operator isn’t even a monoid, it’s a semigroup.

### 7. The set of all polynomials of a fixed upper-bounded degree is a group under addition

If we say “all polynomials of degree at most 7 under addition” this is a valid group.

- Polynomial addition is closed and associative
- The identity is the polynomial 0 (or 0x^0 to be precise)
- The inverse is the coefficients multiplied by -1
- We cannot say degree “exactly 7” because the identity element has degree 0, and wouldn’t be part of the group.

Polynomials of a fixed upper-bounded degree under multiplication are not a group, because generally the degree gets larger when you multiply polynomials, hence the operator would not be closed.

### 8. Addition modulo a prime number is a group
Let’s take a prime number 7.

Here, the identity is still 0, because you add by 0 and get the same number back.

In this situation, what would the inverse of 5 be?

It would just be 2, because 7 - 5 = 2, or 5 + 2 mod 7 is zero (the identity).

### 9. Multiplication modulo a prime number is not a group
The problem is we can’t define an identity and inverse that works for everything.

If we define our identity to be 1, then it isn’t possible to invert zero, because zero cannot be multiplied with anything to obtain 1. If we set our identity to be zero, then it won’t behave like an identity because any number multiplied by zero is not itself, but zero.

If we omit the number 0, then we have a group. The identity element is 1, and the inverse of an element $a$ is its modular inverse $a^{-1}$.

### 10. A fixed based raised to integer powers under multiplication is a group

If two integer powers of $b$ are multiplied together, the result is the integer power of the product of the bases. For example, $2^3 \times 2^4 = 2^{3 + 4} = 2^7$. This works for arbitrary bases:

$$
b^x \times b^y = b^{x + y}
$$

The identity element is $b^0$, which is 1, and the inverse of $b^x$ is $b^{-x}$.

## Finite groups
As the name suggests, a finite group has a finite number of elements in it. The set of all integers under addition is not finite, but addition of integers modulo a prime number is a finite group.

In Zero Knowledge Proofs, we only use finite groups.

## Order of a group
The order of a group is the number of elements in it.

## Cyclic groups
A cyclic group is a group that has an element such that every element in the group can be “generated” by applying the binary operator repeatedly to that element, or to it’s inverse.

### Examples of a cyclic groups
#### Example 1: The group consisting of 0 under addition is a cyclic group

This is trivially true because 0 + 0 = 0 generates every element in the group.

#### Example 2: Addition modulo 7 is a cyclic group
If we start with 1 and add 1 to itself repeatedly, we will generate every element in the group. For example:

$$
\begin{align*}
&1 + 1 &= 2 \\
&1 + 1 + 1 &= 3 \\
&1 + 1 + 1 + 1 &= 4 \\
&1 + 1 + 1 + 1 + 1 &= 5 \\
&1 + 1 + 1 + 1 + 1 + 1 &= 6 \\
&1 + 1 + 1 + 1 + 1 + 1 + 1 &= 0 \\
&1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 &= 1 \\
\end{align*}
$$

#### Example 3: Multiplication modulo 7 is a cyclic group, if we exclude zero
We have to be careful when picking the generator here, because, for example, 2 won't generate the whole group.

$$
\begin{align*}
&2 * 2 &\equiv 4 \pmod 7 \\
&2 * 2 * 2 &\equiv 1 \pmod 7 \\
&2 * 2 * 2 * 2 &\equiv 2 \pmod 7 \\
&2 * 2 * 2 * 2 * 2 &\equiv 4 \pmod 7 \\
&...\
\end{align*}
$$

We can see that 2 can only generate $\set{1,2,4}$. However, if we pick 3 as the generator, then we can generate the whole group.

$$
\begin{align*}
3 ^ 2 \equiv 2 \pmod 7 \\
3 ^ 3 \equiv 6 \pmod 7 \\
3 ^ 4 \equiv 4 \pmod 7 \\
3 ^ 5 \equiv 5 \pmod 7 \\
3 ^ 6 \equiv 1 \pmod 7 \\
3 ^ 7 \equiv 3 \pmod 7 \\
&...\
\end{align*}
$$

The reason why 3 works and 2 does not is because 3 is a *[primitive root](https://en.wikipedia.org/wiki/Primitive_root_modulo_n)*.

We can use the galois library to find primitive roots:

```python
from galois import GF
GF7 = GF(7)
GF.primitive_elements
# [3, 5]
```

### If a group is cyclic, then it is abelian
This one is a bit more subtle, but consider this:

In a cyclic group, every element in the group can be generated as $(g + g + … + g)$. Let’s arbitrarily pick an element R. Let’s partition this set of additions like so

$$
R = \underbrace{g + g + \dots + g}_\text{m times} + \underbrace{g + g + \dots + g}_\text{n times}
$$

Because of associativity, we can add parenthesis 

$$
R = \underbrace{(g + g + \dots + g)}_\text{m times} + \underbrace{(g + g + \dots + g)}_\text{n times}
$$

Let $g$ added to itself $m$ times be $P$ and $g$ added to itself $n$ times be $Q$. Therefore,

$$R = P + Q$$

By associativity, we can repartition the original equation as follows (note that the $m$ and $n$ switched places!)

$$
R = \underbrace{(g + g + \dots + g)}_\text{n times} + \underbrace{(g + g + \dots + g)}_\text{m times}
$$

And we get back:

$$R = Q + P$$

Hence, if the group is cyclic, then the group is abelian.

Note that the converse of this statement isn’t true. Real numbers under addition are an abelian group, but they are not cyclic.

## The identity element of a group is unique
A group cannot have two identity elements. Don’t overthink this one, it’s derived by simple contradiction. Let’s say ▢ is our binary operator and e is our identity element.

Let’s say we have an alternative identity element e'. This means the following:

$$a \square a^{-1} = e \text{ and } a \square a^{-1} = e'$$

If we say $e≠e'$, then it must also be true that 

$$a \square a^{-1} \neq a \square a^{-1}$$

But that is obviously a contradiction, hence identity elements must be unique.

Going back to how we defined binary operators in set theoretic terms, we know the mapping from the sets $S × S$ back to $S$ cannot have the same ordered pair mapping to different elements, so by this definition we know identities are unique.

*Originally Published August 1, 2023*