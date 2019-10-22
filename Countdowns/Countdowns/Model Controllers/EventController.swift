//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation

class EventController {
    // MARK: Properties
    
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
    private static var _testInstance: EventController?
    
    static var shared: EventController {
        if let sharedInstance = _shared {
            return sharedInstance
        } else {
            _shared = EventController()
            return _shared!
        }
    }
    
    static var testInstance: EventController {
        if let testInstance = _testInstance {
            return testInstance
        } else {
            _testInstance = testInit()
            _shared = _testInstance
            return _testInstance!
        }
    }
    
    static func testInit() -> EventController {
        let instance = EventController()
        instance.addTestEvents()
        return instance
    }
    
    // MARK: Methods
    
    //func sort(by:)
    
    //func filter(by:)
    
    static func newDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        let components = DateComponents(
            calendar: .current, timeZone: .current,
            year: year, month: month, day: day, hour: hour, minute: minute
        )
        guard let date = components.date else {
            print("Invalid date/time! Returning current date/time instead.")
            return Date()
        }
        return date
    }
    
    private func addTestEvents() {
        events.append(contentsOf: TestData.events)
    }
    
    func formattedTimeRemaining(for event: Event) -> String {
        let formatter = DateComponentsFormatter()
        //if event.timeRemaining.duration > 31_536_000 {
        formatter.calendar = .autoupdatingCurrent
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        
        guard let formattedTime = formatter.string(from: event.timeInterval)
            else { return "" }
            
        return formattedTime
    }
    
    // MARK: CRUD methods
    
    func create(_ event: Event) {
        events.append(event)
    }
    
    func delete(_ event: Event) {
        guard let index = events.firstIndex(of: event) else {
            fatalError("Event is not in EventController's `events` list.")
        }
        events.remove(at: index)
    }
    
    func archive(_ event: Event) {
        delete(event)
        event.archived = true
        archivedEvents.append(event)
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
