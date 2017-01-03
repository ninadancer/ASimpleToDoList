//
//  ThingModel.swift
//  Things Need To Do
//
//  Created by 蓉蓉 邓 on 7/30/16.
//  Copyright © 2016 Fancy boy. All rights reserved.
//

import Foundation

let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
let ArchiveURL = DocumentsDirectory.appendingPathComponent("lists")
let ArchiveDeletedListsURL = DocumentsDirectory.appendingPathComponent("deletedLists")

class Lists: NSObject, NSCoding {
    
    var name: String
    
    struct PropertyKey {
        static let nameKey = "name"
    }
    
    // MARK: Initialization
    
    init?(name: String) {
        // Initialize stored properties.
        self.name = name
        super.init()
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty {
            return nil
        }
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        // Must call designated initializer.
        self.init(name: name)
    }
    
}
