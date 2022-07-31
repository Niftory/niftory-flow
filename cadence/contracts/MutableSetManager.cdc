/*
MutableSetManager

MutableSet.Set (please see that contract for more details) provides a way to
create Sets of alike resources with some shared properties. This contract
provides management and access to a logical collection of these Sets. For
example, this contract would be best used to manage the metadata for an entire
NFT contract.

A SetManager should have a name and description and provides a way to add
additional Sets and access those Sets for mutation, if allowed by the Set.
*/

import MutableSet from "./MutableSet.cdc"

pub contract MutableSetManager {
  
  // ===========================================================================
  // MetadataAccessor 
  // ===========================================================================

  // NFTs generally need an interface to a specific
  // MutableMetadataTemplate.Template. This struct provides a container for
  // the two values to get a Template
  // - Set identifier
  // - Template identifier (within that Set)
  pub struct MetadataAccessor {
    pub let setId: Int
    pub let templateId: Int
    init(
      setId: Int,
      templateId: Int
    ) {
      self.setId = setId
      self.templateId = templateId
    }
  }

  // ===========================================================================
  // Manager Capabilities
  // ===========================================================================

  // Public functionality for Manager
  pub resource interface ManagerPublic {
    pub fun name(): String
    pub fun description(): String
    pub fun numSets(): Int
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic}
  }

  // Private functionality for Manager
  pub resource interface ManagerPrivate {
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic}
    pub fun name(): String
    pub fun description(): String
    pub fun numSets(): Int

    pub fun getAuth(_ id: Int): &MutableSet.Set{MutableSet.SetPrivate}
    pub fun setName(_ name: String)
    pub fun setDescription(_ description: String)
    pub fun addMutableSet(_ set: @MutableSet.Set)
  }

  // In order to allow public minting if desired by the NFT brand owners,
  // the mint functionality was put in it's own capability. 
  pub resource interface ManagerMinter {
    pub fun name(): String
    pub fun description(): String
    pub fun numSets(): Int
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic}

    pub fun getSetMinter(_ id: Int): &MutableSet.Set{MutableSet.SetMinter}
  }

  // ===========================================================================
  // Manager
  // ===========================================================================

  pub resource Manager : ManagerPublic, ManagerPrivate, ManagerMinter {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Name of this manager
    access(self) var _name: String

    // Description this manager
    access(self) var _description: String  

    // Sets owned by this manager
    access(self) var _mutableSets: @[MutableSet.Set]

    // ========================================================================
    // Public functions
    // ========================================================================

    // Name of this manager
    pub fun name(): String {
      return self._name
    }

    // Description this manager
    pub fun description(): String {
      return self._description
    }

    // Number of sets in this manager
    pub fun numSets(): Int {
      return self._mutableSets.length
    }

    // Get the public version of a particular set
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic} {
      pre {
        id >= 0 && id < self._mutableSets.length :
          id
            .toString()
            .concat(" is not a valid set ID. Number of sets is ")
            .concat(self._mutableSets.length.toString())
      }
      return &self._mutableSets[id] as &MutableSet.Set{MutableSet.SetPublic}
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    // Get the private version of a particular set
    pub fun getAuth(_ id: Int): &MutableSet.Set{MutableSet.SetPrivate} {
      pre {
        id >= 0 && id < self._mutableSets.length :
          id
            .toString()
            .concat(" is not a valid set ID. Number of sets is ")
            .concat(self._mutableSets.length.toString())
      }
      return &self._mutableSets[id] as &MutableSet.Set{MutableSet.SetPrivate}
    }

    // Set the name of the manager
    pub fun setName(_ name: String) {
      self._name = name
    }

    // Set the name of the description
    pub fun setDescription(_ description: String) {
      self._description = description
    }

    // Add a mutable set to the set manager.
    pub fun addMutableSet(_ set: @MutableSet.Set) {
      self._mutableSets.append(<- set)
    }

    // ========================================================================
    // Minter functions
    // ========================================================================

    // Get the minter for a particular Set
    pub fun getSetMinter(_ id: Int): &MutableSet.Set{MutableSet.SetMinter} {
      pre {
        id >= 0 && id < self._mutableSets.length :
          id
            .toString()
            .concat(" is not a valid set ID. Number of sets is ")
            .concat(self._mutableSets.length.toString())
      }
      return &self._mutableSets[id] as &MutableSet.Set{MutableSet.SetMinter}
    }

    init(name: String, description: String) {
      self._name = name
      self._description = description
      self._mutableSets <- []
    }

    destroy() {
      destroy self._mutableSets
    }
  }

  // ========================================================================
  // Contract functions
  // ========================================================================

  // Create a new SetManager resource with the given name and description
  pub fun createSetManager(name: String, description: String): @Manager {
    return <-create Manager(name: name, description: description)
  }
}