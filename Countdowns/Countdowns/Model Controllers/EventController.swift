//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

class EventController {
    private(set) var events = [Event]()
    private(set) var archivedEvents = [Event]()
    private var allEvents = [Event]()
    
    //func sort(by:)
    
    //func filter(by:)
    
    func delete(_ event: Event) {
        guard let index = events.firstIndex(of: event) else {
            fatalError("Event is not in EventController's `events` list.")
        }
        events.remove(at: index)
    }
    
    func archive(_ event: Event) {
        delete(event)
        archivedEvents.append(event)
    }
}
