# Elementary Set Theory for Programmers

Why another set theory tutorial?

The target audience for this piece are the sort of folks who don’t care about abstract math unless they see a direct use-case for it. They want to get the essential parts they need and move on. This piece caters to that audience.


Specifically, abstract algebra has a lot of concepts that can be properly called “useful,” but abstract algebra is heavily dependent on set theory.


Our goal here is to take the most direct path through set theory to abstract algebra such that we understand all the terminology and concepts we will be dealing with.

Engineers are usually not interested in collecting abstractions or proving theorems, they want to ship things while having a sufficiently deep understanding of the topic such that they don’t unintentionally create bugs or inefficiencies. Acquiring knowledge that does not directly aid in this quest is considered a waste of time.


To optimize for this goal, I have deliberately omitted any aspect of set theory that I do not think is directly useful to understanding the aspects of abstract algebra we need, and as such, this resource is not comprehensive by design. But please note that this is part of a series of tutorials, and is not intended to be the complete treatment.

## Motivation of Set Theory for Zero Knowledge Proofs
The point of this tutorial is to give you a firm grasp of what a **binary operator** is in the context of Set Theory.

The concept of a binary operator is the at the core of Group Theory, and Group Theory is used *everywhere* in Zero Knowledge Proofs.

## Our treatment is not rigorous
Some mathematicians will be horrified that I don’t even discuss the axioms of set theory here. This is a feature, not a bug. If you want a proof for something, ask Google or ChatGPT (or better yet, work it out on your own). The concepts discussed here have been proven to death for over a century.


Set theory is not difficult (at least if you skip the proof writing, set theory proofs can be shockingly hard when doing it for the first time). You probably understand set theory intuitively already, and almost certainly have used sets in your code, probably to eliminate duplicates in an array quickly. However, we need to put a language to this intuition and make our intuitive understanding explicit.


Learning abstract math is like learning a human language. You can learn the vocabulary (what the words refer to), and the grammar (how they combine together in a valid way). We place a heavy emphasis on vocabulary over grammar here, to use that analogy. There is good reason for this.


If you enter a store in a foreign country and ask the equivalent of “the breads to be buy for me where?” the clerk can help you even though your grammar is horribly off. But if you nail the grammar and don’t know the vocabulary, your knowledge is useless. You can form a perfect sentence, but if you can’t succinctly refer to “bread” and “buy” your trip to the store will not be a success (I didn’t invent this analogy, but I can’t remember where I first saw it unfortunately).


Hence, we will barely scratch the grammar (proofs and theorems) and emphasize the vocabulary of abstract math (which is very useful in navigating this foreign country).


**Some types of knowledge can only be acquired by experience, not by explanation.**


Therefore, you should do the exercises in this text. Don’t worry, you won’t be writing proofs, just making sure you actually internalized what you just read.


Don’t let the relative brevity of this text fool you. It will take at least an afternoon (or two, maybe three) to work through it if you actually do the exercises. If a certain section doesn’t make sense, consult the internet for alternative explanations of that subtopic.

## Definition of a set
A set is a well-defined collection of objects. Where the abstract power comes from is that these could be *anything* and the rules we learn from set theory apply to them.

What integers, rational numbers, real numbers, complex numbers, matrices, polynomials, polygons, and many other things have in common is that they are all sets.

There is a well-defined rule that decides if something is a member of the set or not. We won’t get into it, but it is clear that a polygon is not a polynomial, and a polynomial is not a matrix, etc.

Sets are allowed to be empty. We call this the *empty set*.

Sets do not contain duplicate items by definition, $\{a, a, b\}$ is really $\{a, b\}$.

**Exercise:** Assume you have a proper definition for integers. Create a well-defined set of rational numbers.

## Superset and subsets
When we look at integers and rational numbers, there seems to be a relationship between some of them. Specifically, all integers are rational numbers, but not all rational numbers are integers. The relationship between them is that integers are a *subset* of rational numbers. On the flip side, rational numbers are a superset of integers.

A subset need not be strictly smaller than the set it is a part of. It is perfectly okay to say that integers are a subset of integers.

The precise definition for the relationship between integers and rational numbers is a *proper subset*, that is, there exist rational numbers that are not integers.

**Exercise:** Define the subset relationship between integers, rational numbers, real numbers, and complex numbers.

**Exercise:** Define the relationship between the set of transcendental numbers and the set of complex numbers in terms of subsets. Is it a proper subset?

## Set equality
Sets are defined to be equal if they contain the same elements, regardless of order. For example, $\{4, 2, 5\}$ is the same set as $\{2, 5, 4\}$. When doing formal proofs for sets, we say that if $A$ is a subset of $B$ and $B$ is a subset of $A$, then $A = B$. Or in more mathy notation: $A = B \iff A \subseteq B$ and $B \subseteq A$. That’s read as $A = B$ if and only if $A$ is a subset of $B$ and $B$ is a subset of $A$.

## Cardinality
In some of our above examples, there are an infinite number of integers, rational numbers, etc. However, we can also define sets in a finite way, such as the numbers $\{0,1,2,3,4,5,6,7,8,9,10\}$. The cardinality of the previous set is 11. If $A = \{5,9,10\}$, then $|A| = 3$, where the two vertical bars around the A mean cardinality.


There are different levels of infinite in set theory. For example, there are infinitely many more real numbers than there are integers. Specifically, we say integers are countably infinite because you can literally count them out. But there is no way to start counting real numbers which are uncountably infinite.


**Exercise:** Using the formal definition of equality, show that if two finite sets have different cardinality, they cannot be equal. (Demonstrating this for infinite sets is a little trickier, so we skip that).

## Fancy blackboard letters
Because “integers as a set” and “real numbers as a set” are used so frequently, there is scary looking mathematical shorthand for that.

- The symbol ℕ is the set of natural numbers (1,2,3,…). It definitely does not include negative numbers, but whether it includes zero depends on who you are talking to.
- The symbol ℤ is the set of all integers (because “zahlen” is integer in German)
- The symbol ℚ is the set of all rational numbers (I remember it as the quotient of the numerator and denominator)
- The symbol ℝ is the set of all real numbers, because R stands for real. Duh.
- The symbol ℂ is the set of all complex numbers for similarly obvious reasons.

Sometimes people write ℝ² as a vector of two real numbers, so a ∈ ℝ² means “a” is a 2d vector. I recommend writing it the second way because it is more concise, and also makes you look smarter.

![Math meme about 2D vectors of real numbers](https://hackmd.io/_uploads/SJKeBF1t0.jpg)

## Ordered pairs
Although sets do not respect order, a new type of data structure can emerge from sets called the ordered pair. For example, $(a, b)$ is an ordered pair while $\{a, b
\}$ is a set.

We programmers typically think of this as a tuple. We say two ordered pairs are equal in the same sense we say two tuples are equal.

How do we create order out of something that is unordered?

The implementation detail is that we write $(a, b)$ in set form as ${a, {b}}$. We can do this because we can define our set as containing either letters or a set of cardinality one that contains a letter. This is why we can say $(a, b) \neq (b, a)$ because ${a, {b}} \neq {b, {a}}$. We will not concern ourselves with this implementation detail any further.

Just like in other programming languages, our ordered pair can be arbitrarily long; for example, $(a,b,c,d)$ is valid. We can also encode and ordered pair holding an ordered pair as $((a, b), c)$, which will be useful later.

## Cartesian product
Because sets are well-defined, we can define a set such that every element from one set is one part of an ordered pair with an element from another set. For example, if $A = {1,2,3}$ and $B = {x, y, z}$ then $A × B$ is the set $\{(1, x), (1, y), (1, z), (2, x), …, (3, z)\}$ or done as a table:

$$
A \times B =\space\space
\begin{array}{c|ccc}
& x & y & z \\
\hline
1 & (1,x) & (1,y) & (1,z) \\
2 & (2,x) & (2,y) & (2,z) \\
3 & (3,x) & (3,y) & (3,z)
\end{array}
$$

Cartesian products are not commutative, as the following exercise will demonstrate. Commutative means $B × A = A × B$ in the general case.

**Exercise:** Compute the Cartesian product of B × A using the definitions above.

## Subsets of the cartesian product form a function
What if we wanted to say we have a function

$$
\begin{align*}
1 \rightarrow y \\
2 \rightarrow z \\
3 \rightarrow x \\
\end{align*}
$$

(I picked this out-of-order example to make it a little more interesting).

We can define a set that defines this mapping. We just take a subset of our Cartesian product above to include $(1, y)$, $(2, z)$, and $(3, x)$.

**In set-theoretic terms, a function is a subset of the Cartesian product of the domain and codomain sets.**

For our example of 1 mapping to y, 2 mapping to z, and 3 mapping to x, the subset of the Cartesian product is shown in bold below:

$$
\{1,2,3\} \times \{x, y, z\} =\space\space
\begin{array}{c|ccc}
& x & y & z \\
\hline
1 & (1,x) & \mathbf{(1,y)} & (1,z) \\
2 & (2,x) & (2,y) & \mathbf{(2,z)} \\
3 & \mathbf{(3,x)} & (3,y) & (3,z) \\
\end{array}
$$

Therefore, our function is defined by the set $\{(1, y), (2, z), (3, x)\}$.

To define the set, we need the set we start from, and the set we end at. We take the Cartesian product of these two sets, which results in every possible assignment from the input set to the output set. Then we take the subset of the Cartesian product to define the function as we like. When dealing with infinite sets like integers, we aren’t bothered that we can’t enumerate all the ordered points explicitly.

### Functions are not necessarily computable
A very important note is that mathematicians rarely concern themselves with *computability*. A function is a mapping between sets. How that function is *computed*, if it is even possible to compute with a reasonable computer, is not a concern of most mathematicians.

This is where programmers sometimes get tripped up. They often only think of functions as something that can be efficiently computed with lines of code. While useful, this limits our understanding of the general properties of functions.

The reason I emphasize this is that in zero knowledge proofs, we are going to be dealing with functions that are a lot “higher level” than plugging an argument into a function and getting a return value. We need to be able to appreciate the “big picture” of functions. *They are a mapping from one set to another set.* And a mapping between sets comes about by taking a subset of their Cartesian product.

#### Functions with dissimilar domains and codomains
Specifically, we are going to be jumping between integers, polynomials, matrices, elliptic curves in one dimension, then elliptic curves in another dimension, and so forth.

You’ll get very dizzy trying to conceptualize this unless you understand at a foundational level that, by Set Theory, we are allowed to define jumps however we like!

Of course, how we map the jump will have a strong effect on its usefulness, if we map everything to zero, that is a valid map, but not very useful.

I want you to understand early that we aren’t doing anything weird when we warp between universes in this way.

At the end of the day, we are allowed to take any two sets we like, create a new set by taking their Cartesian product, taking a subset of that set of ordered pairs, and boom, we have a mapping.

#### Axiom of Choice
If you're thinking "hey wait a minute, I can just pick a subset and define the function however I like?" you are not alone in wondering this. If you want to go down the rabbit hole, we've really been discussing the [axiom of choice](https://en.wikipedia.org/wiki/Axiom_of_choice) this whole time, and it has been the subject of controversy despite the definition seeming non-controversial:

>The Cartesian product of a collection of non-empty sets is non-empty.

## Subsets of the Cartesian product form a function: example
Let’s define a mapping between non-negative real numbers (zero or greater) and non-negative integers (zero or greater) using the floor function. The floor function simply removes the decimal portion of a number. We can’t show all the real numbers (or integers), but we can create a sketch.

When we do $\mathbb{R}\times\mathbb{Z}$ and take a subset, we simply pick the ordered pairs that correspond to taking the floor of the element from the real numbers. The ordered pairs we do not show in the table are ordered pairs that are not in our subset that defines the mapping. For example, 2 is not the floor of 500.3 so that ordered pair (500.3, 2) is not included.

\begin{array}{c|ccccc}
& 1 & 2 & \dots & 499 & 500 \\
\hline
1.5 & \color{red}{\mathbf{(1.5, 1)}} & (1.5, 2) & \dots & (1.5, 499) & (1.5, 500) \\
2.7772 & (2.7772, 1) & \color{red}{\mathbf{(2.7772, 2)}} & \dots & (2.7772, 499) & (2.7772, 500) \\
\vdots & \vdots & \vdots & \ddots & \vdots & \vdots \\
500.3 & (500.3, 1) & (500.3, 2) & \dots & (500.3, 499) & \color{red}{\mathbf{(500.3, 500)}} \\
\end{array}

**Exercise:** Define a mapping (function) from integers $\{1,2,3,4,5,6\}$ to the set $\{\text{even}, \text{odd}\}$.

**Exercise:** Take the Cartesian product of the polygons $\{\text{triangle}, \text{square}, \text{pentagon}, \text{hexagon}, \text{heptagon}, \text{octagon}\}$ and the set of integers $\{0,1,2,…,8\}$. Define a mapping such that the polygon maps to an integer representing the number of sides. For example, the ordered pair $(□, 4$) should be in the subset, but $(△, 7)$ should not be in the subset of the Cartesian product.

**Exercise:** Define a mapping between positive integers and positive rational numbers (not the whole thing, obviously). It is possible to perfectly map the integers to rational numbers. Hint: draw a table to construct rational numbers where the columns are the numerators and the rows are the denominators. Struggle with this for at least 15 minutes before looking up the answer.

### Valid and invalid subsets of the Cartesian product.
There is an important restriction on how we pick our subset. For example, the following subset of the Cartesian product $\{1,2,3\}$, $\{p,q,r\}$ is not valid because 1 maps to $p$ and 1 maps to $q$. When defining a function with a Cartesian product, the same domain element cannot map to two different codomain elements.

$$
\begin{array}{c|cc}
& p & q & r\\
\hline
1&(1,p) & (1,q)\\
2&&(2,q)\\
3&&&(3,4)\\
\end{array}
$$

## A Cartesian product of a set with itself
It should be no surprise that instead of doing a Cartesian product between $A$ and $B$, you can do a Cartesian product between $A$ and $A$. This is just mapping a set to itself.

This is is the first step of a more abstract form of what we traditionally think of as *functions* over integers.

For example, $y=x^2$ (over positive integers) can be visualized in set theoretic terms as the subset of $\mathbb{Z}\times\mathbb{Z}$:

\begin{array}{|c|c|c|c|c|c|c|c|c|c|c|}
\hline
& 1 & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9 & 10 &...\\
\hline
1 & \color{red}{\mathbf{(1,1)}} & (1,2) & (1,3) & (1,4) & (1,5) & (1,6) & (1,7) & (1,8) & (1,9) & (1,10) \\
\hline
2 & (2,1) & (2,2) & (2,3) & \color{red}{\mathbf{(2,4)}} & (2,5) & (2,6) & (2,7) & (2,8) & (2,9) & (2,10) \\
\hline
3 & (3,1) & (3,2) & (3,3) & (3,4) & (3,5) & (3,6) & (3,7) & (3,8) & \color{red}{\mathbf{(3,9)}} & (3,10) \\
\hline
...\\
\hline
\end{array}

## Set relations
The phrase “taking a subset of the Cartesian product” is so common that we have a word for it. It is a *relation*.


A relation can be from a Cartesian product of a set with itself or a set with another set. If we have two sets $A$ and $B$ ($B$ might or might not be equal to $A$ without loss of generality), and we take a subset of $A \times B$, then we say an element $a$ from $A$ is related to an element $b$ from $B$ if there is an ordered pair $(a, b)$ in the subset of $A \times B$.


In the $y=x^2$ example, 2 from $X$ is related to 4 from $Y$, but 3 in $X$ is not related to 6 from $Y$.

## A “binary operator” in set theoretic terms
A binary operator is a function from $A \times A \rightarrow A$. Basically, we take every possible pair from $A \times A$ (the Cartesian product of $A$ with itself) and map it to an element in $A$.


Let’s use an example of the set ${0,1,2}$ with binary operator addition modulo 3. First we take the set’s Cartesian product with itself (i.e. $A \times A$):

\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
0 & (0,0) & (0,1) & (0,2) \\
1 & (1,0) & (1,1) & (1,2) \\
2 & (2,0) & (2,1) & (2,2) \\
\end{array}

Then we take the Cartesian product of this new set of pairs with the original set

\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
(0,0) & ((0,0),0) & ((0,0),1) & ((0,0),2) \\
(0,1) & ((0,1),0) & ((0,1),1) & ((0,1),2) \\
(0,2) & ((0,2),0) & ((0,2),1) & ((0,2),2) \\
(1,0) & ((1,0),0) & ((1,0),1) & ((1,0),2) \\
(1,1) & ((1,1),0) & ((1,1),1) & ((1,1),2) \\
(1,2) & ((1,2),0) & ((1,2),1) & ((1,2),2) \\
(2,0) & ((2,0),0) & ((2,0),1) & ((2,0),2) \\
(2,1) & ((2,1),0) & ((2,1),1) & ((2,1),2) \\
(2,2) & ((2,2),0) & ((2,2),1) & ((2,2),2) \\
\end{array}

And then take the subset of that which defines our binary operator addition modulo 3:

\begin{array}{c|ccc}
& 0 & 1 & 2 \\
\hline
(0,0) & \color{red}{\mathbf{((0,0),0)}} & ((0,0),1) & ((0,0),2) \\
(0,1) & ((0,1),0) & \color{red}{\mathbf{((0,1),1)}} & ((0,1),2) \\
(0,2) & ((0,2),0) & ((0,2),1) & \color{red}{\mathbf{((0,2),2)}} \\
(1,0) & ((1,0),0) & \color{red}{\mathbf{((1,0),1)}} & ((1,0),2) \\
(1,1) & ((1,1),0) & ((1,1),1) & \color{red}{\mathbf{((1,1),2)}} \\
(1,2) & \color{red}{\mathbf{((1,2),0)}} & ((1,2),1) & ((1,2),2) \\
(2,0) & ((2,0),0) & ((2,0),1) & \color{red}{\mathbf{((2,0),2)}} \\
(2,1) & \color{red}{\mathbf{((2,1),0)}} & ((2,1),1) & ((2,1),2) \\
(2,2) & ((2,2),0) & \color{red}{\mathbf{((2,2),1)}} & ((2,2),2) \\
\end{array}



## Functions generally "exist" -- but computability is a different story

Thinking about functions as a subset of a Cartesian product may be a little weird at first -- especially since such definitions don't readily translate to code.

But ZK is heavily influenced by the mathematician definitions, so it's helpful to have this vocabulary in our back pocket.

It's helpful to conceptualize functions as a map that takes an element from one set and returns an element in another set.

**Exercise:** Pick a subset of ordered pairs that defines a * b mod 3.

**Exercise:** Define our set $A$ to be the numbers $\{0,1,2,3,4\}$ and our binary operator to be subtraction modulo 5. Define all the ordered pairs of $A \times A$ in a table, then map that set of ordered pairs to $A$.

A *closed* binary operator takes any two elements of a set, and outputs another element from the same set. The closed part is important, as it restricts the output to be in the same set.

Specifically, start with a set A and construct a binary operator as follows:

Take a Cartesian product of a set with itself, $A \times A$ and call this set of ordered pairs $P$.

Take the Cartesian product of $P$ with $A$ and take a subset of that such that $P\times A$ is well defined.

Division over integers is not a binary operator because what really happens is we do the $P = (\mathbb{Z} \times \mathbb{Z})$ then take a subset of $P \times \mathbb{Q}$ to get our relation. Division over integers is not closed because it can produce rational numbers.

We are going to deal with binary operators a lot on elliptic curves, integers, polynomials, matrices, etc.

When we can trust that the binary operator will have certain properties, then we can abstract away a lot of implementation detail.

For example, “adding” elliptic curve points is not exactly trivial, and the math is not obvious from the get go.

However, if you know the binary operator is closed, and follows certain properties, then how the “addition” is implemented does not matter! It's a map that follows certain rules!

Let’s use a slightly more relatable example. If you multiply two square matrices of determinant 1 together, the determinant of the product matrix will also be 1. The proof is not something you can quickly work out in your head. But if you model this as a “set of 3x3 matrices with determinant 1 and binary operator multiply, and multiply is closed” then you suddenly have a lot of functional knowledge of a system you don’t know the implementation details about. You know no matter what you do, you’ll get a determinant 1 matrix without having to know why.

Having the language to describe a binary operator as “closed” allows you to operate at a higher level and understand the bigger picture of transformations and not get bogged down in the implementation details.

You can reason about operations without understanding how they work! This is *extremely helpful* when it comes to dealing with very esoteric math such as [Ellptic curve bilinear pairings](https://www.rareskills.io/post/bilinear-pairing).

### Constructing valid binary operations
When it comes to binary operators, we are not allowed to take a subset of $A \times A$ before mapping that to $A$. Binary operators must accept *all* members of set $A$ as its inputs. We of course must take a subset of the ordered pairs between $A \times A$ and $A$ because each pair from $A \times A$ must map to exactly one A.

## Learn more with RareSkills
The usefulness of the vocabulary from abstract algebra is why our zero knowledge course does not dodge math. We just make sure we have our essential vocabulary down before we start using it.