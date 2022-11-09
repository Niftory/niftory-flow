interface Serializable<T> {
  toB: (obj: T) => Buffer
}

interface PublicKey {}

interface PrivateKey {}

interface KeyPair {
  public: PublicKey
  private: PrivateKey
}

interface Crypto {
  generateKeyPair: () => KeyPair
}
