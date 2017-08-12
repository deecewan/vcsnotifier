//
//  Actions.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 22/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation
import Cocoa

extension StatusMenuController {

  @IBAction func openAllClicked(_ sender: NSMenuItem) {
    for item in self.store.iter() {
      let id = item.id;
      openMenuItem(id: id)
    }
  }

  @IBAction func preferencesClicked(_ sender: NSMenuItem) {
    preferencesWindow.showWindow(nil)
  }

  @IBAction func refreshAction(_ sender: NSMenuItem) {
    refresh()
  }

  @IBAction func clearAllAction(_ sender: NSMenuItem) {
    // mark all notifications as read, remove them from the store and re-render
    self.api.markAllAsRead {
      self.store.clear()
      self.notificationHandler.removeAll()
    }
  }

  @IBAction func quitAction(_ sender: NSMenuItem) {
    NSApplication.shared().terminate(self)
  }
}
