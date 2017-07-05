//
// Created by David Buchan-Swanson on 27/6/17.
// Copyright (c) 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Foundation

class LoginLaunchHandler {
  static func onMainApplicationBoot() {
    var alreadyRunning = false
    for app in NSWorkspace.shared().runningApplications {
      if app.bundleIdentifier == Constants.APPLICATION_BUNDLE_IDENTIFIER {
        alreadyRunning = true;
      }
    }

    if alreadyRunning {
      LoginLaunchHandler.terminate()
    } else {
      let name = NSNotification.Name.init("kill_launcher")
      DistributedNotificationCenter.default().addObserver(self, selector: #selector(LoginLaunchHandler.terminate), name: name, object: Constants.APPLICATION_BUNDLE_IDENTIFIER)

      let path = Bundle.main.bundlePath as NSString
      var components = path.pathComponents
      components.removeLast()
    }
  }

  @objc
  static func terminate() {
    NSApp.terminate(nil)
  }
}
