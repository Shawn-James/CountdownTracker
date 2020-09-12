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
   private let settings = Settings()

   var currentSortStyle: EventSort {
      get { settings.getCurrentSort() }
      set { settings.setCurrentSort(newValue) }
   }

   var currentFilter: EventFilter {
      get { (try? settings.getCurrentFilter()) ?? .none }
      set { try? settings.setCurrentFilter(newValue) }
   }

   // MARK: - Public Methods

   func fetch(_ fetch: Event.FetchDescriptor) throws -> [Event] {
      try coreDataStack.fetch(with: fetch)
   }

   /// Add the event to the active list, set a notification for the end date, and save the list.
   func create(_ event: Event) {
      let moc = coreDataStack.mainContext
      moc.performAndWait {
         moc.insert(event)
      }
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
}
