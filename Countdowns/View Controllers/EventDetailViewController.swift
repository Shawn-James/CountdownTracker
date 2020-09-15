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
   @IBOutlet weak var nameLabel: UILabel!
   @IBOutlet weak var dateLabel: UILabel!
   @IBOutlet weak var tagsLabel: UILabel!
   @IBOutlet weak var noteView: UITextView!

   let formatter = DateFormatter.eventDateFormatter

   // MARK: - View Lifecyle
   override func viewDidLoad() {
      super.viewDidLoad()

      updateViews()
   }

   /// Populate views with event data
   private func updateViews() {
      guard let event = viewModel?.event else { return }
      nameLabel.text = event.name
      tagsLabel.text = event.tagsText
      noteView.text = event.note

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
