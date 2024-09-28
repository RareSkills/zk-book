# Elliptic Curve Point Addition

This article describes how elliptic curve addition works over real numbers.

Cryptography uses elliptic curves over finite fields, but elliptic curves are easier to conceptualize in a real Cartesian plane. This article is aimed at programmers and tries to strike a balance between getting too math heavy and too hand-wavy.

## Set theoretic definition of elliptic curves
The [set](https://www.rareskills.io/post/set-theory) of points on an elliptic curve form a group under elliptic curve point addition.

Hopefully, if you’ve been following our [group theory introduction](rareskills.io/post/group-theory), then you actually understood most of this, aside from what “point addition” is. But that’s the beauty of abstract algebra right? You don’t need to know what that is, and you still understand the above sentence.

Elliptic curves are a family of curves which have the formula

$$ y^2 = x^3 + ax + b $$

Depending on what value of a and b you pick, you’ll get a curve that looks like some of the following:

![Elliptic curves](https://static.wixstatic.com/media/935a00_26f928a28e2b424690c1e3df172f783a~mv2.png/v1/fill/w_1480,h_632,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_26f928a28e2b424690c1e3df172f783a~mv2.png)

A point on an elliptic curve is an $(x, y)$ pair that satisfies $y² = x³ + ax + b$ for a given $a$ and $b$.

For example, the point $(3, 6)$ is in the curve $y² = x³ + 9$ because it $6² = 3³ + 9$. In group theoretic terms, $(3, 6)$ is a member of the set defined by $y² = x³ + 9$. Since we are dealing with real numbers, the set has infinite cardinality.

The idea here is we can take two points from this set, do a binary operator, and we will get another point that is also in the set. That is, it is an $(x, y)$ pair that also lies on the curve.

**Instead of thinking about elliptic curves as a plot on a graph, think of them as an infinite set of points. Points are in the set if and only if they satisfy the elliptic curve equation.**

Once we see these points as a set, looking at them as a group isn’t mysterious. We just take two points, and produce a third according to the rules of a group.

Specifically, to be a group, the set of points needs to have:
- a binary operator that is closed and associative, i.e. it produces another point in the set
- the set must have an identity element $I$
- every point in the set must have an inverse such that when the two are combined with the binary operator, the result is $I$

## Elliptic Curves form an abelian group under addition

Although we don’t know how the binary operator works, we do know that it takes two $(x, y)$ points on the curve and returns another point on the curve. Because the operator is closed, we know that the point will in fact be a valid solution to the elliptic curve equation, not a point somewhere else.

We also know that this binary operator is associative (and commutative, per the section heading).

So given three points on the elliptic curve $A$, $B$, and $C$ (or $(x_a, y_a)$, $(x_b, y_b)$, and $(x_c, y_c)$ if you prefer), we know the following is true:

- $(A ⊕ B) ⊕ C = A ⊕ (B ⊕ C)$
- $A ⊕ B = B ⊕ A$

I’m using $⊕$, because we know this binary operator is not addition in any normal sense, but a binary operator (again, remember from set theory, a binary operator takes two elements in a set and returns another element in a set, how it does that is not central to the definition).

We also know that there has to be an identity element somewhere. That is, any $(x, y)$ point that falls on the curve is combined with the identity element, the output is the same $(x, y)$ point unchanged.

And because this is a group and not a monoid, every point needs to have an inverse such that $P ⊕ P⁻¹ = I$, where $I$ is the identity element.

### The identity element
Intuitively, we might think of $(0, 0)$ or $(1, 1)$ being the identity element, since something like that often is in other groups, but you can see in the plots above that those points generally do not land on the curve. Since they don’t belong to the set of points on $y² = x³ + ax + b$, they are not part of the group.

But recall from set theory that we can define binary operators however we like over sets arbitrarily defined. This allows us to add a special element that isn’t technically on the curve but by definition is the identity element.

I like to think of the identity element as "the point that is nowhere" because if you combine nowhere with any real point, nothing changes. Annoyingly, mathematicians call this point, the identity element "the point at infinity."

Hey wait, isn’t this point supposed to satisfy $y² = x³ + ax + b$? Nowhere (or infinity) is not a valid value for $(x, y)$.

Ahh, but remember, we can define sets however we like! We define the set that makes up the elliptic curve as points on the elliptic curve and the nowhere point.

Because binary operators are just subsets of a cartesian product (a relation), and we can define the relation however we like. We can have as many hacky “if statements” in our arithmetic as we please and still follow the group laws.

## Addition is closed.
Without loss of generality, let’s take the elliptic curve

$$ y² = x³ + 10 $$

To illustrate how lines intersect on elliptic curves, then let’s draw a nearly vertical line $y = 10x$

(It could be 1000x to make it more vertical, but we would get numerical instability as you will see later)

We get the following set of plots.

![Elliptic curve with a line drawn through it](https://static.wixstatic.com/media/935a00_fe30b49a14b448b2a306925812e052f5~mv2.png/v1/fill/w_1480,h_960,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_fe30b49a14b448b2a306925812e052f5~mv2.png)

It turns out, even though it looks like the purple line ($y = 10x$) is rising faster than the blue curve ($y² = x³ + 10$), they will always eventually intersect.

If we zoom out far enough, we can see the intersection. This is true in general.

**As long as x is not "perfectly vertical" if it crosses two points on the curve, it will always cross a third.** Two of those points could be the same point if one of the points of intersection is a tangent point.

The "if we intersect two points" is important. If we shift our purple line over to the left so it doesn’t cross the "U-turn" of the elliptic curve, then it will only cross at one point

Another way of understanding it:

**If a straight line crosses an elliptic curve at exactly two points, and neither of the intersection points are tangent intersections, then it must be perfectly vertical.**

You could work out an algebraic proof from the formulas above, but I think the geometric argument is more intuitive.

I recommend you stop here and draw some elliptic curves and lines and convince yourself of this visually.

Our exception for vertical lines actually causes inverse and identity elements to fall into place beautifully.

**The inverse of an elliptic curve point is the negative of the y value of the pair.** That is, the inverse of $(x, y)$ is $(x, -y)$ and vice versa. Drawing a line through such points creates a perfectly vertical line.

The identity element is the "point at infinity" we alluded to earlier is simply the point "way up there" when we draw a vertical line.

### Abelian Group
The fact that elliptic curve points are a group under our “2 points always result in a 3rd except for the identity” makes its commutative nature obvious.

When we pick two points, there is only one other third point. You can’t get four intersections in an elliptic curve. Since we only have one possible solution, then it is clear that $A ⊕ B = B ⊕ A$.

## Why elliptic curve addition flips over the x axis
We glossed over a very important detail in the last section, because it really deserves a section on its own.

In it’s current form, it has a bug if we add two points where the intersection happens in the middle.

![3 point intersection through an elliptic curve](https://static.wixstatic.com/media/935a00_cffa7b60afd8486f8cc2f97de8b07f17~mv2.png/v1/fill/w_1480,h_812,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_cffa7b60afd8486f8cc2f97de8b07f17~mv2.png)

Using our definitions above, the following must be true

$$
\begin{align*}
A ⊕ B &= C \\
A ⊕ C &= B \\
B ⊕ C &= A
\end{align*}
$$

With a little algebra, we’ll derive a contradiction

$$
\begin{align*}
(B ⊕ C) ⊕ B &= C \\
B ⊕ C &= \mathsf{inv}(B) ⊕ C \\
B &= \mathsf{inv}(B)
\end{align*}
$$

This says $B$ is equal to it’s inverse. But $B$ is not the identity element (which is the only element that can be the inverse of itself), so we have a contradiction.

Thankfully, there is a way to rescue this. Just define point addition to be the third point *flipped over the y axis*. Again, we are *allowed to do this* because binary operators can be defined however we like, we just care that our definitions satisfy the group laws.

So the correct way to add elliptic curve points is represented graphically below

![Elliptic curve point addition](https://static.wixstatic.com/media/935a00_47a61dc12ed54c2b9a36415cceea5b54~mv2.png/v1/fill/w_1255,h_1228,al_c,q_90,enc_auto/935a00_47a61dc12ed54c2b9a36415cceea5b54~mv2.png)

## Formula for Addition
Using some algebra, and given two points

$$
\begin{align*}
P₁ &= (x₁, y₁) \\
P₂ &= (x₂, y₂)
\end{align*}
$$

One can derive how to compute $P₃ = (x₃, y₃)$ where $P₃ = P₁ ⊕ P₂$ using the following formula.

$$
\begin{align*}
\lambda &= \frac{y₂ - y₁}{x₂ - x₁} \\
x₃ &= \lambda² - x₁ - x₂ \\
y₃ &= \lambda(x₃ - x₁) - y₁
\end{align*}
$$

### Algebraically demonstrating commutativity and associativity
Because we have a closed form equation, we can prove algebraically that $T⊕U = U⊕T$ given points $T$ and $U$.

We do it as follows

$$\begin{align*}
P &= T ⊕ U \\
Q &= U ⊕ T \\
P &= Q
\end{align*}$$

```python
var('y_t', 'y_u', 'x_t', 'x_u')
lambda_p = (y_u - y_t)/(x_u - x_t)
x_p = lambda_p^2 - x_t - x_u
y_p = (lambda_p*(x_t - x_p) - y_t)

lambda_q = (y_t - y_u)/(x_t - x_u)
x_q = lambda_q^2 - x_u - x_t
y_q = (lambda_q*(x_u - x_q) - y_u)
```

Here is a screenshot of running the above code in Jupyter notebook and pretty printing the output. The computer algebra system needs a bit of coaxing, but we can clearly see `x_q == x_p` and `y_q == y_p`.

![Algebraically demonstrating commutativity and associativity](https://static.wixstatic.com/media/935a00_fb8599e0572c4987b88525005917b394~mv2.png/v1/fill/w_1246,h_1140,al_c,q_90,enc_auto/935a00_fb8599e0572c4987b88525005917b394~mv2.png)

$P = Q$ for all $(x_t, y_t)$ and $(x_u, y_u)$ values. We get a division by zero error if $x_t = x_u$, but this means they are the same point and that is obviously commutative.

We can use similar techniques to demonstrate associativity, but unfortunately this is extremely messy so we refer the interested reader to another [proof of associativity](https://www.scirp.org/journal/paperinformation.aspx).

## Elliptic curves meet the abelian group property
Let’s see that elliptic curves meet the group property.

1. The binary operator is closed. It either intersects with a 3rd point on the curve or the point at infinity (identity). We are guaranteed to get a third valid point when we intersect two points. The binary operator is associative.
2. The group has an identity element.
3. Each point has an inverse.
4. The group is abelian because A ⊕ B = B ⊕ A

A binary operator must accept every possible pair from the set. What if the pair is the same element, i.e. A ⊕ A?

## Point multiplication: adding a point with itself
Let’s think of this in limit terms. Adding a point to itself is like bringing two points infinitesimally close to each other until they become the same point. When this convergence happens, the slope of the line will lie tangent to the curve.

So adding a point to itself is simply taking the derivative at that point, getting the intersection, then flipping the $y$ axis.

The following image graphically demonstrates $A ⊕ A = 2A$.

![Point multiplication on an elliptic curve](https://static.wixstatic.com/media/935a00_61ed6a7a5ba14b53a95cf5c16e54f3f5~mv2.png/v1/fill/w_1230,h_1228,al_c,q_90,enc_auto/935a00_61ed6a7a5ba14b53a95cf5c16e54f3f5~mv2.png)

### Shortcut for point multiplication
What if we wanted to compute $1000A$ instead of $2A$? It would seem this is an $\mathcal{O}(n)$ operation, but it isn’t.

Because of associativity, we can write $1000A$ as

$$1000A = 512A ⊕ 256A ⊕ 128A ⊕ 64A ⊕ 32A ⊕ 8A$$

$512A$ (and the other terms) can be computed quickly because 512 is just $A$ doubled 9 times.

So rather than doing 1000 operations, we can do it in 14 (9 to compute 512, caching the intermediate results, then 5 additions).

This is actually an important property when we get to cryptography:

*We can efficiently multiply an elliptic curve point by a large integer efficiently.*

## Implementation details of addition
It isn’t too hard to derive the formula for point addition using simple algebra. When we intersect two points, we know the slope and the points that it crossed through, so we can calculate the point of intersection.

I’d rather not do that here because I don’t want to get lost in a bunch of symbolic manipulation.

The whole power of group theory is that we don’t care what that symbolic manipulation looks like. We know that if we do our binary operator on two points, we’ll get another point in our set, and our set follows the group laws.

If you think about it that way, elliptic curves are much easier to understand.

Rather than trying to understand elliptic curves in isolation from the ground up, we study a bunch of other algebraic groups, then transfer that knowledge and intuition to elliptic curves.

Rational numbers under addition are a group. Integers modulo a prime are a group under multiplication. Matrices of non-zero determinant under multiplication are a group.

You do the binary operator, and you get another item in the set. The group has an identity element, and each element has an inverse. Associative law holds. With all that in mind, you shouldn’t care what the operator ⊕ is doing behind the scenes.

In my opinion, if you try to understand elliptic curves math in isolation from first principles of group theory, you’re doing it the hard way. It’s far easier to understand it in the context of its relatives.

That makes for a smoother learning experience.

### Algebraic manipulation is really just associative addition.
Let $P$ be an elliptic curve point. What happens we do something like this?

$$(a + b)P + cP = aP + (a + c)P$$

At first, it may seem weird that we can do that, because if we try to visualize what is happening with the elliptic curve, we will surely get lost.

Remember, what looks like multiplication above is really just a point getting added with itself repeatedly, so this is what actually happens under the hood when looking at it as a group

$$\underbrace{(a + b)P + cP}_{((a + b + c)P)} = \underbrace{aP + (b + c)P}_{(a + b + c)P}$$

$$
\begin{align*}
(a + b + c)P &= (a + b + c)P \\
(aP + bP) + cP &= aP + (bP + cP) \\
(a + b)P + cP& = aP (b + c)P
\end{align*}
$$

Scalar "multiplication" isn’t "distributive" the way we would think about normal algebra. It’s just shorthand for rearranging the order in which we add P to itself.

Under the hood, we just added $P$ to itself $(a + b + c)$ times. The order we do it in doesn’t matter because of associativity.

So when you see manipulation like that, our group didn’t suddenly gain a multiplication binary operator, it’s just misleading shorthand.

## Elliptic curves in finite fields
If we were to do elliptic curves over real numbers for a real application, they would be very numerically unstable because the intersection point could require a lot of decimal places to compute.

So in reality, we do everything with [modular arithmetic](https://www.rareskills.io/post/finite-fields).

But we lose none of the intuition we’ve gained above by doing this.

## Learn more with RareSkills
This material is from our zero knowledge course, see there to learn more.

*Originally Published September 1, 2023*
