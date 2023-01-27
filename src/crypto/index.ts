import {
  Elliptic as Elliptic_,
  EllipticAlgorithm,
  Signer as Signer_,
} from "./elliptic"
import { Hasher as Hasher_, Hashers as Hashers_ } from "./hashers"

namespace Crypto {
  export const Hashers = Hashers_
  export const Elliptic = Elliptic_
  export type Elliptic = EllipticAlgorithm
  export type Hasher = Hasher_
  export type Signer = Signer_
}

export { Crypto }
