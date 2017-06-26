//
//  MenuItemHandler.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 22/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation
import Cocoa

extension StatusMenuController {
    func render() {
        self.clearMenuItems()
        if store.count == 0 {
            self.markIconRead()
            self.addEmptyState()
            return
        }
        for item in self.store.iter() {
            // render all the items
            // if not rendered, show a notification
            if !item.rendered {
                self.createNotification(item: item)
            }
            self.addMenuItem(item: item)
        }
        self.markIconUnread()
    }

    func addMenuItem(item: Item) {
        // create a new menu item
        let menuItem: NSMenuItem = NSMenuItem.init()
        menuItem.title = item.title
        menuItem.identifier = item.id
        menuItem.action = #selector(self.menuItemClick(sender:))
        menuItem.target = self
        statusMenu.insertItem(menuItem, at: 0)
        item.markRendered(visible: true)
    }

    private func clearMenuItems() {
        // remove items until we get back to the originals
        while statusMenu.items.count > self.startingCount {
            // new items are added from the top, so the bad items
            // are always at index 0 until all are gone
            statusMenu.removeItem(at: 0)
        }
    }

    private func clearCleanItems() {
        for item in self.store.iter() {
            // render all the items
            // if not rendered, show a notification
            if item.clean {
                self.store.remove(id: item.id)
            }
        }
    }

    private func addEmptyState() {
        let menuItem: NSMenuItem = NSMenuItem.init()
        menuItem.title = "🎉 No new notifications!"
        menuItem.isEnabled = false;
        statusMenu.insertItem(menuItem, at: 0)
    }
}
