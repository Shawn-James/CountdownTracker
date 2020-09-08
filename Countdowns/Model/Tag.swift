//
//  Tag.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-22.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import CoreData

class Tag: NSManagedObject {
   @NSManaged var name: String
   @NSManaged var uuid: UUID

   convenience init(name: String, context: NSManagedObjectContext) {
      self.init(context: context)

      self.name = name
      self.uuid = UUID()
   }
}
