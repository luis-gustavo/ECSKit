//
//  Collection+safeSubscript.swift
//
//
//  Created by Luis Gustavo on 28/12/23.
//

import Foundation

extension Collection {
  subscript(safe index: Index) -> Iterator.Element? {
    guard indices.contains(index) else {
      return nil
    }
    return self[index]
  }
}
