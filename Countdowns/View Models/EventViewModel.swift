//
//  EventViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


class EventViewModel: EventViewModeling, EditEventViewModeling, EventDetailViewModeling {
   private(set) var event: Event

   lazy var newName: String = event.name
   lazy var newDateTime: Date = event.dateTime
   lazy var newNote: String = event.note
   lazy var newTagText: String = event.tagsText
   lazy var hasCustomTime: Bool = event.hasTime

   var updateViewsFromEvent: ((Event) -> Void)?
   private(set) var countdownDidEnd: (Event) -> Void
   var didEditEvent: ((Event) -> Void)

   var allTags: [Tag] { (try? controller.fetchTags(.all)) ?? [] }

   var editViewModel: EditEventViewModeling { self }

   private var countdownTimer: Timer?
   private let controller: EventController

   init(
      _ event: Event,
      controller: EventController,
      didEditEvent: @escaping (Event) -> Void,
      countdownDidEnd: @escaping (Event) -> Void
   ) {
      self.event = event
      self.controller = controller
      self.didEditEvent = didEditEvent
      self.countdownDidEnd = countdownDidEnd

      updateTimer()
   }

   func saveEvent() throws {
      try controller.update(event,
                            withName: newName,
                            dateTime: newDateTime,
                            tags: controller.parseTags(from: newTagText),
                            note: newNote,
                            hasTime: hasCustomTime)
      didEditEvent(event)
   }

   private func updateTimer() {
      // if time remaining < 1 day, update in a minute
      let update: (Timer) -> Void = { [weak self] _ in self?.updateTimer() }

      if !event.archived && event.timeRemaining < 1 {
         countdownDidEnd(event)
      } else if abs(event.timeRemaining) < 3660 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false,
            block: update)
      } else if abs(event.timeRemaining) < 86_460 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: false,
            block: update)
      }

      updateViewsFromEvent?(event)
   }
}

// MARK: - Add EVent

class AddEventViewModel: AddEventViewModeling {
   var newName: String = ""
   var newDateTime: Date = Date()
   var newNote: String = ""
   var newTagText: String = ""
   var hasCustomTime: Bool = false

   var allTags: [Tag] { (try? eventController.fetchTags(.all)) ?? [] }

   private var didCreateEvent: (Event) -> Void

   private let eventController: EventController

   init(eventController: EventController,
        didCreateEvent: @escaping (Event) -> Void
   ) {
      self.eventController = eventController
      self.didCreateEvent = didCreateEvent
   }

   func saveEvent() throws {
      let event = try eventController.createEvent(
         withName: newName,
         dateTime: newDateTime,
         tags: eventController.parseTags(from: newTagText),
         note: newNote,
         hasTime: hasCustomTime)
      didCreateEvent(event)
   }
}
