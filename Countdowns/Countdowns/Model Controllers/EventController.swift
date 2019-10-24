//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class EventController {
    // MARK: - Properties
    
    private(set) var events = [Event]()
    
    private(set) var archivedEvents = [Event]()
    
    // MARK: - Computed Properties
    
    var filteredEvents: [Event] {
        var filteredEvents = events
        
        switch currentFilterStyle {
        case .none:
            break
        case .noLaterThanDate:
            filteredEvents = filteredEvents.filter { $0.dateTime < currentFilterDate }
        case .noSoonerThanDate:
            filteredEvents = filteredEvents.filter { $0.dateTime > currentFilterDate }
        case .tag:
            if let existingFilterTag = currentFilterTag {
                filteredEvents = filteredEvents.filter { $0.tags.contains(existingFilterTag) }
            }
        }
        
        return filteredEvents
    }
    
    // active + archived events
    private var allEvents: [Event] {
        var fullList = [Event]()
        fullList.append(contentsOf: events)
        fullList.append(contentsOf: archivedEvents)
        return fullList
    }
    
    // all tags for all (active) events
    var tags: [Tag] {
        var tags = [Tag]()
        
        for event in events {
            for tag in event.tags {
                if !tags.contains(tag) {
                    tags.append(tag)
                }
            }
        }
        
        return tags
    }
    
    // MARK: - Singleton
    
    private static var _shared: EventController?
    
    static var shared: EventController {
        if let sharedInstance = _shared {
            return sharedInstance
        } else {
            _shared = EventController()
            _shared?.loadEventsFromPersistenceStore()
            
            return _shared!
        }
    }
    
    // MARK: - Public Methods
    
    func sort(by style: EventController.SortStyle) {
        switch style {
        case .soonToLate:
            events.sort(by: { $0.dateTime < $1.dateTime })
        case .lateToSoon:
            events.sort(by: { $0.dateTime > $1.dateTime })
        case .numberOfTags:
            events.sort(by: { $0.tags.count < $1.tags.count })
        case .numberOfTagsReversed:
            events.sort(by: { $0.tags.count > $1.tags.count })
        case .creationDate:
            events.sort(by: { $0.creationDate < $1.creationDate })
        case .creationDateReversed:
            events.sort(by: { $0.creationDate > $1.creationDate })
        case .modifiedDate:
            events.sort(by: { $0.modifiedDate < $1.modifiedDate })
        case .modifiedDateReversed:
            events.sort(by: { $0.modifiedDate > $1.modifiedDate })
        }
        saveEventsToPersistenceStore()
    }
    
    func create(_ event: Event) {
        if !events.contains(event) {
            events.append(event)
        }
        
        NotificationsHelper.shared.setNotification(for: event)
        
        saveEventsToPersistenceStore()
    }
    
    func update(_ event: Event,
                with name: String, dateTime: Date, tags: [Tag],
                note: String, image: UIImage? = nil, hasTime: Bool
    ) {
        event.name = name
        event.dateTime = dateTime
        event.tags = tags
        event.note = note
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            event.imageData = imageData
        }
        event.hasTime = hasTime
        event.modifiedDate = Date()
        
        saveEventsToPersistenceStore()
        
        // update notification
        NotificationsHelper.shared.cancelNotification(for: event)
        NotificationsHelper.shared.setNotification(for: event)
    }
    
    func delete(_ event: Event) {
        guard let index = events.firstIndex(of: event) else {
            print("ERROR: event is not in EventController's `events` list.")
            return
        }
        events.remove(at: index)
        
        saveEventsToPersistenceStore()
    }
    
    func archive(_ event: Event) {
        delete(event)
        event.archived = true
        archivedEvents.append(event)
        
        saveEventsToPersistenceStore()
        saveArchivedEventsToPersistenceStore()
    }
    
    // MARK: - User Defaults
    
    var currentSortStyle: SortStyle {
        get {
            if let sortStyleRaw = UserDefaults.standard.string(forKey: .currentSortStyle),
                let sortStyle = SortStyle(rawValue: sortStyleRaw) {
                return sortStyle
            } else {
                return .soonToLate
            }
        }
        set(newSortStyle) {
            UserDefaults.standard.set(newSortStyle.rawValue, forKey: .currentSortStyle)
        }
    }
    
    var currentFilterStyle: FilterStyle {
        get {
            if let filterStyleRaw = UserDefaults.standard.string(forKey: .currentFilterStyle),
                let filterStyle = FilterStyle(rawValue: filterStyleRaw) {
                return filterStyle
            } else {
                return .none
            }
        }
        set(newFilterStyle) {
            UserDefaults.standard.set(newFilterStyle.rawValue, forKey: .currentFilterStyle)
        }
    }
    
    var currentFilterDate: Date {
        get {
            if let filterDate = UserDefaults.standard.object(forKey: .currentFilterDate) as? Date {
                return filterDate
            } else {
                return Date()
            }
        }
        set(newDate) {
            UserDefaults.standard.set(newDate, forKey: .currentFilterDate)
        }
    }
    
    var currentFilterTag: Tag? {
        get {
            if let filterTag = UserDefaults.standard.string(forKey: .currentFilterTag) {
                return filterTag
            } else {
                return nil
            }
        }
        set(newTag) {
            UserDefaults.standard.set(newTag, forKey: .currentFilterTag)
        }
    }
    
    // MARK: - Persistence
    
    private var eventsURL: URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("cannot get events url; invalid directory?")
            return nil
        }
        return dir.appendingPathComponent("Events.plist")
    }
    
    private func saveEventsToPersistenceStore() {
        guard let url = eventsURL else {
            print("Invalid url for events list.")
            return
        }
        
        do {
            let encoder = PropertyListEncoder()
            let eventsData = try encoder.encode(events)
            try eventsData.write(to: url)
        } catch {
            print("Error saving events list data: \(error)")
        }
    }
    
    private func loadEventsFromPersistenceStore() {
        let fm = FileManager.default
        guard let url = eventsURL else {
            print("Invalid url for events list.")
            return
        }
        if !fm.fileExists(atPath: url.path) {
            print("Event list data file does not yet exist!")
            return
        }
        
        do {
            let eventsData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            events = try decoder.decode([Event].self, from: eventsData)
        } catch {
            print("Error loading items list data: \(error)")
        }
    }
    
    // MARK: -- Archive Persistence
    
    private var archivedEventsURL: URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("cannot get archived events url; invalid directory?")
            return nil
        }
        return dir.appendingPathComponent("ArchivedEvents.plist")
    }
    
    private func saveArchivedEventsToPersistenceStore() {
        guard let url = archivedEventsURL else {
            print("cannot save items list; invalid url?")
            return
        }
        
        do {
            let encoder = PropertyListEncoder()
            let archiveData = try encoder.encode(archivedEvents)
            try archiveData.write(to: url)
        } catch {
            print("Error saving items list data: \(error)")
        }
    }
    
    private func loadArchivedEventsFromPersistenceStore() {
        let fm = FileManager.default
        guard let url = archivedEventsURL else {
            print("cannot load; invalid url?")
            return
        }
        if !fm.fileExists(atPath: url.path) {
            print("error loading; items list data file does not yet exist")
        }
        
        do {
            let archiveData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            archivedEvents = try decoder.decode([Event].self, from: archiveData)
        } catch {
            print("Error loading items list data: \(error)")
        }
    }
    
    // MARK: - Sort/Filter Styles
    
    enum SortStyle: String, CaseIterable {
        case soonToLate = "End date ↓"
        case lateToSoon = "End date ↑"
        case creationDate = "Date created ↓"
        case creationDateReversed = "Date created ↑"
        case modifiedDate = "Date modified ↓"
        case modifiedDateReversed = "Date modified ↑"
        case numberOfTags = "Number of tags ↓"
        case numberOfTagsReversed = "Number of tags ↑"
    }
    
    enum FilterStyle: String, CaseIterable {
        case none = "(none)"
        case noLaterThanDate = "Now → ..."
        case noSoonerThanDate = "... → ∞"
        case tag = "Tag..."
    }
}
