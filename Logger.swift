//
//  Logger.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 28/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation

class Logger {
  let logPath = "github_notifier_log.txt"
  let path: URL?
  let formatter: DateFormatter

  init() {
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      self.path = dir.appendingPathComponent(self.logPath)
    } else {
      self.path = nil
    }

    self.formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

    self.write("BOOT", "Application Starting", padding: 1)
  }

  func log(_ text: String) {
    self.write("LOG", text, padding: 2)
  }

  func warn(_ text: String) {
    self.write("WARN", text, padding: 1)
  }

  func error(_ text: String) {
    self.write("ERROR", text)
  }

  private func write(_ type: String, _ text: String, padding: Int = 0) {
    let timestamp = formatter.string(from: Date())
    let message = "[\(type)]\(String(repeating: " ", count: padding))[\(timestamp)] \(text)\n"
    print(message)
    do {
      let handle = try FileHandle.init(forWritingTo: self.path!)
      handle.seekToEndOfFile()
      handle.write(message.data(using: .utf8)!)
      handle.closeFile()
    } catch {
      print("error writing file: \(error)")
      // probably have to make the file first
      try? message.write(to: self.path!, atomically: false, encoding: .utf8)
    }
  }
}
