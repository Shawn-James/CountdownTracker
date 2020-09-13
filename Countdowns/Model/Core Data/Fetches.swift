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
      typealias Object = Event

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
   }
}


extension Tag: CDFetchable {
   enum FetchDescriptor: CDFetchDescriptor {
      typealias Object = Tag

      case all
      case name(String)

      var predicate: NSPredicate? {
         switch self {
         case .all:
            return nil
         case .name(let name):
            return NSPredicate(format: "name == %@", name)
         }
      }
   }
}
