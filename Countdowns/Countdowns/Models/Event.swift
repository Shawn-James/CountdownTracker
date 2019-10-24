//
//  Event.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class Event: Codable {
    // MARK: - Properties
    var uuid: String
    var name: String
    var dateTime: Date
    var tags: [Tag]
    var note: String = ""
    var imageData: Data?
    var hasTime: Bool
    var creationDate: Date
    var modifiedDate: Date
    
    var didNotifyDone: Bool = false
    var archived: Bool = false
    
    // MARK: - Computed Properties
    
    var eventPassed: Bool {
        return Date() > dateTime
    }

    var timeInterval: TimeInterval {
        return dateTime.timeIntervalSinceNow 
    }
    
    var tagsText: String {
        var tagsText = ""
        for i in 0 ..< tags.count {
            tagsText += "\(tags[i])"
            if i != tags.count - 1 {
                tagsText += ", "
            }
        }
        return tagsText
    }
    
    // MARK: - Init
    init(name: String, dateTime: Date, tags: [Tag] = [], note: String = "", image: UIImage? = nil, hasTime: Bool = false) {
        self.name = name
        self.dateTime = dateTime
        self.tags = tags
        self.note = note
        self.hasTime = hasTime
        if let image = image, let imageData = image.jpegData(compressionQuality: 1.0) {
            self.imageData = imageData
        }
        self.creationDate = Date()
        self.modifiedDate = creationDate
        self.uuid = UUID().uuidString
    }
}

// MARK: - Extensions

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs === rhs
    }
}
