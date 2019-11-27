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
    
    private(set) var activeEvents = [Event]()
    
    private(set) var archivedEvents = [Event]()
    
    // MARK: - Computed Properties
    
    /// A list of all active + archived events combined.
    private var allEvents: [Event] {
        var fullList = [Event]()
        fullList.append(contentsOf: activeEvents)
        fullList.append(contentsOf: archivedEvents)
        return fullList
    }
    
    /// The complete list of all tags for all (active) events.
    var tags: [Tag] {
        var tags = [""]
        
        for event in allEvents {
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
    
    /// Returns the current shared instance of EventController if already existing. If not existing, creates instance.
    static var shared: EventController {
        if let sharedInstance = _shared {
            return sharedInstance
        } else {
            _shared = EventController()
            _shared?.loadEventsFromPersistenceStore()
            _shared?.loadArchivedEventsFromPersistenceStore()
            
            return _shared!
        }
    }
    
    // MARK: - Public Methods
    
    /// Add the event to the active list, set a notification for the end date, and save the list.
    func create(_ event: Event) {
        if !activeEvents.contains(event) {
            activeEvents.append(event)
        }
        
        NotificationsHelper.shared.setNotification(for: event)
        
        saveEventsToPersistenceStore()
    }
    
    /// Update the given event, save the event list, cancel the previous notification, and set a new notification.
    func update(_ event: Event,
                withName name: String, dateTime: Date, tags: [Tag],
                note: String, hasTime: Bool
    ) {
        event.name = name
        event.dateTime = dateTime
        event.tags = tags
        event.note = note
        event.hasTime = hasTime
        event.modifiedDate = Date()
        
        saveEventsToPersistenceStore()
        
        // update notification
        NotificationsHelper.shared.cancelNotification(for: event)
        NotificationsHelper.shared.setNotification(for: event)
    }
    
    /// Remove the event from the active events list and save the events list.
    func delete(_ event: Event) {
        if let index = activeEvents.firstIndex(of: event) {
            activeEvents.remove(at: index)
            saveEventsToPersistenceStore()
        } else if let index = archivedEvents.firstIndex(of: event) {
            archivedEvents.remove(at: index)
            saveArchivedEventsToPersistenceStore()
        }
    }
    
    /// Remove the event from the active event list, add it to an archive list, and save both the active and archive lists.
    func archive(_ event: Event) {
        delete(event)
        event.archived = true
        archivedEvents.append(event)
        
        saveEventsToPersistenceStore()
        saveArchivedEventsToPersistenceStore()
    }
    
    // MARK: - Sort/Filter
    
    /// Sort the lists of active & archived events by the given style.
    func sort(_ events: [Event], by style: EventController.SortStyle) -> [Event] {
        return events.sorted {
            switch style {
            case .soonToLate:
                return $0.dateTime < $1.dateTime
            case .lateToSoon:
                return $0.dateTime > $1.dateTime
            case .numberOfTags:
                return $0.tags.count < $1.tags.count
            case .numberOfTagsReversed:
                return $0.tags.count > $1.tags.count
            case .creationDate:
                return $0.creationDate < $1.creationDate
            case .creationDateReversed:
                return $0.creationDate > $1.creationDate
            case .modifiedDate:
                return $0.modifiedDate < $1.modifiedDate
            case .modifiedDateReversed:
                return $0.modifiedDate > $1.modifiedDate
            }
        }
    }
    
    /// Returns an array of events filtered by the provided filter settings
    /// from the provided events array.
    func filter(_ events: [Event], by style: FilterStyle, with filterInfo: (date: Date?, tag: Tag?)?) -> [Event] {
        return events.filter {
            switch style {
            case .none:
                return true
            case .tag:
                if let tag = filterInfo?.tag, tags.contains(tag) {
                    if tag == "" {
                        return $0.tags.isEmpty
                    } else {
                        return $0.tags.contains(tag)
                    }
                } else {
                    return false
                }
            case .noLaterThanDate:
                guard let date = filterInfo?.date else { return true }
                return $0.dateTime < date
            case .noSoonerThanDate:
                guard let date = filterInfo?.date else { return true }
                return $0.dateTime > date
            }
        }
    }
    
    // MARK: - User Defaults
    
    /// For each property, the getter gets from the current saved UserDefault (or app default) and setter saves to the UserDefaults.
    
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
    
    /// Encodes and saves events list to plist.
    private func saveEventsToPersistenceStore() {
        guard let url = eventsURL else {
            print("Invalid url for events list.")
            return
        }
        
        do {
            let encoder = PropertyListEncoder()
            let eventsData = try encoder.encode(activeEvents)
            try eventsData.write(to: url)
        } catch {
            print("Error saving events list data: \(error)")
        }
    }
    
    /// Decodes and loads events list from plist.
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
            activeEvents = try decoder.decode([Event].self, from: eventsData)
        } catch {
            print("Error loading items list data: \(error)")
        }
    }
    
    // MARK: - Archive Persistence
    
    private var archivedEventsURL: URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("cannot get archived events url; invalid directory?")
            return nil
        }
        return dir.appendingPathComponent("ArchivedEvents.plist")
    }
    
    /// Encodes and saves archived events list to plist.
    func saveArchivedEventsToPersistenceStore() {
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
    
    /// Decodes and loads events list from plist.
    private func loadArchivedEventsFromPersistenceStore() {
        let fm = FileManager.default
        guard let url = archivedEventsURL else {
            print("cannot load archived events; invalid url?")
            return
        }
        if !fm.fileExists(atPath: url.path) {
            print("error loading; archived events list data file does not yet exist")
        }
        
        do {
            let archiveData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            archivedEvents = try decoder.decode([Event].self, from: archiveData)
        } catch {
            print("Error loading archived events list data: \(error)")
        }
    }
    
    // MARK: - Sort/Filter Styles
    
    /// Custom types and display strings for sorting and filtering styles.
    
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
