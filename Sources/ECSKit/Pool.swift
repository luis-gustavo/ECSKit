//
//  Pool.swift
//  
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

public protocol IPool {
  func removeEntityFromPool(entityId: Int)
}

public class Pool<T>: IPool {
  var data: [T?]
  var size: Int
  var entityIdToIndex: [Int: Int]
  var indexToEntityId: [Int: Int]

  init() {
    data = []
    size = 0
    entityIdToIndex = [:]
    indexToEntityId = [:]
  }

  var isEmpty: Bool {
    size == 0
  }
   func clear() {
    data.removeAll()
    entityIdToIndex.removeAll()
    indexToEntityId.removeAll()
    size = 0
  }
   func set(entityId: Int, object: T) {
    if let index = entityIdToIndex[entityId] {
      // If the element already exists, simply replace the component object
      data[index] = object
    } else {
      // When adding a new object, we keep track of the entity ids and their vector index
      let index = size
      entityIdToIndex[entityId] = index
      indexToEntityId[index] = entityId
      if index >= data.capacity {
//         If necessary, we resize by always doubling the current capacity
        data.reserveCapacity(max(size, 1) * 2)
      }
      data.insert(object, at: index)
      size += 1
    }
  }
  func remove(entityId: Int) {
    // Copy the last element to the deleted position to keep the array packed
    if let indexOfRemoved = entityIdToIndex[entityId], let indexOfLast = indexToEntityId[size - 1] {
      data[indexOfRemoved] = data[indexOfLast]

      // Update the index-entity maps to point to the correct elements
      entityIdToIndex[indexOfLast] = indexOfRemoved
      indexToEntityId[indexOfRemoved] = indexOfLast

      entityIdToIndex.removeValue(forKey: entityId)
      indexToEntityId.removeValue(forKey: indexOfLast)

      size -= 1
    }
  }
  func get(entityId: Int) -> T? {
    if let index = entityIdToIndex[entityId], index < size {
      return data[index]
    }
    return nil
  }

  subscript(index: Int) -> T? {
    get {
      return data[index]
    } set(newValue) {
      data[index] = newValue
    }
  }

  public func removeEntityFromPool(entityId: Int) {
    if entityIdToIndex[entityId] != nil {
      remove(entityId: entityId)
    }
  }
}
