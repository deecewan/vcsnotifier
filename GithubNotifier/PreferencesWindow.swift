//
//  PreferencesWindow.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 22/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Foundation
import ServiceManagement

protocol PreferencesWindowDelegate {
  func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

  @IBOutlet weak var versionLabel: NSTextField!
  @IBOutlet weak var showNotificationsFlag: NSButton!
  @IBOutlet weak var startOnBootFlag: NSButton!
  @IBOutlet weak var apiKeyField: NSTextField!
  var delegate: PreferencesWindowDelegate?
  let logger = Logger.init()
  let defaults = UserDefaults.standard

  @IBAction func tokenLinkClicked(_ sender: NSButton) {
    let url: URL = URL.init(string: "https://github.com/settings/tokens/new")!
    NSWorkspace.shared().open(url)
  }

  @IBAction func toggleShowNotification(_ sender: NSButton) {
    let enabled = sender.stringValue == "1"
    logger.log("Notifications \(enabled ? "en" : "dis")abled")
    defaults.set(enabled, forKey: "showNotifications")
  }

  @IBAction func toggleStartOnBoot(_ sender: NSButton) {
    let value = sender.stringValue == "1"
    let res = SMLoginItemSetEnabled(Constants.LAUNCHER_BUNDLE_IDENTIFIER as CFString, value)
    if res {
      logger.log("Successfully \(value ? "" : "un")registered for login")
    } else {
      logger.warn("Could not \(value ? "" : "un")register for login")
    }
  }

  @IBAction func saveButtonClicked(_ sender: NSButton) {
    self.window?.close()
  }

  override var windowNibName: String! {
    return "PreferencesWindow"
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    self.versionLabel.stringValue = getVersionString()
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    let apiKey = defaults.string(forKey: "apiKey") ?? ""

    startOnBootFlag.stringValue = checkIfLaunchEnabled() ? "1" : "0"

    let showNotifications = defaults.bool(forKey: "showNotifications")
    showNotificationsFlag.stringValue = showNotifications ? "1" : "0"
    apiKeyField.stringValue = apiKey
    NSApp.activate(ignoringOtherApps: true)
  }

  func windowWillClose(_ notification: Notification) {
    let defaults = UserDefaults.standard
    defaults.setValue(apiKeyField.stringValue, forKey: "apiKey")
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

  private func checkIfLaunchEnabled() -> Bool {
    let jobDicts = SMCopyAllJobDictionaries( kSMDomainUserLaunchd ).takeRetainedValue() as NSArray as! [[String:AnyObject]]
    return jobDicts.filter { $0["Label"] as! String == Constants.LAUNCHER_BUNDLE_IDENTIFIER }.isEmpty == false
  }

}
