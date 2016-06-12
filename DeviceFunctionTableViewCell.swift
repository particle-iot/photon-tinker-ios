//
//  DeviceFunctionTableViewCell.swift
//  Particle
//
//  Created by Ido Kleinman on 5/16/16.
//  Copyright © 2016 spark. All rights reserved.
//

import Foundation

internal class DeviceFunctionTableViewCell: DeviceDataTableViewCell {
    
    var functionName : String? {
        didSet {
            if self.functionName == "" {
                self.noFunctionsLabel.hidden = false
                self.functionNameButton.hidden = true
                self.argumentsButton.hidden = true
            } else {
                self.functionNameButton.setTitle(self.functionName!+"  ", forState: .Normal)
            }
        }
    }

    @IBOutlet weak var noFunctionsLabel: UILabel!
    @IBAction func callButtonTapped(sender: AnyObject) {
        var args = [String]()
        args.append(self.argumentsTextField.text!)
        self.resultLabel.hidden = true
        self.activityIndicator.startAnimating()
        self.device?.callFunction(self.functionName!, withArguments: args, completion: { (resultValue :NSNumber?, error: NSError?) in
            self.resultLabel.hidden = false
            self.activityIndicator.stopAnimating()
            if let _ = error  {
                self.resultLabel.text = "Error"
            } else {
                self.resultLabel.text = resultValue?.stringValue
            }
        })
    }
    @IBOutlet weak var argumentsButton: UIButton!
    @IBOutlet weak var functionNameButton: UIButton!
    @IBOutlet weak var argumentsTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.argumentsTextField.hidden = !selected
//        self.argumentsTitleLabel.hidden = !selected
//        self.callButton.hidden = !selected
//        self.centerFunctionNameLayoutConstraint.constant = selected ? -20 : 0
    }
    
//    @IBAction func argumentsButtonTapped(sender: AnyObject) {
//        self.setSelected(!self.selected, animated: true)
//    }
    
}