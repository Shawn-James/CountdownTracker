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
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }
    
    func updateViews() {
        guard let event = event else { return }
        nameLabel.text = event.name
        noteView.text = event.note
        
        if let imageData = event.imageData, let image = UIImage(data: imageData) {
            imageView.image = image
        }
        
        let formatter = DateFormatter.eventDateFormatter
        if !event.hasTime { formatter.timeStyle = .none }
        
        dateLabel.text = formatter.string(from: event.dateTime)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
