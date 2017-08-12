//
//  StatusMenuController.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 19/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, PreferencesWindowDelegate {

  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var itemView: ItemView!

  var preferencesWindow: PreferencesWindow!
  var startingCount: Int = 0;

  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  let logger: Logger;

  let store: DataStore
  let notificationHandler: NotificationHandler
  let api: API = API.init()
  let defaults = UserDefaults.standard

  override init() {
    self.logger = Logger.init();
    self.store = DataStore.init(logger: logger)
    self.notificationHandler = NotificationHandler.init(store: store)
  }


  override func awakeFromNib() {
    print("Starting")

    // set up default values
    if defaults.object(forKey: "showNotifications") == nil {
      print("No user default")
      defaults.set(true, forKey: "showNotifications")
    }

    self.store.observe { _ in
      self.render()
    }

    let icon = NSImage(named: "icon")
    icon?.isTemplate = true // best for dark mode
    statusItem.image = icon
    statusItem.menu = statusMenu

    preferencesWindow = PreferencesWindow()
    preferencesWindow.delegate = self

    // get the count for reliable item removal
    self.startingCount = statusMenu.items.count

    self.checkForAPIKey()

    startTimer()
    self.refresh()
  }

  func preferencesDidUpdate() {
    logger.log("preferences updated!")
    self.refresh()
  }

  func startTimer() {
    _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
  }

  func refresh() {
    store.cleanAll()
    api.refresh() { items in
      if items == nil {
        self.removeCleanItems();
        self.render()
        return
      }
      for (item) in items! {
        let additionalPiece = self.extractCommentIdUrl(item["subject"]["latest_comment_url"].string)
        let url = self.normaliseUrl(item["subject"]["url"].string!, extra: additionalPiece)
        let id = item["id"].string!
        let title = item["subject"]["title"].string!
        let repo = item["repository"]["full_name"].string!
        self.store.append(id: id, title: title, link: url, repo: repo)
      }
      self.removeCleanItems()
    }
  }

  func removeCleanItems() {
    // remove all the clean items
    for (item) in self.store.cleanItems() {
      self.store.remove(id: item.id)
      self.notificationHandler.remove(id: item.id)
    }
  }

  func createNotification(item: Item) {
    if !defaults.bool(forKey: "showNotifications") {
      return
    }
    let notification = NSUserNotification()
    notification.title = item.title
    notification.informativeText = item.repoName
    notification.identifier = item.id

    NSUserNotificationCenter.default.delegate = notificationHandler
    NSUserNotificationCenter.default.deliver(notification)

  }

  func markIconUnread() {
    self.markIcon(type: false)
  }

  func markIconRead() {
    self.markIcon(type: true)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  private func markIcon(type: Bool) {
    let icon = NSImage(named: "icon")
    icon?.isTemplate = type // best for dark mode
    statusItem.image = icon
  }
}
