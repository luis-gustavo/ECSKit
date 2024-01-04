//
//  Entity.swift
//  
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

public class Entity: Hashable {
  // MARK: - Properties
  public let id: Int
  var registry: Registry?
  // MARK: - Initializers
  init(id: Int) {
    self.id = id
  }
  // MARK: - Equatable
  public static func == (lhs: Entity, rhs: Entity) -> Bool {
    lhs.id == rhs.id
  }
  // MARK: - Hashable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
// MARK: - Entity + Component
public extension Entity {
  func addComponent<TComponent>(_ component: TComponent) {
    registry?.addComponent(component, to: self)
  }
  func removeComponent<TComponent>(_ component: TComponent.Type) {
    registry?.removeComponent(component, from: self)
  }

  func hasComponent<TComponent>(_ component: TComponent.Type) -> Bool {
    registry?.hasComponent(component, entity: self) ?? false
  }

  func getComponent<TComponent>(_ component: TComponent.Type) -> TComponent? {
    registry?.getComponent(component, entity: self)
  }
}
// MARK: - Entity + Tag
public extension Entity {
  func tag(_ tag: String) {
    registry?.tagEntity(self, tag: tag)
  }
  func hasTag(_ tag: String) -> Bool {
    registry?.entity(self, hasTag: tag) ?? false
  }
}
// MARK: - Entity + Group
public extension Entity {
  func group(_ group: String) {
    registry?.groupEntity(self, group: group)
  }
  func belongsToGroup(_ group: String) -> Bool {
    registry?.entity(self, belongsToGroup: group) ?? false
  }
}
