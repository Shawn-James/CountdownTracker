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


class EventController {
   var events: [Event] { activeEventFetcher.fetchedObjects ?? [] }

   var viewingArchive: Bool = false

   var currentSortStyle: EventSortDescriptor {
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

   weak var delegate: FetchDelegate? {
      didSet { activeEventFetcher.delegate = delegate as? NSFetchedResultsControllerDelegate }
   }

   private var activeEventFetcher: NSFetchedResultsController<Event> {
      willSet { activeEventFetcher.delegate = nil }
      didSet {
         activeEventFetcher.delegate = delegate as? NSFetchedResultsControllerDelegate
         try? activeEventFetcher.performFetch()
      }
   }

   private var eventFetchers: [Event.FetchDescriptor: NSFetchedResultsController<Event>] = [:]

   private let coreDataStack = CoreDataStack()
   private let settings = Settings()

   init() {
      let fetch = Event.FetchDescriptor(
         sortDescriptor: settings.getCurrentSort(),
         filterDescriptor: (try? settings.getCurrentFilter())
            ?? EventFilterDescriptor())
      currentFetchDescriptor = fetch
      activeEventFetcher = eventFetchers[fetch]
         ??= coreDataStack.fetchedResultsController(for: currentFetchDescriptor)
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
      moc.performAndWait {
         moc.insert(event)
      }
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
   func update(
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
         tags.forEach(event.addTag(_:))
         event.note = note
         event.hasTime = hasTime
         event.modifiedDate = Date()
      }

      // update notification
      NotificationsHelper.shared.cancelNotification(for: event)
      NotificationsHelper.shared.setNotification(for: event)
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

   private func tagForName(_ tagName: String) throws -> Tag {
      try fetchTags(.name(tagName)).first ?? (try createTag(tagName))
   }
}
