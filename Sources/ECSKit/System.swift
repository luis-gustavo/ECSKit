//
//  System.swift
//
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

public protocol System: AnyObject {
  var componentSignature: Signature { get set }
  var entities: [Entity] { get set }
  func addEntityToSystem(_ entity: Entity)
  func removeEntityFromSystem(_ entity: Entity)
  func requireComponent<TComponent>(ofType componentType: TComponent.Type)
}

public extension System {
  func requireComponent<TComponent>(ofType componentType: TComponent.Type) {
    let componentId = Component<TComponent>.id
    componentSignature.addComponent(componentId)
  }
  func addEntityToSystem(_ entity: Entity) {
    entities.append(entity)
  }
  func removeEntityFromSystem(_ entity: Entity) {
    entities.removeAll(where: { $0.id == entity.id })
  }
}
