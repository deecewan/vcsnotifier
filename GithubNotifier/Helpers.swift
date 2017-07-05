//
// Created by David Buchan-Swanson on 26/6/17.
// Copyright (c) 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation

extension StatusMenuController {
  func checkForAPIKey() {
    // check if the api key exists
    // if it doesn't, add a notification
  }

  func extractCommentIdUrl(_ url: String?) -> String {
    if url == nil {
      return ""
    }
    let url = url!
    let splits = url.characters.split(separator: "/").map { item in
      String(item)
    }
    let secondLast = splits[splits.endIndex - 2]
    if secondLast != "comments" {
      return ""
    }

    let type = splits[splits.endIndex - 3]
    let id = splits[splits.endIndex - 1]

    switch (type) {
    case "pulls":
      return "#discussion_r\(id)"
    case "issues":
      return "#issuecomment-\(id)"
    default:
      return "#commitcomment-\(id)"
    }
  }

  func normaliseUrl(_ url: String, extra: String) -> String {
    // remove all the incorrect things
    // replace all wrong plurals
    let newUrl = url.replacingOccurrences(of: "api.", with: "")
      .replacingOccurrences(of: "repos/", with: "")
      .replacingOccurrences(of: "pulls/", with: "pull/")
      .replacingOccurrences(of: "commits/", with: "commit/")

    return "\(newUrl)\(extra)"
  }
}
