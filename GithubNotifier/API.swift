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
//    let BASE_URL = "https://api.github.com"
    let BASE_URL = "http://localhost:3000"
    let API_KEY = ProcessInfo.processInfo.environment["API_KEY"] ?? "No Key Provided"
    
    func getHeaders() -> HTTPHeaders {
        return ["Authorization": "Bearer \(API_KEY)", "Cache-Control": "no-cache"]
    }
    
    func refresh(cb: @escaping (JSON) -> Void) {
        print("refreshing")
        var urlRequest = try! URLRequest(url: "\(BASE_URL)/notifications", method: .get, headers: getHeaders())
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        
        Alamofire.request(urlRequest)
            .responseJSON { response in
                print(response)
            if let json = response.result.value {
                let js = JSON(json)
                if js.count == 0 {
                    print("No Notifications!")
                } else {
                    // handle notifications
                    for (_, item) in js {
                        print(item["subject"])
                        cb(item)
                    }
                }
            }
        }
    }
}
