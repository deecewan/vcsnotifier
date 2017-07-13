//
//  API.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 19/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class API {
  let BASE_URL = "https://api.github.com"
  // let BASE_URL = "http://localhost:3000"

  let logger = Logger.init()

  func getHeaders() -> HTTPHeaders {
    let defaults = UserDefaults.standard
    let apiKey = defaults.string(forKey: "apiKey") ?? ""
    return ["Authorization": "Bearer \(apiKey)", "Cache-Control": "no-cache"]
  }

  func refresh(cb: @escaping ([JSON]?) -> Void) {
    var urlRequest = try! URLRequest(url: "\(BASE_URL)/notifications", method: .get, headers: getHeaders())
    urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
    print("requesting")
    Alamofire.request(urlRequest)
      .validate(statusCode: 200..<300)
      .responseJSON { response in
        switch response.result {
        case .success:
          if let json = response.result.value {
            let js = JSON(json)
            if js.count == 0 {
              print("No Notifications!")
              cb(nil)
            } else {
              // handle notifications
              var items: [JSON] = [];
              for (_, item) in js {
                items.append(item)
              }
              cb(items)
            }
          } else {
            self.logger.error("Failed to parse JSON: \(response)")
          }
        case .failure(let error):
          print("THERE WAS A FAILURE!", error)
          let notification = NSUserNotification.init()
          notification.title = "Error accessing GitHub"
          notification.subtitle = "Make sure your credentials are correct and GitHub is up."
          NSUserNotificationCenter.default.deliver(notification)
      }
    }
  }

  func markAllAsRead(afterAction: @escaping (Void) -> Void) {
    var urlRequest = try! URLRequest(url: "\(BASE_URL)/notifications", method: .put, headers: getHeaders())
    urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
    Alamofire.request(urlRequest)
      .responseJSON { _ in
        afterAction()
      }
  }
}
