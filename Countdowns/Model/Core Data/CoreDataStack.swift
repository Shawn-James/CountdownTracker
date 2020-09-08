//
//  CoreDataStack.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-07-30.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData
import Combine


class CoreDataStack {
   lazy var container: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "Countdowns")
      container.loadPersistentStores { _, error in
         if let error = error {
            preconditionFailure("Failed to load persistent stores: \(error)")
         }
      }
      //container.viewContext.automaticallyMergesChangesFromParent = true
      return container
   }()
   var mainContext: NSManagedObjectContext { container.viewContext }
   
   @Published private(set) var error: Error?

   init() {}

   func save(in context: NSManagedObjectContext? = nil) {
      let context = context ?? mainContext

      context.perform {
         do {
            try context.save()
         } catch {
            self.error = error
         }
      }
   }
}
