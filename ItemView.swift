//
//  ItemView.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 28/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Cocoa
import Foundation
import PureLayout

class ItemView: NSView {
  @IBOutlet weak var imageView: NSImageView!
  @IBOutlet weak var titleField: NSTextField!
  @IBOutlet weak var infoField: NSTextField!
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  var isHovered = false;

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    Swift.print("Drawing view")
    if (isHovered) {
      NSColor.selectedMenuItemColor.set()
    } else {
      NSColor.clear.set()
    }
    NSBezierPath.fill(dirtyRect)
    Swift.print("titleField: \(String(describing: titleField?.stringValue))")
  }

  override func viewDidUnhide() {
    Swift.print("unhiding")
  }

  override func mouseDown(with event: NSEvent) {
    Swift.print("Click")
  }

  override func mouseEntered(with event: NSEvent) {
    Swift.print("Hovering")
    isHovered = true;
  }

  override func mouseExited(with event: NSEvent) {
    Swift.print("Unhovering")
    isHovered = false;
  }

  func updateTitle(_ title: String) {
    // titleField.stringValue = title
  }

  func updateInfo(_ info: String) {
    // infoField.stringValue = info
  }

  func updateText(title: String, info: String) {
    updateTitle(title)
    updateInfo(info)
  }

}

/*
 what we started with
 ****************************
 static let EDGES_INSET: CGFloat = 10.0;

 static func createView(title: String) -> NSView {
 let outerRect = NSMakeRect(0, 0, 250, 44)
 let view = NSView.init(frame: outerRect)

 view.addSubview(self.textField(title))
 view.addSubview(self.secondLine("demo/demodemo"))

 return view;
 }

 static func textField(_ text: String) -> NSTextField {
 let textFrame = NSMakeRect(10, 14, 250, 24)
 let field = NSTextField.init(frame: textFrame)
 field.isEditable = false
 field.isBordered = false
 field.stringValue = text
 return field
 }

 static func secondLine(_ text: String) -> NSTextField {
 let textFrame = NSMakeRect(10, -10, 250, 24)
 let field = NSTextField.init(frame: textFrame)
 field.isEditable = false
 field.isBordered = false
 field.font = NSFont.init(name: "Helvetica", size: 10)
 field.stringValue = text
 return field
 }
 */
