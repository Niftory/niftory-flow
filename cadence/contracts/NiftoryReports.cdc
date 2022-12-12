pub contract NiftoryReports {

  pub struct PublicCapability {
    pub let path: PublicPath
    pub let type: Type

    init(path: PublicPath, type: Type) {
      self.path = path
      self.type = type
    }
  }

  pub struct PrivateCapability {
    pub let path: PrivatePath
    pub let type: Type

    init(path: PrivatePath, type: Type) {
      self.path = path
      self.type = type
    }
  }

  pub struct StoredResource {
    pub let address: Address
    pub let path: StoragePath
    pub let public: PublicCapability?
    pub let private: PrivateCapability?

    init(
      address: Address,
      path: StoragePath,
      public: PublicCapability?,
      private: PrivateCapability?
    ) {
      self.address = address
      self.path = path
      self.public = public
      self.private = private
    }
  }

  pub struct CollectionOverview {
    pub let brand: String
    pub let contractName: String
    pub let storage: StoredResource
    pub let numNfts: UInt64

    init(
      brand: String,
      contractName: String,
      storage: StoredResource,
      numNfts: UInt64
    ) {
      self.brand = brand
      self.contractName = contractName
      self.storage = storage
      self.numNfts = numNfts
    }
  }

  pub struct AccountOverview {
    pub let address: Address
    pub let collections: [CollectionOverview]

    init(address: Address, collections: [CollectionOverview]) {
      self.address = address
      self.collections = collections
    }
  }
}
