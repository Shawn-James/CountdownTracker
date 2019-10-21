//
//  Event.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class Event: Codable {
    var name: String
    var dateTime: Date
    //var tags: [Tag]
    var note: String = ""
    var imageData: Data?
    var postEventNote: String?
    var archived: Bool = false
    
    var timeRemaining: DateInterval {
        return DateInterval(start: Date(), end: dateTime)
    }
    
    init(name: String, dateTime: Date, note: String = "", image: UIImage? = nil) {
        self.name = name
        self.dateTime = dateTime
        self.note = note
        if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
            self.imageData = imageData
        }
    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs === rhs
    }
}
