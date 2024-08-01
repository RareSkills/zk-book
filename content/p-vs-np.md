# P vs NP and its application to zero knowledge proofs

The P = NP problem asks: “If we can quickly verify a solution to a problem is correct, can we also quickly compute the solution?” Most researchers believe the answer is no, i.e., P ≠ NP.

By understanding the P vs NP problem, we can see how Zero Knowledge Proofs (ZKPs) fit into the larger field of computer science and comprehend what ZKPs can and cannot do.


It is far easier to “get” Zero Knowledge Proofs by relating them to the P vs NP problem.

This tutorial has three parts:

It is far easier to “get” Zero Knowledge Proofs by relating them to the P vs NP problem.

This tutorial has three parts:
1. Explaining the P vs NP problem
2. Expressing problems and solutions as a Boolean formula
3. P vs NP and how they relate to Zero Knowledge Proofs

## Prerequisites
We assume the reader is familiar with time complexity and big $\mathcal{O}$ notation.

We say an algorithm takes polynomial time if it runs in $\mathcal{O}(nᶜ)$ time or better, where $n$ is the size of the input and $c$ is a constant. We may refer to algorithms that run in polynomial time or faster as *efficient algorithms* because their running time doesn't grow too quickly with the input size.

We say an algorithm takes *exponential time* or is *expensive* if it runs in $\mathcal{O}(cⁿ)$ where $c$ is a constant greater than 1 and $n$ is the size of the problem because the algorithm becomes exponentially slow as the problem size increases.

## Part 1: Explaining the P vs NP problem
### Problems in P are problems that are easy to solve and easy to verify solutions for

Problems that can be solved in polynomial time and whose solutions can verified in polynomial time are called problems in P.

Here are some example problems that are easy to compute and verify solutions for. These tasks might be performed by different parties, one doing the computation and another checking the results are valid:

#### P Example 1: Sorting a list
We can efficiently sort a list, and we can efficiently verify that a list is sorted.
- **Solving:** Sorting the list takes $\mathcal{O}(n \log n)$ time (for example, using mergesort), which is polynomial time. Although $n \log n$ is not a polynomial, we know that $\log n < n$ and therefore $(n \log n) < n²$, so our algorithm’s running time is bounded above by some polynomial, which is the requirement for “polynomial time.”

- **Verifying:** We can verify the list is sorted by traversing the list and checking that each item is greater than its left neighbor, which would take $\mathcal{O}(n)$ time.

#### P Example 2: Returning the index of a number in a list, if it occurs in the list
We can efficiently search to see if a number is in a list and then even more efficiently verify that number is present if we know the index it is in.

- **Solving:** For example, given the list `[8, 2, 1, 6, 7, 3]`, we need $\mathcal{O}(n)$ time to determine if the number `7` is in the list.

- **Verifying:** But if we give you the list and say 7 is in index 4, you can verify the number is in the list at that position in $\mathcal{O}(1)$ time. Searching for an item, if we aren’t told its position, takes $\mathcal{O}(n)$ time in the general case since we have to search through the list. If we’re told the supposed location of the item, it takes $\mathcal{O}(1)$ time to verify the item is, in fact, in the list at that location.

#### P Example 3: Determining if two nodes in a graph are connected
We can efficiently determine if two nodes in a graph are connected by using breadth-first search — start at a node, then visit all of its neighbors except nodes we’ve already visited, then search the neighbors of the neighbors, and so forth.

- **Solving:** Discovering the path between nodes using breadth-first search will take $\mathcal{O}(n + e)$ time, where n is the number of nodes in the graph and e is the number of edges. The number of edges e cannot exceed n², so we can treat $\mathcal{O}(n + e)$ as $\mathcal{O}(n²)$ in the worst case.

- **Verifying:** We can verify the proposed path is valid in $\mathcal{O}(n)$ time simply by following the proposed path to see if the two points really are connected by that path.

**In all the examples above, both computing and verifying the solution can be done in polynomial time.**

### The Witness
A *witness* in computer science is proof that you solved the problem correctly. In the examples above, the witness is the correct answer to the problem. For the examples above, these are things we could use as a witness:
1. The sorted list
2. The index where a number appears in the list
3. The path between two nodes in a graph

We will see later that a witness does not necessarily have to be the solution to the original problem. It could also be a solution for an alternative representation of the same problem.

## Problems in PSPACE: Not all problems have solutions that can be efficiently verified
Problems that require exponential resources to solve and verify are called problems in PSPACE. The reason they are called PSPACE is because although they might take exponential time to solve, they don’t require exponential memory space to run the search.

This class of problems has been researched extensively, yet no efficient algorithm to solve them has been discovered. Many researchers believe no efficient algorithm to solve these problems exists at all. If an efficient solution to these problems could be discovered, it would also be possible to reuse the algorithm to break all modern encryption and fundamentally alter computing as we know it.

Despite significant incentives for finding efficient solutions to these problems, evidence suggests such solutions likely do not exist. These problems are so challenging you cannot provide easily verifiable proof (witness) even if you solve them correctly.

### Examples of problems in PSPACE
#### PSPACE Example 1: Finding the optimal Chess move
![Image of a chess board](https://static.wixstatic.com/media/935a00_71d5fe7538a847ccaef0c82b5bea6b57~mv2.jpeg/v1/fill/w_720,h_720,al_c,q_85,enc_auto/935a00_71d5fe7538a847ccaef0c82b5bea6b57~mv2.jpeg)

Suppose we ask a powerful computer, "Given this chess board with the pieces in this position, what is the optimal next move?"

The computer responds with "move the black pawn on f4 to f3."

How can you trust the computer is giving you the correct answer?

There is no efficient way to check—you must do the same work the computer did. This involves doing a full search through all possible future board states. There’s no witness the computer could provide us that would allow us to confirm that "move the pawn on e3 to e4" is actually the next best move. In this way, the nature of this problem is very different from the examples in the previously discussed: we cannot efficiently verify that the claimed optimal move is the true optimal move.

In this example, the "witness" presented by the computer consists of all potential future game states. However, the massive volume of this data makes it practically impossible to verify the accuracy of the solution efficiently.

#### PSPACE Example 2: Determining if regexes (regular expressions) are equivalent
The two regexes, `a+` and `aa*`, match the same strings. If a string matches the first regex, it will also match the second, and vice versa.

However, checking if two *arbitrary* regexes are equivalent takes exponential time to compute. Even if a powerful computer told you they match the same strings, there is no short proof (witness) the computer can give you to show the answers are correct. Similar to the chess example, you’d have to search a very large space of strings to check if the regexes are equivalent, and that will take exponential time.

Both Chess and Regex equivalence have a common characteristic in that they both require exponential resources to find answers and exponential resources to verify the answers.

### Problems even more computationally intensive than PSPACE
There are problems that are so difficult that they require exponential time and exponential memory to solve, but those problems are usually theoretical and don’t frequently show up in the real world.

An example of such a problem is Checkers with a rule that pieces can never move into a position that recreates an earlier board state. In order to ensure we don’t repeat a board state for a game as we explore the space of possible moves, we have to keep track of all the board states that have already been visited. Since the length of the game can be exponential in the board size, the memory requirements are also exponential.

## Problems in NP: Some problems can be quickly verified but not quickly computed
If we can quickly verify the solution to a problem, then the problem is in NP. However, finding the solution might require exponential resources.

Any problem whose proposed solution (witness) can be quickly verified as correct is an NP problem. If the problem also has an algorithm for finding the solution in polynomial time, then it is a P problem. All P problems are NP problems, but it is extremely unlikely that all NP problems are also P problems.
    
Examples of problems in NP:
- Computing the solution to a Sudoku puzzle — verifying the proposed solution to a Sudoku puzzle.
- Computing the 3-coloring of a map (if it exists) — verifying a proposed 3-coloring of a map.
- Finding an assignment to Boolean formula that results in true — verifying the proposed assignment causes the formula to result in true.

**Note:** NP stands for non-deterministic polynomial. We won’t get into the jargon about where that name came from; we’re just giving the name so the reader doesn’t mistakenly think it stands for “not polynomial time.”

### Examples of problems in NP
#### NP Example 1: Sudoku
In the game Sudoku, a player is given a 9x9 grid with some numbers filled in. The goal is for the player to fill in the rest of the grid with numbers 1-9 such that no number occurs more than once in any row, column, or 3x3 box (the ones outlined by bold lines). The following images from [Wikipedia](https://en.wikipedia.org/wiki/Sudoku) illustrate this. In the first image, we see the 9x9 grid as given to the player. In the second image, we see the player’s solution.

![An incomplete sudoku puzzle](https://static.wixstatic.com/media/935a00_697037a2589d4091a95a9123d3796b4c~mv2.png/v1/fill/w_600,h_600,al_c,lg_1,q_85,enc_auto/935a00_697037a2589d4091a95a9123d3796b4c~mv2.png)

![A completed sudoku puzzle](https://static.wixstatic.com/media/935a00_2b17812514524ee584f0d9e7c340c73f~mv2.png/v1/fill/w_600,h_600,al_c,lg_1,q_85,enc_auto/935a00_2b17812514524ee584f0d9e7c340c73f~mv2.png)

Given a Sudoku puzzle *solution*, we can quickly verify the solution is correct simply by looping over the columns, rows, and 3x3 subgrids. The witness can be verified in polynomial time.

However, *computing* the solution requires significantly more resources — there are an exponential number of combinations to search. For a 9x9 grid, this is not difficult for a computer. But suppose, instead, we allowed the Sudoku puzzle to be arbitrarily large: each side has size $n$, where $n$ is a multiple of 9. In that case, the difficulty of searching for the solution grows exponentially with $n$.

#### NP Example 2: Three-coloring a map
Any 2D map of territories can be “colored” with four colors (see the [four color theorem](https://en.wikipedia.org/wiki/Four_color_theorem)). That is, we can assign a unique color (one of four colors) to each territory such that no neighboring territories share the same color. For example, the following image (from [Wikipedia](https://en.wikipedia.org/wiki/U.S._state#/media/File:Map_of_USA_with_state_names_2.svg)) shows the United States properly colored with four colors: pink, green, yellow, and red. Take a moment to scan the map and see for yourself that no two touching states have been given the same color:

![A map of the United States colored with four colors](https://static.wixstatic.com/media/935a00_80bcbb69d39348819f674827b8c25691~mv2.png/v1/fill/w_400,h_246,al_c,lg_1,q_85,enc_auto/935a00_80bcbb69d39348819f674827b8c25691~mv2.png)

The three coloring question asks if a map can be colored with three colors instead of four. Discovering a three-coloring (if it exists) is a computationally intensive search problem. However, verifying a *proposed* 3-coloring is easy: loop through each of the regions and check that the colors of the neighbors don’t match the proposed color of the territory currently being checked.

It turns out it is not possible to 3-color the United States.

The reasons a particular map cannot be 3 colored vary, but in the case of the United States, Nevada (the <span style="color:red">red</span> region in the map below) is surrounded by five territories. We pick the first color for Nevada, then we must alternate the neighbors' colors around Nevada. However, when we finish circling the neighbors of Nevada, we will end up with a territory having neighbors with three colors on its boundaries, leaving no valid color for the uncolored territory.

![A map showing Nevada and the surrounding states](https://static.wixstatic.com/media/935a00_5ddfcf6c6b0f4920bdb3624fbab031d9~mv2.jpg/v1/fill/w_898,h_674,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/935a00_5ddfcf6c6b0f4920bdb3624fbab031d9~mv2.jpg)

Here is a [quick and interesting video about 3-coloring maps](https://www.youtube.com/watch?v=WlcXoz6tn4g) if you want to learn more about this problem.

However, it is possible to 3-color Australia:
![A 3 Coloring of Australia](https://static.wixstatic.com/media/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg/v1/fill/w_696,h_628,al_c,lg_1,q_85,enc_auto/935a00_d8396ac3cd15406281b6c83deb2abc71~mv2.jpg)

Not all maps can be three-colored. Computing a three-coloring for an arbitrary 2D map, if it exists, cannot be done efficiently—a brute-force search that may take exponential time is required.

However, if someone solves a three-coloring, it is easy to verify their solution.

## The relationship between P, NP, and PSPACE
### Computational resources for each class
The table below summarizes the computational resources required for each class of problem:


| Category | Compute Time | Polynomial Verification Time |
| --- | --- | --- |
| P | Must be polynomial or better | Must be polynomial or better
| NP | No Requirement | Must be polynomial or better |
| PSPACE | No Requirement | No Requirement |

### Hierarchy of Difficulty between P, NP, and PSPACE
Any problem that requires exponential resources to verify the witness for is a PSPACE (or harder problem). If one has exponential resources to verify witnesses for PSPACE problems, they can trivially compute solutions for any P or NP problem. Therefore, all P and NP problems are a subset of PSPACE problems, as illustrated in the figure below.

That is, if you have a powerful enough computer to solve or verify a class of problem in the larger circle, you can solve or verify subset of it:

![Hierarchy of computation complexity classes](https://static.wixstatic.com/media/935a00_9a3130175f2945eb8ae7a4d975b36f55~mv2.jpg/v1/fill/w_1022,h_766,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/935a00_9a3130175f2945eb8ae7a4d975b36f55~mv2.jpg)

## The P vs NP problem
P is the class of problems that can be solved and verified efficiently, while NP is the class of problems that can be verified efficiently. The "P vs NP" question asks, simply, whether these two sets are the same.

If P = NP, it would mean that whenever we can find an efficient method for verifying a solution, we can also find an efficient method for finding that solution. Remember that finding a solution is always at least as hard as verifying it. (By definition, solving means finding the correct answer, so an algorithm that solves the problem is also effectively verifying its answer at the same time).

If P = NP is true, that means an efficient algorithm for computing Sudoku puzzles (of arbitrary size) and finding three coloring exists. It also means there is an efficient algorithm to break most modern cryptography algorithms.


Currently, it remains uncertain whether P and NP are the same set. Although numerous attempts have been made to find efficient solution algorithms for NP problems, there is a lack of evidence proving or disproving the existence of such algorithms.


Similarly, whether efficient solutions or verification mechanisms exist for PSPACE problems remains open. While researchers widely speculate that P ≠ NP and NP ≠ PSPACE, no formal mathematical proof exists for these conclusions. Therefore, despite extensive efforts, efficient solutions for NP problems and efficient verification methods for PSPACE problems remain undiscovered.

For practical purposes, we can assume P ≠ NP and NP ≠ PSPACE. In fact, we implicitly make that assumption when we trust important data to modern cryptography algorithms.