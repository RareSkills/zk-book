# Roots of Unity in Finite Fields

This article explains what Roots of Unity in a Finite Field are and how they are intertwined with multiplicative subgroups. The reader is expected to be familiar with the prior chapter about the [Fundamental Theorem of Cyclic Groups](https://rareskills.io/post/fundamental-theorem-cyclic-groups). 

That theorem states that, given a multiplicative group $\mathbb{F}_q^*$ of order $q-1$, there exists a unique subgroup of order $k$ when $k$ divides $q-1$. Otherwise, if $k$ does not divide $q-1$, no subgroup of order $k$ exists.

It also states that, if $g$ is a generator of $\mathbb{F}_q^*$, then $g^\frac{q-1}{k}$ generates the subgroup of order $k$. 

In this article, we will show that all elements of this subgroup are what are called $k$-th roots of unity, and that the generator $\omega$ is what is called a primitive $k$-th root of unity.

## Motivation and goal for this chapter

The square roots of $1$ in a finite field are easy to compute: they are the numbers congruent to $1$ and negative $1$ (which are $1$ and $q - 1$ respectively. Remember that, in a field $\mathbb{F}_q$, the number $-x$ is congruent to $q-x$ ). In other words, $\sqrt{1} = \{1, q-1 \}$. This set is the set of solutions of the equation $a^2 \equiv 1$, where $a$ is an element of the finite field.

But what if we want to compute the cube roots of $1$, or more generally, the $k$-th roots of 1, i.e., $\sqrt[^k]{1}$? By definition, $k$-th roots of unity are the elements that satisfy the equation $a^k \equiv 1$. But how can we find them?

We could try all elements one by one — a brute-force approach — but that would be infeasible when the field contains many elements. Fortunately, there is a simple way to find them all. **In the finite field $\mathbb{F}_q$, the $k$-th roots of unity are precisely the elements of the multiplicative subgroup of order $k$.** This definition assumes $k$ divides **$q-1.$**

To state it in the strongest possible terms: **If an element $a$ in a finite field is part of a multiplicative subgroup of order $k$, then it is a $k$-th root of unity, and $a^k\equiv1$. And if an element $a$ is a $k$-th root of unity (meaning $a^k\equiv1)$, then it is part of a multiplicative subgroup of order k.**

### Equivalence of terminology

It may seem like we are just adding a new terminology for the same entity (an element in a multiplicative group) and pointing out that raising it to the $k$-th power equals 1.

In a certain sense, yes, we are introducing a new term for the same entity: a $k$-th root of unity is an element in a multiplicative subgroup of order $k$ and vice-versa. Normally, giving the same entity two names leads to confusion, so we need to justify introducing the term “root of unity.”

When we speak about cyclic groups of order $k$ in the most general sense, we do not have the guarantee that taking an element in that group and applying the binary operator to that element and itself $k$ times results in the identity element, i.e., $a^k\equiv1$ , or more generally for a binary operator $\star$:

$$
\underbrace{a\star a\star\dots\star a}_k=\text{identity}
$$

For cyclic groups in general, the above property is not guaranteed to hold, but for roots of unity in a finite field, it is guaranteed.

Therefore, we can say that roots of unity have all the properties the Fundamental Theorem of Cyclic groups says they should have, *and* they have the property that $a^k\equiv1.$

So, to put the reader’s mind at ease, you already know a good bit about roots of unity in a finite group simply because you understand the Fundamental Theorem of Cyclic Groups. Since roots of unity in a finite field are a cyclic subgroup, the Fundamental Theorem of Cyclic Groups applies to them.

However, the added guarantee that $a^k\equiv1$ unlocks additional properties that efficient ZK algorithms directly leverage. These properties enable us to create efficient algorithms like the Number Theoretic Transform and other [Zero-Knowledge Proof](rareskills.io/zk-book) algorithms, such as PLONK and ZK-STARKs.

We study these additional properties of roots of unity in later chapters. This chapter focuses on definitions and examples to build the understanding that an element $a$ in a finite field has the property $a^k\equiv1$ if and only if it is part of a multiplicative subgroup of order $k.$

### Computing k-th roots of unity is the same as finding the multiplicative subgroup of order k

In the article on the Fundamental Theorem of Cyclic Groups, we learned how to find all the elements of a multiplicative subgroup of order $k$. First, we obtain a generator of this subgroup from the generator of the multiplicative group $\mathbb{F}_q^*$. Then, using this generator, we can find all the elements of the subgroup of order $k$.

**Thus, finding the $k$-th roots of unity of $\mathbb{F}_q$ is no different from finding the multiplicative subgroup of order $k$, if $k$ divides $q-1$, which we already know how to do.**  

Our aim in this chapter is to prove this equivalence - between the group of all $k$-th roots of unity and the multiplicative subgroup of order $k$, if $k$ divides $q-1$. 

To do this, we need to prove the following two statements:

1. Every element $a$ within the multiplicative subgroup of order $k$ satisfies $a^k\equiv 1$.
2. Suppose $k$ divides $q-1$. Then, every element $a$ in $\mathbb{F}_q^*$ that satisfies $a^k\equiv 1$ belongs to the unique subgroup of order $k$.

We will explore these two statements through examples to illustrate that they hold true. Since the formal proofs can be somewhat mathematically demanding, we will defer some of them to the appendix for the interested reader, though we have made the effort to make the proofs as widely understandable as possible.

## 1. Every element $a$ in the subgroup of order $k$ satisfies $a^k\equiv 1$

This first statement shows that all elements of the multiplicative subgroup of order $k$ are $k$-th roots of unity. 

However, this is NOT sufficient to establish the equivalence between the group of all $k$-th roots of unity and the multiplicative subgroup of order $k$ (when $k$ divides $q-1$) since it does not guarantee that all $k$-th roots of unity belong to this subgroup — which will be discussed in Statement 2.

We will begin this section with a proof of this statement, and then show through examples that this statement holds true.

### Proof of Statement 1

Recall from the article on the Fundamental Theorem of Cyclic Groups that a unique subgroup of order $k$ is generated by $\omega = g^{\frac{q-1}{k}}$, where $g$ is a generator of the multiplicative group $\mathbb{F}_{q}^*$. We refer to $\langle\omega\rangle$ as the elements generated by taking successive powers of $\omega$ modulo $q$:

$$
\langle\omega\rangle = \{\omega^{0},\omega^{1},\omega^{2},\dots ,\omega^{k-1}\}.
$$

Let $\omega^m$ be an arbitrary element in $\langle\omega\rangle$ for some $0\le m\le k-1$. The goal is to prove that $(\omega^m)^k\equiv 1$.

*The proof below assumes that the generator has the property $\omega^k \equiv 1$; see Appendix A for the proof of this fact.* 

Let’s compute $(\omega^m)^k$ as follows:

$$
\begin{aligned}
(\omega^m)^k 
&= (\omega^{mk}) &&\qquad\text{Power of a power rule
}\\
&= (\omega^{km}) &&\qquad\text{Commutativity of exponents}\\
&=(\omega^k)^m&&\qquad\text{Factoring the exponent}\\
&\equiv (1)^m&&\qquad\text{Based on the discussion in the appendix A: $\omega^k\equiv 1$}\\
&\equiv 1&&\qquad\text{One raised to an arbitrary power is 1}.
\end{aligned}
$$

**Therefore, every element in the subgroup of order $k$, when raised to the power $k$, equals 1.**

### Example of Statement 1 in $\mathbb{F}_7 = \{0,1,2,3,4,5,6\}$

In this example, we have $q-1 = 7-1 = 6$. Also, the element $g = 3$ is a generator of the multiplicative group $\mathbb{F}_q^* = \{1,2,3,4,5,6\}$.  

*How to find the generator of the multiplicative group will not be covered in this article, but the `galois` library provides a quick way to do it. Given the field $\mathbb{F}_q$, one way to find the generator is by using the `primitive_element` property, as shown below.*

```python
import galois
GF = galois.GF(7) # define the field
GF.primitive_element # GF(3, order=7) 
```

**Subgroup of order 3**

Since 3 divides $q-1 = 6$, the Fundamental Theorem of Cyclic Groups guarantees the existence of a unique subgroup of order 3. 

This subgroup is generated by $3^{\frac{q-1}{k}} = 3^{\frac{6}{3}} = 3^{2} = 9\equiv 2\pmod{7}$. Thus,

$$
\langle 2\rangle = \{2^0,2^1,2^2\} = \{1, 2, 4\}.
$$

Now, we want to verify that every element $a$ in $\langle 2\rangle$ satisfies $a^3\equiv 1$. This is done below:

$$
\begin{aligned}
&1^3 \equiv \boxed{1}\pmod{7}\\
&2^3 \equiv 8 \equiv \boxed{1}\pmod{7}\\
&4^3 \equiv 16 \cdot 4 \equiv 2 \cdot 4 \equiv 8 \equiv \boxed{1}\pmod{7}\\
\end{aligned}
$$

So, the elements $1, 2$ and $4$ satisfy $a^3\equiv 1\pmod{7}$. Therefore, the condition is satisfied.

**Subgroup of order 2**

Since 2 divides $q-1 = 6$, the Fundamental Theorem of Cyclic Groups guarantees the existence of a unique subgroup of order 2. 

This subgroup is generated by $3^{\frac{q-1}{k}} = 3^{\frac{6}{2}} = 3^{3} = 27\equiv 6\pmod{7}$. Thus,

$$
\langle 6\rangle = \{6^0,6^1\} = \{1, 6\}.
$$

Now, we want to verify that every element $a$ in $\langle 6\rangle$ satisfies $a^2\equiv 1$.

$$
\begin{aligned}
&1^2 \equiv \boxed{1}\pmod{7}\\
&6^2 = 36 \equiv \boxed{1}\pmod{7}
\end{aligned}
$$

So, the elements $1$ and $6$ satisfy $a^2\equiv 1\pmod{7}$. Therefore, the condition is satisfied.

**Exercise.** Verify that every element $a$ in $\mathbb{F}_7^*$ satisfies $a^6\equiv 1$. 

## 2. If $k$ divides $q-1$, then every element $a$ in $\mathbb{F}_q^*$ with $a^k\equiv 1$ belongs to the unique subgroup of order $k$

This statement asserts that ALL $k$-th roots of unity belong to the multiplicative subgroup of order $k$, provided that $k$ divides $q-1$.

In this section, we illustrate this claim through a few examples. The full proof is provided in Appendix B for the interested reader.

*Before moving on, let’s consider the case where $k$ does not divide $q-1$. In this situation, the Fundamental Theorem of Cyclic Groups tells us that there is no subgroup of order $k$, and therefore no equivalence can exist.* 

### Example in $\mathbb{F}_7 = \{0,1,2,3,4,5,6\}$

In this example, we have $q-1 = 7-1 = 6$. Also, the element $g = 3$ is a generator of the multiplicative group $\mathbb{F}_q^* = \{1,2,3,4,5,6\}$. 

**Subgroup of order $k=3$**

Since 3 divides $q-1 = 6$, there exists a unique subgroup of order 3. This subgroup is generated by $3^{\frac{q-1}{k}} = 3^{\frac{6}{3}} = 3^{2} = 9\equiv 2\pmod{7}$. Thus,

$$
\langle 2\rangle = \{2^0,2^1,2^2\} = \{1, 2, 4\}.
$$

We want to verify that every element $a$ in $\mathbb{F}_{7}^*$ satisfying $a^3\equiv 1$ belongs to this unique subgroup of order $k = 3$ in $\mathbb{F}_{7}^*$. Let's find all such elements $a$ in $\mathbb{F}_{7}^*$, as follows:

$$
\begin{aligned}
&\boxed{1^3 \equiv 1}\pmod{7}\\
&\boxed{2^3 \equiv 8 \equiv 1}\pmod{7}\\
&3^3 \equiv 9 \cdot 3 \equiv 2 \cdot 3 \equiv 6\pmod{7}\\
&\boxed{4^3 \equiv 16 \cdot 4 \equiv 2 \cdot 4 \equiv 8 \equiv 1}\pmod{7}\\
&5^3 \equiv 25 \cdot 5 \equiv 4 \cdot 5 \equiv 20 \equiv 6\pmod{7}\\
&6^3 \equiv 36 \cdot 6 \equiv 1 \cdot 6 \equiv 6\pmod{7}.
\end{aligned}
$$

The elements $1, 2$ and $4$ satisfy $a^3\equiv 1\pmod{7}$. These three elements are exactly the members of the subgroup of order $k =3$ in $\mathbb{F}_{7}^*$. Therefore, every element $a$ in $\mathbb{F}_{7}^*$ with $a^3\equiv 1$ belongs to the unique subgroup of order $k = 3$.

**Exercise.** Verify that every element $a$ in $\mathbb{F}_7^*$ satisfying $a^2\equiv 1$ belongs to the unique subgroup of order $k = 2$.

### Example in $\mathbb{F}_{17} = \{0,1,2,\dots,16\}$

In this example, we have $q-1 = 17-1 = 16$. Also, the element $g = 3$ is a generator of the multiplicative group $\mathbb{F}_q^* = \{1,2,\dots,16\}$, which can be verified using the `galois` library:

```python
GF = galois.GF(17) # define the field
GF.primitive_element # GF(3, order=17) 
```

**Subgroup of order $k=4$**

Since 4 divides $q-1 = 16$, there exists a unique subgroup of order 4. This subgroup is generated by $3^{\frac{q-1}{k}} = 3^{\frac{16}{4}} = 3^{4} = 81\equiv 13\pmod{17}$. Thus,

$$
\langle 13\rangle = \{13^0,13^1,13^2, 13^3\} = \{1, 13,  16, 4\}.
$$

We want to verify that every element $a$ in $\mathbb{F}_{17}^*$ satisfying $a^4\equiv 1$ belongs to this unique subgroup of order $k = 4$ in $\mathbb{F}_{17}^*$. Let's find all such elements $a$ in $\mathbb{F}_{17}^*$, as follows:

$$
\begin{aligned}
&\boxed{1^4 = 1}\\
&2^4 = 16\not\equiv 1\\
&3^4 = 81 \equiv 13\not\equiv 1\\
&\boxed{4^4 \equiv 16 \cdot 16 \equiv (-1) \cdot (-1) \equiv 1}\\
&5^4 \equiv 25 \cdot 25 \equiv 7 \cdot 7 \equiv 49 \equiv 15\not\equiv 1\\
&6^4 \equiv 36 \cdot 36 \equiv 2 \cdot 2 \equiv 4\not\equiv 1\\
&7^4 \equiv 49 \cdot 49 \equiv 15 \cdot 15 \equiv (-2) \cdot (-2)\equiv 4\not\equiv 1\\
&8^4 \equiv (2^3)^4 = (2^4)^3 \equiv (-1)^3 \equiv -1\equiv 16\not\equiv 1\qquad\qquad\pmod{17}\\
&9^4 = 81 \cdot 81 \equiv 13 \cdot 13 \equiv (-4) \cdot (-4) \equiv 16\not\equiv 1\\
&10^4 \equiv 100 \cdot 100 \equiv 15 \cdot 15 \equiv (-2) \cdot (-2) \equiv 4\not\equiv 1\\
&11^4 \equiv 121 \cdot 121 \equiv 2 \cdot 2 \equiv 4\not\equiv 1\\
&12^4 \equiv 144 \cdot 144 \equiv 8 \cdot 8 \equiv 13\not\equiv 1\\
&\boxed{13^4 \equiv 169 \cdot 169 \equiv 16 \cdot 16 \equiv (-1) \cdot (-1)\equiv 1}\\
&14^4 \equiv (-3)^4 \equiv 9 \cdot 9\equiv 13\not\equiv 1\\
&15^4\equiv (-2)^4\equiv 16\not\equiv 1\\
&\boxed{16^4 \equiv (-1)^4 \equiv 1}.
\end{aligned}
$$

The elements $1, 4, 13$ and $16$ satisfy $a^4\equiv 1\pmod{17}$. These four elements are exactly the members of the subgroup of order $k =4$ in $\mathbb{F}_{17}^*$. Therefore, every element $a$ in $\mathbb{F}_{17}^*$ with $a^4\equiv 1$ belongs to the unique subgroup of order $k = 4$.

**Exercise.** Verify that every element $a$ in $\mathbb{F}_{17}^*$ satisfying $a^8\equiv 1$ belongs to the unique subgroup of order $k = 8$.

## Primitive $k$-th root of unity

A primitive $k$-th root of unity is a special $k$-th root of unity: **it is a $k$-th root of unity that generates all other $k$-th roots of unity.**

**Since the group of $k$-th roots of unity we are interested in is the same as the subgroup of order $k$, the primitive $k$-th roots of unity are exactly the generators of this subgroup.**

*Note: In the case where $k$ does not divide $q-1$ (considering finite fields $\mathbb{F}_q$), there may still be $k$-th roots of unity, but in this case there are NO primitive $k$-th roots of unity.*

Thus, finding a primitive $k$-th root of unity is straightforward: it is the same as finding a generator of the subgroup of order $k$, and the Fundamental Theorem of Cyclic Groups tells us how to do this.

*A formal definition of a primitive $k$-th root of unity is that it is a $k$-th root of unity with order $k$, where the order of an element $a$ is the smallest positive integer greater than zero $r$ such that $a^r \equiv 1$.*

For example, $4$ is a 6th root of unity in $\mathbb{F}_7$ because $4^6\equiv 1\pmod{7}$, but it is not a primitive 6th root because there is a power lower than 6 that makes it $1$, specifically 3, i.e. $4^3 \equiv 1\pmod{7}$.

### The number of primitive $k$-th roots of unity

Just as a subgroup of order $k$ can have more than one generator, there can be more than one primitive $k$-th root of unity. The number of primitive $k$-th roots of unity is the same as the number of generators of the subgroup of order $k$.

The number of primitive $k$-th roots of unity (and generators) is given by Euler's totient function $\phi(k)$. The proof of this fact is beyond the scope of this article. For the application we are considering—the Number Theoretic Transform—we only need a primitive $k$-th root of unity, which can be found using the Fundamental Theorem, assuming we know a generator for $\mathbb{F}_q^*$.

In the rest of this chapter, we will present examples showing how to use the Fundamental Theorem to find a primitive $k$-th root of unity, and then all $k$-th roots of unity for a given $k$.

### Example of 4th roots of unity in $\mathbb{F}_{17}^*$

A generator of the multiplicative group $\mathbb{F}_{17}^*$ is the element $3$, which can be found using the `galois` library. 

A generator for the subgroup of order 4 is then $\omega = 3^{\frac{16}{4}} = 3^4 \equiv 13$.

Based on our discussion, this generator is a primitive 4th root of unity. Let us check that using the definition of a primitive $k$-th root of unity. We need to show that:

1. Element $13$ is a 4th root of unity. This can be seen by checking that $13^4 \equiv 1 \pmod{17}$.
2. The order of element $13$ is 4. This means that 4 is the smallest positive integer $r$ such that $13^r \equiv 1 \pmod{17}$. Let us check that below:

$$
\begin{aligned}
&13^1 = 13,\\
&13^2 \equiv 16,&&\pmod{17}\\
&13^3 \equiv 13 \cdot 16 \equiv 4,\\
&\boxed{13^4 \equiv 16 \cdot 16\equiv -1 \cdot -1 \equiv 1}.
\end{aligned}
$$

Therefore, element $13$ is a primitive 4th root of unity, and we can use element $13$ to generate the subgroup of all 4th roots of unity, as follows:

$$
\begin{aligned}
\langle\omega\rangle &= \{ \omega^0, \omega^1, \omega^2, \omega^3, \omega^4\}\\
&= \{13^0, 13^1, 13^2, 13^3\}\\
&=\{1, 13, 16, 4\}.
\end{aligned}
$$

### Example of 8th roots of unity in $\mathbb{F}_{17}^*$

Since $g =3$ is a generator of the multiplicative group $\mathbb{F}_{17}^*$, a generator for the subgroup of order $8$ is $\omega = 3^{\frac{16}{8}} = 3^2 \equiv 9$. 

Let us check that it is also a primitive 8th root of unity. We need to check that:

1. Element $9$ is a 8th root of unity. This can be seen by checking that $9^8 \equiv 1 \pmod{17}$.
2. The order of element $9$ is 8. This means that 8 is the smallest positive integer $r$ such that $9^r \equiv 1 \pmod{17}$. Let us check that below:

$$
\begin{aligned}
&9^1 = 9,\\
&9^2 \equiv 13,\\
&9^3 \equiv 9 \cdot 13 \equiv 15,\\
&9^4 \equiv 13 \cdot 13 \equiv (-4) \cdot (-4)\equiv 16,\qquad\pmod{17}\\
&9^5 \equiv 9 \cdot 16 \equiv 8,\\
&9^6 \equiv 9 \cdot 8 \equiv 4,\\
&9^7 \equiv 9 \cdot 4 \equiv 2,\\
&\boxed{9^8 \equiv 9 \cdot 2 = 18\equiv 1}.
\end{aligned}
$$

Therefore, element $9$ is a primitive 8th root of unity, and we can use element $9$ to generate the subgroup of all 8th roots of unity, as follows:

$$
\begin{aligned}
\langle\omega\rangle &= \{ \omega^0, \omega^1, \omega^2, \omega^3, \omega^4, \omega^5, \omega^6, \omega^7\}\\
&= \{9^0, 9^1, 9^2, 9^3, 9^4, 9^5, 9^6, 9^7\}\\
&=\{1, 9, 13, 15, 16, 8, 4, 2\}.
\end{aligned}
$$

**Exercise.** Find a primitive 2nd root of unity in $\mathbb{F}_{17}^*$ and the subgroup of all 2nd roots of unity.

## Conclusion and summary

An efficient method is needed to find all $k$-th roots of unity, which is what we studied in this article. In summary, we established that:

- An element $a$ of a finite field $\mathbb{F}_q$ is a $k$-th root of unity if $a^k \equiv 1$.
- If $k$ divides $q-1$, then the subgroup of $\mathbb{F}_q^*$ containing all $k$-th roots of unity is the unique subgroup of order $k$ guaranteed by the Fundamental Theorem of Cyclic Groups.
- A primitive $k$-th root of unity generates the subgroup of all $k$-th roots of unity. If $g$ is a generator of the multiplicative group $\mathbb{F}_q^*$ and $k$ divides $q-1$, then the element $\omega = g^{\frac{q-1}{k}}$ is a primitive $k$-th root of unity.

## Appendix A

### The generator $\omega$ of the subgroup of order $k$ satisfies**: $\omega^k \equiv 1$**

Let $g$ be a generator of the multiplicative group $\mathbb{F}_q^*$. Recall from the Fundamental Theorem of Cyclic Groups that the element $\omega = g^{\frac{q-1}{k}}$ generates the unique subgroup of order $k$. We aim to prove that $\omega^k \equiv 1$.

**Proof.** [Fermat’s Little Theorem](https://en.wikipedia.org/wiki/Fermat%27s_little_theorem#:~:text=In%20number%20theory%2C%20Fermat's%20little,an%20integer%20multiple%20of%207) states that if $q$ is a prime number, then for any integer $g$:

$$
g^{q}\equiv g\pmod{q}.
$$

For example, if $g = 2$ and $q=7$, then $2^7\equiv 2\pmod{7}$.

If $g$ is not divisible by $q$, we can divide both sides of the equation above by $g$. This shows that Fermat’s Little Theorem is equivalent to the statement:

$$
g^{q-1}\equiv 1\pmod{q}.
$$

We now compute $\omega^k$ as follows:

$$
\begin{aligned}
\omega^k &= (g^{\frac{q-1}{k}})^k &&\qquad\text{By definition of $\omega$}\\
&= g^{q-1} &&\qquad\text{Simplifying the exponent}\\
&\equiv 1\pmod{q}&&\qquad\text{Applying Fermat's Little Theorem}
\end{aligned}
$$

## Appendix B

### If $a\in\mathbb{F}_q^*$ and $a^k\equiv1$ then $a$ is a member of a unique cyclic subgroup of order $k$.

Let $g$ be a generator of $\mathbb{F}_q^*$. This equivalently means that $g$ is a $(q-1)$-th root of unity.

Let $\omega=g^\frac{q-1}{k}$ be a generator for the multiplicative subgroup of order $k$ ($\omega=g^\frac{q-1}{k}$ is directly from the Fundamental Theorem of Cyclic Groups). 

If $a\in\mathbb{F}_q^*$ and $a^k\equiv1$ then we must prove that there exists an integer $s$ such that $\omega^s=a$. The existence of integer $s$ in $\omega^s\equiv a$ proves that $a$ can be generated by $\omega$ and thus is part of the unique subgroup of order $k$.

To find such an $s$, we will substitute $\omega$ with $g^\frac{q-1}{k}$and $a$ with $g^m$ to convert $\omega^s=a$ into:

$$
{\left(g^\frac{q-1}{k}\right)}^s\stackrel{?}{=}g^m
$$

Can we come up with an $s$ that makes the equation true? If we strategically pick an $s$ such that the exponent $\frac{q-1}{k}$ will cancel and leave $m$ we have:

$$
s=\frac{mk}{q-1}
$$

Plugging $s=\frac{mk}{q-1}$ into the left-hand side of this equation ${\left(g^\frac{q-1}{k}\right)}^s\stackrel{?}{=}g^m$, we obtain

$$
{\left(g^\frac{q-1}{k}\right)}^{(\frac{mk}{q-1})}
$$

We can see that the $q-1$ and $k$ terms cancel, leaving us with $g^m$.

$$
g^{\frac{\cancel{q-1}}{\cancel{k}}\frac{m\cancel{k}}{\cancel{q-1}}}\implies g^m
$$

We can substitute back the original definitions for $g^\frac{q-1}{k}=\omega$, $\frac{mk}{q-1}=s$, and $g^m=a$ and see that

$$
\omega^s=a
$$

Therefore, if $a^k\equiv1$, then there does in fact exist an $s$ such that $\omega^s=a$. $s$ is simply

$$
s=\frac{mk}{q-1}
$$

where $m$ is the solution to $g^m=a$, $k$ is the order of the subgroup, and $q$ is the modulus of our finite field.

However, we must still prove that $s$ is an integer because generating a value by raising $\omega$ to a fraction doesn’t qualify as being a member of the subgroup generated by $\omega$.

### Showing $s$ is an integer

To show that $\frac{mk}{q-1}$ is an integer, we need to show that dividing $mk$ by $q-1$ has no remainder.

When we carry out the division, we should get a quotient $n$ and a remainder $r$. We want to show that $r$ is necessarily 0.

$$
\frac{mk}{q-1}=n+r
$$

A remainder cannot be larger than the divisor (e.g., $\frac{11}{5}$ cannot have a remainder 5 or larger), so we also have the condition that:

$$
0\leq r\lt q-1
$$

We can isolate $mk$ in $\frac{mk}{(q-1)}=n+r$ by translating it from the form `dividend / divisor = quotient + remainder` to `dividend = quotient⋅divisor + remainder`. (To illustrate this re-write, consider that 6/4=1 remainder 2 can be written as 6 = 4⋅1 + 2). In re-written form, we have:

$$
mk = n\cdot(q-1) + r\qquad\text{where $0\le r < q-1$}
$$

In order to show that $r=0$, we will set aside $mk=n\cdot(q-1)+r$ for a moment, and derive another property of $mk$.

**Fact:** $g^{mk}\equiv1$

$g^{mk}\equiv1$ can be derived from the following facts:

- $a^k\equiv1$
- $a=g^m$

So by substitution, $(g^m)^k\equiv1$ and by the power of a power rule, $g^{mk}\equiv1$.

**Substitute $mk = n\cdot(q-1) + r$ into $g^{mk}\equiv1$**

We now have enough tools to show that the remainder $r$ in $mk = n\cdot(q-1) + r$ is zero. We remind the reader that $g^{q-1}\equiv1$ since $g$ is a primitive $(q-1)$-th root of unity.

We now show that using the definitions

- $g^{mk}\equiv1$
- $mk = n\cdot(q-1) + r$
- $g^{q-1}\equiv1$

are sufficient to show that $g^{mk}\equiv g^r$:

$$
\begin{aligned}
g^{mk} &= g^{n\cdot (q-1) + r}&&\qquad\text{Substitution}\\
&= g^{n\cdot(q-1)}\cdot g^r&&\qquad\text{Power multiplication rule}\\
&= (g^{q-1})^n\cdot g^r&&\qquad\text{Power of a power rule}\\
&\equiv 1\cdot g^r&&\qquad\text{Because $g^{q-1}\equiv 1$}\\
&= g^r
\end{aligned}
$$

As a consequence of $g^{mk}\equiv g^r$ and $g^{mk}\equiv 1$, we have that

$$
g^r\equiv1
$$

Since $g$ is a primitive $(q-1)$-th root of unity, there are only two solutions for $r$:

- $r=0$
- $r\equiv q-1$

Recall that $r$ is defined as the solution to

$$
\frac{mk}{q-1}=n+r\qquad\text{where $0\le r < q-1$}
$$

We know that any valid division $\frac{mk}{q-1}$ cannot result in a remainder $r$ of $q-1$ or higher, specifically, the remainder must be in the range $0\le r \lt q-1$. That range restriction on the remainder implies $r\neq q-1$.

So ruling out the possibility that $r=q-1$, the only solution for $g^r\equiv1$ is $r=0$ (i.e. $g^0\equiv1$).

Since $r=0$, the result of dividing $mk$ by $q-1$ is an integer.

Finally, since $s$ is defined as

$$
s=\frac{mk}{q-1}
$$

$s$ is an integer.
