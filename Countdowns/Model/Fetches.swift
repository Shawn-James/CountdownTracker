//
//  EventFetch.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-11.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData


extension Event: CDFetchable {
   typealias FetchDescriptor = EventFetchDescriptor
}

struct EventFetchDescriptor: CDFetchDescriptor, Hashable {
   typealias Object = Event

   var sortDescriptor: EventSortDescriptor
   var filterDescriptor: EventFilterDescriptor

   var sectionNameKeyPath: String? { nil }

   static let unarchived: Self = EventFetchDescriptor(
      sortDescriptor: EventSortDescriptor(),
      filterDescriptor: EventFilterDescriptor())
   static let archived: Self = EventFetchDescriptor(
      sortDescriptor: EventSortDescriptor(),
      filterDescriptor: EventFilterDescriptor(archived: true))

   func request() -> NSFetchRequest<Event> {
      let request = Event.fetchRequest() as! NSFetchRequest<Event>
      request.sortDescriptors = [sortDescriptor.nsSortDescriptor()
         ?? NSSortDescriptor(keyPath: \Event.dateTime, ascending: true)]
      request.predicate = filterDescriptor.nsPredicate
      return request
   }

   func hash(into hasher: inout Hasher) {
      // limit hash elements so when number of options doesn't get out of hand when using as dictionary key (eg with fetched results controller)
      hasher.combine(sortDescriptor.rawValue)
      hasher.combine(filterDescriptor.option.intValue)
      hasher.combine(filterDescriptor.archived)
   }
}

extension Tag: CDFetchable {
   typealias FetchDescriptor = TagFetchDescriptor
}

enum TagFetchDescriptor: CDFetchDescriptor, Hashable {
   typealias Object = Tag

   case all
   case name(String)

   var sectionNameKeyPath: String? { nil }

   var predicate: NSPredicate? {
      switch self {
      case .all:
         return nil
      case .name(let name):
         return NSPredicate(format: "name == %@", name)
      }
   }

   func request() -> NSFetchRequest<Tag> {
      let request = Tag.fetchRequest() as! NSFetchRequest<Tag>
      request.predicate = self.predicate
      return request
   }
}
