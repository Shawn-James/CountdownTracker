//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit
import Combine
import CoreData


protocol EventController: AnyObject {
   var events: [Event] { get }
   var currentFilter: EventFilterDescriptor { get set }
   var currentSort: EventSortDescriptor { get set }

   var delegate: EventFetchDelegate? { get set }

   @discardableResult
   func createEvent(
      withName name: String,
      dateTime: Date,
      tags: [Tag],
      note: String,
      hasTime: Bool) throws -> Event
   func updateEvent(
      _ event: Event,
      withName: String,
      dateTime: Date,
      tags: [Tag],
      note: String,
      hasTime: Bool) throws
   func archiveEvent(_ event: Event) throws
   func deleteEvent(_ event: Event) throws

   func fetchTags(_ fetch: TagFetchDescriptor) throws -> [Tag]
   func parseTags(from tagText: String) throws -> [Tag]
}


// MARK: - App Event Controller

class AppEventController: NSObject, EventController {
   var events: [Event] = [] {
      didSet {
         delegate?.eventsDidChange(with: events)
      }
   }

   var currentSort: EventSortDescriptor {
      get { currentFetchDescriptor.sortDescriptor }
      set { currentFetchDescriptor.sortDescriptor = newValue }
   }
   var currentFilter: EventFilterDescriptor {
      get { currentFetchDescriptor.filterDescriptor }
      set { currentFetchDescriptor.filterDescriptor = newValue }
   }

   private var currentFetchDescriptor: Event.FetchDescriptor {
      didSet {
         settings.setCurrentSort(currentFetchDescriptor.sortDescriptor)
         try? settings.setCurrentFilter(currentFetchDescriptor.filterDescriptor)
         activeEventFetcher = eventFetchers[currentFetchDescriptor]
            ??= coreDataStack.fetchedResultsController(for: currentFetchDescriptor)
      }
   }

   weak var delegate: EventFetchDelegate? {
      didSet {
         resetFetchControllerDelegate()
      }
   }

   private var activeEventFetcher: NSFetchedResultsController<Event> {
      willSet { activeEventFetcher.delegate = nil }
      didSet { resetFetchControllerDelegate() }
   }

   private var eventFetchers: [Event.FetchDescriptor: NSFetchedResultsController<Event>] = [:]

   private let coreDataStack: CoreDataStack
   private let settings: Settings

   override init() {
      let settings = Settings()
      self.settings = settings
      let fetch = Event.FetchDescriptor(
         sortDescriptor: settings.getCurrentSort(),
         filterDescriptor: (try? settings.getCurrentFilter())
            ?? EventFilterDescriptor())
      self.currentFetchDescriptor = fetch
      let cdStack = CoreDataStack()
      self.coreDataStack = cdStack
      self.activeEventFetcher = cdStack.fetchedResultsController(for: currentFetchDescriptor)
      self.eventFetchers[fetch] = activeEventFetcher
      super.init()

      resetFetchControllerDelegate()
   }

   // MARK: - Public Methods

   func event(withID uuid: UUID) throws -> Event? {
      let request = Event.fetchRequest() as! NSFetchRequest<Event>
      request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
      return try coreDataStack.mainContext.fetch(request).first
   }

   func fetchEvents(_ fetch: Event.FetchDescriptor) throws -> [Event] {
      try coreDataStack.fetch(with: fetch)
   }

   func fetchTags(_ fetch: Tag.FetchDescriptor) throws -> [Tag] {
      try coreDataStack.fetch(with: fetch)
   }

   /// Add the event to the active list, set a notification for the end date, and save the list.
   @discardableResult func createEvent(
      withName name: String,
      dateTime: Date,
      tags: [Tag],
      note: String,
      hasTime: Bool
   ) throws -> Event {
      let moc = coreDataStack.mainContext
      let event = Event(
         name: name,
         dateTime: dateTime,
         tags: Set(tags),
         note: note,
         hasTime: hasTime,
         context: moc)
      try moc.save()
      return event
   }

   func createTag(_ name: String) throws -> Tag {
      let moc = coreDataStack.mainContext
      let tag = Tag(name: name, context: moc)
      try coreDataStack.save(in: moc)
      return tag
   }

   /// Update the given event, save changes, and reset the event's user notification.
   func updateEvent(
      _ event: Event,
      withName name: String,
      dateTime: Date,
      tags: [Tag],
      note: String,
      hasTime: Bool
   ) throws {
      let moc = try event.getContext()

      moc.performAndWait {
         event.name = name
         event.dateTime = dateTime
         event.nsmanagedTags.removeAllObjects()
         tags.forEach(event.addTag(_:))
         event.note = note
         event.hasTime = hasTime
         event.modifiedDate = Date()
      }
      try coreDataStack.save(in: moc)

      // update notification
      NotificationsHelper.shared.cancelNotification(for: event)
      NotificationsHelper.shared.setNotification(for: event)
   }

   func archiveEvent(_ event: Event) throws {
      let moc = try event.getContext()

      moc.performAndWait {
         event.archived = true
      }
      try coreDataStack.save(in: moc)
   }

   func deleteEvent(_ event: Event) throws {
      let moc = try event.getContext()

      moc.performAndWait {
         moc.delete(event)
      }
      try coreDataStack.save(in: moc)
   }

   /// If tags were entered, separate by commas, strip extraneous whitespace,
   /// and return for use in saving the event. Empty tags are not allowed.
   func parseTags(from tagText: String) throws -> [Tag] {
      try tagText
         .split(separator: .tagSeparator, omittingEmptySubsequences: true)
         .lazy
         .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
         .filter({ !$0.isEmpty })
         .compactMap(tagForName(_:))
   }

   // MARK: - Private

   private func tagForName(_ tagName: String) throws -> Tag {
      try fetchTags(.name(tagName)).first ?? (try createTag(tagName))
   }

   private func resetFetchControllerDelegate() {
      activeEventFetcher.delegate = self
      do {
         try activeEventFetcher.performFetch()
      } catch {
         print(error) // todo: handle error
      }
   }
}

// MARK: - Fetch Delegate

extension AppEventController: NSFetchedResultsControllerDelegate {
   func controller(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>,
      didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
   ) {
      if currentSort.nsSortDescriptor() == nil {
         events = activeEventFetcher.fetchedObjects?.sorted(by: currentSort) ?? []
      } else {
         events = activeEventFetcher.fetchedObjects ?? []
      }
   }
}
