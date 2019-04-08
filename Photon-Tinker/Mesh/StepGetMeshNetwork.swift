//
// Created by Raimundas Sakalauskas on 2019-03-04.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

class StepGetMeshNetwork: MeshSetupStep {
    private var meshNetworkInfoLoaded = false
    private var apiNetworksLoaded = false

    override func reset() {
        meshNetworkInfoLoaded = false
        apiNetworksLoaded = false
    }

    override func start() {
        guard let context = self.context else {
            return
        }

        if (!meshNetworkInfoLoaded) {
            self.getTargetDeviceMeshNetworkInfo()
        } else if (!apiNetworksLoaded) {
            self.getAPINetworks()
        } else {
            self.stepCompleted()
        }
    }

    private func getTargetDeviceMeshNetworkInfo() {
        context?.targetDevice.transceiver!.sendGetNetworkInfo { [weak self, weak context] result, networkInfo in

            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("targetDevice.sendGetNetworkInfo: \(result.description())")
            self.log("\(networkInfo as Optional)");

            if (result == .NOT_FOUND) {
                self.meshNetworkInfoLoaded = true
                context.targetDevice.meshNetworkInfo = nil
                self.start()
            } else if (result == .NONE) {
                self.meshNetworkInfoLoaded = true
                if (networkInfo!.networkID.count == 0) {
                    context.targetDevice.meshNetworkInfo = nil
                } else {
                    context.targetDevice.meshNetworkInfo = networkInfo
                }
                self.start()
            } else {
                self.handleBluetoothErrorResult(result)
            }
        }
    }

    override func rewindTo(context: MeshSetupContext) {
        super.rewindTo(context: context)

        guard let context = self.context else {
            return
        }

        context.targetDevice.meshNetworkInfo = nil
    }

    func getAPINetworks() {
        ParticleCloud.sharedInstance().getNetworks { [weak self, weak context] networks, error in
            guard let self = self, let context = context, !context.canceled else {
                return
            }

            self.log("getNetworks: \(networks as Optional), error: \(error as Optional)")
            guard error == nil else {
                self.fail(withReason: .UnableToRetrieveNetworks, nsError: error)
                return
            }

            self.apiNetworksLoaded = true

            if let networks = networks {
                context.apiNetworks = networks
            } else {
                context.apiNetworks = []
            }

            self.stepCompleted()
        }
    }
}

