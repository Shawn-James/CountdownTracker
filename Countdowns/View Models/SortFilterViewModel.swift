//
//  SortFilterViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


protocol SortFilterViewModeling: AnyObject {
   var tags: [Tag] { get }

   var didChange: (() -> Void)? { get set }
   var didFinish: (() -> Void)? { get set }

   var currentSort: EventSortDescriptor { get set }
   var currentFilter: EventFilterDescriptor { get set }
}


class SortFilterViewModel: SortFilterViewModeling {
   var tags: [Tag] { (try? controller.fetchTags(.all)) ?? [] }

   var currentSort: EventSortDescriptor {
      get {
         controller.currentSort
      }
      set {
         controller.currentSort = newValue
         didChange?()
      }
   }
   var currentFilter: EventFilterDescriptor {
      get {
         controller.currentFilter
      }
      set {
         controller.currentFilter = newValue
         didChange?()
      }
   }

   var didChange: (() -> Void)?
   var didFinish: (() -> Void)?

   private var controller: EventController

   init(_ controller: EventController) {
      self.controller = controller
   }

   deinit {
      didFinish?()
   }
}
