//
//  ComponentMask.swift
//  
//
//  Created by Luis Gustavo on 27/12/23.
//

import Foundation

private let minComponentCout = 0
private let maxComponentCout = 64

public typealias Signature = ComponentMask

public final class ComponentMask: Equatable {
  private var mask: UInt64 = 0

  public init(mask: UInt64 = 0) {
    self.mask = mask
  }

  func addComponent(_ componentId: Int) {
    guard componentId >= minComponentCout && componentId < maxComponentCout else {
      fatalError("Component ID out of range")
    }
    mask |= 1 << componentId
  }

  func removeComponent(_ componentId: Int) {
    guard componentId >= minComponentCout && componentId < maxComponentCout else {
      fatalError("Component ID out of range")
    }
    mask &= ~(1 << componentId)
  }

  func hasComponent(_ componentId: Int) -> Bool {
    guard componentId >= minComponentCout && componentId < maxComponentCout else {
      fatalError("Component ID out of range")
    }
    return (mask & (1 << componentId)) != 0
  }

  func reset() {
    mask = 0
  }

  static func &(lhs: ComponentMask, rhs: ComponentMask) -> ComponentMask {
    let result = ComponentMask()
    result.mask = lhs.mask & rhs.mask
    return result
  }

  public static func ==(lhs: ComponentMask, rhs: ComponentMask) -> Bool {
    return lhs.mask == rhs.mask
  }
}
