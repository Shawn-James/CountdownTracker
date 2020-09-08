//
//  EventController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import Foundation
import Combine


class EventController {

   private let coreDataStack = CoreDataStack()

   // MARK: - Public Methods

   /// Add the event to the active list, set a notification for the end date, and save the list.
   func create(_ event: Event) {
      unimplemented()
   }

   /// Update the given event, save the event list, cancel the previous notification, and set a new notification.
   func update(_ event: Event,
               withName name: String, dateTime: Date, tags: [Tag],
               note: String, hasTime: Bool
   ) {
      event.name = name
      event.dateTime = dateTime
      tags.forEach(event.addTag(_:))
      event.note = note
      event.hasTime = hasTime
      event.modifiedDate = Date()

      saveEventsToPersistenceStore()

      // update notification
      NotificationsHelper.shared.cancelNotification(for: event)
      NotificationsHelper.shared.setNotification(for: event)
   }

   func delete(_ event: Event) {
      event.managedObjectContext?.performAndWait {
         event.managedObjectContext?.delete(event)
      }

      return coreDataStack.save(in: event.managedObjectContext)
   }

   /// Remove the event from the active event list, add it to an archive list, and save both the active and archive lists.
   func archive(_ event: Event) -> AnyPublisher<Void, Error> {
      event.managedObjectContext?.perform {
         event.archived = true
      }
   }

   // MARK: - User Defaults

   /// For each property, the getter gets from the current saved UserDefault (or app default) and setter saves to the UserDefaults.

   var currentSortStyle: EventSort {
      get {
         if let sortStyle = EventSort(
               rawValue: UserDefaults.standard.integer(
                  forKey: .currentSortStyle))
         {
            return sortStyle
         } else {
            return EventSort()
         }
      }
      set {
         UserDefaults.standard.set(newValue.rawValue, forKey: .currentSortStyle)
      }
   }

   func currentFilter() throws -> EventFilter {
      guard let filterData = UserDefaults.standard.data(forKey: .currentFilter)
      else {
         throw EventFilter.Error.noData
      }

      return try JSONDecoder().decode(EventFilter.self, from: filterData)
   }

   // MARK: - Persistence

   /// Encodes and saves events list to plist.
   private func saveEventsToPersistenceStore() {
      unimplemented()
   }

   /// Decodes and loads events list from plist.
   private func loadEventsFromPersistenceStore() {
      unimplemented()
   }

   /// Encodes and saves archived events list to plist.
   func saveArchivedEventsToPersistenceStore() {
      unimplemented()
   }

   /// Decodes and loads events list from plist.
   private func loadArchivedEventsFromPersistenceStore() {
      unimplemented()
   }
}

