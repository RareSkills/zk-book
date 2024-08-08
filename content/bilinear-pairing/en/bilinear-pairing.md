# Bilinear Pairings in Python, Solidity, and the EVM

Sometimes also called bilinear mappings, bilinear pairings allow us to take three numbers, $a$, $b$, and $c$, where $ab = c$, encrypt them to become $E(a)$, $E(b)$, $E(c)$, where $E$ is an encryption function, then send the two encrypted values to a verifier who can verify $E(a)E(b) = E(c)$ but not know the original values. We can use bilinear pairings to prove that a 3rd number is the product of the first two without knowing the first two original numbers.

We will explain bilinear pairings at a high level and provide some examples in Python.

## Prerequisites
- The reader should know what [point addition](https://www.rareskills.io/post/elliptic-curve-addition) and scalar multiplication are in the context of elliptic curves.
- The reader should also know the discrete logarithm problem in this context: a scalar multiplied by a point will result in another point, and it is infeasible in general to calculate the scalar given the elliptic curve point.
- The reader should know what a [finite field](rareskills.io/post/finite-fields) and cyclic group are, and what a generator is in the context of elliptic curves. We will refer to generators with the variable G.
- The reader should know about [Ethereum Precompiles](https://www.rareskills.io/post/solidity-precompiles).
We will use capital letters to denote EC (elliptic curve) points and lower case letters to denote elements of finite fields ("scalars"). When we say element, this could be an integer in a finite field or it could be a point on an elliptic curve. The context will make it clear.

It is possible to read this tutorial without fully understanding all of the above, but it will be harder to build a good intuition about this subject.

## How bilinear pairings work
When a scalar is multiplied by a point on an elliptic curve, another elliptic curve point is produced. That is $P = pG$ where $p$ is a scalar, and $G$ is the generator. Given $P$ and $G$ we cannot determine $p$.

Assume $pq = r$. What we are trying to do is take

$$
\begin{align*}
P = pG\\
Q = qG\\
R = rG\\
\end{align*}
$$

and convince a verifier that the discrete logs of $P$ and $Q$ multiply to produce the discrete log of $R$.

If $pq = r$, and $P = pG$, $Q = qG$, and $R = rG$, then we want a function such that

$$f(P,Q)=R$$

and not equal to $R$ when $pq ≠ r$. This should be true of all possible combinations of $p$, $q$, and $r$ in the group.

However, this is typically not how we express $R$ when using bilinear pairings. For reasons we will discuss later, it’s usually computed as

$$f(P,Q) = f(R,G)$$

$G$ is the generator point, and can be thought of as $1$. In this context. For example, $pG$ means we did $(G + G + … + G)$ $p$ times. $G$ just means we took $G$ and didn’t add anything. So in a sense, this is the same as saying $P 
\times Q = R \times 1$.

So our bilinear pairing is a function that if you plug in two elliptic curve points you get an output that *corresponds* to the product of the discrete logs of those two points.

### Notation
A bilinear pairing is usually written as $e(P, Q)$. Here, $e$ has nothing to do with the natural logarithm, and $P$ and $Q$ are elliptic curve points.

### Generalization, checking if two products are equal
Suppose someone gave us four elliptic curve points $P_1$, $P_2$, $Q_1$, and $Q_2$ and claimed that the discrete logs of $P_1$ and $P_2$ have the same product as $Q_1$ and $Q_2$, i.e. $p_1p_2 = q_1q_2$. Using a bilinear pairing, we can check if this is true without knowing $p_1$, $p_2$, $q_1$, or $q_2$. We simply do:

$$e(P_1, P_2) \stackrel{?}{=} e(Q_1, Q_2)$$

### What "bilinear" means
Bilinear means that if a function takes two arguments, and one of them is held constant, and the other varies, then the output linearly varies with the non-constant argument.

If $f(x,y)$ is bilinear, and $c$ is constant, then $z = f(x, c)$ varies linearly with $x$ and $z = f(c, y)$ varies linearly with $y$.

We can infer from this that an elliptic curve bilinear pairing has the following property:

$$
f(aG, bG) = f(abG, G) = f(G, abG)
$$

### What is $e(P, Q)$ returning?
To be honest, the output is so mathematically scary that it would be counterproductive to try to really explain it. This is why so much of the book earlier spent a lot of time explaining Groups, because it's exponentially easier to understand what a Group is than to understand what $e(P, Q)$ is returning.

The output of a bilinear pairing is a group element, specifically an element of a finite cyclic group.

**It's best to treat $e(P, Q)$ as a black box** similar to how most programmers treat hash functions like black boxes.

However, despite it being a black box, we still know a lot about the properties of the output, which we call $G_T$:

- $G_T$ is a cyclic group, so it has a closed binary operator.
- The binary operator of $G_T$ is associative.
- $G_T$ has an identity element.
- Each element in $G_T$ has an inverse.
- Because the group is cyclic, it has a generator.
- Because the group is cyclic and finite, then finite cyclic groups are homomorphic to $G_T$. That is, we have some way to homomorphically map elements in a finite field to elements in $G_T$.

Because the group is cyclic, we have a notion of $G_T$, $2G_T$, $3G_T$, and so forth. The binary operator of $G_T$ is roughly what we would call "multiplication" so $8G_T = 2G_T * 4G_T$.

If you really want to know what $G_T$ "looks like", it's a 12-Dimensional object. The identity element isn't so scary looking however:

$$(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)$$

## Symmetric and Asymmetric Groups
The above notation implies that we are using the same generator and elliptic curve group everywhere when we say

$$e(aG, bG) = e(abG, G)$$

In practice however, it turns out to be easier to create bilinear pairings when a different group (but same order) is different for both of the arguments. 

Specifically, we say

$$e(a, b) → c, \space\space a ∈ G_1, b ∈ G_2, c ∈ G_T$$

None of the groups used are the same.

However, the property we care about still holds.

$$e(aG_1, bG_2) = e(abG_1, G_2) = e(G_1, abG_2)$$

In the above equation, the group $G_T$ is not explicitly shown but that is the codomain (output space) of $e(G_1, G_2)$.

One could think of $G_1$ and $G_2$ being different elliptic curve equations with different parameters (but the same number of points) and that would be valid because those are different groups.

In a symmetric pairing, the same elliptic curve Group is used for both the arguments of the bilinear pairing function. This means that the generator and elliptic curve group used in both arguments is the same. In this case, the pairing function is often denoted as:

$$e(aG_1, bG_1) = e(abG_1, G_1) = e(G_1, abG_1)$$

In an asymmetric pairing, the arguments use different groups. For example, the first argument can use a different generator and elliptic curve group than the second argument. The pairing function can still satisfy the desired properties

$$e(aG_1, bG_2) = e(abG_1, G_2) = e(G_1, abG_2)$$

In practice we use asymmetric groups, and the difference between the groups we use is explained in the next section.

$G_1$ is the same group we talked about in previous chapters, and in the context of Ethereum, it's the same `G1` we import from the library:

```python
from py_ecc.bn128 import G1
```

We can also import the `G2` from the same library as:

```python
from py_ecc.bn128 import G1, G2
```

But what is $G_2$?

## Field Extensions and the `G2` point in Python
Bilinear pairings are rather agnostic to the kinds of groups you opt for, but Ethereum’s $G_2$ uses elliptic curves with field extensions. If you want to be able to read Solidity code that uses ZK-SNARKS, you’ll at least need a rough idea of what these are.

We usually think of EC points as two points $x$ and $y$. With *field extensions*, the $x$ and $y$ themselves become two-dimensional objects $(x, y)$ pairs. This is analogous to how complex numbers “extend” real numbers and turn them into something with 2 dimensions (a real component and an imaginary component).

A field extension is a very abstract concept, and frankly, the relationship between a field and its extension doesn’t matter from a purely functional concept.

Just think of it this way:

![Math meme about field extensions](https://static.wixstatic.com/media/935a00_19c62a78929f4cb28ee0e42a14e8ff85~mv2.png/v1/fill/w_861,h_574,al_c,lg_1,q_90,enc_auto/935a00_19c62a78929f4cb28ee0e42a14e8ff85~mv2.png)

An elliptic curve in $G_2$ is an elliptic curve where both the $x$ and $y$ element are two dimensional objects.

### The G2 point in Python
Enough theory, let’s code this and see a $G_2$ point. Install the `py_ecc` library as follows.

```bash
python -m pip install py_ecc
```

Now let’s import the functions that we need from this

```python
from py_ecc.bn128 import G1, G2, pairing, add, multiply, eq

print(G1)
# (1, 2)
print(G2)
#((10857046999023057135944570762232829481370756359578518086990519993285655852781, 11559732032986387107991004021392285783925812861821192530917403151452391805634), (8495653923123431417604973247489272438418190587263600148770280649306958101930, 4082367875863433681332203403145435568316851327593401208105741076214120093531))
```
If you look closely, you'll see the `G2`, you’ll see that `G2` is a pair of tuples. The first tuple is the two-dimensional $x$ point and the second tuple is the two-dimensional $y$ point.

`G1` and `G2` are the generator points for their respective groups.

Both `G1` and `G2` have the same order (number of points on the curve):
```python
from py_ecc.bn128 import G1, G2, eq, curve_order, multiply, eq, curve_order

x = 10 # chosen randomly
assert eq(multiply(G2, x + curve_order), multiply(G2, x))
assert eq(multiply(G1, x + curve_order), multiply(G1, x))
```

Even though `G2` points might seem a little strange, their behavior is the same as other cyclic groups, especially the `G1` group we are familiar with. This means we can construct other points with scalar multiplication (which is really repeated addition) as expected

```python
print(eq(add(G1, G1), multiply(G1, 2)))
# True
print(eq(add(G2, G2), multiply(G2, 2)))
# True
```
It should be obvious that you can only add elements from the same group.

```python
add(G1, G2) # TypeError
```

By the way, this library overrides some arithmetic operators (you can do that in python), meaning you can do the following:

```python
print(G1 + G1 + G1 == G1*3)
# True

# The above is the same as this:
eq(add(add(G1, G1), G1), multiply(G1, 3))
# True
```

## Bilinear Pairings in Python
At the beginning of this article, we said that bilinear pairings can be used to check if the discrete logs of $P$ and $Q$ multiply to produce the discrete log of $R$, i.e. $PQ = R$.

Here's how we can do that in Python:

```python
from py_ecc.bn128 import G1, G2, pairing, multiply, eq

P = multiply(G1, 3)
Q = multiply(G2, 8)

R = multiply(G1, 24)

assert eq(pairing(Q, R), pairing(G2, R))
```

Rather annoyingly, the library requires that you pass the `G2` point as the first argument to `pairing`.

### Equality of products
Also at the beginning of this article we said a pairing can check:

$$e(P_2, P_1) \stackrel{?}{=} e(Q_2, Q_1)$$

Here's how we can do that in Python:

```python
from py_ecc.bn128 import G1, G2, pairing, multiply, eq

P_1 = multiply(G1, 3)
P_2 = multiply(G2, 8)

Q_1 = multiply(G1, 6)
Q_2 = multiply(G2, 4)

assert eq(pairing(P_2, P_1), pairing(Q_2, Q_1))
```

### The binary operator of $G_T$
Elements in $G_T$ are combined using "multiplication" but keep in mind that this is actually a syntactic override in Python:

```python
from py_ecc.bn128 import G1, G2, pairing, multiply, eq

# 2 * 3 = 6
P_1 = multiply(G1, 2)
P_2 = multiply(G2, 3)

# 4 * 5 = 20
Q_1 = multiply(G1, 4)
Q_2 = multiply(G2, 5)

# 10 * 12 = 120 (6 * 20 = 120 also)
R_1 = multiply(G1, 13)
R_2 = multiply(G2, 2)

assert eq(pairing(P_2, P_1) * pairing(Q_2, Q_1), pairing(R_2, R_1))

# Fails!
```

But the assertion fails!

Elements in $G_T$ behave like "powers" of a base.

Recall from algebra that

$$b^xb^y = b^{x+y}$$

Suppose we generate an element in $G_T$ as $e(3G_2, 2G_1)$. We might think of the element as $6G_T$, but it would be a lot more helpful to think of it as $b^6G_T$. There's no need to know what $b$ is in this context, merely that it exists.

Therefore, to make our code from above work, change $R_1$ and $R_2$ to multiply to 26.

Our code is effectively computing:

$$
\begin{align*}
b ^ {2 \cdot 3} * b ^ {4 \cdot 5} = b ^ {13 \cdot 2}\\
b ^ 6 \cdot b ^ {20} = b ^ {26}
\end{align*}
$$


```python
from py_ecc.bn128 import G1, G2, pairing, multiply, eq

# 2 * 3 = 6
P_1 = multiply(G1, 2)
P_2 = multiply(G2, 3)

# 4 * 5 = 20
Q_1 = multiply(G1, 4)
Q_2 = multiply(G2, 5)

# 13 * 2 = 16 
R_1 = multiply(G1, 13)
R_2 = multiply(G2, 2)

# b ^ {2 * 3} * b ^ {4 * 5} = b ^ {13 * 2}
# b ^ 6 * b ^ 20 = b ^ 26

assert eq(pairing(P_2, P_1) * pairing(Q_2, Q_1), pairing(R_2, R_1))
```

## Bilinear Pairings in Ethereum
### EIP 197 Specification
The py_ecc library is actually maintained by the [Ethereum Foundation](https://ethereum.org/), and it is what powers the precompile at address 0x8 in the [PyEVM implementation](https://github.com/ethereum/py-evm).

The Ethereum precompile defined in [EIP-197](https://eips.ethereum.org/EIPS/eip-197) works on points in `G1` and `G2`, and *implicitly* works on points in $G_T$.

The specification of this precompile will seem a little weird at first. It takes in a list of G1 and G2 points laid out as follows:

`A₁B₁A₂B₂...AₙBₙ : Aᵢ ∈ G1, Bᵢ ∈ G2`

These were originally created as

```
A₁ = a₁G1
B₁ = b₁G2
A₂ = a₂G1
B₂ = b₂G2
...
Aₙ = aₙG1
Bₙ = bₙG2
```

The precompile returns 1 if the following is true

```
a₁b₁ + a₂b₂ + ... + aₙbₙ = 0
```

and zero otherwise.

This might be a bit of a head-scratcher at first! This seems to imply that the precompile is taking the discrete log of each of the points, which is accepted to be infeasible in general. Furthermore, why doesn’t it behave like pairing from the earlier Python examples? The earlier examples returned an element in $G_T$, but this precompile returns a boolean.

#### Justification for EIP 197 design decision
The first problem is that elements in $G_T$ are large, specifically, they 12-dimensional objects. 

This will take up a lot of space in memory leading to larger gas costs. Also, because of how most ZK verification algorithms work (this is outside the scope of this article), we generally don’t check the value of the output of a pairing, but only that it is equal to other pairings. Specifically, the final step in [Groth16](https://www.rareskills.io/post/groth16) (the zero knowledge algorithm used by tornado cash) looks like the following

$$
e(A₁, B₂) = e(α₁, β₂) + e(L₁, γ₂) + e(C₁, δ₂)
$$

Where each variable is an elliptic curve point of either $\mathbb{G}_1$ or $\mathbb{G}_2$ based on it's subscript notation (we would have used upper-case Greek letters to stay consistent with our notation, but those look too similar to the Latin alphabet).

The meanings of these variables is not important at this stage. The fact that it can be written as the sum of "products" (elliptic curve pairing) is what matters. Specifically, we can write it as

$$
0 = e(−A₁, B₂) + e(α₁, β₂) + e(L₁, γ₂) + e(C₁, δ₂)
$$

And now it matches the precompile specification perfectly!

It’s not just Groth16, most zk algorithm have verification formula that looks like that, which is why the precompile was designed to work with sums of pairings rather than return the value of a single pairing.

If we look at the verification code of [Tornado Cash](https://www.rareskills.io/post/how-does-tornado-cash-work), we can see it is exactly implementing this (even the Greek letters match, but don’t worry if you don’t understand it yet). The $\beta_2$ simply means it is a $\mathbb{G}_2$ point, $\alpha_1$ means $\mathbb{G}_1$ point, etc.

![annotation of the verification code in Tornado Cash](https://static.wixstatic.com/media/935a00_63f7afa2360e49a09139ed2de90189fc~mv2.png/v1/fill/w_1480,h_246,al_c,q_90,usm_0.66_1.00_0.01,enc_auto/935a00_63f7afa2360e49a09139ed2de90189fc~mv2.png)

Inside the pairing function is where the call to `address(8)` is done to complete the pairing calculation and determine if the proof if valid or not.

*Sometimes, the group $G_T$ is referred to as $G_{12}$ in the context of EIP 197.*

#### Sum of discrete logarithms
The key insight here is that if

$$ab + cd = 0$$

Then it must also be true that

$$A₁B₂ + C₁D₂ = 0₁₂ \space\space\space\space  A₁,C₁ ∈ G1, B₂,D₂ ∈ G2$$

in the $\mathbb{G}_{12}$ group.

The precompile isn’t actually computing the discrete logarithm, it’s simply checking if the sum of pairings is zero.

The sum of pairings is zero if and only if the sum of the products of the discrete logarithms is zero.


## End to End Solidity Example of Bilinear Pairings
Let us take these inputs of `a`, `b`, `c` and `d`.

```
a = 4
b = 3
c = 6
d = 2

-ab + cd = 0
```

Putting it into the formula we can get

$$
A₁B₂ + C₁D₂  = e(−aG1, bG2) + e(cG1, dG2) = 0
$$

In Python this will equate to

```python
from py_ecc.bn128 import neg, multiply, G1, G2
a = 4
b = 3
c = 6
d = 2
# negate G1 * a to make the equation sum up to 0

print(neg(multiply(G1, a)))
#(3010198690406615200373504922352659861758983907867017329644089018310584441462, 17861058253836152797273815394432013122766662423622084931972383889279925210507)
print(multiply(G2, b))
# ((2725019753478801796453339367788033689375851816420509565303521482350756874229, 7273165102799931111715871471550377909735733521218303035754523677688038059653), (2512659008974376214222774206987427162027254181373325676825515531566330959255, 957874124722006818841961785324909313781880061366718538693995380805373202866))
print(multiply(G1, c))
# (4503322228978077916651710446042370109107355802721800704639343137502100212473, 6132642251294427119375180147349983541569387941788025780665104001559216576968)
print(multiply(G2, d))
# ((18029695676650738226693292988307914797657423701064905010927197838374790804409, 14583779054894525174450323658765874724019480979794335525732096752006891875705), (2140229616977736810657479771656733941598412651537078903776637920509952744750, 11474861747383700316476719153975578001603231366361248090558603872215261634898))
```

Here’s the output in a structured format

```python
aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462,
aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507,

bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229,
bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653,
bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255,
bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866,

cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473,
cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968,

dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409,
dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705,
dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750,
dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898
```

Now we have the values encrypted into points in the $\mathbb{G}_1$ and $\mathbb{G}_2$ groups, someone else or a program can confirm that we computed $e(A_1,B_2)+e(C_1,D_2)=0$ correctly without knowing the individual values of `a`, `b`, `c`, or `d`. Here’s a Solidity contract that uses the ecPairing precompile to confirm that we computed the equations with valid values.

We create a file Pairings.sol to [unit test in Foundry](https://www.rareskills.io/post/foundry-testing-solidity) (we will supply the test file next)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Pairings {
    /** 
     *  returns true if == 0,
     *  returns false if != 0,
     *  reverts with "Wrong pairing" if invalid pairing
     */
     function run(uint256[12] memory input) public view returns (bool) {
        assembly {
            let success := staticcall(gas(), 0x08, input, 0x0180, input, 0x20)
            if success {
                return(input, 0x20)
            }
        }
        revert("Wrong pairing");
    }
}
```

We use this Foundry test file to deploy and call our Pairings contract to confirm our ecPairing calculation. The following file we call `TestPairings.sol`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/Pairings.sol";

contract PairingsTest is Test {
    Pairings public pairings;

    function setUp() public {
        pairings = new Pairings();
    }

    function testPairings() public view {
        uint256 aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462;
        uint256 aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507;

        uint256 bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
        uint256 bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
        uint256 bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
        uint256 bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

        uint256 cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473;
        uint256 cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968;

        uint256 dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
        uint256 dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
        uint256 dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
        uint256 dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

        uint256[12] memory points = [
            aG1_x,
            aG1_y,
            bG2_x2,
            bG2_x1,
            bG2_y2,
            bG2_y1,
            cG1_x,
            cG1_y,
            dG2_x2,
            dG2_x1,
            dG2_y2,
            dG2_y1
        ];

        bool x = pairings.run(points);
        console2.log("result:", x);
    }
}
```

**Note that the way G2 points are arranged is not the same way Python lays out the G2 points.**

This passes and prints out `true` to the console. Notice that the points have been labeled by their variable name, which group they belong to, and if they represent an `x` or a `y` of the elliptic curve point.

Its important to note that the ecPairing precompile does not expect or require an array and that our choice of using one with inline-assembly is simply optional. One could do the same with solidity like so:

```solidity
function run(bytes calldata input) public view returns (bool) {
    // optional, the precompile checks this too and reverts (with no error) if false, this helps narrow down possible errors
    if (input.length % 192 != 0) revert("Points must be a multiple of 6");
    (bool success, bytes memory data) = address(0x08).staticcall(input);
    if (success) return abi.decode(data, (bool));
    revert("Wrong pairing");
}
```

And update the test file like so:
```solidity
function testPairings() public view {
    uint256 aG1_x = 3010198690406615200373504922352659861758983907867017329644089018310584441462;
    uint256 aG1_y = 17861058253836152797273815394432013122766662423622084931972383889279925210507;

    uint256 bG2_x1 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
    uint256 bG2_x2 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
    uint256 bG2_y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;
    uint256 bG2_y2 = 957874124722006818841961785324909313781880061366718538693995380805373202866;

    uint256 cG1_x = 4503322228978077916651710446042370109107355802721800704639343137502100212473;
    uint256 cG1_y = 6132642251294427119375180147349983541569387941788025780665104001559216576968;

    uint256 dG2_x1 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
    uint256 dG2_x2 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
    uint256 dG2_y1 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
    uint256 dG2_y2 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

    bytes memory points = abi.encode(
        aG1_x,
        aG1_y,
        bG2_x2,
        bG2_x1,
        bG2_y2,
        bG2_y1,
        cG1_x,
        cG1_y,
        dG2_x2,
        dG2_x1,
        dG2_y2,
        dG2_y1
    );

    bool x = pairings.run(points);
    console2.log("result:", x);
}
```
This will pass and return true just like the initial implementation because it sends the exact same calldata to the precompile.

The only difference is that in the first implementation, the test file sends an array of points to the pairing contract which uses inline-assembly to slice off the first 32 bytes (array length) and sends the rest to the precompile. And in the second implementation, the test file sends the abi encoded points to the pairing contract which forwards it as it is to the precompile.

## Learn More from RareSkills
This material is taken from our [Zero Knowledge Course](https://www.rareskills.io/zk-bootcamp). Please see the program to learn more.

---
## I really want to understand the math behind bilinear pairings
You've been warned, the math is quite intense, and understanding it will not help you actually implement ZK Proofs, which is the goal of this book. You've probably used SHA-256 or Keccak256 productively without knowing their internals, and we *strongly* suggest you treat pairings the same way at this stage in your journey. Nevertheless, if you haven't been deterred by our warnings, here is a good resource if you still want to dive into it: [Pairings for Beginners](https://static1.squarespace.com/static/5fdbb09f31d71c1227082339/t/5ff394720493bd28278889c6/1609798774687/PairingsForBeginners.pdf). *Here be dragons.*

*Originally Published July 18, 2023*