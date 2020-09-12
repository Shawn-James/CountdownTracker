//
//  EventFetch.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-11.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData


extension Event: CDFetchable {
   enum FetchDescriptor: CDFetchDescriptor {
      case all
      case unarchived
      case archived
      case uuid(UUID)

      var predicate: NSPredicate? {
         switch self {
         case .all:
            return nil
         case .unarchived:
            return NSPredicate(format: "archived == false")
         case .archived:
            return NSPredicate(format: "archived == true")
         case .uuid(let uuid):
            return NSPredicate(format: "uuid == %@", uuid as CVarArg)
         }
      }

      func request() -> NSFetchRequest<Event> {
         let request = Event.fetchRequest() as! NSFetchRequest<Event>
         request.predicate = self.predicate
         return request
      }
   }
}
