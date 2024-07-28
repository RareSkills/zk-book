# Abstract Algebra

Abstract Algebra is the study of sets that have one or more operators on that set. For our purposes, we only care about binary operators.

If we have sets and a binary operator on that set, we can categorize those sets based on how the binary operator behaves, and what elements are allowed (or expected) to be in the set.

Mathematicians have a word for every possible kind of behavior of the binary operator on the set. As applied programmers, we care about the Group (from Group Theory) in particular, but let’s work our way there incrementally. The group is just one type of animal in this large zoo. So rather than study the group in isolation, let’s study the group in its larger context of related algebraic structures (i.e. sets with a binary operator).

## Magma
A Magma is a set with a closed binary operator. That’s it.

A Magma is definitely something you understand intuitively as a programmer. Now you have a word for it.

As an example, let our set be all positive integers and our binary operator be $x^y$. Note that we don’t allow negative numbers because if $y$ is negative, we get a fraction.

Clearly, the output will be in the space of integers. Our function is a subset of the Cartesian product $(\mathbb{Z}\times\mathbb{Z})\times\mathbb{Z}$.

Interestingly, this example is not commutative or associative. You can convince yourself of this by picking values for a, b, and c in the python code below.

```python
assert a ** (b ** c) != (a ** b) ** c
assert a ** b != b ** a
```

But we don’t care. A Magma is the one of the least restrictive kinds of *algebraic structures*. All that matters is that the binary operator is closed. Everything else is fair game.

An algebraic structure is a set with a collection of operations on that set. For our purposes, the only operation we care about is a binary operator.

## Semigroup
A Semigroup is a Magma where the binary operator must be associative.

All Semigroups are Magmas, but not all Magmas are Semigroups.

In other words, a Semigroup is a set with a binary operator that is closed and associative.

Let our (infinite) set be the set of all possible non-empty strings from the traditional alphabet a,b,c,…,x,y,z. For example, “az”, “programmer”, “zero”, “asdfghjk”, “foo”, and “bar” are all in this set.

Let our binary operator be the concatenation of strings. This is closed, because it produces another string in the set.


Note that if we commute “foo” and “bar”, the output string will not be the same, i.e. “foobar” and “barfoo”. However, that does not matter. Both “foobar” and “barfoo” are members of the set, so the binary operator “concatenate” is closed. Because we have a set with a closed and associative binary operator, the set of all strings under concatenation is a Semigroup.

**Exercise:** Work out for yourself that concatenating “foo”, “bar”, “baz” in that order is associative. Remember, associative means $(A \square B) \square C = A \square (B \square C)$, where $\square$ is the Semigroup's binary operator.

**Exercise:** Give an example of a magma and a Semigroup. The magma must not be a Semigroup. Don’t use the examples above. This means you must think of a binary operator that is closed but not associative.

## Monoid
A Monoid is a Semigroup with an identity element.


Awww yes, this is the same Monoid from the “A monad is a monoid in the category of endofunctors.”

![Math meme about monad tutorials](https://static.wixstatic.com/media/935a00_bd9a8814842b4359b63050555a1c1c95~mv2.png/v1/fill/w_500,h_991,al_c,q_90,enc_auto/935a00_bd9a8814842b4359b63050555a1c1c95~mv2.png)

If we look at the [monoid documentation](https://typelevel.org/cats/typeclasses/monoid.html) in the Cats library for Scala, we see these definitions explicitly:

```scala
trait Semigroup[A] {
    def combine(x: A, y: A): A
}

trait Monoid[A] extends Semigroup[A] {
    def empty: A
}
```

The Cats library simply refers to "identity" as `empty` and the binary operator as `combine`. The fact that Monoid extends Semigroup shows that a Monoid is a Semigroup with the requirement that it has an "empty" (identity).

The snippet above doesn’t show it, but it is indeed required that combine be associative.

A Semigroup just has a binary operator with no restrictions on it except that it outputs the same type (`A`) as the inputs (`x`, and `y`).

For example, addition over positive integers without zero is a Semigroup, but if you include zero, it becomes a Monoid.


An *identity element* means you do a binary operator with the identity element and another element $a$, you get $a$. In the example of addition 8 + 0 = 8, where 0 is the identity element. If your binary operator was multiplication, then the identity element would be 1, since multiplying by 1 gives the same number back.

If our set was the set of all 2x2 matrices, the identity element would be the identity matrix

$$
\begin{bmatrix}
1&0\\
0&1\\
\end{bmatrix}
$$

### Sets of sets over union and intersection
Something bizarrely absent from our discussion of sets earlier was the discussion of union and intersection of sets. These are binary operators, and now is a good time to introduce them.

If you take the union of two sets $\set{1,2,3,4}$ and $\set{3,4,5,6}$, you get $\set{1,2,3,4,5,6}$. If you take the intersection of $\set{1,2,3,4}$ and $\set{3,4,5,6}$ you get $\set{3, 4}$.

It should be clear that both of these operators are associative.

If we define our domain to be the set of all finite sets of integers, then the binary operators union and intersection are closed because their result is a set of integers.

Set union has an identity element in this domain: the empty set $\set{}$. Take the union of a set with the empty set and you get the original set, i.e. $A \cup \set{} = A$.

Hence, the set of all *finite* sets of integers over union is a Monoid.

However, in the set of all possible finite sets of integers under intersection ($\cap$), it is a Semigroup -- no finite set will work as the identity. But if we expand this set to include ℤ itself -- that is, our set is $\{\text{all finite sets of integers}\}\cup\mathbb{\{Z\}}$ under intersection, then that is be a Monoid, as $\mathbb{Z}$ is the identity element.

If it feels like we "hacked" the identity element in, we did.

We’ll see later that elliptic curves use a trick like this and include a special point called the “point at infinity” to stay consistent with the algebraic laws. The point is we need to be very clear what our identity element is if we say a set is a Monoid over some binary operator.

As another example, we could say our set is all positive integers under addition, with the additional element $\text{mug}$. We define $\text{mug} + x = x$ and $x + \text{mug} = x$. As the architects of the systems, we are allow to make our set consist of whatever we like, and the binary operator behave however we like. However, the binary operator must be closed, associative, and the set must have an identity element for that algebraic data structure to be a Monoid.

If we restrict the domain to be all subsets of $\set{0,1,2,3,4,5}$, then intersection clearly becomes a Monoid because the identity element would be $\set{0,1,2,3,4,5}$, as any set of integers you intersect with it will produce the other set, i.e. $A ∩ \set{0,1,2,3,4,5} = A$. For example, $\set{1,3,4} ∩ \set{0,1,2,3,4,5} = \set{1,3,4}$.

At this point it should be clear that the category of an algebraic structure for a given binary operator is very sensitive to the domain of the set.

**Exercise:** Let our binary operator be the function `min(a,b)` over integers. Is this a Magma, Semigroup, or Monoid? What if we restrict the domain to be positive integers (zero or greater)? What about the binary operator `max(a,b)` over those two domains?

**Exercise:** Let our set be all 3 bit binary numbers (a set of cardinality 8). Let our possible binary operators be bit-wise and, bit-wise or, bit-wise xor, bit-wise nor, bit-wise xnor, and bit-wise nand. Clearly this is closed because the output is a 3 bit binary number. For each binary operator, determine if the set under that binary operator is a Magma, Semigroup, or Monoid.

## Group - The Star of the Show
A Group is a Monoid where each element has an inverse.

Or to be explicit, it is a set with four properties

1. The binary operator is closed (Magma)
2. The binary operator is associative (Semigroup)
3. The set has an identity element (Monoid)
4. Every element has an *inverse*

That is, for any element $a$ in the set $A$, there exists an $a'$ such that $a \square a' = i$ where $i$ is the identity element and $\square$ is the binary operator. Spoken more mathematically, that would be:

$$
\forall a \in A \space\space \exists a' \in A: a\square a' = i
$$

Here, $\square$ is the binary operator of the set.

It is rather incorrect to say "the set has an inverse." To be precise, every element has another element in the set that is that element's inverse.

Using integers with addition, the identity element is zero (because you add zero, you get the same number back), and the inverse of an integer is that integer with the sign flipped (e.g. the inverse of 5 is -5 and the inverse of -7 is 7).

Going back to the domain sensitivity, addition over positive integers is not a group because there can be no inverse elements.

Here is a table to drive the point home

| set domain                       | binary operator | algebraic structure | reason                       |
|----------------------------------|-----------------|---------------------|------------------------------|
| non-zero positive integers       | addition        | Semigroup           | no identity                  |
| positive integers including zero | addition        | Monoid              | has identity, no inverses    |
| all integers                     | addition        | Group               | every element has an inverse |

Note that “inverse” is not meaningful if the set does not have an identity, because the definition of inverse is doing a binary operator of an element with its inverse produces the identity.

**Exercise:** Why can’t strings under concatenation be a group?

**Exercise:** Polynomials under addition satisfy the property of a group. Demonstrate this is the case by showing it matches all the properties that define a group.

Unfortunately, our tutorial must end here, because elementary group theory is the subject of another chapter.


But now you have a lot of context to understand what a group is even though we barely discussed it here!

### A word about commutativity
None of the algebraic data structures above are required to be commutative. If they are, we say they are abelian over their binary operator. So an abelian group means the binary operator is not sensitive to the order.

Abelian means the binary operator is commutative.

But say abelian, you'll sound smarter.

The technicality is we don't normally say "addition is abelian" but "the group is abelian over addition."

## Subsets again
Let’s tie this all back to what we learned at the beginning. Magmas, Semigroups, Monoids, and Groups are all sets that have a closed binary operator. A binary operator is just a map from all the ordered pairs of the set’s Cartesian product with itself back to itself.


Groups are a subset of Monois, Monoids are a subset of Semigroups, Semigroups are a subset of Magmas, and Magmas are a subset of sets in general. Every Group is also a Magma or a set, but a Magma is not necessarily a Group.

“Sets” are easy to conceptualize, but when we start talking about groups and other algebraic structures, it’s easy to start getting lost. Groups are very important in our study of cryptography. Just remember:


**Groups are sets with a binary operator that follows four rules.**


Also, it’s time to free your mind from “addition” and “multiplication” being the primary way of combining things.


We are allowed to take a Cartesian product of a set (which could be anything) with itself then map that set of ordered pairs back to the set. This is a binary operator. If it follows the construction above, then it is closed.

## Math vocabulary doesn’t need to scare us
Before you began this tutorial, the sentence

“The set of strings over the binary operator string concatenation is a Semigroup or a Monoid depending on the presence or absence of the empty string in the set”

probably didn’t make sense.

You might still have to translate that in your head like most learners of a second language, but you realize it’s actually packing a lot of information into a tiny space.

Could I say that sentence without the mathiness? Of course I could, but it would take me at least 500 words to do it clearly. It’s actually worth understanding what those terms mean. This will save us a lot of trouble in the long run.

What makes it cool is there are a plethora of theorems about Groups that let us make claims about the group *without understanding how the binary operator of the group work under the hood.* This is very roughly like polymorphism in object-oriented programming or traits in functional languages. They hide implementation details from you and let you focus on the high level. That is powerful.

## Learn more with RareSkills
See our [Zero Knowledge Course](https://www.rareskills.io/zk-bootcamp) to learn with our community.

Our [ZK Book](https://www.rareskills.io/zk-book) contains the rest of the ZK tutorials in this series.

*Originally Published July 25, 2023*
