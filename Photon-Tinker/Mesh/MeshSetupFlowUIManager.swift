//
// Created by Raimundas Sakalauskas on 04/09/2018.
// Copyright © 2018 Particle. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import MessageUI

class MeshSetupFlowUIManager : UIViewController, Storyboardable, MeshSetupFlowManagerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonImage: UIImageView!
    
    
    private var flowManager: MeshSetupFlowManager!
    private var embededNavigationController: UINavigationController!

    private var targetDeviceDataMatrix: MeshSetupDataMatrix?
    private var alert: UIAlertController?
    private var lockAlert: Bool = false //when critical alert is shown, this is set to true


    override func awakeFromNib() {
        super.awakeFromNib()

        self.flowManager = MeshSetupFlowManager(delegate: self)
        self.flowManager.startSetup()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(isBusyChanged), name: Notification.Name.MeshSetupViewControllerBusyChanged, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedNavigation") {
            self.embededNavigationController = segue.destination as! UINavigationController
            self.embededNavigationController.delegate = self

            let findStickerVC = MeshSetupFindStickerViewController.loadedViewController()
            findStickerVC.setup(didPressScan: self.showTargetDeviceScanSticker)
            findStickerVC.allowBack = false
            self.embededNavigationController.setViewControllers([findStickerVC], animated: false)
        }
        super.prepare(for: segue, sender: sender)
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.backButton.isHidden = !(viewController as! MeshSetupViewController).allowBack
        self.backButtonImage.isHidden = self.backButton.isHidden
        self.backButtonImage.alpha = 1
        self.backButton.isUserInteractionEnabled = false //prevent back button during animation
        log("ViewControllers: \(navigationController.viewControllers)")
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.backButton.isUserInteractionEnabled = !self.backButtonImage.isHidden
    }

    @objc func isBusyChanged(notification: Notification) {
        self.backButtonImage.alpha = (embededNavigationController.topViewController as! MeshSetupViewController).isBusy ? 0.5 : 1
    }

    private func rewindTo<T>(_ vcType: T.Type) -> Bool {
        //rewinding
        for vc in self.embededNavigationController.viewControllers {
            if type(of: vc) == vcType.self {
                (vc as! MeshSetupViewController).resume(animated: false)
                self.embededNavigationController.popToViewController(vc, animated: true)
                log("Rewinding to: \(vc)")
                return true
            }
        }
        return false
    }

    private func log(_ message: String) {
        ParticleLogger.logInfo("MeshSetupFlowUI", format: message, withParameters: getVaList([]))
    }

    //MARK: Get Target Device Info
    func meshSetupDidRequestTargetDeviceInfo() {
        //do nothing here
    }

    func showTargetDeviceScanSticker() {
        log("sticker found by user")

        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupScanStickerViewController.self)) {
                let scanVC = MeshSetupScanStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.setTargetDeviceStickerString)
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }

    func setTargetDeviceStickerString(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.validateMatrix(dataMatrixString, targetDevice: true)
    }

    private func validateMatrix(_ dataMatrixString: String, targetDevice: Bool, deviceType: ParticleDeviceType? = nil) {
        if let matrix = MeshSetupDataMatrix(dataMatrixString: dataMatrixString, deviceType: deviceType) {
            if (matrix.type != nil && matrix.isMobileSecretValid()) {
                if (targetDevice) {
                    self.targetDeviceDataMatrix = matrix
                    self.showTargetDeviceGetReady()
                } else {
                    self.showCommissionerDevicePairing(dataMatrixString: dataMatrixString)
                }
            } else if (matrix.type == nil) {
                self.log("Attempting to recover unknown device type")
                recoverUnknownDeviceType(matrix: matrix, targetDevice: targetDevice)
            } else {
                self.log("Attempting to recover incomplete mobile secret")
                recoverIncompleteMobileSecret(matrix: matrix, targetDevice: targetDevice)
            }
        } else {
            showWrongMatrixError(targetDevice: targetDevice)
        }
    }


    private func recoverUnknownDeviceType(matrix: MeshSetupDataMatrix, targetDevice: Bool) {
        matrix.attemptDeviceTypeRecovery { recoveredType, error in
            if let recoveredType = recoveredType {
                self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: recoveredType)
            } else if let nserror = error as? NSError, nserror.code == 404 {
                self.showWrongMatrixError(targetDevice: targetDevice)
            } else {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.NetworkError.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                            self.cancelTapped(self)
                        })

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                            self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: matrix.type)
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            }
        }
    }


    private func recoverIncompleteMobileSecret(matrix: MeshSetupDataMatrix, targetDevice: Bool) {
        matrix.attemptMobileSecretRecovery { recoveredMatrixString, error in
            if let recoveredString = recoveredMatrixString {
                self.validateMatrix(recoveredString, targetDevice: targetDevice)
            } else if let nserror = error as? NSError, nserror.code == 200 {
                self.showFailedMatrixRecoveryError(dataMatrix: matrix)
            } else {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.NetworkError.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                            self.cancelTapped(self)
                        })

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                            self.validateMatrix(matrix.matrixString, targetDevice: targetDevice, deviceType: matrix.type)
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            }
        }
    }




    func showWrongMatrixError(targetDevice: Bool) {
        //show error where selected device type mismatch
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle,
                        message: targetDevice ? MeshSetupFlowError.WrongTargetDeviceType.description : MeshSetupFlowError.WrongCommissionerDeviceType.description,
                        preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    private func showFailedMatrixRecoveryError(dataMatrix: MeshSetupDataMatrix) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: MeshSetupFlowError.StickerError.description, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                    self.restartCaptureSession()
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.ContactSupport, style: .default) { action in
                    self.openEmailClient(dataMatrix: dataMatrix)
                    self.restartCaptureSession()
                })

                self.present(self.alert!, animated: true)
            }
        }
    }

    private func openEmailClient(dataMatrix: MeshSetupDataMatrix) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        composeVC.setToRecipients(["hello@particle.io"])
        composeVC.setSubject("3rd generation sticker problem")
        composeVC.setMessageBody("""
                                -- BEFORE SENDING Please attach a picture of the device sticker! --

                                Hi Particle! My sticker barcode has an issue.

                                Serial number: \(dataMatrix.serialNumber)
                                Full scan results: \(dataMatrix.serialNumber) \(dataMatrix.mobileSecret)
                                """, isHTML: false)

        self.present(composeVC, animated: true)
    }

    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }



    func showTargetDeviceGetReady() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupGetReadyViewController.self)) {
                let getReadyVC = MeshSetupGetReadyViewController.loadedViewController()
                getReadyVC.setup(didPressReady: self.showTargetDevicePairing, dataMatrix: self.targetDeviceDataMatrix!)
                self.embededNavigationController.pushViewController(getReadyVC, animated: true)
            }
        }
    }



    func showTargetDevicePairing(useEthernet: Bool) {
        log("target device ready")

        if let error = flowManager.setTargetDeviceInfo(dataMatrix: self.targetDeviceDataMatrix!, useEthernet: useEthernet) {
            DispatchQueue.main.async {
                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: error.description, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                        DispatchQueue.main.async {
                            if (!self.rewindTo(MeshSetupScanStickerViewController.self)) {
                                let scanVC = MeshSetupScanStickerViewController.loadedViewController()
                                scanVC.setup(didFindStickerCode: self.setTargetDeviceStickerString)
                                self.embededNavigationController.pushViewController(scanVC, animated: true)
                            }
                        }
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        } else {
            self.flowManager.pauseSetup()
            DispatchQueue.main.async {
                if (!self.rewindTo(MeshSetupPairingProcessViewController.self)) {
                    let pairingVC = MeshSetupPairingProcessViewController.loadedViewController()
                    pairingVC.allowBack = false
                    pairingVC.setup(didFinishScreen: self.targetDevicePairingScreenDone, deviceType: self.flowManager.context.targetDevice.type, deviceName: self.flowManager.context.targetDevice.bluetoothName ?? self.flowManager.context.targetDevice.type!.description)
                    self.embededNavigationController.pushViewController(pairingVC, animated: true)
                }
            }
        }
    }

    func targetDevicePairingScreenDone() {
        self.flowManager.continueSetup()
    }

    func meshSetupDidRequestToUpdateFirmware() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFirmwareUpdateViewController.self)) {
                let prepareUpdateFirmwareVC = MeshSetupFirmwareUpdateViewController.loadedViewController()
                prepareUpdateFirmwareVC.setup(didPressContinue: self.didSelectToUpdateFirmware)
                prepareUpdateFirmwareVC.allowBack = false
                self.embededNavigationController.pushViewController(prepareUpdateFirmwareVC, animated: true)
            }
        }
    }

    func didSelectToUpdateFirmware() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFirmwareUpdateProgressViewController.self)) {
                let updateFirmwareVC = MeshSetupFirmwareUpdateProgressViewController.loadedViewController()
                updateFirmwareVC.setup(didFinishScreen: self.targetDeviceFirmwareUpdateScreenDone)
                updateFirmwareVC.allowBack = false
                self.embededNavigationController.pushViewController(updateFirmwareVC, animated: true)
            }
        }

        self.flowManager.setTargetPerformFirmwareUpdate(update: true)
    }

    func targetDeviceFirmwareUpdateScreenDone() {
        self.flowManager.continueSetup()
    }

    func meshSetupDidRequestToLeaveNetwork(network: MeshSetupNetworkInfo) {
        DispatchQueue.main.async {
            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.LeaveNetworkTitle, message: MeshSetupStrings.Prompt.LeaveNetworkText, preferredStyle: .alert)

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.LeaveNetwork, style: .default) { action in
                    self.flowManager.setTargetDeviceLeaveNetwork(leave: true)
                })

                self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.DontLeaveNetwork, style: .cancel) { action in
                    self.flowManager.setTargetDeviceLeaveNetwork(leave: false)
                })

                self.present(self.alert!, animated: true)
            }
        }
    }


    func meshSetupDidRequestToSelectStandAloneOrMeshSetup() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupStandAloneOrMeshSetupViewController.self)) {
                let setupVC = MeshSetupStandAloneOrMeshSetupViewController.loadedViewController()
                setupVC.allowBack = false
                setupVC.setup(setupMesh: self.didSelectToSetupMesh, deviceType: self.flowManager.context.targetDevice.type)
                self.embededNavigationController.pushViewController(setupVC, animated: true)
            }
        }
    }

    func didSelectToSetupMesh(setupMesh: Bool) {
        flowManager.setSelectStandAloneOrMeshSetup(meshSetup: setupMesh)
    }



    func meshSetupDidRequestToShowPricingInfo(info: ParticlePricingInfo) {
        DispatchQueue.main.async {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupPricingInfoViewController {
                //the call has been retried and if cc was added it should pass this time
                self.didFinishPricingInfo()
            } else {
                if (!self.rewindTo(MeshSetupPricingInfoViewController.self)) {
                    let pricingInfoVC = MeshSetupPricingInfoViewController.loadedViewController()
                    pricingInfoVC.rewindFlowOnBack = true
                    pricingInfoVC.setup(didPressContinue: self.didFinishPricingInfo, pricingInfo: info)
                    self.embededNavigationController.pushViewController(pricingInfoVC, animated: true)
                }
            }
        }
    }

    private func didFinishPricingInfo() {
        if let error = self.flowManager.setPricingImpactDone() {
            DispatchQueue.main.async {
                var message = error.description

                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: message, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                        //reload pricing impact endpoint
                        self.flowManager.retryLastAction()
                    })

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .cancel) { action in
                        //do nothing
                        self.cancelTapped(self)
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        }
    }



    //MARK: Gateway Info
    func meshSetupDidRequestToShowInfo() {
        if let activeInternetInterface = self.flowManager.context.targetDevice.activeInternetInterface {
            switch activeInternetInterface {
                case .ethernet:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupInfoEthernetViewController.self)) {
                            let infoVC = MeshSetupInfoEthernetViewController.loadedViewController()
                            infoVC.rewindFlowOnBack = true
                            infoVC.setup(didFinishScreen: self.didFinishInfoScreen, setupMesh: self.flowManager.context.userSelectedToSetupMesh!, deviceType: self.flowManager.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .wifi:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupInfoWifiViewController.self)) {
                            let infoVC = MeshSetupInfoWifiViewController.loadedViewController()
                            infoVC.rewindFlowOnBack = true
                            infoVC.setup(didFinishScreen: self.didFinishInfoScreen, setupMesh: self.flowManager.context.userSelectedToSetupMesh!, deviceType: self.flowManager.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(infoVC, animated: true)
                        }
                    }
                case .ppp:
                    DispatchQueue.main.async {
                        if (!self.rewindTo(MeshSetupCellularInfoViewController.self)) {
                            let cellularInfoVC = MeshSetupCellularInfoViewController.loadedViewController()
                            cellularInfoVC.rewindFlowOnBack = true
                            cellularInfoVC.setup(didFinishScreen: self.didFinishInfoScreen, setupMesh: self.flowManager.context.userSelectedToSetupMesh!, simActive: self.flowManager.context.targetDevice.simActive ?? false, deviceType: self.flowManager.context.targetDevice.type!)
                            self.embededNavigationController.pushViewController(cellularInfoVC, animated: true)
                        }
                    }
                default:
                    //others are not interesting
                    break
            }
        } else {
            DispatchQueue.main.async {
                if (!self.rewindTo(MeshSetupInfoJoinerViewController.self)) {
                    let infoVC = MeshSetupInfoJoinerViewController.loadedViewController()
                    //if we are setting up gateway device, user will be asked to select if he wants to setup mesh
                    //for xenons this will be nil.
                    infoVC.rewindFlowOnBack = self.flowManager.context.userSelectedToSetupMesh != nil
                    infoVC.setup(didFinishScreen: self.didFinishInfoScreen, setupMesh: self.flowManager.context.userSelectedToSetupMesh, deviceType: self.flowManager.context.targetDevice.type!)
                    self.embededNavigationController.pushViewController(infoVC, animated: true)
                }
            }
        }
    }

    func didFinishInfoScreen() {
        self.flowManager.setInfoDone()
    }


    func meshSetupDidRequestToEnterDeviceName() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupNameDeviceViewController.self)) {
                let nameVC = MeshSetupNameDeviceViewController.loadedViewController()
                nameVC.allowBack = false
                nameVC.setup(didEnterName: self.didEnterName, deviceType: self.flowManager.context.targetDevice.type, currentName: self.flowManager.context.targetDevice.name)
                self.embededNavigationController.pushViewController(nameVC, animated: true)
            }
        }
    }

    func didEnterName(name: String) {
        flowManager.setDeviceName(name: name) { error in
            if error == nil {
                //this will happen automatically
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupNameDeviceViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }





    //MARK: Scan WIFI networks
    private func showScanWifiNetworks() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectWifiNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectWifiNetworkViewController.loadedViewController()
                    networksVC.rewindFlowOnBack = true
                    networksVC.setup(didSelectNetwork: self.didSelectWifiNetwork)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    func didSelectWifiNetwork(network: MeshSetupNewWifiNetworkInfo) {
        flowManager.setSelectedWifiNetwork(selectedNetwork: network)
    }

    func meshSetupDidRequestToSelectWifiNetwork(availableNetworks: [MeshSetupNewWifiNetworkInfo]) {
        NSLog("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanWifiNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanWifiNetworks()
                }
            }
        }
    }

    private func rescanWifiNetworks() {
        if self.flowManager.context.selectedWifiNetworkInfo == nil {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectWifiNetworkViewController {
                if (flowManager.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    NSLog("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }





    //MARK: Wifi network password
    func meshSetupDidRequestToEnterSelectedWifiNetworkPassword() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupWifiNetworkPasswordViewController.self)) {
                let passwordVC = MeshSetupWifiNetworkPasswordViewController.loadedViewController()
                passwordVC.rewindFlowOnBack = true
                passwordVC.setup(didEnterPassword: self.didEnterWifiNetworkPassword, networkName: self.flowManager.context.selectedWifiNetworkInfo!.ssid)
                self.embededNavigationController.pushViewController(passwordVC, animated: true)
            }
        }
    }

    func didEnterWifiNetworkPassword(password: String) {
        flowManager.setSelectedWifiNetworkPassword(password) { error in
            if error == nil {
                //this will happen automatically
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupWifiNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }


    //MARK: Scan networks
    private func showSelectNetwork() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectNetworkViewController.loadedViewController()
                    networksVC.rewindFlowOnBack = true
                    networksVC.setup(didSelectNetwork: self.didSelectNetwork)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    private func showSelectOrCreateNetwork() {
        DispatchQueue.main.async {
            if let _ = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController {
                //do nothing
            } else {
                if (!self.rewindTo(MeshSetupSelectOrCreateNetworkViewController.self)) {
                    let networksVC = MeshSetupSelectOrCreateNetworkViewController.loadedViewController()
                    networksVC.setup(didSelectNetwork: self.didSelectOptionalNetwork)
                    self.embededNavigationController.pushViewController(networksVC, animated: true)
                }
            }
        }
    }

    func didSelectNetwork(network: MeshSetupNetworkCellInfo?) {
        guard network != nil else {
            log("Selected empty network for joiner flow")
            return
        }

        flowManager.setSelectedNetwork(selectedNetworkExtPanID: network!.extPanID)
    }


    func didSelectOptionalNetwork(network: MeshSetupNetworkCellInfo?) {
        flowManager.setOptionalSelectedNetwork(selectedNetworkExtPanID: network?.extPanID)
    }


    func meshSetupDidRequestToSelectNetwork(availableNetworks: [MeshSetupNetworkCellInfo]) {
        NSLog("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanNetworks()
                }
            }
        }
    }


    func meshSetupDidRequestToSelectOrCreateNetwork(availableNetworks: [MeshSetupNetworkCellInfo]) {
        NSLog("scan complete")

        //if by the time this returned, user has already selected the network, ignore the results of last scan
        if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController {
            vc.setNetworks(networks: availableNetworks)

            //if no networks found = force instant rescan
            if (availableNetworks.count == 0) {
                rescanNetworks()
            } else {
                //rescan in 3seconds
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    [weak self] in
                    //only rescan if user hasn't made choice by now
                    self?.rescanNetworks()
                }
            }
        }
    }

    private func rescanNetworks() {
        if self.flowManager.context.selectedNetworkMeshInfo == nil {
            if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectNetworkViewController {
                if (flowManager.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    NSLog("rescanNetworks was attempted when it shouldn't be")
                }
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupSelectOrCreateNetworkViewController, self.flowManager.context.userSelectedToCreateNetwork == nil {
                if (flowManager.rescanNetworks() == nil) {
                    vc.startScanning()
                } else {
                    NSLog("rescanNetworks was attempted when it shouldn't be")
                }
            }
        }
    }


    //MARK: Connect to selected network
    func meshSetupDidRequestCommissionerDeviceInfo() {
        log("requesting commisioner info!!")

        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupScanCommissionerStickerViewController.self)) {
                let getReadyVC = MeshSetupGetCommissionerReadyViewController.loadedViewController()
                getReadyVC.rewindFlowOnBack = true
                getReadyVC.setup(didPressReady: self.showCommissionerDeviceFindSticker, deviceType: self.flowManager.context.targetDevice.type, networkName: self.flowManager.context.selectedNetworkMeshInfo!.name)
                self.embededNavigationController.pushViewController(getReadyVC, animated: true)
            }
        }
    }

    func showCommissionerDeviceFindSticker() {
        log("commissioner device ready")

        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupFindCommissionerStickerViewController.self)) {
                let findStickerVC = MeshSetupFindCommissionerStickerViewController.loadedViewController()
                findStickerVC.setup(didPressScan: self.showCommissionerDeviceScanSticker, networkName: self.flowManager.context.selectedNetworkMeshInfo!.name)
                self.embededNavigationController.pushViewController(findStickerVC, animated: true)
            }
        }
    }

    func showCommissionerDeviceScanSticker() {
        log("sticker found by user")

        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupScanCommissionerStickerViewController.self)) {
                let scanVC = MeshSetupScanCommissionerStickerViewController.loadedViewController()
                scanVC.setup(didFindStickerCode: self.setCommissionerDeviceStickerString)
                self.embededNavigationController.pushViewController(scanVC, animated: true)
            }
        }
    }

    func setCommissionerDeviceStickerString(dataMatrixString:String) {
        log("dataMatrix scanned: \(dataMatrixString)")
        self.validateMatrix(dataMatrixString, targetDevice: false)
    }


    //user successfully scanned target code
    func showCommissionerDevicePairing(dataMatrixString: String) {
        log("dataMatrix validated: \(dataMatrixString)")

        //make sure the scanned device is of the same type as user requested in the first screen
        if let matrix = MeshSetupDataMatrix(dataMatrixString: dataMatrixString),
            let deviceType = matrix.type {

            if let error = flowManager.setCommissionerDeviceInfo(dataMatrix: matrix) {
                DispatchQueue.main.async {
                    if (self.hideAlertIfVisible()) {
                        self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: error.description, preferredStyle: .alert)

                        self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                            self.restartCaptureSession()
                        })

                        self.present(self.alert!, animated: true)
                    }
                }
            } else {
                self.flowManager.pauseSetup()

                DispatchQueue.main.async {
                    if (!self.rewindTo(MeshSetupPairingCommissionerProcessViewController.self)) {
                        let pairingVC = MeshSetupPairingCommissionerProcessViewController.loadedViewController()
                        pairingVC.setup(didFinishScreen: self.commissionerDevicePairingScreenDone, deviceType: self.flowManager.context.commissionerDevice?.type, deviceName: self.flowManager.context.commissionerDevice?.bluetoothName ?? deviceType.description)
                        self.embededNavigationController.pushViewController(pairingVC, animated: true)
                    }
                }
            }
        } else {
            restartCaptureSession()
        }
    }


    private func restartCaptureSession() {
        if let vc = self.embededNavigationController.topViewController as? MeshSetupScanCommissionerStickerViewController {
            vc.resume(animated: true)
        } else if let vc = self.embededNavigationController.topViewController as? MeshSetupScanStickerViewController {
            vc.resume(animated: true)
        } else {
            NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupScanCommissionerStickerViewController / MeshSetupScanStickerViewController.restartCaptureSession was attempted when it shouldn't be")
        }
    }

    func commissionerDevicePairingScreenDone() {
        self.flowManager.continueSetup()
    }

    func meshSetupDidRequestToEnterSelectedNetworkPassword() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupNetworkPasswordViewController.self)) {
                let passwordVC = MeshSetupNetworkPasswordViewController.loadedViewController()
                passwordVC.rewindFlowOnBack = true
                passwordVC.allowBack = false
                passwordVC.setup(didEnterPassword: self.didEnterNetworkPassword, networkName: self.flowManager.context.selectedNetworkMeshInfo!.name)
                self.embededNavigationController.pushViewController(passwordVC, animated: true)
            }
        }
    }

    func didEnterNetworkPassword(password: String) {
        flowManager.setSelectedNetworkPassword(password) { error in
            if error == nil {
                //this will happen automatically
            } else if let vc = self.embededNavigationController.topViewController as? MeshSetupNetworkPasswordViewController {
                vc.setWrongInput(message: error!.description)
            }
        }
    }

    private func showJoiningNetwork() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupJoiningNetworkViewController.self)) {
                let joiningVC = MeshSetupJoiningNetworkViewController.loadedViewController()
                joiningVC.allowBack = false
                joiningVC.setup(didFinishScreen: self.didFinishJoinNetworkScreen, networkName: self.flowManager.context.selectedNetworkMeshInfo!.name, deviceType: self.flowManager.context.targetDevice.type)
                self.embededNavigationController.pushViewController(joiningVC, animated: true)
            }
        }
    }




    func didFinishJoinNetworkScreen() {
        self.flowManager.continueSetup()
    }





    func meshSetupDidRequestToAddOneMoreDevice() {
        DispatchQueue.main.async {
            if (self.flowManager.context.userSelectedToCreateNetwork != nil && self.flowManager.context.userSelectedToCreateNetwork!) {
                //this is the end of create network flow
                if (!self.rewindTo(MeshSetupNetworkCreatedViewController.self)) {
                    let successVC = MeshSetupNetworkCreatedViewController.loadedViewController()
                    successVC.setup(didSelectDone: self.didSelectSetupDone, deviceName: self.flowManager.context.commissionerDevice!.name!) //at this point the target device has already been marked as commissioner
                    self.embededNavigationController.pushViewController(successVC, animated: true)
                }
            } else {
                //this is the end of joiner or standalone flow
                if (!self.rewindTo(MeshSetupSuccessViewController.self)) {
                    let successVC = MeshSetupSuccessViewController.loadedViewController()
                    successVC.allowBack = false
                    successVC.setup(didSelectDone: self.didSelectSetupDone, deviceName: self.flowManager.context.targetDevice.name!, networkName: self.flowManager.context.selectedNetworkMeshInfo?.name)
                    self.embededNavigationController.pushViewController(successVC, animated: true)
                }
            }
        }
    }

    func didSelectSetupDone(done: Bool) {
        flowManager.setAddOneMoreDevice(addOneMoreDevice: !done)

        if (done) {
            //setup done
            self.dismiss(animated: true)
        } else {
            targetDeviceDataMatrix = nil

            let findStickerVC = MeshSetupFindStickerViewController.loadedViewController()
            findStickerVC.setup(didPressScan: self.showTargetDeviceScanSticker)
            self.embededNavigationController.setViewControllers([findStickerVC], animated: true)
        }
    }



    //MARK: Connect to internet
    private func showConnectingToInternet() {
        switch self.flowManager.context.targetDevice.activeInternetInterface! {
            case .ethernet:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetEthernetViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetEthernetViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetEthernetViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.setup(didFinishScreen: self.didFinishConnectToInternetScreen, deviceType: self.flowManager.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .wifi:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetWifiViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetWifiViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetWifiViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.setup(didFinishScreen: self.didFinishConnectToInternetScreen, deviceType: self.flowManager.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            case .ppp:
                DispatchQueue.main.async {
                    if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetCellularViewController {
                        vc.setState(.TargetDeviceConnectingToInternetStarted)
                    } else {
                        if (!self.rewindTo(MeshSetupConnectingToInternetCellularViewController.self)) {
                            let connectingVC = MeshSetupConnectingToInternetCellularViewController.loadedViewController()
                            connectingVC.allowBack = false
                            connectingVC.setup(didFinishScreen: self.didFinishConnectToInternetScreen, deviceType: self.flowManager.context.targetDevice.type)
                            self.embededNavigationController.pushViewController(connectingVC, animated: true)
                        }
                    }
                }
            default:
                //others are not interesting
                break
        }



    }

    func didFinishConnectToInternetScreen() {
        self.flowManager.continueSetup()
    }



    func meshSetupDidRequestToEnterNewNetworkNameAndPassword() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreateNetworkNameViewController.self)) {
                let networkNameVC = MeshSetupCreateNetworkNameViewController.loadedViewController()
                networkNameVC.setup(didEnterNetworkName: self.didEnterCreateNetworkName)
                networkNameVC.rewindFlowOnBack = true
                self.embededNavigationController.pushViewController(networkNameVC, animated: true)
            }
        }
    }

    func didEnterCreateNetworkName(networkName: String) {
        if let error = self.flowManager.setNewNetworkName(name: networkName),
           let vc = self.embededNavigationController.topViewController as? MeshSetupCreateNetworkNameViewController {
            vc.setWrongInput(message: error.description)
        } else {
            showCreateNetworkPassword()
        }
    }


    private func showCreateNetworkPassword() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreateNetworkPasswordViewController.self)) {
                let networkPasswordVC = MeshSetupCreateNetworkPasswordViewController.loadedViewController()
                networkPasswordVC.setup(didEnterNetworkPassword: self.didEnterCreateNetworkPassword)
                self.embededNavigationController.pushViewController(networkPasswordVC, animated: true)
            }
        }
    }

    func didEnterCreateNetworkPassword(networkPassword: String) {
        if let error = self.flowManager.setNewNetworkPassword(password: networkPassword),
           let vc = self.embededNavigationController.topViewController as? MeshSetupCreateNetworkPasswordViewController{
            vc.setWrongInput(message: error.description)
        }
    }


    private func showCreateNetwork() {
        DispatchQueue.main.async {
            if (!self.rewindTo(MeshSetupCreatingNetworkViewController.self)) {
                let createNetworkVC = MeshSetupCreatingNetworkViewController.loadedViewController()
                createNetworkVC.allowBack = false
                createNetworkVC.setup(didFinishScreen: self.createNetworkScreenDone, deviceType: self.flowManager.context.targetDevice.type, deviceName: self.flowManager.context.targetDevice.name)
                self.embededNavigationController.pushViewController(createNetworkVC, animated: true)
            }
        }
    }

    func meshSetupDidCreateNetwork(network: MeshSetupNetworkCellInfo) {
        //nothing needs to be done on ui side
    }

    func createNetworkScreenDone() {
        // simply do nothing. screen will be exited automatically
    }


    func meshSetupDidEnterState(state: MeshSetupFlowState) {
        log("flow setup entered state: \(state)")

        switch state {
            case .TargetDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingProcessViewController {
                    vc.setSuccess()
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupPairingProcessViewController.setSuccess was attempted when it shouldn't be. If this is happening not during BLE OTA Update, this shouldn't be.")
                }
            case .CommissionerDeviceReady:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupPairingCommissionerProcessViewController {
                    vc.setSuccess()
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupPairingCommissionerProcessViewController.setSuccess was attempted when it shouldn't be")
                }


            case .FirmwareUpdateProgress:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    vc.setProgress(progress: Int(round(self.flowManager.context.targetDevice.firmwareUpdateProgress ?? 0)))
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setProgress was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateFileComplete:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    vc.setFileComplete()
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setFileComplete was attempted when it shouldn't be")
                }
                break;
            case .FirmwareUpdateComplete:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupFirmwareUpdateProgressViewController {
                    self.flowManager.pauseSetup()
                    vc.setFirmwareUpdateComplete()
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupFirmwareUpdateProgressViewController.setFirmwareUpdateComplete was attempted when it shouldn't be")
                }
                break;


            case .TargetDeviceScanningForWifiNetworks:
                showScanWifiNetworks()
            case .TargetDeviceScanningForNetworks:
                showSelectNetwork()
            case .TargetInternetConnectedDeviceScanningForNetworks:
                showSelectOrCreateNetwork()


            case .TargetDeviceConnectingToInternetStarted:
                showConnectingToInternet()
            case .TargetDeviceConnectingToInternetStep1Done, .TargetDeviceConnectingToInternetStep0Done, .TargetDeviceConnectingToInternetCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetEthernetViewController {
                    if state == .TargetDeviceConnectingToInternetCompleted {
                        self.flowManager.pauseSetup()
                    }
                    vc.setState(state)
                } else if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetWifiViewController {
                    if state == .TargetDeviceConnectingToInternetCompleted {
                        self.flowManager.pauseSetup()
                    }
                    vc.setState(state)
                } else if let vc = self.embededNavigationController.topViewController as? MeshSetupConnectingToInternetCellularViewController {
                    if state == .TargetDeviceConnectingToInternetCompleted {
                        self.flowManager.pauseSetup()
                    }
                    vc.setState(state)
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupConnectToInternetViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .JoiningNetworkStarted:
                showJoiningNetwork()
            case .JoiningNetworkStep1Done, .JoiningNetworkStep2Done, .JoiningNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupJoiningNetworkViewController {
                    if state == .JoiningNetworkCompleted {
                        self.flowManager.pauseSetup()
                    }

                    vc.setState(state)
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupJoiningNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .CreateNetworkStarted:
                showCreateNetwork()
            case .CreateNetworkStep1Done, .CreateNetworkCompleted:
                if let vc = self.embededNavigationController.topViewController as? MeshSetupCreatingNetworkViewController {
                    vc.setState(state)
                } else {
                    NSLog("!!!!!!!!!!!!!!!!!!!!!!! MeshSetupCreatingNetworkViewController.setState was attempted when it shouldn't be: \(state)")
                }

            case .SetupCanceled:
                self.cancelTapped(self)
            default:
                break;



        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        //resume previous VC
        let vcs = self.embededNavigationController.viewControllers
        log("Back tapped: \(vcs)")

        if (vcs.last! as! MeshSetupViewController).viewControllerIsBusy {
            log("viewController is busy, not backing")
            //view controller cannot be backed from at this moment
            return
        }

        if vcs.count > 1 {
            (vcs[vcs.count-2] as! MeshSetupViewController).resume(animated: false)
        }

        if (vcs.last! as! MeshSetupViewController).rewindFlowOnBack {
            log("Rewinding")
            self.flowManager.rewindFlow()
        } else if (vcs.last! as! MeshSetupViewController).allowBack {
            log("Popping")
            self.embededNavigationController.popViewController(animated: true)
        } else {
            log("Back button was pressed when it was not supposed to be pressed. Ignoring.")
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        if let _ = sender as? MeshSetupFlowUIManager {
            self.flowManager.cancelSetup()
            self.dismiss(animated: true)
        } else {
            DispatchQueue.main.async {
                if (self.hideAlertIfVisible()) {
                    self.alert = UIAlertController(title: MeshSetupStrings.Prompt.CancelSetupTitle, message: MeshSetupStrings.Prompt.CancelSetupText, preferredStyle: .alert)

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.CancelSetup, style: .default) { action in
                        self.cancelTapped(self)
                    })

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.ContinueSetup, style: .cancel) { action in
                        //do nothing
                    })

                    self.present(self.alert!, animated: true)
                }
            }
        }
    }


    func meshSetupError(error: MeshSetupFlowError, severity: MeshSetupErrorSeverity, nsError: Error?) {
        DispatchQueue.main.async {

            var message = error.description

            if let apiError = nsError as? NSError {
                message = "\(message) (\(apiError.localizedDescription))" 
            }

            if (self.hideAlertIfVisible()) {
                self.alert = UIAlertController(title: MeshSetupStrings.Prompt.ErrorTitle, message: message, preferredStyle: .alert)

                if (severity == .Fatal) {
                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Ok, style: .default) { action in
                        self.cancelTapped(self)
                    })
                } else {
                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Retry, style: .default) { action in
                        self.flowManager.retryLastAction()
                    })

                    self.alert!.addAction(UIAlertAction(title: MeshSetupStrings.Action.Cancel, style: .cancel) { action in
                        self.cancelTapped(self)
                    })
                }

                self.present(self.alert!, animated: true)
            }
        }
    }


    private func hideAlertIfVisible() -> Bool {
        if (self.lockAlert) {
            return false
        }

        if (alert?.viewIfLoaded?.window != nil) {
            alert!.dismiss(animated: false)
            return true
        } else {
            return true
        }
    }
}
