//
//  PreferencesWindow.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 22/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var startOnBootFlag: NSButton!
    @IBOutlet weak var showNotificationsFlag: NSButton!
    @IBOutlet weak var apiKeyField: NSTextField!
    var delegate: PreferencesWindowDelegate?

    @IBAction func tokenLinkClicked(_ sender: NSButton) {
        print("Clicking link in preferences")
        let url: URL = URL.init(string: "https://github.com/settings/tokens/new")!
        NSWorkspace.shared().open(url)
    }

    override var windowNibName : String! {
        return "PreferencesWindow"
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        self.versionLabel.stringValue = getVersionString()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        let defaults = UserDefaults.standard
        let apiKey = defaults.string(forKey: "apiKey") ?? ""
        apiKeyField.stringValue = apiKey
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        defaults.setValue(apiKeyField.stringValue, forKey: "apiKey")
        print("updating api key to: \(apiKeyField.stringValue)")
        delegate?.preferencesDidUpdate()
    }

    private func getVersionString() -> String {
        var versionString = "Notifier"
        if let infoDict = Bundle.main.infoDictionary {
            let version = infoDict["CFBundleShortVersionString"] as? String
            let buildNumber = infoDict["CFBundleVersion"] as? String
            if version != nil {
                versionString += " v\(version!)"
            }
            if buildNumber != nil {
                versionString += " (Build \(buildNumber!))"
            }
        }

        return versionString;
    }
    
}
