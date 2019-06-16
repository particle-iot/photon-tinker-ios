//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright © 2018 Particle. All rights reserved.
//

import UIKit
import CoreBluetooth

class MeshSetupControlPanelFlowCompleteViewController: MeshSetupViewController, Storyboardable {

    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successTitleLabel: MeshLabel!
    @IBOutlet weak var successTextLabel: MeshLabel!


    internal private(set) weak var context: MeshSetupContext!
    internal private(set) var action: MeshSetupControlPanelCellType!
    internal private(set) var callback: (() -> ())!

    override var allowBack: Bool {
        get {
            return false
        }
        set {
            super.allowBack = newValue
        }
    }

    func setup(didFinishScreen: @escaping () -> (), deviceType: ParticleDeviceType?, deviceName: String, action: MeshSetupControlPanelCellType, context: MeshSetupContext) {
        self.callback = didFinishScreen
        self.deviceType = deviceType
        self.deviceName = deviceName
        self.action = action
        self.context = context
    }

    override func setStyle() {
        successTitleLabel.setStyle(font: MeshSetupStyle.BoldFont, size: MeshSetupStyle.LargeSize, color: MeshSetupStyle.PrimaryTextColor)
        successTextLabel.setStyle(font: MeshSetupStyle.RegularFont, size: MeshSetupStyle.RegularSize, color: MeshSetupStyle.PrimaryTextColor)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSuccess()
    }

    override func setContent() {
        switch action! {
            case .actionChangeDataLimit:
                self.successTitleLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ChangeDataLimit.Title
                self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ChangeDataLimit.Text
            case .actionNewWifi:
                self.successTitleLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.AddNewWifi.Title
                self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.AddNewWifi.Text
            case .actionChangePinsStatus:
                self.successTitleLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleEthernet.Title
                if (context.targetDevice.enableEthernetDetectionFeature!) {
                    self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleEthernet.ActivateText
                } else {
                    self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleEthernet.DeactivateText
                }
            case .actionChangeSimStatus:
                self.successTitleLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleSim.Title
                if (context.targetDevice.setSimActive!) {
                    self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleSim.ActivateText
                } else {
                    self.successTextLabel.text = MeshSetupStrings.ControlPanel.FlowComplete.ToggleSim.DeactivateText
                }
            default:
                break
        }
    }

    func setSuccess() {
        DispatchQueue.main.async {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                [weak self] in
                if let callback = self?.callback {
                    callback()
                }
            }
        }
    }
}