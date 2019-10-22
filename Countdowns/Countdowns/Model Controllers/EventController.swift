//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

class EventController {
    // MARK:- Properties
    
    private(set) var events = [Event]()
    private(set) var archivedEvents = [Event]()
    private var allEvents: [Event] {
        var fullList = [Event]()
        fullList.append(contentsOf: events)
        fullList.append(contentsOf: archivedEvents)
        return fullList
    }
    
    // MARK: - Singletons
    
    private static var _shared: EventController?
    
    static var shared: EventController {
        if let sharedInstance = _shared {
            return sharedInstance
        } else {
            // CHANGE THIS WHEN PERSISTENCE IS IMPLEMENTED
            //_shared = EventController()
            _shared = testInit()
            return _shared!
        }
    }
    
    static func testInit() -> EventController {
        let instance = EventController()
        instance.events.append(contentsOf: TestData.events)
        return instance
    }
    
    // MARK: Methods
    
    //func sort(by:)
    
    //func filter(by:)
    
    // MARK: - 'CRUD' methods
    
    func create(_ event: Event) {
        if !events.contains(event) {
            events.append(event)
        }
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
    }
    
    func delete(_ event: Event) {
        guard let index = events.firstIndex(of: event) else {
            fatalError("Event is not in EventController's `events` list.")
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
            print("cannot save items list; invalid url?")
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
            print("cannot load; invalid url?")
            return
        }
        if !fm.fileExists(atPath: url.path) {
            print("error loading; items list data file does not yet exist")
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
}
