//
//  EventDetailViewController.swift
//  Countdowns
//
//  Created by Jon Bash on 2019-10-21.
//  Copyright © 2019 Jon Bash. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    // MARK: - Properties
    var event: Event?
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var noteView: UITextView!
    
    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }
    
    /// Populate views with event data
    func updateViews() {
        guard let event = event else { return }
        nameLabel.text = event.name
        tagsLabel.text = event.tagsText
        noteView.text = event.note
        
        let formatter = DateFormatter.eventDateFormatter
        if !event.hasTime { formatter.timeStyle = .none }
        
        dateLabel.text = formatter.string(from: event.dateTime)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editEventVC = segue.destination as? AddEditEventViewController,
            let event = event, segue.identifier == .editEventSegue
            else { return}
        
        editEventVC.event = event
        editEventVC.editEventDelegate = self
    }

}

extension EventDetailViewController: EditEventViewControllerDelegate {}
