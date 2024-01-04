//
//  Component.swift
//
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

class IComponent {
  fileprivate static var nextId: Int = 0
  fileprivate static var typeIds: [ObjectIdentifier: Int] = [:]
}

final class Component<T>: IComponent {
  static var id: Int {
    let typeId = ObjectIdentifier(T.self)
    if let storedId = typeIds[typeId] {
      return storedId
    } else {
      defer { nextId += 1 }
      typeIds[typeId] = nextId
      return nextId
    }
  }
}
