# Roots of Unity raised to the k/2 power equals 1 or -1

Any $k$-th root of unity with even $k$ raised to the $k/2$ power will result in 1 or -1.

This should not be confused with the similar-looking concepts that $\omega^{k/2}\equiv-1$ or that roots of unity $\omega^{i}$ and $\omega^{i+k/2}$ are additive inverses of each other.

Let’s use the primitive 8-th roots of unity as an example with generator (primitive 8-th root of unity) $\omega$:

- $(1)^{k/2}=1$
- $(\omega)^{k/2}\equiv-1$
- $(\omega^2)^{k/2}\equiv\omega^{2k/2}\equiv\omega^k\equiv1$
- $(\omega^3)^{k/2}\equiv\omega^{3k/2}\equiv(\omega^{k/2})^{3}\equiv(-1)^3\equiv-1$
- $(\omega^4)^{k/2}\equiv\omega^{4k/2}\equiv\omega^{2k}\equiv1$
- $(\omega^5)^{k/2}\equiv\omega^{5k/2}\equiv(\omega^{k/2})^{5}\equiv(-1)^5\equiv-1$
- $(\omega^6)^{k/2}\equiv\omega^{6k/2}\equiv\omega^{3k}\equiv1$
- $(\omega^7)^{k/2}\equiv\omega^{7k/2}\equiv(\omega^{k/2})^{7}\equiv(-1)^7\equiv-1$

As an exercise for the reader, we recommend taking the 6-th roots of unity, raising each element to the 3rd power ($k/2$) and seeing that the results are $\set{1,-1}$.

Looking at the evaluations above, we see a pattern that the even powered roots of unity plugged into $f(x)=x^{k/2}$ evaluate to 1 and the odd-powered roots of unity plugged into $f(x)=x^{k/2}$ evaluate to -1. A proof of this is in the appendix. Meanwhile, let’s make the central claim of the chapter:

**Any k-th root of unity raised to $k/2$ where $k$ is even results in 1 or -1. Specifically, let $\omega$ be the primitive $k$-th root of unity and let the root of unity in question be $\omega^s$. If $s$ is even, $(\omega^s)^{k/2}$ will evaluate to 1 and if $s$ is odd, then $(\omega^s)^{k/2}$ will evaluate to -1.**

**A side-effect of this claim is that terms in a polynomial with the power $x^{k/2}$ can be evaluated almost for free if evaluated on a root of unity.**

Suppose for example that we have a polynomial $f(x)=x^4$ that we want to evaluate on 8 points. Now suppose we set the 8 points to be the 8-th roots of unity. Normally, we’d have to loop through $\set{1, \omega,...,\omega^7}$ and evaluate $f(x)$ on each point. However, we don’t need to actually exponentiate each point of evaluation — we just check if the power of the root of unity is even or odd!

In fact, we can shortcut the process entirely. Let’s treat $\set{1, \omega,...,\omega^7}$ as an array with length 8. We can return 1 or -1 based on whether the array index is even or odd, and completely ignore the exponent. In other words, $f(x)=x^4$ will evaluate to

$$
[1,-1,1,-1,1,-1,1,-1]
$$

If the polynomial has a coefficient other than one, for example $f(x)=ax^4$, the evaluation depends just on whether we are on an even or odd index:

$$
[a,-a,a,-a,a,-a,a,-a]
$$

But what about polynomials that aren’t of the form $f(x)=x^{k/2}$? Polynomials can be factored to introduce as many $x^{k/2}$ terms as possible. For example, consider the polynomial

$$
f(x)=a_0+a_1x+a_2x^2+a_3x^3+a_4x^4+a_5x^5+a_6x^6+a_7x^7
$$

Only the term $a_4x^4$ is of the form $x^{k/2}$. However, suppose we factor the polynomial as follows:

$$
f(x)=(a_0+a_4x^4)+(a_1x+a_5x^5)+(a_2x^2+a_6x^6)+(a_3x^3+a_7x^7)
$$

$$
f(x)=(a_0+a_4x^4)+x(a_1+a_5x^4)+x^2(a_2+a_6x^4)+x^3(a_3+a_7x^4)
$$

This polynomial is much easier to evaluate since we know in advance when the $x^4$ terms will evaluate to 1 or -1.

However, we don’t yet have a nice trick to handle the lower powers of $x$. This will be the subject of upcoming chapters.

## Summary

Raising a $k$-th root of unity $\omega^s$ to the $k/2$ power results in 1 if $s$ is even and -1 if $s$ is odd. If we evaluate a polynomial on the $k$-th roots of unity, the terms with power $k/2$ can be automatically computed simply by knowing if the root of unity we are evaluating on is an even power or odd power. Therefore, it is desirable to factor the polynomial so that we maximize the amount of $x^{k/2}$ terms.

## Appendix — Proof that $(\omega^s)^{k/2}$ is 1 if $s$ is even and -1 if $s$  is odd for even $k$

$\omega^s$ and $\omega^{s+k/2}$ are additive inverses of each other. Since $\omega^0=1$ and $\omega^{0+k/2}=\omega^{k/2}$, $\omega^{k/2}$ must be the additive inverse of $1$ and hence $\omega^{k/2}\equiv-1$.

Now we take $\omega^{k/2}$ (which is -1) and raise it to $s$

$$
\left(\omega^{k/2}\right)^s
$$

Note that $(-1)^s$ can only be 1 or -1. Specifically, if $s$ is even, then $(-1)^s=1$ and if $s$ is odd, then $(-1)^s=-1$. Hence, if $s$ is even, the outcome of our expression is 1, and if $s$ is odd, then the outcome is -1.

Our expression can be rewritten as:

$$
\left(\omega^{k/2}\right)^s=\left(\omega^{(k/2)s}\right)=\left(\omega^{s(k/2)}\right)=\left(\omega^s\right)^{k/2}
$$

Since the algebraic identity of the expression has not changed, we can still say if $s$ is even, then $(\omega^s)^{k/2}=1$ and if $s$ is odd, $(\omega^s)^{k/2}=-1$.

Therefore, we have proved the original statement that $(\omega^s)^{k/2}=1$ when $s$ is even and $(\omega^s)^{k/2}=-1$ when $s$ is odd.
