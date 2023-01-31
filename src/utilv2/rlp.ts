/*
We want to make an RLP type-safe codec. To simplify things, an RLP item is
either a Buffer or an array of RLP items. The base codec can be focused on just
those two things. However, we can make a few more complex codecs based on
BufferLike objects, including
- string (utf8)
- Hex (custom type)
- Base64 (custom type)
- number (via bigint)
- bigint

The codec could look something like this
const codec = Rlp.Tuple([Rlp.String, Rlp.Hex, Rlp.Array(Rlp.number)])
*/

type RlpItem = Buffer | RlpItem[]

console.log(BigInt("0x1224"))
