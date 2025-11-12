# Evaluating multivalued functions by square root expansion

In the previous chapter on Image Preservation of Multivalued Functions we saw that instead of evaluating $f(x)$ on the $k$-th roots of unity, we can transform $f(x)$ into a multivalued function and evaluate it on the domain $\set{1}$.

## Unwrapping Square Roots

It’s much easier to think of the 8-th root of 1 as nested square roots:

$$
\sqrt[8]{x}=\sqrt{\sqrt{\sqrt{x}}}
$$

We now show how to evaluate:

$$
\sqrt{\sqrt{\sqrt{1}}}
$$

using square root expansion.

We know that $\sqrt{1}$ evaluates to $\set{1,-1}$ so we replace the inner-most square root of 1 with its evaluations:

![A diagram showing the that a times the 8-th root of 1 is equal to a times the fourth root of 1 and a times the fourth root of -1](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image1.png)

This “removes” one layer of square roots. Next, we evaluate $\sqrt{1}$ and $\sqrt{-1}$. Since we are working with the 8-th roots of unity, $-1\equiv\omega^4$ so $\sqrt{-1}=\{\omega^2,-\omega^2\}$

![A diagram showing how the fourth roots can be expanded into two square roots](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image2.png)

Then, we evaluate each of the remaining square roots:

![A diagram showing how four square roots evaluate to the 8th roots of unity](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image7.png)

Observe that the “leaves” of the evaluation tree are exactly $f$ evaluated on an 8-th root of unity.

## Evaluating $f(x)=x^2$ on the 8-th roots of unity

The nice thing about square root expansion is that for most powers of $x$, the square roots “disappear early” as this example shows. We replace $x$ with $\sqrt[8]{x}$, but since $x$ is squared, we have end up with $\sqrt[4]{x}$ or

$$
\sqrt{\sqrt{x}}
$$

Here is the evaluation tree from repeatedly expanding the square roots until we have eight evaluations. In the final row, when there are no square roots, we simply copy the values down.

![An evaluation tree for the 8-th roots of unity evaluated on x^2 using square root expansion](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image5.jpg)

Now observe what happens if we evaluate the 8-th roots of unity $\set{1,...,\omega^7}$  directly on $f(x)=x^2$ — the outcome is exactly the same.

$$
\begin{align*}
f(1)&=(1)^2&=1\\
f(-1)&=(-1)^2&=1\\
f(\omega^2)&=(\omega^2)^2&=-1\\
f(-\omega^2)&=(-\omega^2)^2&=-1\\
f(\omega)&=(\omega)^2&=\omega^2\\
f(-\omega)&=(-\omega)^2&=\omega^2\\
f(\omega^3)&=(\omega^3)^2&=-\omega^2\\
f(-\omega^3)&=(-\omega^3)^2&=-\omega^2\\
\end{align*}
$$

## Evaluating $f(x)=x^4$ on the 8-th roots

Again, we replace $x$ with $\sqrt[8]{x}$ which gives us $\sqrt{x}$. Since we only have one square root, we will only expand the square root once, then simply copy the results down.

![A diagram showing the square root expansion of 1 to the 8-th roots](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image4.jpg)

We saw in an earlier chapter that $x^{k/2}$ is 1 if evaluated on an even power of $\omega$ and -1 otherwise. The result here matches the expected outcome.

## Evaluating $f(x)=ax+bx^5$ on the 8-th roots of unity

If we replace $x$ with $\sqrt[8]{x}$, we get a slightly awkward result:

$$
f(x)=a\sqrt[8]{x}+bx^{5/8}
$$

However, if we factor $x$ out first to turn $f(x)$ into $f(x)=x(a+bx^4)$, the new form becomes a lot more manageable when we substitute $\sqrt[8]{x}$ for $x$:

$$
g(x)=\sqrt[8]{x}(a+b\sqrt{x})
$$

The first square root will disappear after the first evaluation and $(a+b\sqrt{x})$ will become a constant for most of the tree. 

Below is a diagram of expanding the square roots. At each level, we unwrap (evaluate) one square root. The square roots in blue represent the ones evaluated at each step. As a general rule, evaluate the innermost square root if it is nested:

![A diagram showing the square root expansion of a + bx^4](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image6.jpg)

Now let’s compare the result to evaluating $f(x)=ax+bx^5$ on the 8-th roots of unity one-by-one:

$$
\begin{array}{rcll}
f(1)        &=& a(1) + b(1)^5 &= a + b\\[4pt]
f(-1\equiv\omega^4) &=& a\omega^4 + b\omega^{20} = a(-1) + b(-1) &= -a - b\\[4pt]
f(\omega^2) &=& a\omega^2 + b\omega^{10} = a\omega^2 + b\omega^2 &= (a + b)\omega^2\\[4pt]
f(-\omega^{2}\equiv\omega^6) &=& a\omega^6 + b\omega^{30} = a(-\omega^2) + b(-\omega^2) &= -(a + b)\omega^2\\[4pt]
f(\omega)   &=& a\omega + b\omega^5 &= a\omega - b\omega \\[4pt]
f(-\omega\equiv\omega^5) &=& a\omega^5 + b\omega^{25} = a(-\omega) + b\omega &= -a\omega + b\omega = (b - a)\omega\\[4pt]
f(\omega^3) &=& a\omega^3 + b\omega^{15} = a\omega^3 + b\omega^7 &= a\omega^3 - b\omega^3 = (a - b)\omega^3\\[4pt]
f(-\omega^3\equiv\omega^7) &=& a\omega^7 + b\omega^{35} = a(-\omega^3) + b(-\omega^3) &= -(a + b)\omega^3
\end{array}

$$

Evaluating the terms using the method above requires 8 additions and 16 multiplications.

However, using square root expansion, we only need 2 additions and 10 multiplications. Whenever a square root is expanded into its two solutions, we multiply it by the adjacent term. So whenever the “final” square root is unwrapped, it results in two multiplications. These are highlighted in red below. The additions are highlighted in blue.

![A diagram counting the number of additions and multiplications in the square root expansion.](https://r2media.rareskills.io/SquareRootMultivaluedFunctions/image3.jpg)

Note that “computing the square root” is completely deterministic. We know it always follows the pattern of $\set{1}$, 2nd roots of unity, 4-th roots of unity, 8-th roots of unity, and so on. Thus, there is no need to explicitly compute the square roots.

## Easy terms and hard terms

We can see that terms $x^{k/2}$ are easiest to evaluate because they only require 1 evaluation, and the rest is just copying values down the tree.

On the other hand, $x$ with no power is the “hardest” to evaluate because we need to do a square root expansion at every step down the tree.

The nice thing about the function $f(x)=a+bx^{k/2}$, which becomes the multivalued function $g(x)=(a+b\sqrt{x})$ on the $k$-th roots of unity is that we fully evaluate the square root at the second level of the tree, and simply copy down the sum of $a+b$ for the rest of the evaluation.

In fact, any polynomial can be written to “maximize” the amount of $a+bx^{k/2}$ terms and “minimize” the amount of $x$ terms.

Suppose we have a 7-degree polynomial that we want to evaluate on the 8-th roots of unity.

$$
f(x)= a_0 + a_1x + a_2x^2 + a_3x^3 + a_4x^4 + a_5x^5 + a_6x^6 + a_7x^7
$$

To maximize the number of $x^4$ terms and have only one $x$ term, we factor it as follows:

$$
f(x)= a_0 + a_2x^2 + a_4x^4 + a_6x^6  + a_1x + a_5x^5  +  a_3x^3+ a_7x^7
$$

$$
f(x)= a_0 + a_4x^4 + (a_2x^2 + a_6x^6)  + (a_1x + a_5x^5)  +  (a_3x^3+ a_7x^7)
$$

$$
f(x)= a_0 + a_4x^4 + x^2(a_2 + a_6x^4)  + x(a_1 + a_5x^4)  +  x^3(a_3x+ a_7x^4)
$$

$$
f(x)= a_0 + a_4x^4 + x^2(a_2 + a_6x^4)  + x((a_1 + a_5x^4)  +  x^2(a_3x+ a_7x^4))
$$

**Exercise:** How should the polynomial $f(x)=a_0+a_1x+a_2x^2+a_3x^3$ evaluated on the 4th roots of unity be factored to have only one $x$ term and as many $x^2$ terms as possible? Remember, $x^{k/2}$ is $x^2$ in this case.

In the next chapter, we will show how to evaluate a general degree 4 and degree 8 polynomial using square root expansion, which also happens to be exactly the NTT algorithm.