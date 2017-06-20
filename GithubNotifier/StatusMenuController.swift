//
//  StatusMenuController.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 19/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Regex

struct Item {
    let link: String;
    let title: String;
}

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    let COMMENT_URL_REGEX = Regex("comments/(\\d+)")
    
    @IBAction func quitAction(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    func getPrefix(_ url: String) -> String {
        if url.range(of: "issues/") != nil {
            return "issuecomment-"
        }
        if url.range(of: "pulls/") != nil {
            return "discussion_r"
        }
        return "commitcomment-"
    }
    
    func extractCommentIdUrl(_ incoming: String?) -> String? {
        if incoming == nil {
            return nil
        }
        let prefix = getPrefix(incoming!)
        if let commentId = self.COMMENT_URL_REGEX.firstMatch(in: incoming!)?.captures[0] {
            return "#\(prefix)\(commentId)"
        }
        return nil
    }
    
    func normaliseUrl(_ url: String?, extra: String) -> String {
        if url == nil {
            return "";
        }
        var url = url!
        url.replaceFirst(matching: "api.", with: "")
        url.replaceFirst(matching: "repos/", with: "")
        url.replaceFirst(matching: "pulls/", with: "pull/")
        url.replaceFirst(matching: "commits/", with: "commit/")
        return "\(url)\(extra)"
    }
    
    override func awakeFromNib() {
        print("Starting")
        let api = API.init()
        api.refresh() { item in
            print("refresh")
            if let type = item["subject"]["type"].string {
                var additionalPiece = ""
                if type == "Commit" {
                    additionalPiece = self.extractCommentIdUrl(item["subject"]["latest_comment_url"].string) ?? ""
                } else if type == "Issue" || type == "PullRequest" {
                    additionalPiece = self.extractCommentIdUrl(item["subject"]["latest_comment_url"].string) ?? ""
                }
                let url = self.normaliseUrl(item["subject"]["url"].string, extra: additionalPiece)
                // extract the comment id from the URL
                self.addItem(name: item["subject"]["title"].string!, link: url)
            }
        }
        
        let icon = NSImage(named: "icon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    func addItem(name: String, link: String) {
        print(name);
        print(link);
//        // create a new menu item
        let item: NSMenuItem = NSMenuItem.init()
        item.title = name
        item.identifier = link
        item.action = #selector(self.printOnClick(sender:))
        item.target = self//itemTarget as AnyObject
        statusMenu.insertItem(item, at: 0)
    }
    
    func printOnClick(sender: NSMenuItem) {
        print(sender.identifier)
        if let string = sender.identifier {
            let url: URL = try! URL.init(string: string)!
            NSWorkspace.shared().open(url)
            // let's also remove the item from the list - the notification has been actioned
            statusMenu.removeItem(sender)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
