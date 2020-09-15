//
//  Persistence.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import CoreData


// TODO: Make generic & reusable (can apply to systems other than Core Data)



/// An NSManagedObject subclass that can be fetched using the CDFetchDescriptor and associated interfaces.
protocol CDFetchable: NSManagedObject {
   /// The class's associated FetchDescriptor type.
   associatedtype FetchDescriptor: CDFetchDescriptor where FetchDescriptor.Object == Self
}


/// A type with attributes for requests and predicates that makes fetching more simple and type safe for Core Data NSManagedObjects.
protocol CDFetchDescriptor: Hashable {
   associatedtype Object: CDFetchable where Object.FetchDescriptor == Self

   var sectionNameKeyPath: String? { get }

   func request() -> NSFetchRequest<Object>
}


/// Temporary stand-in for NSFetchedResultsControllerDelegate; TODO: modify to make more generic & reusable
protocol FetchDelegate: AnyObject {
   func fetchDidChange()
}

extension FetchDelegate {
   func fetchDidChange() {}
}

protocol EventFetchDelegate: FetchDelegate {
   func eventsDidChange(with events: [Event])
}
