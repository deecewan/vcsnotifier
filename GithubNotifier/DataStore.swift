//
//  DataStore.swift
//  GithubNotifier
//
//  Created by David Buchan-Swanson on 20/6/17.
//  Copyright © 2017 David Buchan-Swanson. All rights reserved.
//

import Foundation

class Item {
    let id: String;
    let link: String;
    let title: String;
    let repoName: String;

    var dirty: Bool = false;
    var clean: Bool {
        get {
            return !self.dirty
        }
    }
    var rendered: Bool = false;
    
    init(id: String, link: String, title: String, repoName: String, dirty: Bool = true) {
        self.id = id
        self.link = link
        self.title = title
        self.repoName = repoName;
        self.dirty = dirty;
    }
    
    func markRendered(visible: Bool) {
        self.rendered = visible;
    }

    // the 'dirty' state means that this item has come in fresh. after each refresh,
    // go through the list (maybe beforethe render) and remove all 'clean' items
    // the remaining ones are the recent notification list

    func markDirty() {
        self.dirty = true;
    }

    func markClean() {
        self.dirty = false;
    }
}

class DataStore {
    var DataStore: Array = [Item]()
    var observer: (Void) -> Void = {};

    func observe(with cb: @escaping (Void) -> Void) {
        observer = cb;
    }

    var count: Int {
        get {
            return DataStore.count
        }
    }
    
    func getIds() -> [String] {
        var ids = [String]()
        for item in DataStore {
            ids.append(item.id)
        }
        return ids
    }

    func append(item: Item) -> Void {
        // need to check it exists, and only add if it doesn't
        // otherwise, we mess with the rendered state
        let found = DataStore.first(where: {storeItem in return storeItem.id == item.id})
        if found != nil {
            found!.markDirty()
        } else {
            DataStore.append(item)
        }
        observer()
    }
    
    func append(id: String, title: String, link: String, repo: String) {
        self.append(item: Item.init(id: id, link: link, title: title, repoName: repo))
    }
    
    func get(id: String) -> Item? {
        let found = DataStore.first(where: {item in return item.id == id})
        if found != nil {
            return found
        }
        return nil
    }
    
    func iter() -> IndexingIterator<Array<Item>> {
        return DataStore.makeIterator()
    }
    
    func remove(id: String) {
        if let index = DataStore.index(where: {item in return item.id == id}) {
            DataStore.remove(at: index)
            observer()
        }
    }

    func cleanAll() {
        for item in DataStore {
            item.markClean();
        }
        observer()
    }

    func clear() {
        DataStore.removeAll()
        observer()
    }
}
