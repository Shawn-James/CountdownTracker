//
//  TagController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

class TagController {
    private(set) var tags = [Tag]()
    
    func create(_ tag: Tag) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
}
