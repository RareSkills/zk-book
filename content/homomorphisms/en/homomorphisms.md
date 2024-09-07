# Homomorphisms by Example

A homomorphism between two groups exists if a *structure preserving map* between the two groups exists.

Suppose we have two algebraic data structures $(A,\square)$ and $(B, \blacksquare)$, where the binary operator of $A$ is $\square$ and the binary operator of $B$ is $\blacksquare$.

A homomorphism from $A$ to $B$ exists if and only if there exists a function $\phi: A\rightarrow B$ such that

$$
\phi(a_i \square a_j)=\phi(a_i)\blacksquare\phi(a_j)\space\space\forall a_i,a_j\in A
$$

In other words, if $a_i \square a_j = a_k$, then $\phi(a_i) \blacksquare \phi(a_j) = \phi(a_k)$.

Note that a homomorphism is one-directional. The function $\phi$ takes elements in $A$ and maps them to elements in $B$. We have no requirements about "going backwards."

We’ll first show some simple examples, provide some clarification, and then provide more complex examples.

## Simple examples of Homomorphisms

### All integers under addition to all even integers under addition

Let $A$ be the set of all integers under addition, and let $B$ be the set of all even integers under addition. It is clear that both $A$ and $B$ are groups.

Let $\phi(x)=2x$

We see that $\phi$ defines a homomorphism from $A$ to $B$ because the following is true for any pair of integers $a_i$ and $a_j$

$$
\begin{align*}
\phi(a_i+a_j)&=\phi(a_i)+\phi(a_j)\\
2(a_i+a_j)&=2(a_i)+2(a_j)
\end{align*}
$$

### All strings under concatenation to all integers zero or greater

For example, let $A$ be the Monoid of all strings (including the empty string) under concatenation, and let $B$ be the Monoid of all integers zero or greater under addition.

There exists a homomorphism from $A$ to $B$ because there exists a function $\phi$ that maps strings to integers zero or greater and preserves the following property

$$
\phi(a_i+a_j)=\phi(a_i)+\phi(a_j)
$$

In this case, $\phi$ is the *length* of the string. For example:

$$
\begin{align*}
\text{Rare}&\rightarrow 4\\
\text{Skills}&\rightarrow 6\\
\text{RareSkills}&\rightarrow 10\\
\end{align*}
$$

Here, we have

$$
\begin{align*}
\phi(\text{Rare})&=4\\
\phi(\text{Skills})&=6\\
\phi(\text{RareSkills})&=10\\
\phi(\mathsf{concat}(\text{Rare},\text{Skills}))&=\phi(\text{Rare})+\phi(\text{Skills})\\
\end{align*}
$$

### All real numbers under addition to all $n\times m$ matrices of real number under addition

Some homomorphisms may seem rather trivial once you get the hang of them. This is an example of such a homomorphism. In this case, our function $\phi$ simply repeats the real number $n\times m$ times. For example, if $n=3$ and $m=2$, then $\phi(8.8)$ would be:

$$
\begin{bmatrix}
8.8&8.8\\
8.8&8.8\\
8.8&8.8
\end{bmatrix}
$$

As an example, if $\phi(8.8 + 0.2)=\phi(8.8)+\phi(0.2)$ because

$$
\begin{bmatrix}
9&9\\
9&9\\
9&9\\
\end{bmatrix}=
\begin{bmatrix}
8.8&8.8\\
8.8&8.8\\
8.8&8.8
\end{bmatrix}+
\begin{bmatrix}
0.2&0.2\\
0.2&0.2\\
0.2&0.2\\
\end{bmatrix}
$$

## Clarifications about Homomorphisms

- $\phi$ must work with every possible pair of elements from $A$ (including pairs of the same element). However, it does not need to “access” all the elements of $B$. For example, a homomorphism that maps every element in $A$ to the identity element in $B$ is a valid homomorphism, but not a useful one. It’s called the *trivial homomorphism*.
- If we choose two arbitrary sets with a binary operator, a homomorphism may not necessarily exist.
- There may be a homomorphism from $A$ to $B$, but not necessarily from $B$ to $A$.
- If there is a homomorphism from $A$ to $B$ and from $B$ to $A$, and $\phi$ is the map from $A$ to $B$, the inverse of $\phi$ may not necessarily be a valid map for the homomorphism from $B$ to $A$

## More examples of homomorphisms

### Integers under addition to integer powers of $b$ under multiplication

Suppose we have group $A=(\mathbb{Z},+)$ (the set of all integers under addition) and the group $B$, which is the set of all integer powers of $b$ under multiplication, i.e., $B=(b^i\space:\space i\in\mathbb{Z}, \times)$. We can arbitrarily set $b=2$ to make the example easier to think about.

There exists a homomorphism from $A$ to $B$, defined by $\phi(x)=b^x$. By the rules of algebra,

$$
\begin{align*}
\phi(a_i+a_j)&=\phi(a_i)\times\phi(a_j)\\
b^{a_i + a_j}&=b^{a_i}b^{a_j}
\end{align*}
$$

To understand why this relationship holds, consider that

$$
b^{a_i}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_i} \text{ times}}
$$

$$
b^{a_j}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_j} \text{ times}}
$$

$$
b^{a_i +a_j}=\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_i} \text{ times}}\cdot\underbrace{b\cdot b\cdot\dots\cdot b}_{{a_j} \text{ times}}
$$

$$
b^{a_i +a_j}=\underbrace{b\cdot b\cdot\dots\cdot b\cdot b\cdot b\dots\cdot b}_{{a_i+a_j} \text{ times}}
$$

### Integers under addition to integer powers of $b$ under multiplication modulo a prime number

### $n\times m$ matrices under addition to integers under addition

In this case, $\phi$ simply adds up all the elements in a matrix. Why this works is left as an exercise for the reader.

### $2\times2$ matrices of integers under multiplication to integers under multiplication

There is a homomorphism from the first to the second Monoid because $\phi$ is the *determinant* of the matrix and the following rule holds:

$$
XY=Z\rightarrow\det(X)\det(Y)=\det(Z)
$$

where $X,Y,Z$ are $2\times2$ integer matrices. Why these are two algebraic data structures are Monoids and not groups are left as an exercise for the reader.

### The group of rational numbers (excluding rational numbers where the denominator is a multiple of $p$) to addition modulo $p$

This concept was already taught in our article on [finite fields](https://www.rareskills.io/post/finite-fields), but we didn’t use the term “homomorphism” to describe it.

Let $A$ be the group of all rational numbers whose denominators are not a multiple of $p$, under addition. Let $B$ be the finite field modulo $p$.

There exists a homomorphism from group $A$ to group $B$. $\phi$ is 

$$
\phi(x) = \mathsf{numerator}(x)\times\mathsf{modular\_inverse}(\mathsf{denominator}(x)) \pmod p
$$

Or in Python:

```python
p = 11
def phi(num, den):
    return num * pow(den, -1, p) % p
```

For example: 

- $1/3 + 3/5 = 14/15$
- $1/3$ is congruent to $6 \pmod {17}$
- $3/5$ is congruent to $4 \pmod {17}$
- $4 + 6\equiv10 \pmod {17}$
- $14/15\equiv 10 \pmod {17}$

Saying $1/3$ is congruent to $6 \pmod {17}$ is equivalent to the statement $\phi(1/3)=6$.

### The Monoid of rational numbers (excluding rational numbers where the denominator is a multiple of $p$) to multiplication modulo $p$ (excluding zero)

Let’s use the same example as above, but with multiplication. The function $\phi$ remains the same.

- $1/3 * 3/5 = 1/5$
- $1/3$ is congruent to $6 \pmod {17}$
- $3/5$ is congruent to $4 \pmod {17}$
- $4 \times 6\equiv7 \pmod {17}$
- $1/5\equiv 7 \pmod {17}$

## Exercises for the reader

Find a homomorphism for the following pairs of algebraic data structures. If you get stuck (or just don’t want to solve the problem), you can Google the answer or consult with a chatbot.

1. Real numbers under addition to polynomials with real coefficients under addition.
2. Polynomials with real coefficients to real numbers under addition. Hint: even though this look similar to problem 1, the function $\phi$ will be completely unrelated to the answer for the previous problem.
3. Positive real numbers greater than zero under multiplication to all real numbers under addition.

## Homomorphic Encryption

If $\phi$ is computationally difficult to invert, then $\phi$ *homomorphically encrypts* the elements of $A$.

Let $A$ be all integers under addition, and $B$ be the target group and $\blacksquare$ be binary operator of $B$.

### Zero Knowledge Addition, example 1
Suppose we wish to prove to a verifier that we computed $2 + 3=5$. We would give the verifier $(x, y, 5)$ where $x=\phi(2), y= \phi(3)$ and the verifier check that:

$$
x\blacksquare y \stackrel{?}=\phi(5)
$$

Note that homomorphic encryption implies that the verifier knows the function $\phi$.

### Zero Knowledge Addition, example 2
A prover makes the claim, "I have two numbers $a$ and $b$, and $b$ is five times $a$." The prover sends $\phi(a)$ and $\phi(b)$ to the verifier, and the verifier checks that

$$\phi(a) + \phi(a) + \phi(a) + \phi(a) + \phi(a) = \phi(b)$$

Remember, "multiplication" here is not the binary operator, it's simply shorthand for repeated addition.

In these examples, note that we didn’t say anything about what elements of $B$ are or what $\blacksquare$ is. $B$ can be scary mathematical objects, and $\blacksquare$ can be a scary mathematical operator, but *that doesn’t matter*.

This is the beauty of abstract algebra: *we don’t need to know*. As long as it has the properties we care about, we can reason about its behavior even if we know nothing about the implementation.

## Motivation

Okay cool; we understand groups and homomorphisms, but how does this help us? The reason I went through all the effort explaining this is because I want you to understand the statement below:

“Elliptic curve points in a finite field under addition are a finite cyclic group and integers under addition are homomorphic to this group.”

You probably don’t know what elliptic curve points are or what adding them means, but you do know:

1. The set of elliptic curve points under addition produces another elliptic curve point.
2. The binary operator that takes two elliptic curve points and returns another elliptic curve point is associative.
3. The set of elliptic curve points contains an identity element.
4. The elliptic curve group has an identity element, which is unique.
5. Each elliptic curve point has an inverse such that adding a point and its inverse produces the identity.
6. Because the group is cyclic, every elliptic curve point can be generated by repeatedly applying the binary operator to some generator element.
7. Because the group of elliptic curve points is cyclic, it is also an abelian group.
8. Because it is a finite group, the order is finite.
9. Because of the homomorphism, we have a strong idea of how the binary operator for elliptic curve points behaves. We can use the elliptic curve point binary operator to “add integers” in a certain sense.

Even though you don’t know what elliptic curve points are, you already know nine things about them!

So whatever these bizarre objects "elliptic curve points" are, you know it behaves like, and has the same properties as the groups we discussed above.

Believe it or not, you are already 90% of the way to comprehending elliptic curves. It’s far easier to make sense of elliptic curves by understanding their similarity to other familiar structures than to try to understand their funky math from the ground up.

This is similar to me telling you that Ethereum uses “Patricia Merkle trees” to store state. You may not know what a “Patricia tree” or a “Merkle tree” is, but you do know:

- It has a root.
- You can probably access elements in logarithmic time, or at least that is the intent.
- Something useful is stored in the leaves.
- There exists some algorithm to traverse the tree and access a leaf you care about.

So when I tell you elliptic curve points under addition form a group, you should already know what to look out for when you learn about that subject.

Again, groups don’t need to be mysterious moon math. You’ve worked with groups intuitively as a programmer. Now you have a concrete word to describe this recurring phenomenon.

It’s far more efficient to say "group" than it is to say "this is a set with a way to combine elements associatively and the elements all have blah blah blah."

I know this may seem like a huge tangent, but trust me, understanding "homomorphism" enables us to succinctly describe a concept that we will regularly see. It will also come in handy again when we discuss [Quadratic Arithmetic Programs](https://www.rareskills.io/post/quadratic-arithmetic-program). Homomorphisms appear frequently in the ZK world.

Imagine trying to discuss tree data structures without a word for "roots" or "leaves." That would be immensely frustrating.

## Summary

A homomorphism from $A$ to $B$ exists **if and only if** a function $\phi$ exists that takes an element from $A$ and returns and element from $B$ and  $\phi(a_i \square a_j)=\phi(a_i)\blacksquare\phi(a_j)$ or all $a_i$ and $a_j$ in $A$, where $\square$ is the binary operator of $A$ and $\blacksquare$ is the binary operator of $B$. **The existence of $\phi$ is sufficient for the homomorphism to exist.**

Homomorphisms are not necessarily bidirectional. They are only required to work in one direction, from $A$ to $B$.

If $\phi: A \rightarrow B$ is computationally difficult to invert, then $\phi$ homomorphically encrypts the elements of $A$. That means we can validate claims about computations in $A$ using elements in $B$.

The good news is, we are done with our treatment of abstract algebra, and we now have a strong foundation to move on to [elliptic curves](https://www.rareskills.io/post/elliptic-curve-addition).