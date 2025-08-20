# Multiplicative Subgroups and Primitive Elements

## Introduction

This chapter continues our study of group theory by exploring **subgroups** and **generators**. The concept of a **primitive element** will be introduced at the end. We assume you are already familiar with the definition of a group. If you need a refresher, check out [this article](https://www.rareskills.io/post/group-theory).

To build intuition, we begin with **additive groups**, which are straightforward and help clarify core concepts like subgroups and generators.

We then shift to **multiplicative groups of integers modulo $n$**. The integers themselves, under multiplication, do not form a group—only $1$ and $-1$ have multiplicative inverses in $\mathbb{Z}$, so the group axioms fail. To address this, we consider multiplication modulo $n$, focusing on the integers less than $n$ that are **coprime** to it. These coprime integers **do** have multiplicative inverses modulo $n$, and together they form a well-defined group. This construction plays a central role in number theory and is foundational to many cryptographic systems.

> **Coprime:** Two numbers are coprime if their Greatest Common Divisor (GCD) is 1.  
>
> **Example 1:** 8 and 15 are coprime because  
> Factors of 8: 1, 2, 4, 8  
> Factors of 15: 1, 3, 5, 15  
> Common factor: 1  
> The gcd is 1.  
>
> **Example 2:** 12 and 18 are NOT coprime because  
> Factors of 12: 1, 2, 3, 4, 6, 12  
> Factors of 18: 1, 2, 3, 6, 9, 18  
> Common factor: 1, 2, 3, 6  
> The gcd is 6.  

Finally, we examine **generators**—elements that can produce an entire group or subgroup through repeated multiplication. Understanding generators reveals important subgroup structures, especially when $n$ is prime, and highlights their critical role in cryptographic applications.

## 1. Additive Groups

Additive groups use addition (often modulo some number) as the operation, with the identity element being $0$ and the inverse of an element $a$ being $-a$, making their structure relatively straightforward. Let's dive into examples to see how they work.

### 1.1 Example: $(\mathbb{Z}_6, +)$

To warm up, consider $\mathbb{Z}_6 = \{0, 1, 2, 3, 4, 5\}$ under addition. Start with *closure*: 
$$3 + 4 = 7, \text{ or } 5 + 5 = 10$$
takes us outside the set. To fix this, we use **addition modulo 6**: 
$$3 + 4 = 7 \equiv 1 \pmod{6} \text{ and } 5 + 5 = 10 \equiv 4 \pmod{6}.$$
Now every result stays in $\{0, 1, 2, 3, 4, 5\}$. Here is the addition table:

| $+ \mod 6$ | $0$ | $1$ | $2$ | $3$ | $4$ | $5$ |
|------------|-----|-----|-----|-----|-----|-----|
| $0$        | $0$ | $1$ | $2$ | $3$ | $4$ | $5$ |
| $1$        | $1$ | $2$ | $3$ | $4$ | $5$ | $6 \equiv 0$ |
| $2$        | $2$ | $3$ | $4$ | $5$ | $6 \equiv 0$ | $7 \equiv 1$ |
| $3$        | $3$ | $4$ | $5$ | $6 \equiv 0$ | $7 \equiv 1$ | $8 \equiv 2$ |
| $4$        | $4$ | $5$ | $6 \equiv 0$ | $7 \equiv 1$ | $8 \equiv 2$ | $9 \equiv 3$ |
| $5$        | $5$ | $6 \equiv 0$ | $7 \equiv 1$ | $8 \equiv 2$ | $9 \equiv 3$ | $10 \equiv 4$ |

Every result is in $\{0, 1, 2, 3, 4, 5\}$, so closure holds. Check the other properties:
- **Associativity:** Grouping does not change the result:
    - $(2 + 3) + 4 = 5 + 4 = 9 \equiv 3 \pmod{6}$,
    - $2 + (3 + 4) = 2 + (7 \equiv 1) = 3$.
- **Identity**: $0$ works as identity element, since $3 + 0 = 3$ (see the table's first row or column).
- **Inverses**: Each element has a pair summing to $0 \pmod{6}$:

| Element | Inverse | Check |
|---------|---------|-------|
| $0$     | $0$     | $0 + 0 = 0$ |
| $1$     | $5$     | $1 + 5 = 6 \equiv 0$ |
| $2$     | $4$     | $2 + 4 = 6 \equiv 0$ |
| $3$     | $3$     | $3 + 3 = 6 \equiv 0$ |
| $4$     | $2$     | $4 + 2 = 6 \equiv 0$ |
| $5$     | $1$     | $5 + 1 = 6 \equiv 0$ |

Thus, $(\mathbb{Z}_6, +)$ is a group with **order** (the number of elements in a set) $|\mathbb{Z}_6| = 6$. 

**Exercise 1.1**: Check whether $(\mathbb{Z}_{9}, +)$ is a group.  

*Hint:* Try building the addition table like we did for $\mathbb{Z}_6$.  

Doing this by hand can be a bit tedious, so here's a Python script that will generate the full addition table for any $\mathbb{Z}_n$:


```python

def print_addition_table(mod):
    header = ["+ mod " + str(mod)] + list(range(mod))
    print(" | ".join(str(h).rjust(4) for h in header))
    print("-" * (6 * (mod + 1)))
    for row in range(mod):
        line = [str(row).rjust(4)]
        for col in range(mod):
            value = row + col
            result = value % mod
            if value >= mod:
                line.append(f"{value} ≡ {result}".rjust(6))
            else:
                line.append(str(result).rjust(6))
        print(" | ".join(line))


# Try it with Z_9
print_addition_table(9)

```
**Follow-up:** After analyzing $\mathbb{Z}_9$, try generating the table for $\mathbb{Z}_{10}$. Can you determine whether $(\mathbb{Z}_{10}, +)$ is also a group?


Thus, $(\mathbb{Z}_n, +)$ is a group with order $n$. Finite groups like this are key in modular arithmetic and cryptography. Next, we turn our attention to how certain elements and subsets within a group can reveal deeper structure—through subgroups and generators.

## 2. Subgroups and Generators

### 2.1 Understanding Subgroups

When studying groups, we often encounter subsets that retain the group's structure under the same operation. These special subsets, called **subgroups**, behave like miniature versions of the parent group. Not every subset qualifies, though—let's explore this with examples to see what makes a subgroup.

#### Example 2.1.1: Subgroups in $(\mathbb{Z}, +)$

Consider $(\mathbb{Z}, +)$, the group of all integers under addition, and two familiar subsets:

* The set of **even integers**: $\{\ldots, -4, -2, 0, 2, 4, \ldots\}$
* The set of **odd integers**: $\{\ldots, -3, -1, 1, 3, 5, \ldots\}$

Let's check the even integers:

* **Closure**: The sum of two even numbers is even (e.g., $-2 +4= 2$).
* **Identity**: $0$ is even and included.
* **Inverses**: The inverse of any even number is also even (e.g., the inverse of $2$ is $-2$).
* **Associativity**: Inherited from $\mathbb{Z}$.

The even integers satisfy all group properties—this is a valid subgroup.

Now check the odd integers:

* **Closure**: $1 + 3= 4$, which is even—not part of the set. So closure fails.
* **Identity**: $0$ is not odd, so the identity element is missing.
* **Inverses**: For $1$, $-1$ is odd—but since closure and identity already fail, it is not a subgroup.

The odd integers under addition do not satisfy the subgroup criteria—they're just a subset, not a subgroup.

#### Example 2.1.2: Subgroups in $(\mathbb{Z}_8, +)$

Now take $(\mathbb{Z}_8, +) = \{0, 1, 2, 3, 4, 5, 6, 7\}$ and test two subsets:

* **Evens modulo 8**: $\{0, 2, 4, 6\}$
* **First half**: $\{0, 1, 2, 3\}$

For $\{0, 2, 4, 6\}$:

* **Closure**: $2 +4= 6$, $4 +6= 10 \equiv2\pmod{8}$ (both in set).
* **Identity**: $0$ is present.
* **Inverses**: $2 +6= 8 \equiv 0$, $4 +4= 8 \equiv 0$, $0 + 0 = 0$ (all pairs work).
* **Associativity**: Holds from $\mathbb{Z}_8$.

This is a subgroup!

For $\{0, 1, 2, 3\}$ :
* **Closure**: $2+3= 5$ (not in set).
* **Identity**: $0$ is present.
* **Inverses**: For $1$, no element in ${0, 1, 2, 3}$ gives $0$ (e.g., $1 +3=4\pmod{8}$).

This fails to be a group, so it is only a subset, not a subgroup.

**Definition**: A subset $H$ of a group $G$ is a **subgroup** if it is a group under the same operation, meaning it satisfies closure, contains the identity, has inverses for all its elements, and inherits associativity from $G$.

**Exercise 2.1.1:** Find all subgroups of $(\mathbb{Z}_{5}, +)$.


### 2.2 Generators in Additive Groups

Now that we have seen subgroups, let's explore how single elements can generate them—or even the whole group. We'll revisit $(\mathbb{Z}_6, +) = \{0, 1, 2, 3, 4, 5\}$, the additive group under modulo $6$ addition, and examine what happens when we repeatedly add an element to itself, like *"walking*" around the numbers modulo $6$.

#### Example 2.2.1: Generators in $(\mathbb{Z}_6, +)$

*Try 1:*

* $1$
* $1 + 1 = 2$
* $2 + 1 = 3$
* $3 + 1 = 4$
* $4 + 1 = 5$
* $5 + 1 = 6 \equiv 0 \pmod{6}$

This gives $\{0, 1, 2, 3, 4, 5\} = \mathbb{Z}_6$. Repeatedly adding $1$ cycles through the **entire group**.

*Try 2:*

* $2$
* $2 + 2 = 4$
* $4 + 2 = 6 \equiv 0 \pmod{6}$
* $0 + 2 = 2$

This gives $\{0, 2, 4\}$—only **half the group**.

*Try 3:*

* $3$
* $3 + 3 = 6 \equiv 0 \pmod{6}$
* $0 + 3 = 3$

This gives $\{0, 3\}$, even smaller!

*Try 5:*

* $5$
* $5 + 5 = 10 \equiv 4 \pmod{6}$
* $4 + 5 = 9 \equiv 3 \pmod{6}$
* $3 + 5 = 8 \equiv 2 \pmod{6}$
* $2 + 5 = 7 \equiv 1 \pmod{6}$
* $1 + 5 = 6 \equiv 0 \pmod{6}$

This gives $\{0, 1, 2, 3, 4, 5\} = \mathbb{Z}_6$, covering everything, just like $1$.

**Exercise 2.2.1**: In $(\mathbb{Z}_9, +)$, which elements generate the entire $\mathbb{Z}_9$? Which elements generate proper subgroups?
#### 2.2.2 Subgroups Generated by Elements

Now consider any group $G$ with a binary operation (like addition or multiplication), and let $g$ be an element of $G$. By repeatedly applying the group operation to $g$, we can form the set of elements it generates. This set is denoted $\langle g \rangle$ and is called the **cyclic subgroup generated by $g$**.


For example in additive groups:

$$\langle g \rangle = \{ g, g + g, g + g + g, \ldots \} = \{ n \cdot g \mid n \in \mathbb{Z} \}$$

For many elements, $\langle g \rangle$ is a **proper subgroup**. But when $\langle g \rangle = G$, we say that $g$ is a **generator** of $G$, and that $G$ is a **cyclic group**.
As shown in Example 2.2.1, we computed the subgroups generated by elements in $(\mathbb{Z}_6, +) = \{0, 1, 2, 3, 4, 5\}$ under addition modulo 6. The subgroups generated by each element are as follows:
- $\langle 0 \rangle = \{0\}$ (proper subgroup)
- $\langle 1 \rangle = \{0, 1, 2, 3, 4, 5\} = \mathbb{Z}_6$
- $\langle 2 \rangle = \{0, 2, 4\}$ (proper subgroup)
- $\langle 3 \rangle = \{0, 3\}$ (proper subgroup)
- $\langle 4 \rangle = \{0, 4, 2\}$ (proper subgroup)
- $\langle 5 \rangle = \{0, 1, 2, 3, 4, 5\} = \mathbb{Z}_6$

Elements $1$ and $5$ generate the entire group $\mathbb{Z}_6$, making them generators, while $0$, $2$, $3$, and $4$ generate proper subgroups.

#### Example 2.2.3: Generators in $(\mathbb{Z}_5, +)$

Now test $\mathbb{Z}_5 = \{0, 1, 2, 3, 4\}$ under addition modulo 5:

* $\langle1\rangle = \{0, 1, 2, 3, 4\}=\mathbb{Z}_5$
* $\langle2\rangle =\{2, 4, 6 \equiv 1 \pmod 5 , 8 \equiv 3 \pmod 5\} =\{1,2,3,4\}=\mathbb{Z}_5$
* $\langle3\rangle= \{3, 6 \equiv 1 \pmod 5, 9 \equiv 4\pmod 5 , 7 \equiv 2\pmod 5 \}=\{1,2,3,4\}=\mathbb{Z}_5$
* $\langle4\rangle =\{4, 8 \equiv 3 \pmod 5, 12 \equiv 2\pmod 5 , 16 \equiv 1\pmod 5 \}=\{1,2,3,4\}=\mathbb{Z}_5$

Every non-zero element is a generator.

This happens because $\gcd(g, 5) = 1$ for all $g \neq 0$, and $5$ is prime.

**Conclusion**: In $(\mathbb{Z}_n, +)$, an element $g$ generates the entire group if and only if $\gcd(g, n) = 1$. For prime $n$, all non-zero elements are generators. For composite $n$, only some elements qualify.

### 2.3 Code: Exploring Additive Generators in $(\mathbb{Z}_n, +)$

```python
def additive_closure(a, n):
    """Generates {0, a, 2a, 3a, ...} mod n until it repeats."""
    result = []
    current = 0
    while current not in result:
        result.append(current)
        current = (current + a) % n
    return sorted(result)  # Sorted for readability

# Show generated sets in (Z_6 , +)
print("Z_6:")
for a in range(6):
    print(f"Generated by {a}: {additive_closure(a, 6)}")

# Show generated sets in (Z_5, +)
print("\nZ_5:")
for a in range(5):
    print(f"Generated by {a}: {additive_closure(a, 5)}")
```

**Output:**

```
(Z_6, +):
Generated by 0: [0]
Generated by 1: [0, 1, 2, 3, 4, 5]
Generated by 2: [0, 2, 4]
Generated by 3: [0, 3]
Generated by 4: [0, 2, 4]
Generated by 5: [0, 1, 2, 3, 4, 5]

(Z_5, +):
Generated by 0: [0]
Generated by 1: [0, 1, 2, 3, 4]
Generated by 2: [0, 1, 2, 3, 4]
Generated by 3: [0, 1, 2, 3, 4]
Generated by 4: [0, 1, 2, 3, 4]
```


Having explored additive groups, we now turn to their multiplicative counterparts.


## 3. Multiplicative Groups

Multiplicative groups operate under multiplication (often modulo some number), with the identity element being $1$, though finding inverses can be more nuanced, especially in finite settings. To illustrate this, we'll examine a concrete example using multiplication modulo $7$.
### 3.1 Example:
Consider $\mathbb{Z}_7 = \{0, 1, 2, 3, 4, 5, 6\}$:


| $\times\mod 7$ | $0$ | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ |
|------------|---|---|---|---|---|---|---|
| $0$      | $0$ | $0$ | $0$ | $0$ | $0$ | $0$ | $0$ |
| $1$      | $0$ | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ |
| $2$      | $0$ | $2$ | $4$ | $6$ | $8 \equiv 1$ | $10 \equiv 3$ | $12 \equiv 5$ |
| $3$      |$0$|$3$|$6$| $9 \equiv2$| $12 \equiv5$| $15 \equiv1$| $18 \equiv4$|
| $4$      |$0$|$4$| $8 \equiv1$| $12 \equiv5$| $16 \equiv2$| $20 \equiv6$| $24 \equiv3$|
| $5$      |$0$|$5$| $10 \equiv3$| $15 \equiv1$| $20 \equiv6$| $25 \equiv4$| $30 \equiv2$|
| $6$      |$0$|$6$| $12 \equiv5$| $18 \equiv4$| $24 \equiv3$|  $30 \equiv2$| $36 \equiv1$|

- **Closure** holds, e.g., $2 \times5= 10  \equiv 3$, is in the set.
- **Identity**: The identity element is $1$, but this fails for $0$, which has no inverse;
- **Inverses**: Each nonzero element has an inverse:
  - $1 \times1= 1$
  - $2 \times4= 8 \equiv1\pmod{7}$
  - $3 \times5= 15 \equiv1\pmod{7}$
  - $4 \times2= 8 \equiv1\pmod{7}$
  - $5 \times3= 15 \equiv1\pmod{7}$
  - $6 \times6= 36 \equiv1\pmod{7}$


Since $0$ has no inverse, $(\mathbb{Z}_7, \times)$ is **not** a group. But if we remove $0$ and consider only the nonzero elements — that is, $\mathbb{Z}_7 \setminus \{0\} = \{1, 2, 3, 4, 5, 6\}$ — we do get a group under multiplication. This set is often denoted $\mathbb{Z}_7^*$ and is a group of order 6.


You can use this code to generate the multiplication table for any modulus $n$:
```python
def print_multiplication_table(mod):
    header = ["× mod " + str(mod)] + list(range(mod))
    print(" | ".join(str(h).rjust(4) for h in header))
    print("-" * (6 * (mod + 1)))

    for row in range(mod):
        line = [str(row).rjust(4)]
        for col in range(mod):
            value = row * col
            result = value % mod
            if value >= mod:
                line.append(f"{value} ≡ {result}".rjust(6))
            else:
                line.append(str(result).rjust(6))
        print(" | ".join(line))

print_multiplication_table(5)
```

### 3.2 Example: $(\mathbb{Z}_6\setminus \{0\}, \times),$ Is Not a Group
Let's now test the set $\{1, 2, 3, 4, 5\}$ under multiplication mod 6.

| $\times \mod 6$ |$1$|$2$|$3$|$4$|$5$|
|------------|---|---|---|---|---|
| **1**      | $1$ | $2$ | $3$ | $4$ | $5$ |
| **2**      | $2$ | $4$ | $6 \equiv  0$ | $8 \equiv  2$ | $10\equiv 4$ |
| **3**      | $3$ | $6\equiv 0$ | $9 \equiv  3$ | $12 \equiv 0$  | $15 \equiv  3$ |
| **4**      | $4$ | $8\equiv 2$| $12 \equiv  0$ | $16 \equiv  4$ | $20 \equiv  2$ |
| **5**      | $5$ | $10\equiv 4$  | $15 \equiv 3$ | $20 \equiv  2$ | $25 \equiv1$  |

- **Closure**: Holds.
- **Identity**:$1$ still works.
- **Inverses**:  Inverses fail. Only $1$ and $5$ are invertible:
  - $1 \times1= 1$
  - $5 \times5= 25 \equiv1\mod 6$


Elements $2$, $3$, and $4$ have no counterparts that yield $1$. This failure arises because $6$ is not prime: it factors as $6 =2\times 3$. The factorization introduces zero divisors—nonzero elements that, when multiplied by other nonzero elements, yield zero modulo $n$. For example, $4 \times3= 12 \equiv 0 \pmod{6}$, even though both $3$ and $4$ are nonzero in $\mathbb{Z}_6$. Since $2$, $3$, and $4$ share common factors with $6$ (namely $2$, $3$, and $2$, respectively), they fail to have multiplicative inverses.

### 3.3 Example: $(\mathbb{Z}_8\setminus\{0\}, \times)$

As another example, let's now consider multiplication in $\mathbb{Z}_8\setminus\{0\} = \{1, 2, 3, 4, 5, 6, 7\}$:
| $\times$ | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ | $7$ |
|----------|-----|-----|-----|-----|-----|-----|-----|
| **$1$**  | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ | $7$ |
| **$2$**  | $2$ | $4$ | $6$ | $8 \equiv 0$ | $10 \equiv 2$ | $12 \equiv 4$ | $14 \equiv 6$ |
| **$3$**  | $3$ | $6$ | $9 \equiv 1$ | $12 \equiv 4$ | $15 \equiv 7$ | $18 \equiv 2$ | $21 \equiv 5$ |
| **$4$**  | $4$ | $8 \equiv 0$ | $12 \equiv 4$ | $16 \equiv 0$ | $20 \equiv 4$ | $24 \equiv 0$ | $28 \equiv 4$ |
| **$5$**  | $5$ | $10 \equiv 2$ | $15 \equiv 7$ | $20 \equiv 4$ | $25 \equiv 1$ | $30 \equiv 6$ | $35 \equiv 3$ |
| **$6$**  | $6$ | $12 \equiv 4$ | $18 \equiv 2$ | $24 \equiv 0$ | $30 \equiv 6$ | $36 \equiv 4$ | $42 \equiv 2$ |
| **$7$**  | $7$ | $14 \equiv 6$ | $21 \equiv 5$ | $28 \equiv 4$ | $35 \equiv 3$ | $42 \equiv 2$ | $49 \equiv 1$ |


Only the elements $\{1, 3, 5, 7\}$—those that are coprime with 8—have multiplicative inverses modulo 8:
- $1 \times1= 1 \pmod 8$
- $3 \times3= 9 \equiv 1 \pmod 8$
- $5 \times5= 25 \equiv 1 \pmod 8$
- $7 \times7= 49 \equiv 1 \pmod 8$

The remaining elements, $\{2, 4, 6\}$, all share a common factor with 8 and therefore do not have inverses. Thus, $\mathbb{Z}_8 \setminus \{0\}$ is **not** a group under multiplication.

### 3.4. What Is $\mathbb{Z}_n^*$?

The set **$\mathbb{Z}_n^*$** is formally defined as:

$$
\mathbb{Z}_n^* = \{ a \in \mathbb{Z}_n \mid \gcd(a, n) =1\}
$$

That is, $\mathbb{Z}_n^*$ consists of all elements in $\mathbb{Z}_n$ that have a **multiplicative inverse modulo $n$**.

- When **$n$ is prime**, every nonzero element is invertible, so:  
  $$\mathbb{Z}_n^* = \mathbb{Z}_n \setminus \{0\}$$

- When **$n$ is composite**, only elements **coprime** to $n$ are invertible. For example:  
  - $\mathbb{Z}_6^* = \{1, 5\}$  
  - $\mathbb{Z}_8^* = \{1, 3, 5, 7\}$

In both cases, $\mathbb{Z}_n^*$ forms a **group** under multiplication. However, the full set $\mathbb{Z}_n \setminus \{0\}$ does **not** always form a group—unless $n$ is prime.

Earlier, we used $\mathbb{Z}_n \setminus \{0\}$ to demonstrate why the absence of inverses (and presence of zero divisors) breaks group structure when $n$ is composite. That distinction is more than technical: it plays a central role in understanding modular arithmetic, cryptographic algorithms, and number theory.

In the next section, we'll explore how the structure of $\mathbb{Z}_n^*$ changes when $n$ is prime. 

### 3.5 Why Prime Moduli Work
These failures motivate **prime moduli**. In $\{1,2,\ldots, p-1\}$, where $p$ is prime, every element has an inverse. In fact, this is guaranteed by a classic result from number theory.

Consider the pattern for $\{1, 2, \ldots, n-1\}$ modulo $n$:
- If $n$ is **not prime**, it is **not** a group due to zero divisors and missing inverses (e.g., $n = 6, 8$).
- If $n$ **is prime**, it is a group.

### 3.6 Python Code for Computing Inverse

One of the simplest and most efficient methods is to use Python's built-in
`pow(a, -1, p)` to compute modular inverses. Behind the scenes, this works because of a famous number theory result called **Fermat's Little Theorem**, which guarantees that an inverse exists and tells us:
$$
a^{-1} \equiv a^{p - 2} \pmod{p}
$$

when the modulus $p$ is a prime number and $a$ is not divisible by $p$.

Here's an example:

```python
def mod_inverse(a, p):  
    return pow(a, -1, p)

# Test for Z_7^*
def test_inverses(p):
    print(f"Testing inverses modulo {p}:")
    for a in range(1, p):
        inv = mod_inverse(a, p)
        print(f"Inverse of {a} mod {p} is {inv} (check: {a} * {inv} = {a * inv % p})")

if __name__ == "__main__":
    p = 7
    test_inverses(p)
```

**Output:**
```
Testing inverses modulo 7:
Inverse of 1 mod 7 is 1 (check: 1 * 1 = 1)
Inverse of 2 mod 7 is 4 (check: 2 * 4 = 1)
Inverse of 3 mod 7 is 5 (check: 3 * 5 = 1)
Inverse of 4 mod 7 is 2 (check: 4 * 2 = 1)
Inverse of 5 mod 7 is 3 (check: 5 * 3 = 1)
Inverse of 6 mod 7 is 6 (check: 6 * 6 = 1)
```


### 3.7 Exercises

#### Math Exercises:
1. Find the modular inverse (if it exists) for the following, using Python's `pow(a, -1, n)` function or a calculator. For prime moduli, you may optionally use Fermat's Little Theorem:  

   - $3^{-1} \mod 11$  
   - $7^{-1} \mod 26$  
   - $4^{-1} \mod 15$

2. For which values of $a$ in $\mathbb{Z}_{12}^*$ does the modular inverse exist?

#### Coding Exercises:

1. Write a function `list_all_inverses(n)` that returns a dictionary of all elements in $\mathbb{Z}_n^*$ with their inverses (if they exist).

2. Write a program that takes user input `a` and `n`, and checks whether a modular inverse exists. If it does, print the inverse. Try it with different values and see what you discover.

3. **Challenge:** Pick a few small primes `p`, and write a program that checks whether  
`pow(a, p - 1, p) == 1` for all `a` in `{1, 2, ..., p - 1}`.  
Does this hold for every `a`? What happens if `p` isn't prime?


## 4. Generators in Multiplicative Groups

We now turn our attention to generators in multiplicative groups. To build intuition, we begin with concrete examples in $\mathbb{Z}_7^* = \{1, 2, 3, 4, 5, 6\}$, exploring how individual elements can generate the full group—or just a part of it—through repeated multiplication

#### Example 4.1: $(\mathbb{Z}_7^*, \times)$
*Try 3:*
- $3^1 = 3$
- $3^2 = 9 \equiv 2 \pmod{7}$
- $3^3 = 27 \equiv 6 \pmod{7}$
- $3^4 = 81 \equiv 4 \pmod{7}$
- $3^5 = 243 \equiv 5 \pmod{7}$
- $3^6 = 729 \equiv 1 \pmod{7}$

$\langle 3 \rangle = \{1, 2, 3, 4, 5, 6\} = \mathbb{Z}_7^*$. Element $3$ is a generator.

*Try 2:*
- $2^1 = 2$
- $2^2 = 4$
- $2^3 = 8 \equiv 1 \pmod{7}$

$\langle 2 \rangle = \{1, 2, 4\}$, a subgroup, not the full group.

*Try Other Elements:*
- $4$: $4, 16 \equiv 2, 8 \equiv 1$ $\Rightarrow \{1, 2, 4\}$
- $5$: $5, 25 \equiv 4, 20 \equiv 6, 30 \equiv 2, 10 \equiv 3, 15 \equiv 1$ $\Rightarrow \mathbb{Z}_7^*$
- $6$: $6, 36 \equiv 1$ $\Rightarrow \{1, 6\}$

**Summary**:

| Element | Generated Set         | Size | Generator? |
|---------|-----------------------|------|------------|
| $2$     | $\{1, 2, 4\}$         | $3$  | ❌         |
| $3$     | $\{1, 2, 3, 4, 5, 6\}$| $6$  | ✅         |
| $4$     | $\{1, 2, 4\}$         | $3$  | ❌         |
| $5$     | $\{1, 2, 3, 4, 5, 6\}$| $6$  | ✅         |
| $6$     | $\{1, 6\}$            | $2$  | ❌         |


### 4.1 Primitive Elements
As we see, in the additive group $(\mathbb{Z}_p, +)$, where $p$ is prime, **every non-zero element is guaranteed to be a generator**. That is, repeatedly adding any non-zero element will eventually cycle through all elements of the group. However, in multiplicative groups $(\mathbb{Z}_p^*, \times)$, **only some elements are generators**—these are called **primitive elements**. This contrast highlights a fundamental difference: additive groups over primes are always cyclic with all non-zero elements as generators, while multiplicative groups over primes are cyclic but have only a subset of elements that serve as generators.

> **Definition**: An element $g \in \mathbb{Z}_p^*$ is a **primitive element** if $$\langle g \rangle = \{g^1, g^2, \ldots, g^{p-1}\} \pmod{p} = \mathbb{Z}_p^*.$$

Take, for example, $\mathbb{Z}_7^*$: $3$ and $5$ are primitive elements, while $2$, $4$, and $6$ are not.

A [foundational result](https://en.wikipedia.org/wiki/Primitive_root_modulo_n) in number theory guarantees that for any prime $p$, the group $\mathbb{Z}_p^*$ is **cyclic**, which means it always contains at least one primitive element. This stands in contrast to the additive group $(\mathbb{Z}_p, +)$, where **every non-zero element** generates the full group.

#### Example 4.1.1: $\mathbb{Z}_5^* = \{1, 2, 3, 4\}$
- **Element 2**:
  $$\begin{align*}
  2^1 &= 2 \pmod{5}, \\
  2^2 &= 4 \pmod{5}, \\
  2^3 &= 8 \equiv 3 \pmod{5}, \\
  2^4 &= 16 \equiv 1 \pmod{5}
  \end{align*}$$
  $\langle 2 \rangle = \{1, 2, 3, 4\} = \mathbb{Z}_5^*$, so $2$ is a primitive element.

- **Element 3**:
  $$\begin{align*}
  3^1 &= 3 \pmod{5}, \\
  3^2 &= 9 \equiv 4 \pmod{5}, \\
  3^3 &= 27 \equiv 2 \pmod{5}, \\
  3^4 &= 81 \equiv 1 \pmod{5}
  \end{align*}$$
  $\langle 3 \rangle = \{1, 2, 3, 4\} = \mathbb{Z}_5^*$, so $3$ is a primitive element too.

#### Example 4.1.2: $\mathbb{Z}_{11}^* = \{1, 2, 3, 4, 5, 6, 7, 8, 9, 10\}$
- **Element 2**:
  $$\begin{align*}
  2^1 &= 2 \pmod{11}, \\
  2^2 &= 4 \pmod{11}, \\
  2^3 &= 8 \pmod{11}, \\
  2^4 &= 16 \equiv 5 \pmod{11}, \\
  2^5 &= 10 \pmod{11}, \\
  2^6 &= 20 \equiv 9 \pmod{11}, \\
  2^7 &= 18 \equiv 7 \pmod{11}, \\
  2^8 &= 14 \equiv 3 \pmod{11}, \\
  2^9 &= 6 \pmod{11}, \\
  2^{10} &= 12 \equiv 1 \pmod{11}
  \end{align*}$$
  $\langle 2 \rangle = \{1, 2, 3, 4, 5, 6, 7, 8, 9, 10\} = \mathbb{Z}_{11}^*$, so $2$ is a primitive element.

- **Element 3**:
  $$\begin{align*}
  3^1 &= 3 \pmod{11}, \\
  3^2 &= 9 \pmod{11}, \\
  3^3 &= 27 \equiv 5 \pmod{11}, \\
  3^4 &= 15 \equiv 4 \pmod{11}, \\
  3^5 &= 12 \equiv 1 \pmod{11}
  \end{align*}$$
  $\langle 3 \rangle = \{1, 3, 4, 5, 9\}$, a subgroup, not the full group.

#### Example 4.1.3: $\mathbb{Z}_{17}^*$
- **Element 3**:
  $$\begin{align*}
  3^1 &= 3 \pmod{17}, \\
  3^2 &= 9 \pmod{17}, \\
  3^3 &= 27 \equiv 10 \pmod{17}, \\
  3^4 &= 81 \equiv 13 \pmod{17}, \\
  3^5 &= 243 \equiv 5 \pmod{17}, \\
  3^6 &= 729 \equiv 15 \pmod{17}, \\
  3^7 &= 2187 \equiv 11 \pmod{17}, \\
  3^8 &= 6561 \equiv 16 \pmod{17}, \\
  3^9 &= 19683 \equiv 14 \pmod{17}, \\
  3^{10} &= 59049 \equiv 8 \pmod{17}, \\
  3^{11} &= 177147 \equiv 7 \pmod{17}, \\
  3^{12} &= 531441 \equiv 4 \pmod{17}, \\
  3^{13} &= 1594323 \equiv 12 \pmod{17}, \\
  3^{14} &= 4782969 \equiv 2 \pmod{17}, \\
  3^{15} &= 14348907 \equiv 6 \pmod{17}, \\
  3^{16} &= 43046721 \equiv 1 \pmod{17}
  \end{align*}$$
  $\langle 3 \rangle = \{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16\} = \mathbb{Z}_{17}^*$, order $16$ (full group). So, $3$ is a primitive element of $\mathbb{Z}_{17}^*$.

**Additional Note:** Although we mentioned earlier that $\mathbb{Z}_n^*$ is always a group, it is **not always cyclic** when $n$ is not prime. In contrast, when $n = p$ is prime, $\mathbb{Z}_p^*$ is **always cyclic**. This distinction matters in practice—especially in cryptography—where we prefer to work with **cyclic groups**, so we often choose prime moduli to ensure that $\mathbb{Z}_p^*$ has this cyclic structure.


### 4.2 Python Code: Finding Primitive Elements Modulo a Prime

To find primitive elements in $\mathbb{Z}_p^*$, we compute the subgroup generated by a candidate element and check whether it includes **all** elements of $\mathbb{Z}_p^*$. The following code verifies whether a given element $g$ is primitive by performing this check. You can use it to explore and test more examples of primitive elements:


```python
def is_primitive_element(g, p):
    """Check if g is a primitive element modulo p."""
    required = set(range(1, p))
    generated = set()
    val = 1
    for _ in range(1, p):
        val = (val * g) % p
        generated.add(val)
    return generated == required

def primitive_elements(p):
    """Find all primitive elements of prime p."""
    elements = []
    for g in range(2, p):
        if is_primitive_element(g, p):
            elements.append(g)
    return elements

# Example usage:
prime = 11
print(f"Primitive elements modulo {prime}: {primitive_elements(prime)}")
```

**Sample Output:**
```bash
Primitive elements modulo 11: [2, 6, 7, 8]
```

For a more efficient approach, the galois library can directly compute primitive elements in the multiplicative group of a finite field, which for a prime $p$ corresponds to $\mathbb{Z}_p^*$. First, install the library with `pip install galois`, then use:
```python
import galois
print(galois.GF(7).primitive_elements)  # Output: [3, 5]
```

This method is optimized for large primes, making it ideal for practical applications, while the manual code above helps understand the concept of primitive elements.


#### Exercise

Let's apply what we've learned about generators and primitive elements.


1. Use the Python code above to find a generator of $(\mathbb{Z}_{13}^*, \times)$.  
*(Hint: You're looking for an element whose powers generate all elements of $\mathbb{Z}_{13}^*$.)*

2. Use your generator $g$ to list all elements of $\mathbb{Z}_{13}^*$ in the form $g^k$. 
*(Hint: You should get 12 distinct powers.)*



3. For each of the following values of $k \in \{1, 2, 3, 4, 6\}$, write out the subgroup generated by $g^k$.  
*(Hint: This approach helps you find all subgroups without brute force. For example, consider the case $k = 2$ below)*
>**Example:**  
If $g = 2$ (a generator of $\mathbb{Z}_{13}^*$), then:  
>- $g^2 = 2^2 = 4$  
>- The subgroup generated by $4$ is:   
>$$  \langle4\rangle = \{4, 4^2 =16\equiv3\pmod{13}, 4^3=64\equiv12 \pmod{13}, \dots\} = \{4, 3, 12, 9, 10, 1\}  $$

Now try this for $k = 1, 3, 4, 6$.  
*(Remember: compute $g^k$ first, then list its successive powers modulo 13 until you loop back to 1.)*

4. Use your work above to list all *distinct* subgroups of $(\mathbb{Z}_{13}^*, \times)$.
*(Hint: Some powers of $g$ generate the same subgroup.)*

**Conclusion:**  
This chapter focused on understanding multiplicative groups modulo a prime and their subgroup structures. We saw that these groups are cyclic, meaning they can be generated by a single element — called a primitive element. We also explored how the powers of a primitive element generate cyclic subgroups, and how different powers produce different subgroups.

Because we haven't yet introduced formal tools like Lagrange's Theorem, we approached subgroup discovery manually — especially in the final exercise, where we tried a few values of $k$ to see which subgroups they generate. In the next chapter, you'll learn the underlying principles that allow you to determine subgroup sizes and generators systematically.
