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
