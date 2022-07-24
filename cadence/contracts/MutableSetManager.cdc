import MutableMetadata from "./MutableMetadata.cdc"
import MutableSet from "./MutableSet.cdc"

pub contract MutableSetManager {

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

  pub resource interface ManagerPublic {
    pub fun name(): String
    pub fun description(): String
    pub fun numSets(): Int
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic}
  }

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

  pub resource interface ManagerMinter {
    pub fun name(): String
    pub fun description(): String
    pub fun numSets(): Int
    pub fun get(_ id: Int): &MutableSet.Set{MutableSet.SetPublic}

    pub fun getSetMinter(_ id: Int): &MutableSet.Set{MutableSet.SetMinter}
  }

  pub resource Manager : ManagerPublic, ManagerPrivate, ManagerMinter {

    access(self) var _name: String
    access(self) var _description: String  
    access(self) var _mutableSets: @[MutableSet.Set]

    pub fun name(): String {
      return self._name
    }

    pub fun description(): String {
      return self._description
    }

    pub fun numSets(): Int {
      return self._mutableSets.length
    }

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

    pub fun setName(_ name: String) {
      self._name = name
    }

    pub fun setDescription(_ description: String) {
      self._description = description
    }

    pub fun addMutableSet(_ set: @MutableSet.Set) {
      self._mutableSets.append(<- set)
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

  pub fun createSetManager(name: String, description: String): @Manager {
    return <-create Manager(name: name, description: description)
  }
}