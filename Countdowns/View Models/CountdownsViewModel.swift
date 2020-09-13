//
//  CountdownsViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


protocol CountdownsViewModeling {
   var displayedEvents: [Event] { get }
   
   var isViewingArchive: Bool { get set }
   var isFiltering: Bool { get }
//   var currentSort: EventSortDescriptor { get }
//   var currentFilter: EventFilterDescriptor { get }

   var eventDidEnd: (Event) -> Void { get set }

   var delegate: FetchDelegate? { get set }

   func sortFilterViewModel() -> SortFilterViewModeling
   func eventViewModel(
      _ event: Event)
      -> EventViewModeling
   func addViewModel(
      didCreateEvent: @escaping (Event) -> Void)
      -> AddEventViewModeling
   func detailViewModel(for event: Event) -> EventDetailViewModeling
   func editViewModel(for event: Event) -> EditEventViewModeling

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

   var delegate: FetchDelegate? {
      get { eventController.delegate }
      set { eventController.delegate = newValue }
   }

   private let eventController = EventController()

   init(eventDidEnd: @escaping (Event) -> Void) {
      self.eventDidEnd = eventDidEnd
   }

   func sortFilterViewModel() -> SortFilterViewModeling {
      SortFilterViewModel(eventController)
   }

   func eventViewModel(_ event: Event) -> EventViewModeling {
      EventViewModel(event, controller: eventController, countdownDidEnd: eventDidEnd)
   }

   func addViewModel(didCreateEvent: @escaping (Event) -> Void) -> AddEventViewModeling {
      AddEventViewModel(eventController: eventController)
   }

   func detailViewModel(for event: Event) -> EventDetailViewModeling {
      EventViewModel(event, controller: eventController, countdownDidEnd: eventDidEnd)
   }

   func editViewModel(for event: Event) -> EditEventViewModeling {
      EventViewModel(event, controller: eventController, countdownDidEnd: eventDidEnd)
   }

   func delete(_ event: Event) throws {
      try eventController.deleteEvent(event)
   }
}
