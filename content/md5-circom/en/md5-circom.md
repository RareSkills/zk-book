# MD5 Hash In Circom

In this tutorial, we will implement the MD5 hash in Circom both to compute the hash and to constrain in Circom that it was computed correctly.

Although the MD5 hash function is not cryptographically secure (since collisions have been found), the mechanics are similar to cryptographically secure hash functions. 

Importantly, the MD5 hash function can be learned quickly. The following 14-minute video explains how the MD5 hash works. We recommend watching it first:

[https://www.youtube.com/watch?v=5MiMK45gkTY](https://www.youtube.com/watch?v=5MiMK45gkTY)

To create a proof that we know the preimage of the MD5 hash without revealing it, we need to prove we executed every step of the hash correctly and produced a certain result. This tutorial shows how to design the constraints for each state transition.

Specifically, the MD5 hash has the following subroutines:

- Bitwise AND, OR, NOT, and XOR
- LeftRotate
- Add 32-bit numbers and overflow at $2^{32}$
- The function `Func`, which combines registers `B`, `C`, and `D` together using bitwise operators
- The padding step at the beginning, which adds a 1 bit after the input and puts the length (in bits) of the input

Additionally, the output of MD5 is usually written as a 128-bit number in big-endian form. Suppose we have a 128-bit value `0x1234567890ABCDEF1122334455667788`

In big-endian, it would be written as:

```solidity
0x12   0x34   0x56   0x78   0x90   0xAB   0xCD   0xEF   0x11   0x22   0x33   0x44   0x55   0x66   0x77   0x88
```

In little-endian, it would be:

```solidity
0x88   0x77   0x66   0x55   0x44   0x33   0x22   0x11   0xEF   0xCD   0xAB   0x90   0x78   0x56   0x34   0x12
```

We will need a separate routine to reverse the order of the bytes from little endian to big endian. Most hash implementations output big endian, so to easily compare our result to established libraries, we want our implementation to output in big endian format. We will later create a `ToBytes` component for this.

Although there is a significant amount of array indexing, the index we use is deterministic based on the iteration of the hash, so there is no need for a Quin selector anywhere in the hash constraints — we can hardcode the array indexing.

## Building an MD5 prototype in Python

When building something as complex as a hash function, it is a good idea to build a reference implementation in a more familiar and easier-to-debug language such as Python, then translate the Python code to Circom.

Here is the Python implementation of MD5 (which only supports 448 bits of input for simplicity). This is heavily inspired by this [other implementation by Utkarsh87](https://github.com/Utkarsh87/md5-hashing). We have tried to make the functions behave “component-like,” so the translation to Circom is more straightforward.

Some implementation notes:

- Addition mod $2^{32}$ is done by adding the numbers and then calling the function `Overflow32()`.
- We accept the inputs as an array of bytes, not as an array of bits.
- The byte `0x80` looks like `10000000` in binary. This allows us to pad the input with a single bit at the end.
- The output is in big-endian format.

```python
s = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
     5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
     4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
     6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21]

K = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
     0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
     0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
     0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
     0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
     0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
     0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
     0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
     0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
     0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
     0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
     0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
     0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
     0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
     0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
     0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]

iter_to_index = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1, 6, 11, 0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, 5, 8, 11, 14, 1, 4, 7, 10, 13, 0, 3, 6, 9, 12, 15, 2, 0, 7, 14, 5, 12, 3, 10, 1, 8, 15, 6, 13, 4, 11, 2, 9]

def Overflow32(x):
    return x & 0xFFFFFFFF

def leftRotate(x, amount):
    #x &= 0xFFFFFFFF
    xo = Overflow32(x)
    return Overflow32((xo << amount | xo >> (32 -amount)))

def func(B, C, D, i):
    out = None

    # note that i will be 1..64 inclusive
    if i <= 16:
        out = (B & C) | (~B & D)

    elif i > 16 and i <= 32:
        out = (D & B) | (~D & C)

    elif i > 32 and i <= 48:
        out = B ^ C ^ D

    elif i > 48 and i <= 64:
        out = C ^ (B | ~D)

    else:
        assert False, "1) What"

    return out

# concatenates four bytes to become 32 bits
def To32BitWord(byte1, byte2, byte3, byte4):
    return byte1 + byte2 * 2**8 + byte3 * 2**16 + byte4 * 2**24

# length is the byte where the data stops
# so if we have zero bytes, we write 0x80
# to byte 0
def md5(bytes, length):
    data = bytearray(64)
    msg = bytearray(bytes, 'ascii')

    # 56 bytes, 64 is the max
    assert length < 56, "too long"

    if length < 56:
        data[length] = 0x80
        data[56] = (length * 8).to_bytes(1, byteorder='little')[0]
        for i in range(57,64):
            data[i] = 0x00

    for i in range(0, length):
        data[i] = msg[i]
        
    # data is a len 64 array of bytes. However, it will be much easier to work
    # on if we turn it into a len 16 array of 32 bit words
    data_32 = [0] * 16
    for i in range(0, 16):
        data_32[i] = To32BitWord(data[4*i], data[4*i + 1], data[4*i + 2], data[4*i + 3])

    # algo runs for 64 iterations with 4 registers, each using 32 bits
    # we allocate 65, because the 0th will be the default starting value
    buffer = [[0]*4 for _ in range(65)]

    buffer[0][0] = 0x67452301
    buffer[0][1] = 0xefcdab89
    buffer[0][2] = 0x98badcfe
    buffer[0][3] = 0x10325476

    A = 0
    B = 1
    C = 2
    D = 3
    for i in range(1, 65):

        F = func(buffer[i - 1][B], buffer[i - 1][C], buffer[i - 1][D], i)
        G = iter_to_index[i - 1]
        to_rotate = buffer[i-1][A] + F + K[i - 1] + data_32[iter_to_index[i - 1]]
        rotated = leftRotate(to_rotate, s[i - 1])
        new_B = Overflow32(buffer[i-1][B] + rotated)

        buffer[i][A] = buffer[i - 1][D]
        buffer[i][B] = new_B 
        buffer[i][C] = buffer[i - 1][B]
        buffer[i][D] = buffer[i - 1][C]

    final = [0,0,0,0]
    for i, b in enumerate(buffer[64]):
        final[i] = Overflow32((b + buffer[0][i]))

    digest = final[0] + final[1] * 2**32 + final[2] * 2**64 + final[3] * 2**96

    raw = digest.to_bytes(16, byteorder='little')
    return int.from_bytes(raw, byteorder='big')
 

print(hex(md5("RareSkills", 10)))

```

## Prerequisite Components

### Overflow32

Overflow32 emulates a 32-bit overflow in a VM that happens at $2^{32}$:

```jsx
template Overflow32() {
    signal input in;
    signal output out;

    component n2b = Num2Bits(252);
    component b2n = Bits2Num(32);

    n2b.in <== in;
    for (var i = 0; i < 32; i++) {
        n2b.out[i] ==> b2n.in[i];
    }

    b2n.out ==> out;
}
```

## LeftRotate

LeftRotate rotates the bits as if they are in a circular buffer:

```jsx
template LeftRotate(s) {
    signal input in;
    signal output out;

    component n2b = Num2Bits(32);
    component b2n = Bits2Num(32);

    n2b.in <== in;

    for (var i = 0; i < 32; i++) {
        b2n.in[(i + s) % 32] <== n2b.out[i];
    }

    out <== b2n.out;
}
```

## Bitwise AND, OR, XOR, and NOT

The following templates were built in our tutorial on 32-bit emulation:

```jsx
template BitwiseAnd32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Ands[32];
    for (var i = 0; i < 32; i++) {
        Ands[i] = AND();
        Ands[i].a <== n2ba.out[i];
        Ands[i].b <== n2bb.out[i];
        Ands[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseOr32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Ors[32];
    for (var i = 0; i < 32; i++) {
        Ors[i] = OR();
        Ors[i].a <== n2ba.out[i];
        Ors[i].b <== n2bb.out[i];
        Ors[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseXor32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Xors[32];
    for (var i = 0; i < 32; i++) {
        Xors[i] = XOR();
        Xors[i].a <== n2ba.out[i];
        Xors[i].b <== n2bb.out[i];
        Xors[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseNot32() {
    signal input in;
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    n2ba.in <== in;

    component b2n = Bits2Num(32);
    component Nots[32];
    for (var i = 0; i < 32; i++) {
        Nots[i] = NOT();
        Nots[i].in <== n2ba.out[i];
        Nots[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}
```

### Func

Func takes registers `B`, `C` and `D` and combines them into a single output — and that combination depends on which iteration we are on:

```jsx
template Func(i) {
    assert(i <= 64);
    signal input b;
    signal input c;
    signal input d;

    signal output out;

    if (i <= 16) {
        signal bAndc;
        component a1 = BitwiseAnd32();
        a1.in[0] <== b;
        a1.in[1] <== c;

        component a2 = BitwiseAnd32();
        component n1 = BitwiseNot32();
        n1.in <== b;
        a2.in[0] <== n1.out;
        a2.in[1] <== d;

        component o1 = BitwiseOr32();
        o1.in[0] <== a1.out;
        o1.in[1] <== a2.out;

        out <== o1.out;
    }
    else if (i > 16 && i <= 32) {
        component a1 = BitwiseAnd32();
        a1.in[0] <== d;
        a1.in[1] <== b;

        component n1 = BitwiseNot32();
        n1.in <== d;
        component a2 = BitwiseAnd32();
        a2.in[0] <== n1.out;
        a2.in[1] <== c;

        component o1 = BitwiseOr32();
        o1.in[0] <== a1.out;
        o1.in[1] <== a2.out;

        out <== o1.out;
    }
    else if (i > 32 && i <= 48) {
        component x1 = BitwiseXor32();
        component x2 = BitwiseXor32();

        x1.in[0] <== b;
        x1.in[1] <== c;
        x2.in[0] <== x1.out;
        x2.in[1] <== d;

        out <== x2.out;
    }
    // i must be <= 64 by the assert
    // statement above
    else {
        component o1 = BitwiseOr32();
        component n1 = BitwiseNot32();
        n1.in <== d;
        o1.in[0] <== n1.out;
        o1.in[1] <== b;

        component x1 = BitwiseXor32();
        x1.in[0] <== o1.out;
        x1.in[1] <==c;

        out <== x1.out;
    }

```

### Input padding

To simplify, our hash function accepts an array of bytes as input, not an array of bits. Furthermore, we limit the input length to 56 bytes so that we can hardcode inserting the length at byte index 56 of the 64 bytes (512 bit) input the hash uses.

Since the input will be at most 56 bytes large, the number we must use for the length won’t be more than 448 bits, which requires at most 2 bytes to store.

```jsx
// n is the number of bytes
template Padding(n) {
    // 56 bytes = 448 bits
    assert(n < 56);

    signal input in[n];

    // 64 bytes = 512 bits
    signal output out[64];

    for (var i = 0; i < n; i++) {
        out[i] <== in[i];
    }

    // add 128 = 0x80 to pad the 1 bit (0x80 = 10000000b)
    out[n] <== 128;

    // pad the rest with zeros
    for (var i = n + 1; i < 56; i++) {
        out[i] <== 0;
    }

    var lenBits = n * 8;
    if (lenBits < 256) {
        out[56] <== lenBits;
    }
    else {
        var lowOrderBytes = lenBits % 256;
        var highOrderBytes = lenBits \ 256;
        out[56] <== lowOrderBytes;
        out[57] <== highOrderBytes;
    }
}
```

## Num2Bytes

To change the endianness we need to turn a signal `in` into an array of bytes `out`:

```jsx
// n is the number of bytes
template ToBytes(n) {
    signal input in;
    signal output out[n];

    component n2b = Num2Bits(n * 8);
    n2b.in <== in;

    component b2ns[n];
    for (var i = 0; i < n; i++) {
        b2ns[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            b2ns[i].in[j] <== n2b.out[8*i + j];
        }
        out[i] <== b2ns[i].out;
    }
}
```

## Final Solution

The code below combines all the components together to perform the MD5 hash. It also converts the result to big-endian form. The reader can test the code in [zkrepl](https://zkrepl.dev).

```jsx
include "circomlib/bitify.circom";
include "circomlib/gates.circom";

template BitwiseAnd32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Ands[32];
    for (var i = 0; i < 32; i++) {
        Ands[i] = AND();
        Ands[i].a <== n2ba.out[i];
        Ands[i].b <== n2bb.out[i];
        Ands[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseOr32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Ors[32];
    for (var i = 0; i < 32; i++) {
        Ors[i] = OR();
        Ors[i].a <== n2ba.out[i];
        Ors[i].b <== n2bb.out[i];
        Ors[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseXor32() {
    signal input in[2];
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    component n2bb = Num2Bits(32);
    n2ba.in <== in[0];
    n2bb.in <== in[1];

    component b2n = Bits2Num(32);
    component Xors[32];
    for (var i = 0; i < 32; i++) {
        Xors[i] = XOR();
        Xors[i].a <== n2ba.out[i];
        Xors[i].b <== n2bb.out[i];
        Xors[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template BitwiseNot32() {
    signal input in;
    signal output out;

    // range check
    component n2ba = Num2Bits(32);
    n2ba.in <== in;

    component b2n = Bits2Num(32);
    component Nots[32];
    for (var i = 0; i < 32; i++) {
        Nots[i] = NOT();
        Nots[i].in <== n2ba.out[i];
        Nots[i].out ==> b2n.in[i];
    }

    b2n.out ==> out;
}

// n is the number of bytes
template ToBytes(n) {
    signal input in;
    signal output out[n];

    component n2b = Num2Bits(n * 8);
    n2b.in <== in;

    component b2ns[n];
    for (var i = 0; i < n; i++) {
        b2ns[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            b2ns[i].in[j] <== n2b.out[8*i + j];
        }
        out[i] <== b2ns[i].out;
    }
}

// n is the number of bytes
template Padding(n) {
    // 56 bytes = 448 bits
    assert(n < 56);

    signal input in[n];

    // 64 bytes = 512 bits
    signal output out[64];

    for (var i = 0; i < n; i++) {
        out[i] <== in[i];
    }

    // add 128 = 0x80 to pad the 1 bit (0x80 = 10000000b)
    out[n] <== 128;

    // pad the rest with zeros
    for (var i = n + 1; i < 56; i++) {
        out[i] <== 0;
    }

    var lenBits = n * 8;
    if (lenBits < 256) {
        out[56] <== lenBits;
    }
    else {
        var lowOrderBytes = lenBits % 256;
        var highOrderBytes = lenBits \ 256;
        out[56] <== lowOrderBytes;
        out[57] <== highOrderBytes;
    }
}
template Overflow32() {
    signal input in;
    signal output out;

    component n2b = Num2Bits(252);
    component b2n = Bits2Num(32);

    n2b.in <== in;
    for (var i = 0; i < 32; i++) {
        n2b.out[i] ==> b2n.in[i];
    }

    b2n.out ==> out;
}

template LeftRotate(s) {
    signal input in;
    signal output out;

    component n2b = Num2Bits(32);
    component b2n = Bits2Num(32);

    n2b.in <== in;

    for (var i = 0; i < 32; i++) {
        b2n.in[(i + s) % 32] <== n2b.out[i];
    }

    out <== b2n.out;
}

template Func(i) {
    assert(i <= 64);
    signal input b;
    signal input c;
    signal input d;

    signal output out;

    if (i < 16) {
        component a1 = BitwiseAnd32();
        a1.in[0] <== b;
        a1.in[1] <== c;

        component a2 = BitwiseAnd32();
        component n1 = BitwiseNot32();
        n1.in <== b;
        a2.in[0] <== n1.out;
        a2.in[1] <== d;

        component o1 = BitwiseOr32();
        o1.in[0] <== a1.out;
        o1.in[1] <== a2.out;

        out <== o1.out;
    }
    else if (i >= 16 && i < 32) {
        // (D & B) | (~D & C)
        component a1 = BitwiseAnd32();
        a1.in[0] <== d;
        a1.in[1] <== b;

        component n1 = BitwiseNot32();
        n1.in <== d;
        component a2 = BitwiseAnd32();
        a2.in[0] <== n1.out;
        a2.in[1] <== c;

        component o1 = BitwiseOr32();
        o1.in[0] <== a1.out;
        o1.in[1] <== a2.out;

        out <== o1.out;
    }
    else if (i >= 32 && i < 48) {
        component x1 = BitwiseXor32();
        component x2 = BitwiseXor32();

        x1.in[0] <== b;
        x1.in[1] <== c;
        x2.in[0] <== x1.out;
        x2.in[1] <== d;

        out <== x2.out;
    }
    // i must be < 64 by the assert statement above
    else {
        component o1 = BitwiseOr32();
        component n1 = BitwiseNot32();
        n1.in <== d;
        o1.in[0] <== n1.out;
        o1.in[1] <== b;

        component x1 = BitwiseXor32();
        x1.in[0] <== o1.out;
        x1.in[1] <==c;

        out <== x1.out;
    }
}

// n is the number of bytes
template MD5(n) {

    var s[64] = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
     5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
     4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21];

    var K[64] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
     0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
     0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
     0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
     0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
     0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
     0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
     0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
     0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
     0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
     0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
     0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
     0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
     0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
     0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
     0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391];

    var iter_to_index[64] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
     1, 6, 11, 0, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12,
     5, 8, 11, 14, 1, 4, 7, 10, 13, 0, 3, 6, 9, 12, 15, 2,
    0, 7, 14, 5, 12, 3, 10, 1, 8, 15, 6, 13, 4, 11, 2, 9];

    signal input in[n];

    signal inp[64];
    component Pad = Padding(n);

    for (var i = 0; i < n; i++) {
        Pad.in[i] <== in[i];
    }
    for (var i = 0; i < 64; i++) {
        Pad.out[i] ==> inp[i];
    }

    signal data32[16];
    for (var i = 0; i < 16; i++) {
        data32[i] <== inp[4 * i] + inp[4 * i + 1] * 2**8 + inp[4 * i + 2] * 2**16 + inp[4 * i + 3] * 2**24;
    }

    var A = 0;
    var B = 1;
    var C = 2;
    var D = 3;
    signal buffer[65][4];
    buffer[0][A] <== 1732584193;
    buffer[0][B] <== 4023233417;
    buffer[0][C] <== 2562383102;
    buffer[0][D] <== 271733878;

    component Funcs[64];
    signal toRotates[64];
    component SelectInputWords[64];
    component LeftRotates[64];
    component Overflow32s[64];
    component Overflow32s2[64];
    for (var i = 0; i < 64; i++) {
        Funcs[i] = Func(i);
        Funcs[i].b <== buffer[i][B];
        Funcs[i].c <== buffer[i][C];
        Funcs[i].d <== buffer[i][D];
        
        Overflow32s[i] = Overflow32();
        Overflow32s[i].in <== buffer[i][A] + Funcs[i].out + K[i] + data32[iter_to_index[i]];
        
        // rotated = rotate(to_rotate, s[i])
        toRotates[i] <== Overflow32s[i].out;
        LeftRotates[i] = LeftRotate(s[i]);
        LeftRotates[i].in <== toRotates[i];

        // new_B = rotated + B
        Overflow32s2[i] = Overflow32();
        Overflow32s2[i].in <== LeftRotates[i].out + buffer[i][B];

        // store into the next state
        buffer[i + 1][A] <== buffer[i][D];
        buffer[i + 1][B] <== Overflow32s2[i].out;
        buffer[i + 1][C] <== buffer[i][B];
        buffer[i + 1][D] <== buffer[i][C];
    }

    component addA = Overflow32();
    component addB = Overflow32();
    component addC = Overflow32();
    component addD = Overflow32();

    // we hardcode initial state because we only
    // process one 512 bit block
    addA.in <== 1732584193 + buffer[64][A];
    addB.in <== 4023233417 + buffer[64][B];
    addC.in <== 2562383102 + buffer[64][C];
    addD.in <== 271733878 + buffer[64][D];

    signal littleEndianMd5;
    littleEndianMd5 <== addA.out + addB.out * 2**32 + addC.out * 2**64 + addD.out * 2**96;

    // convert the answer to bytes and reverse
    // the bytes order to make it big endian
    component Tb = ToBytes(16);
    Tb.in <== littleEndianMd5;

    // sum the bytes in reverse
    var acc;
    for (var i = 0; i < 16; i++) {
        acc += Tb.out[15 - i] * 2**(i * 8);
    }
    signal output out;
    out <== acc;
}

component main = MD5(10);

// The result out = 
// "RareSkills" in ascii to decimal
/* INPUT = {"in": [82, 97, 114, 101, 83, 107, 105, 108, 108, 115]} */

// The result is 246193259845151292174181299259247598493

// The MD5 hash of "RareSkills" is 0xb93718dd21d2f5081239d7a16cf69b9d when converted to decimal is 246193259845151292174181299259247598493
```

## Motivation for ZK-friendly hashes

The [R1CS](https://www.rareskills.io/post/rank-1-constraint-system) produced by the code above is over fifty-two thousand rows long, as highlighted in the figure below. There are a lot of opportunities to reduce the size of the circuit, especially by not converting the field elements to 32-bit arrays every time we use them.

![Screenshot showing how many constraints are created](https://pub-32882f615aa84e4a94e1279ccf3ab85a.r2.dev/Md5-circom/md5-constraints.png)

However, each word in an MD5 (and other modern hashes) is 32 bits, so it will take 32 times as many signals to represent compared to regular code.

In the following chapter, we will learn about hashes that operate on the native finite field rather than on 32-bit words and avoid costly operations like XOR, which require decomposing signals into bits.