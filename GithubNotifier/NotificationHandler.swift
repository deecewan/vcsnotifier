//
// Created by David Buchan-Swanson on 26/6/17.
// Copyright (c) 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Foundation

class NotificationHandler: NSObject, NSUserNotificationCenterDelegate {
  let store: DataStore;

  init(store: DataStore) {
    self.store = store;
  }

  func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
    // when it activates, get the notification item out of the store
    if let id = notification.identifier {
      if let item = store.get(id: id) {
        if let url: URL = URL.init(string: item.link) {
          NSWorkspace.shared().open(url)
          // let's also remove the item from the store - the notification has been actioned
          print("Removing \(id) from store")
          self.store.remove(id: id)
          self.remove(notification: notification)
        }
      }
    }
  }

  func removeAll() {
    let center = NSUserNotificationCenter.default;
    center.removeAllDeliveredNotifications()
  }

  func remove(id: String) {
    let center = NSUserNotificationCenter.default;
    let maybeNotification = center.deliveredNotifications.first { item in
      return item.identifier == id
    }
    if maybeNotification != nil {
      center.removeDeliveredNotification(maybeNotification!)
    }
  }

  func remove(notification: NSUserNotification) {
    let center = NSUserNotificationCenter.default;
    center.removeDeliveredNotification(notification);
  }
}