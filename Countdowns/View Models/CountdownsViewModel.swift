//
//  CountdownsViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import CoreData


protocol CountdownsViewModeling {
   var displayedEvents: [Event] { get }

   var isViewingArchive: Bool { get set }
   var isFiltering: Bool { get }

   var eventDidEnd: (Event) -> Void { get set }

   var delegate: EventFetchDelegate? { get set }

   func sortFilterViewModel() -> SortFilterViewModeling
   func eventViewModel(_ event: Event) -> EventViewModeling
   func addViewModel() -> AddEventViewModeling
   func detailViewModel(for event: Event) -> EventDetailViewModeling
   func editViewModel(for event: Event) -> EditEventViewModeling

   func archive(_ event: Event) throws
   func delete(_ event: Event) throws
}


class CountdownsViewModel: CountdownsViewModeling {
   var displayedEvents: [Event] { eventController.events }

   var isViewingArchive: Bool {
      get { eventController.currentFilter.archived }
      set { eventController.currentFilter.archived = newValue }
   }

   var isFiltering: Bool {
      eventController.currentFilter.option != .all
   }

   var eventDidEnd: (Event) -> Void
   var didEditEvent: (Event) -> Void
   var didCreateEvent: (Event) -> Void

   var delegate: EventFetchDelegate? {
      get { eventController.delegate }
      set { eventController.delegate = newValue }
   }

   private var eventController: EventController

   private var eventVMs: [Event: EventViewModel] = [:]

   init(eventController: EventController = AppEventController(),
      eventDidEnd: @escaping (Event) -> Void,
      didEditEvent: @escaping (Event) -> Void,
      didCreateEvent: @escaping (Event) -> Void
   ) {
      self.eventController = eventController
      self.eventDidEnd = eventDidEnd
      self.didEditEvent = didEditEvent
      self.didCreateEvent = didCreateEvent
   }

   func sortFilterViewModel() -> SortFilterViewModeling {
      SortFilterViewModel(eventController)
   }

   func eventViewModel(_ event: Event) -> EventViewModeling {
      eventVMs[event] ??= EventViewModel(
         event,
         controller: eventController,
         didEditEvent: didEditEvent,
         countdownDidEnd: eventDidEnd)
   }

   func addViewModel() -> AddEventViewModeling {
      AddEventViewModel(eventController: eventController, didCreateEvent: didCreateEvent)
   }

   func detailViewModel(for event: Event) -> EventDetailViewModeling {
      eventVMs[event] ??= EventViewModel(
         event,
         controller: eventController,
         didEditEvent: didEditEvent,
         countdownDidEnd: eventDidEnd)
   }

   func editViewModel(for event: Event) -> EditEventViewModeling {
      eventVMs[event] ??= EventViewModel(
         event,
         controller: eventController,
         didEditEvent: didEditEvent,
         countdownDidEnd: eventDidEnd)
   }

   func archive(_ event: Event) throws {
      try eventController.archiveEvent(event)
   }

   func delete(_ event: Event) throws {
      eventVMs.removeValue(forKey: event)
      try eventController.deleteEvent(event)
   }
}
