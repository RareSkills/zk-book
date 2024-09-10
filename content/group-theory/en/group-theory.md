# Elementary Group Theory for Programmers

![Group Theory Hero Image](https://static.wixstatic.com/media/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png/v1/fill/w_1000,h_1000,al_c,q_90,enc_auto/935a00_fd134878f9e449418c68ee94bc24cfd9~mv2.png)

This article provides several examples of algebraic groups so that you can build an intuition for them.

A group is a set with:
- a closed binary operator
- the binary operator is also associative
- an identity element
- every element having an inverse

We also discussed abelian groups. An abelian group has the additional requirement that the binary operator is commutative.

Now it’s time to discuss groups as a mathematical structure.

One confusing aspect of using integers under addition as an example of a group is that students often respond with, "but can’t you also multiply integers?"

Admittedly, this can be confusing. There are other algebraic structures, like rings and fields, that involve two binary operators. However, for now, think of a group as having one fixed and unchanging binary operator, and from the group’s perspective, any other possible binary operator either does not exist or isn’t a concern.

Here’s where it gets even more confusing. Sometimes binary operators are other binary operators in disguise.

For example, when dealing with groups that only have addition, sometimes writers casually refer to multiplication even though the group does not have that binary operator. What multiplication is in this context is really shorthand for repeating an addition operation a certain number of times.

## Examples of groups
The best way to get a feel for a group is to see a lot of them. Let’s do that.

### 1. The trivial group
Let our group be a set consisting of the number $\set{0}$ with the binary operator of addition. It is clear that the binary operator is closed and associative

$$
(0 + 0) + 0 = (0 + 0) + 0
$$

and each element has an identity and inverse.

This is not an interesting group, but it is the smallest valid you can create.

Note that a group cannot be empty because by definition it must contain an identity element.

As an exercise for the reader, show that the set $\set{1}$ with the binary operator $\times$ is a group.

### 2. Real numbers are not a group under multiplication
Although reals ($\mathbb{R}$) under multiplication has an identity (the number $1$) and is closed and associative, they do not all have an inverse.

Real numbers are invertible by taking their multiplicative inverse $(1 / n)$, but zero, although a real number, cannot be inverted because $1/0$ is undefined and not a real number.

Strictly speaking, the inverse of $a$, is $b$ such that $ab = 1$. Here we are saying that if $a = 0$ there is no element in the set $b$ such that $ab = 1$.

Positive real numbers excluding zero are a group under multiplication however. Every element has an inverse ($1/n$), and the identity element is 1.

**Exercise:**  Integers (positive and negative) are not a group under multiplication. Show which of the four requirements (closed, associative, existence of identity, all elements having an inverse) are not satisfied.

### 3. $n \times m$ matrices of real numbers are a group under addition

Let’s work it out:

Matrix addition is closed and associative. If you add an $n × m$ matrix of real numbers with another $n × m$ matrix of real numbers, you get an $n × m$ matrix of real numbers.
The identity matrix is an $n × m$ matrix of all zeros
the inverse of a matrix is that matrix multiplied by -1.
Hey wait, we aren’t allowed to multiply by -1 right?

A group doesn’t require the inverse to be "computable using the group binary operator" only to exist. That is, we compute the inverse as multiplying each element by $-1$ even though multiplication by $-1$ is not a group operation.

If we define our operator for $n \times m$ matrices to be the Hadamard product (element-wise multiplication), this cannot be a group for the same reason discussed above. Specifically, the inverse is computed as the reciprocal of the element, and the reciprocal of zero is not a real number.

If we define our operator to be traditional matrix multiplication over square matrices, this may or may not be a group depending on the set definition, as we will see in section example 5.

### 4. The set of 2D points on an euclidean plane under element-wiseaddition is a group

This is actually a special case of the previous example, but let’s look at it through a different angle.

Consider the set of all real-valued $(x, y)$ points on a standard 2D plane.

Our binary operator is adding points together, for example $(1,1) + (2,2) = (3,3)$.

Our identity element is the origin, because adding with that will result in the same location of the other point.

The inverse of a point is simply the “mirror image” over the origin (with the $x$ and $y$ coordinates negated) because when you add a point to its inverse, they result in the origin.

### 5. $n \times n$ matrices of non-zero determinant under multiplication are a group
By way of review, if a matrix has a non-zero determinant, then it is invertible. When a matrix of non-zero determinant is multiplied by another matrix of non-zero determinant, then the product also has a non-zero determinant. Actually, we can be more specific, if $A$, $B$, and $C$ are square matrices, and $AB = C$, then $\det(a) \times \det(b) = \det(c)$.

Let’s work through the definitions

- Multiplication of non-zero determinant matrices is closed because you cannot “leave the group” as the product will always have non-zero determinant. Matrix multiplication is associative.
- The identity element is the identity matrix (all zeros, except the main diagonal is one).
- The inverse is simply the matrix inverse, and matrices with determinant of non-zero are invertible.

### 6. $n \times n$ matrices of zero determinant under multiplication are a not group
Remember, a matrix with zero determinant cannot be inverted, so this set cannot have an inverse. In this case, we do not have an identity element because the identity matrix has determinant one. Since we have no identity element, this set and binary operator isn’t even a monoid, it’s a semigroup.

### 7. The set of all polynomials of a fixed upper-bounded degree is a group under addition

If we say "all polynomials with real coefficients of degree at most 7 under addition" this is a valid group.

- Polynomial addition is closed and associative
- The identity is the polynomial $0$ (or $0x^0$ to be precise)
- The inverse is the coefficients multiplied by $-1$
- We cannot say degree "exactly $7$" because the identity element has degree 0, and wouldn’t be part of the group.

Polynomials of a fixed upper-bounded degree under multiplication are not a group, because generally the degree gets larger when you multiply polynomials, hence the operator would not be closed.

### 8. Addition modulo a prime number is a group
Let’s take a prime number $7$.

Here, the identity is still $0$, because you add by $0$ and get the same number back.

In this situation, what would the inverse of $5$ be?

It would just be $2$, because $7 - 5 = 2$, or $5 + 2 \mod 7$ is zero (the identity).

### 9. Multiplication modulo a prime number is not a group
Zero doesn't have an inverse for this example.

If we omit the number $0$, then we have a group. The identity element is 1, and the inverse of an element $a$ is its modular inverse $a^{-1}$.

### 10. A fixed based raised to integer powers under multiplication is a group

If two integer powers of $b$ are multiplied together, the result is the integer power of the product of the bases. For example, $2^3 \times 2^4 = 2^{3 + 4} = 2^7$. This works for arbitrary bases:

$$
b^x \times b^y = b^{x + y}
$$

The identity element is $b^0$, which is $1$, and the inverse of $b^x$ is $b^{-x}$.

## Finite groups
As the name suggests, a finite group has a finite number of elements in it. The set of all integers under addition is not finite, but addition of integers modulo a prime number is a finite group.

In zero knowledge proofs, we only use finite groups.

## Order of a group
The order of a group is the number of elements in it.

## Cyclic groups
A cyclic group is a group that has an element such that every element in the group can be “generated” by applying the binary operator repeatedly to that element, or to it’s inverse.

### Examples of a cyclic groups
#### Example 1: The group consisting of 0 under addition is a cyclic group

This is trivially true because $0 + 0 = 0$ generates every element in the group.

#### Example 2: Addition modulo 7 is a cyclic group
If we start with $1$ and add $1$ to itself repeatedly, we will generate every element in the group. For example:

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

#### Example 3: Multiplication modulo $7$ is a cyclic group, if we exclude zero
We have to be careful when picking the generator here, because, for example, $2$ won't generate the whole group.

$$
\begin{align*}
&2 * 2 &\equiv 4 \pmod 7 \\
&2 * 2 * 2 &\equiv 1 \pmod 7 \\
&2 * 2 * 2 * 2 &\equiv 2 \pmod 7 \\
&2 * 2 * 2 * 2 * 2 &\equiv 4 \pmod 7 \\
&...\
\end{align*}
$$

We can see that $2$ can only generate $\set{1,2,4}$. However, if we pick $3$ as the generator, then we can generate the whole group.

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

The reason why $3$ works and $2$ does not is because $3$ is a *[primitive root](https://en.wikipedia.org/wiki/Primitive_root_modulo_n)*.

We can use the galois library to find primitive roots:

```python
from galois import GF
GF7 = GF(7)
print(GF.primitive_elements)
# [3, 5]
```

From the code output above, we can see that $5$ will also generate all the non-zero elements.

### If a group is cyclic, then it is abelian
This one is a bit more subtle, but consider this:

In a cyclic group, every element in the group can be generated as $(g + g + … + g)$. Let’s arbitrarily pick an element $r$. Let’s partition this set of additions like so

$$
r = \underbrace{g + g + \dots + g}_\text{m times} + \underbrace{g + g + \dots + g}_\text{n times}
$$

Because of associativity, we can add parenthesis 

$$
r = \underbrace{(g + g + \dots + g)}_\text{m times} + \underbrace{(g + g + \dots + g)}_\text{n times}
$$

Let $g$ added to itself $m$ times be $p$ and $g$ added to itself $n$ times be $q$. Therefore,

$$r = p + q$$

By associativity, we can repartition the original equation as follows (note that the $m$ and $n$ switched places!)

$$
r = \underbrace{(g + g + \dots + g)}_\text{n times} + \underbrace{(g + g + \dots + g)}_\text{m times}
$$

And we get back:

$$r = q + p$$

Hence, if the group is cyclic, then the group is abelian.

Note that the converse of this statement isn’t true. Real numbers under addition are an abelian group, but they are not cyclic.

Cyclic groups don't have to be arithmetic modulo some prime number, but these are the only cyclic groups we will be using in our discussion of zero knowledge proofs.

## The identity element of a group is unique
A group cannot have two identity elements. Don’t overthink this one, it’s derived by simple contradiction. Let’s say $\square$ is our binary operator and $e$ is our identity element.

Let’s say we have an alternative identity element $e'$. This means the following:

$$a \square a^{-1} = e \text{ and } a \square a^{-1} = e'$$

If we say $e≠e'$, then it must also be true that 

$$a \square a^{-1} \neq a \square a^{-1}$$

But that is obviously a contradiction, hence identity elements must be unique.

## The use of groups in zero knowledge proofs
Understanding group theory for the purpose of zero knowledge proofs is more of an exercise in vocabulary. When we say "inverse" or "identity" we want to you to immediately grasp what those mean.

Additionally, groups help us reason about very complex mathematical objects without understanding how they work. We've used familiar examples in this article, but later on we will deal with very unfamiliar objects such as *elliptic curves over field extensions*. Even though you don't know what exactly that is, if we tell you it is a group, you already know a lot about what it is.

## Learn more with RareSkills
This article is part of a series on ZK proofs. See our [ZK Book](https://www.rareskills.io/zk-book) for the full series.

*Originally Published August 1, 2023*