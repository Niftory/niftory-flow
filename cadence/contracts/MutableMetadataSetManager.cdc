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

import MutableMetadataSet from "./MutableMetadataSet.cdc"

pub contract MutableMetadataSetManager {

  // ===========================================================================
  // Manager
  // ===========================================================================

  pub resource interface Public {

    // Name of this manager
    pub fun name(): String

    // Description this manager
    pub fun description(): String

    // Number of sets in this manager
    pub fun numSets(): Int

    // Get the public version of a particular set
    pub fun getSet(_ id: Int): &MutableMetadataSet.Set{MutableMetadataSet.Public}
  }

  pub resource interface Private {
    
    // Set the name of the manager
    pub fun setName(_ name: String)

    // Set the name of the description
    pub fun setDescription(_ description: String)

    // Get the private version of a particular set
    pub fun getSetMutable(_ id: Int):
      &MutableMetadataSet.Set{MutableMetadataSet.Public, MutableMetadataSet.Private}

    // Add a mutable set to the set manager.
    pub fun addSet(_ set: @MutableMetadataSet.Set)
  }

  pub resource Manager: Public, Private {

    // ========================================================================
    // Attributes
    // ========================================================================

    // Name of this manager
    access(self) var _name: String

    // Description of this manager
    access(self) var _description: String  

    // Sets owned by this manager
    access(self) var _mutableSets: @[MutableMetadataSet.Set]

    // ========================================================================
    // Public functions
    // ========================================================================

    pub fun name(): String {
      return self._name
    }

    pub fun description(): String {
      return self._description
    }

    pub fun numSets(): Int {
      return self._mutableSets.length
    }

    pub fun getSet(_ id: Int): &MutableMetadataSet.Set{MutableMetadataSet.Public} {
      pre {
        id >= 0 && id < self._mutableSets.length :
          id
            .toString()
            .concat(" is not a valid set ID. Number of sets is ")
            .concat(self._mutableSets.length.toString())
      }
      return &self._mutableSets[id] 
        as &MutableMetadataSet.Set{MutableMetadataSet.Public}
    }

    // ========================================================================
    // Private functions
    // ========================================================================

    pub fun setName(_ name: String) {
      self._name = name
    }

    pub fun setDescription(_ description: String) {
      self._description = description
    }

    pub fun getSetMutable(_ id: Int): 
      &MutableMetadataSet.Set{MutableMetadataSet.Public, MutableMetadataSet.Private} {
      pre {
        id >= 0 && id < self._mutableSets.length :
          id
            .toString()
            .concat(" is not a valid set ID. Number of sets is ")
            .concat(self._mutableSets.length.toString())
      }
      return &self._mutableSets[id] 
        as &MutableMetadataSet.Set{MutableMetadataSet.Public, MutableMetadataSet.Private}
    }

    pub fun addSet(_ set: @MutableMetadataSet.Set) {
      self._mutableSets.append(<- set)
    }

    // ========================================================================
    // init/destroy
    // ========================================================================

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
  pub fun create(name: String, description: String): @Manager {
    return <-create Manager(name: name, description: description)
  }
}
