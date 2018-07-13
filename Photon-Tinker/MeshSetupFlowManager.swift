//
//  MeshSetupFlowManager.swift
//  Particle
//
//  Created by Ido Kleinman on 7/3/18.
//  Copyright © 2018 spark. All rights reserved.
//

import Foundation

// TODO: define flows
enum MeshSetupFlowType {
    case None
    case Detecting
    case InitialXenon
    case InitialArgon
    case InitialBoron
    case InitialESP32 // future
    case ModifyXenon // future
    case ModifyArgon // future
    case ModifyBoron // future
    case ModifyESP32 // future
    case Diagnostics // future
    
}


enum MeshSetupErrorSeverity {
    case Info
    case Warning
    case Error
    case Fatal
}

// future
enum flowErrorAction {
    case Dialog
    case Pop
    case Fail
}

protocol MeshSetupFlowManagerDelegate {
    //    required
    func flowError(error : String, severity : MeshSetupErrorSeverity, action : flowErrorAction) //
    func scannedNetworks(networkNames: [String]?)
}




class MeshSetupFlowManager: NSObject, MeshSetupBluetoothConnectionFactoryDelegate, MeshSetupProtocolManagerDelegate {
    func bluetoothConnectionFactoryError(error: String, severity: MeshSetupErrorSeverity) {
        //..
    }
    
    func bluetoothConnectionCreated(connection: MeshSetupBluetoothConnection) {
        //..
    }
    
    func bluetoothConnectionDropped(connection: MeshSetupBluetoothConnection) {
        //..
    }
    

    var bluetoothConnectionFactory : MeshSetupBluetoothConnectionFactory?
    var commissionerBluetoothManager : MeshSetupBluetoothConnectionFactory?
    var protocolManager  : MeshSetupProtocolManager?
    var flowType : MeshSetupFlowType = .None
//    var delegate : MeshSetupFlowManagerDelegate?
    var currentFlow : MeshSetupFlow?
    var deviceType : ParticleDeviceType?
    var delegate : MeshSetupFlowManagerDelegate?
    
//    var mobileSecret : String?
//    var serialNumber : String?
    
//    var claimCode : String?
    //    var flowState : ...
    
    // meant to be initialized after choosing device type + scanning sticker
    init?(deviceType : ParticleDeviceType, stickerData : String) {
        super.init()
        
        self.deviceType = deviceType
        
        let (serialNumber, mobileSecret) = self.getStickerParameters(stickerData: stickerData)
//        let mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        
        var joinerPeripheralName : String
        switch deviceType {
            case .argon :
                joinerPeripheralName = "Argon-"+serialNumber.suffix(6)
            case .xenon :
                joinerPeripheralName = "Xenon-"+serialNumber.suffix(6)
            case .boron :
                joinerPeripheralName = "Boron-"+serialNumber.suffix(6)
            case .ESP32 :
                joinerPeripheralName = "ESP32-"+serialNumber.suffix(6)
            default:
                return nil
        }
        
        self.flowType = .Detecting
        self.bluetoothConnectionFactory = MeshSetupBluetoothConnectionFactory(delegate : self)
        self.bluetoothConnectionFactory?.scanAndConnect(to: joinerPeripheralName)
        
        
        
    }

    // init?(...modify...)
    private func getStickerParameters(stickerData : String) -> (serialNumer : String, mobileSecret : String) {
        let arr = stickerData.split(separator: "_")
        let serialNumber = String(arr[0])//"12345678abcdefg"
        let mobileSecret = String(arr[1])//"ABCDEFGHIJKLMN"
        return (serialNumber, mobileSecret)
    }
    
    
    // MARK: MeshSetupProtocolManagerDelegate
    func didReceiveDeviceIdReply(deviceId: String) {
        self.currentFlow!.didReceiveDeviceIdReply(deviceId: deviceId)
    }
    
    func didReceiveClaimCodeReply() {
        self.currentFlow!.didReceiveClaimCodeReply()
    }
    
    func didReceiveAuthReply() {
        //..
    }
    
    func didReceiveIsClaimedReply(isClaimed: Bool) {
        // first action that happens before flow class instance is determined (TBD: commissioner password request in future for already setup devices or getNetworkInfo - to see if device already on mesh or any other future commands)
        if (isClaimed == false) {
            switch self.deviceType! {
            case .xenon :
                self.currentFlow = MeshSetupInitialXenonFlow(flowManager: self)
                self.flowType = .InitialXenon
            default:
                self.delegate?.flowError(error: "Device not supported yet", severity: .Fatal, action: .Fail)
                return
            }
        } else {
            switch self.deviceType {
                default:
                    self.delegate?.flowError(error: "Device already claimed - flow not supported yet", severity: .Fatal, action: .Fail)
                    return
            }
        }
        
        self.currentFlow!.start()
    }
    
    func didReceiveCreateNetworkReply(networkInfo: MeshSetupNetworkInfo) {
        //..
    }
    
    func didReceiveStartCommissionerReply() {
        //..
    }
    
    func didReceiveStopCommissionerReply() {
        //..
    }
    
    func didReceivePrepareJoinerReply(eui64: String, password: String) {
        //..
    }
    
    func didReceiveAddJoinerReply() {
        //..
    }
    
    func didReceiveRemoveJoinerReply() {
        //..
    }
    
    func didReceiveJoinNetworkReply() {
        //..
    }
    
    func didReceiveSetClaimCodeReply() {
        self.currentFlow?.didReceiveSetClaimCodeReply()
    }
    
    func didReceiveLeaveNetworkReply() {
        self.currentFlow!.didReceiveLeaveNetworkReply()
    }
    
    func didReceiveGetNetworkInfoReply(networkInfo: MeshSetupNetworkInfo?) {
        self.currentFlow!.didReceiveGetNetworkInfoReply(networkInfo: networkInfo)
    }
    
    func didReceiveScanNetworksReply(networks: [MeshSetupNetworkInfo]) {
        self.currentFlow!.didReceiveScanNetworksReply(networks: networks)
    }
    
    func didReceiveGetSerialNumberReply(serialNumber: String) {
        //
    }
    
    func didReceiveGetConnectionStatusReply(connectionStatus: CloudConnectionStatus) {
        //
    }
    
    func didReceiveTestReply() {
        //
        print("Test control message to device OK")
    }
    
    func didReceiveErrorReply(error: ControlRequestErrorType) {
        self.delegate?.flowError(error: "Device returned control message reply error \(error.description())", severity: .Error, action: .Pop)
    }
    
    
    // MARK: MeshSetupBluetoothManaherDelegate
    func bluetoothDisabled() {
        self.flowType = .None
        self.delegate?.flowError(error: "Bluetooth is disabled, please enable bluetooth on your phone to setup your device", severity: .Fatal, action: .Fail)
//        self.delegate?.errorBluetoothDisabled()
    }
    
    func messageToUser(level: RMessageType, message: String) {
        // TODO: do we need this? maybe refactor
    }
    
    func didDisconnectPeripheral() {
        self.flowType = .None
        self.delegate?.flowError(error: "Device disconnected from phone", severity: .Fatal, action: .Fail)
//        self.delegate?.errorPeripheralDisconnected()
    }
    
    func peripheralReadyForData()
    {
        // first action for all flows is checking if device is claimed - to determine whether its initial setup process or not (update SDD)
        // TODO: add timeout timer after each send
        self.protocolManager?.sendIsClaimed()
    }
    
    func peripheralNotSupported() {
        self.flowType = .None
        self.delegate?.flowError(error: "Device does not seems to be a Particle device", severity: .Fatal, action: .Fail)
//        self.delegate?.errorPeripheralNotSupported()
        
    }
    
    func didReceiveData(data buffer: Data) {
        self.protocolManager?.didReceiveData(data: buffer)
    }
    
  
    

}