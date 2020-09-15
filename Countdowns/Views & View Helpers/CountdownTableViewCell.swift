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


class CountdownTableViewCell: UITableViewCell {
   private(set) var viewModel: EventViewModeling?

   // MARK: - Outlets

   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var timeRemainingLabel: UILabel!
   @IBOutlet private weak var tagsLabel: UILabel!

   func configure(with viewModel: EventViewModeling, indexPath: IndexPath) {
      viewModel.updateViewsFromEvent = { [weak self] event in
         self?.timeRemainingLabel.text = DateFormatter.formattedTimeRemaining(for: event)
      }

      // Populate subviews and set timer when event is set
      titleLabel.text = viewModel.event.name
      tagsLabel.text = viewModel.event.tagsText

      if indexPath.row % 2 == 0 {
         backgroundColor = UIColor(named: .secondaryCellBackgroundColor)
      } else {
         backgroundColor = UIColor(named: .cellBackgroundColor)
      }
      viewModel.updateViewsFromEvent?(viewModel.event)
   }
}
