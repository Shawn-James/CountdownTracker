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

   func fetchedResultsController<Object: CDFetchable>(
      for fetch: Object.FetchDescriptor,
      with context: NSManagedObjectContext? = nil
   ) -> NSFetchedResultsController<Object> {
      NSFetchedResultsController(
         fetchRequest: fetch.request(),
         managedObjectContext: context ?? mainContext,
         sectionNameKeyPath: nil,
         cacheName: nil
      )
   }

   init() {}

   func fetch<Object: CDFetchable>(
      with descriptor: Object.FetchDescriptor,
      from context: NSManagedObjectContext? = nil
   ) throws -> [Object] {
      let moc = context ?? mainContext

      return try moc.fetch(descriptor.request())
   }

   func save(in context: NSManagedObjectContext? = nil) throws {
      let moc = context ?? mainContext

      var caughtError: Error?
      moc.performAndWait {
         do {
            try moc.save()
         } catch {
            caughtError = error
         }
      }
      if let error = caughtError {
         throw error
      }
   }
}


// MARK: - NSMO Extensions

extension NSManagedObject {
   func getContext() throws -> NSManagedObjectContext {
      guard let moc = self.managedObjectContext else {
         throw CountdownError.noManagedObjectContextForObject
      }
      return moc
   }
}
