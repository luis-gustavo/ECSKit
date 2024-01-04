//
//  Logger.swift
//  
//
//  Created by Luis Gustavo on 28/12/23.
//

import Foundation

final class Logger {
  static var messages: [String] = []

  static func currentDateTimeToString() -> String {
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
    return formatter.string(from: now)
  }

  static func log(_ message: String) {
    let logEntry = "[TofuKit] - ℹ️ LOG: [\(currentDateTimeToString())]: \(message)"
    print("\(logEntry)")
    messages.append(logEntry)
  }

  static func err(_ message: String) {
    let logEntry = "[TofuKit] - 🔴 ERR: [\(currentDateTimeToString())]: \(message)"
    messages.append(logEntry)
    print("\(logEntry)")
  }
}
