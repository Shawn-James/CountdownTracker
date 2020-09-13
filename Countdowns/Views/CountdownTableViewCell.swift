//
//  CountdownTableViewCell.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


protocol EventViewModeling: AnyObject {
   var event: Event { get }
   var updateViewsFromEvent: ((Event) -> Void)? { get set }
}

class EventViewModel: EventViewModeling {
   private(set) var event: Event

   var updateViewsFromEvent: ((Event) -> Void)?
   private(set) var countdownDidEnd: (Event) -> Void

   private var countdownTimer: Timer?

   init(_ event: Event, countdownDidEnd: @escaping (Event) -> Void) {
      self.event = event
      self.countdownDidEnd = countdownDidEnd

      updateTimer()
   }

   private func updateTimer() {
      // if time remaining < 1 day, update in a minute
      let update: (Timer) -> Void = { [weak self] _ in self?.updateTimer() }

      if !event.archived && event.timeInterval < 1 {
         countdownDidEnd(event)
      } else if abs(event.timeInterval) < 3660 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false,
            block: update)
      } else if abs(event.timeInterval) < 86_460 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: false,
            block: update)
      }

      updateViewsFromEvent?(event)
   }
   
}


class CountdownTableViewCell: UITableViewCell {
   var viewModel: EventViewModeling? {
      didSet {
         guard let vm = viewModel else { return }

         vm.updateViewsFromEvent = { [weak self] event in
            self?.timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
         }

         // Populate subviews and set timer when event is set
         titleLabel.text = vm.event.name
         tagsLabel.text = vm.event.tagsText
      }
   }

   // MARK: - Outlets

   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var timeRemainingLabel: UILabel!
   @IBOutlet private weak var tagsLabel: UILabel!
}
