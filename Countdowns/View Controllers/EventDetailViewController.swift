//
//  EventDetailViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit


protocol EventDetailViewModeling: AnyObject {
   var event: Event { get }

   var editViewModel: EditEventViewModeling { get }
}


class EventDetailViewController: UIViewController {
   var viewModel: EventDetailViewModeling?

   // MARK: - Outlets

   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var dateLabel: UILabel!
   @IBOutlet private weak var tagsLabel: UILabel!
   @IBOutlet private weak var notesLabel: UILabel!

   let formatter = DateFormatter.eventDateFormatter

   // MARK: - View Lifecyle
   
   override func viewDidLoad() {
      super.viewDidLoad()

      updateViews()
   }

   /// Populate views with event data
   private func updateViews() {
      guard let event = viewModel?.event else { return }

//      titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle)
//         .scaledFont(for: UIFont.systemFont(ofSize: 34, weight: .bold))
      titleLabel.text = event.name
      tagsLabel.text = event.tagsText
      notesLabel.text = event.note

      formatter.timeStyle = event.hasTime ? .short : .none

      dateLabel.text = formatter.string(from: event.dateTime)
   }

   // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      guard
         let nav = segue.destination as? UINavigationController,
         let editEventVC = nav.viewControllers.first as? AddEditEventViewController,
         segue.identifier == .editEventSegue,
         let editVM = viewModel?.editViewModel
         else { return}

      editEventVC.viewModel = .b(editVM)
      editEventVC.didFinishEditing = { [weak self] in self?.updateViews() }
   }
}
