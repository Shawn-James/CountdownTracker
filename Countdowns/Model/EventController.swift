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

   private let coreDataStack = CoreDataStack()

   // MARK: - Public Methods

   func fetch(_ fetch: Event.FetchDescriptor) throws -> [Event] {
      try coreDataStack.fetch(with: fetch)
   }

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
   private func saveArchivedEventsToPersistenceStore() {
      unimplemented()
   }

   /// Decodes and loads events list from plist.
   private func loadArchivedEventsFromPersistenceStore() {
      unimplemented()
   }
}
