//
// Created by Raimundas Sakalauskas on 2019-03-15.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class MeshSetupControlPanelUnclaimViewController : MeshSetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: MeshLabel!
    @IBOutlet weak var textLabel: MeshLabel!
    @IBOutlet weak var continueButton: MeshSetupButton!

    private var unclaimCallback: ((Bool) -> ())!

    override var customTitle: String {
        return MeshSetupStrings.ControlPanel.Unclaim.Title
    }

    override var allowBack: Bool {
        get {
            return true
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(deviceName: String, callback: @escaping (Bool) -> ()) {
        self.deviceName = deviceName
        self.unclaimCallback = callback
    }

    override func setStyle() {
        titleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.ExtraLargeSize, color: MeshSetupStyle.PrimaryTextColor)
        textLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
        continueButton.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.RegularSize)
    }

    override func setContent() {
        titleLabel.text = MeshSetupStrings.ControlPanel.Unclaim.TextTitle
        textLabel.text = MeshSetupStrings.ControlPanel.Unclaim.Text
        continueButton.setTitle(MeshSetupStrings.ControlPanel.Unclaim.UnclaimButton, for: .normal)
    }

    
    @IBAction func continueButtonClicked(_ sender: Any) {
        self.fade()
        self.unclaimCallback(true)
    }
}