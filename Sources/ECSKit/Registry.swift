//
//  Registry.swift
//  
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

public class Registry {
  var entityCount = 0
  var componentPools: [IPool]
  var entityComponentSignatures: [Signature]
  var systems: [ObjectIdentifier: System]
  var entitiesToBeAdded: Set<Entity>
  var entitiesToBeKilled: Set<Entity>
  var freeIds: [Int]
  var entityPerTag: [String: Entity]
  var tagPerEntity: [Int: String]
  var entitiesPerGroup: [String: Set<Entity>]
  var groupPerEntity: [Int: String]

  public init() {
    self.entityCount = 0
    self.componentPools = []
    self.entityComponentSignatures = []
    self.systems = [:]
    self.entitiesToBeAdded = []
    self.entitiesToBeKilled = []
    self.freeIds = []
    self.entityPerTag = [:]
    self.tagPerEntity = [:]
    self.entitiesPerGroup = [:]
    self.groupPerEntity = [:]
  }

  public func update() {
    // Processing the entities that are waiting to be created to the active Systems
    for entity in entitiesToBeAdded {
      addEntityToSystems(entity)
    }
    entitiesToBeAdded.removeAll()
    // Process the entities that are waiting to be killed from the active Systems
    for entity in entitiesToBeKilled {
      removeEntityFromSystems(entity)
      entityComponentSignatures[entity.id].reset()

      // Remove entity from component pools
      for index in componentPools.indices {
        componentPools[index].removeEntityFromPool(entityId: entity.id)
      }

      // Make the entity id available to be reused
      freeIds.append(entity.id)

      // Remove any traces of that entity from the tag/group maps
      removeEntityTag(entity)
      removeEntityGroup(entity)
    }
    entitiesToBeKilled.removeAll()
  }
  public func createEntity() -> Entity {
    let entityId: Int

    if !freeIds.isEmpty {
      let freeId = freeIds.removeFirst()
      entityId = freeId
    } else {
      entityId = entityCount
      entityCount += 1
      if entityId >= entityComponentSignatures.count {
        let newSize = entityId + 1
        entityComponentSignatures += Array(repeating: .init(), count: newSize - entityComponentSignatures.count)
      }
    }

    let entity = Entity(id: entityId)
    entity.registry = self
    entitiesToBeAdded.insert(entity)

    Logger.log("Entity created with id \(entityId)")

    return entity
  }
  func killEntity(_ entity: Entity) {
    Logger.log("Entity \(entity.id) was killed")
    entitiesToBeKilled.insert(entity)
  }
}
// MARK: - Registry + Component
public extension Registry {
  func addComponent<TComponent>(_ component: TComponent, to entity: Entity) {
    let componentId = Component<TComponent>.id
    let entityId = entity.id

    if componentId >= componentPools.count {
      componentPools += Array(repeating: Pool<TComponent>(), count: componentId - componentPools.count + 1)
    }

    let componentPool = componentPools[safe: componentId] as? Pool<TComponent>
    componentPool?.set(entityId: entityId, object: component)

    let entityComponentSignature = entityComponentSignatures[safe: entityId]
    entityComponentSignature?.addComponent(componentId)

    Logger.log("Component id = \(componentId) was added to entity id \(entityId)")
  }

  func removeComponent<TComponent>(_ component: TComponent.Type, from entity: Entity) {
    let componentId = Component<TComponent>.id
    let entityId = entity.id

    let componentPool = componentPools[componentId] as? Pool<TComponent>
    componentPool?.remove(entityId: entityId)

    entityComponentSignatures[entityId].removeComponent(componentId)

    Logger.log("Component id = \(componentId) was removed from entity id \(entityId)")
  }
  func hasComponent<TComponent>(_ component: TComponent.Type, entity: Entity) -> Bool {
    let componentId = Component<TComponent>.id
    let entityId = entity.id
    return entityComponentSignatures[entityId].hasComponent(componentId)
  }
  func getComponent<TComponent>(_ component: TComponent.Type, entity: Entity) -> TComponent? {
    let componentId = Component<TComponent>.id
    let entityId = entity.id
    let componentPool = componentPools[componentId] as? Pool<TComponent>
    return componentPool?.get(entityId: entityId)
  }
}
// MARK: - Registry + System
public extension Registry {
  func addSystem<TSystem: System>(_ system: TSystem) {
    let identifier = ObjectIdentifier(type(of: TSystem.self))
    systems[identifier] = system
  }
  func removeSystem<TSystem: System>(_ system: TSystem.Type) {
    let identifier = ObjectIdentifier(type(of: TSystem.self))
    systems.removeValue(forKey: identifier)
  }
  func hasSystem<TSystem: System>(_ system: TSystem.Type) -> Bool {
    let identifier = ObjectIdentifier(type(of: TSystem.self))
    return systems[identifier] != nil
  }
  func getSystem<TSystem: System>(_ system: TSystem.Type) -> TSystem? {
    let identifier = ObjectIdentifier(type(of: TSystem.self))
    return systems[identifier] as? TSystem
  }
  func addEntityToSystems(_ entity: Entity) {
    let entityId = entity.id

    guard let entityComponentSignature = entityComponentSignatures[safe: entityId] else { return }

    for system in systems {
      let systemComponentSignature = system.value.componentSignature

      let isInterested = (entityComponentSignature & systemComponentSignature) == systemComponentSignature

      if isInterested {
        system.value.addEntityToSystem(entity)
      }
    }
  }
  func removeEntityFromSystems(_ entity: Entity) {
    for system in systems {
      system.value.removeEntityFromSystem(entity)
    }
  }
}
// MARK: - Registry + Tag
public extension Registry {
  func tagEntity(_ entity: Entity, tag: String) {
    entityPerTag[tag] = entity
    tagPerEntity[entity.id] = tag
  }
  func entity(_ entity: Entity, hasTag tag: String) -> Bool {
    if tagPerEntity[entity.id] == nil {
      return false
    }
    return entityPerTag[tag] == entity
  }
  func getEntityByTag(_ tag: String) -> Entity? {
    entityPerTag[tag]
  }
  func removeEntityTag(_ entity: Entity) {
    if let taggedEntity = tagPerEntity[entity.id] {
      entityPerTag.removeValue(forKey: taggedEntity)
      tagPerEntity.removeValue(forKey: entity.id)
    }
  }
}
// MARK: - Registry + Group
public extension Registry {
  func groupEntity(_ entity: Entity, group: String) {
    if entitiesPerGroup[group] == nil {
      entitiesPerGroup[group] = Set<Entity>()
    }

    entitiesPerGroup[group]?.insert(entity)
    groupPerEntity[entity.id] = group
  }
  func entity(_ entity: Entity, belongsToGroup group: String) -> Bool {
    if let groupEntities = entitiesPerGroup[group] {
      return groupEntities.contains(entity)
    }
    return false
  }
  func getEntitiesByGroup(_ group: String) -> [Entity] {
    if let setOfEntities = entitiesPerGroup[group] {
      return Array(setOfEntities)
    }
    return []
  }
  func removeEntityGroup(_ entity: Entity) {
    if let groupedEntity = groupPerEntity[entity.id], var group = entitiesPerGroup[groupedEntity] {
      group.remove(entity)
      groupPerEntity.removeValue(forKey: entity.id)
    }
  }
}
