import { ec } from 'elliptic'

// Get P-256 Public key from private key using nodejs crypto library
const p256 = new ec('p256')

const key = p256.keyFromPrivate(
  '418acca4607d4a220009623d5d4f392b0e1511a3cca422cbd54ae817a0f65f69',
)

console.log(key.getPublic().encode('hex', false))

console.log(key.getPublic().getX().toString('hex'))
