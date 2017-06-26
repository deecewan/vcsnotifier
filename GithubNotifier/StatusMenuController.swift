//
//  StatusMenuController.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 19/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Regex

class StatusMenuController: NSObject, PreferencesWindowDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var itemView: ItemView!

    var preferencesWindow: PreferencesWindow!
    var startingCount: Int = 0;

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let store: DataStore
    let notificationHandler: NotificationHandler
    
    let COMMENT_URL_REGEX: Regex = Regex("comments/(\\d+)")
    let api: API = API.init()

    override func awakeFromNib() {
        print("Starting")

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
    
    override init() {
        self.store = DataStore.init()
        self.notificationHandler = NotificationHandler.init(store: store)
    }

    func preferencesDidUpdate() {
        print("preferences updated!")
        self.refresh()
    }
    
    func startTimer() {
        _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
    }
    
    func refresh() {
        print("refreshing")
        api.refresh() { item in
            if item == nil {
                self.render()
                return
            }
            let item = item!
            print("item added")
            if let type = item["subject"]["type"].string {
                var additionalPiece = ""
                if type == "Commit" {
                    additionalPiece = self.extractCommentIdUrl(item["subject"]["latest_comment_url"].string) ?? ""
                } else if type == "Issue" || type == "PullRequest" {
                    additionalPiece = self.extractCommentIdUrl(item["subject"]["latest_comment_url"].string) ?? ""
                }
                let url = self.normaliseUrl(item["subject"]["url"].string, extra: additionalPiece)
                let id = item["id"].string!
                let title = item["subject"]["title"].string!
                let repo = item["repository"]["full_name"].string!
                self.store.append(id: id, title: title, link: url, repo: repo)
            }
        }
    }
    
    func createNotification(item: Item) {
        let notification = NSUserNotification()
        notification.title = item.title
        notification.informativeText = item.repoName
        notification.identifier = item.id
        
        NSUserNotificationCenter.default.delegate = notificationHandler
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func menuItemClick(sender: NSMenuItem) {
        // is there a better way to do these nested lets?
        if let id = sender.identifier {
            if let item: Item = store.get(id: id) {
                if let url: URL = URL.init(string: item.link) {
                    NSWorkspace.shared().open(url)
                    // let's also remove the item from the store - the notification has been actioned
                    print("Removing \(id) from store")
                    self.store.remove(id: id)
                    self.notificationHandler.remove(id: id)
                }
            }
        }
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
