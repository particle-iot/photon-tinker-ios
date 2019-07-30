//
// Created by Raimundas Sakalauskas on 2019-04-17.
// Copyright (c) 2019 spark. All rights reserved.
//

import Foundation

enum MeshSetupControlPanelCellType {
    case name
    case notes

    case wifi
    case cellular
    case ethernet
    case mesh
    case documentation
    case unclaim

    case actionNewWifi
    case actionManageWifi

    case actionChangeSimStatus
    case actionChangeDataLimit

    case actionChangePinsStatus

    case actionPromoteToGateway
    case actionDemoteFromGateway


    case meshInfoNetworkName
    case meshInfoNetworkID
    case meshInfoNetworkExtPanID
    case meshInfoNetworkPanID
    case meshInfoNetworkChannel
    case meshInfoNetworkDeviceCount
    case meshInfoDeviceRole


    case wifiInfoSSID
    case wifiInfoChannel
    case wifiInfoRSSI


    case actionLeaveMeshNetwork
    case actionAddToMeshNetwork

    func getCellTitle(context: MeshSetupContext) -> String {
        switch self {
            case .name:
                return MeshSetupStrings.ControlPanel.Root.Name
            case .notes:
                return MeshSetupStrings.ControlPanel.Root.Notes
            case .wifi:
                return MeshSetupStrings.ControlPanel.Root.Wifi
            case .cellular:
                return MeshSetupStrings.ControlPanel.Root.Cellular
            case .ethernet:
                return MeshSetupStrings.ControlPanel.Root.Ethernet
            case .mesh:
                return MeshSetupStrings.ControlPanel.Root.Mesh
            case .documentation:
                return MeshSetupStrings.ControlPanel.Root.Documentation
            case .unclaim:
                return MeshSetupStrings.ControlPanel.Root.UnclaimDevice

            case .actionNewWifi:
                return MeshSetupStrings.ControlPanel.Wifi.AddNewWifi
            case .actionManageWifi:
                return MeshSetupStrings.ControlPanel.Wifi.ManageWifi

            case .wifiInfoSSID:
                return MeshSetupStrings.ControlPanel.Wifi.SSID
            case .wifiInfoChannel:
                return MeshSetupStrings.ControlPanel.Wifi.Channel
            case .wifiInfoRSSI:
                return MeshSetupStrings.ControlPanel.Wifi.RSSI


            case .actionChangeSimStatus:
                return MeshSetupStrings.ControlPanel.Cellular.ChangeSimStatus
            case .actionChangeDataLimit:
                return MeshSetupStrings.ControlPanel.Cellular.ChangeDataLimit

            case .actionChangePinsStatus:
                return MeshSetupStrings.ControlPanel.Ethernet.ChangePinsStatus


            case .meshInfoNetworkName:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkName
            case .meshInfoNetworkID:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkID
            case .meshInfoNetworkExtPanID:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkExtPanID
            case .meshInfoNetworkPanID:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkPanID
            case .meshInfoNetworkChannel:
                return MeshSetupStrings.ControlPanel.Mesh.NetworkChannel
            case .meshInfoNetworkDeviceCount:
                return MeshSetupStrings.ControlPanel.Mesh.DeviceCount
            case .meshInfoDeviceRole:
                return MeshSetupStrings.ControlPanel.Mesh.DeviceRole

            case .actionLeaveMeshNetwork:
                return MeshSetupStrings.ControlPanel.Mesh.LeaveNetwork
            case .actionAddToMeshNetwork:
                return MeshSetupStrings.ControlPanel.Mesh.AddToNetwork
            case .actionPromoteToGateway:
                return MeshSetupStrings.ControlPanel.Mesh.PromoteToGateway
            case .actionDemoteFromGateway:
                return MeshSetupStrings.ControlPanel.Mesh.DemoteFromGateway

}
    }

    func getCellDetails(context: MeshSetupContext) -> String? {
        switch self {
            case .actionChangeSimStatus:
                if context.targetDevice.sim!.status! == .activate {
                    return MeshSetupStrings.ControlPanel.Cellular.Active
                } else if (context.targetDevice.sim!.status! == .inactiveDataLimitReached) {
                    return MeshSetupStrings.ControlPanel.Cellular.Paused
                } else {
                    return MeshSetupStrings.ControlPanel.Cellular.Inactive
                }
            case .actionChangePinsStatus:
                return context.targetDevice.ethernetDetectionFeature! ? MeshSetupStrings.ControlPanel.Ethernet.Active : MeshSetupStrings.ControlPanel.Ethernet.Inactive
            case .actionChangeDataLimit:
                return MeshSetupStrings.ControlPanel.Cellular.DataLimit.DataLimitValue.replacingOccurrences(of: "{{0}}", with: String(context.targetDevice.sim!.dataLimit!))
            case .name:
                return context.targetDevice.name
            case .notes:
                return context.targetDevice.notes

            case .meshInfoNetworkName:
                if let _ = context.targetDevice.meshNetworkInfo {
                    return context.targetDevice.meshNetworkInfo!.name
                } else {
                    return MeshSetupStrings.ControlPanel.Mesh.NoNetworkInfo
                }
            case .meshInfoNetworkID:
                return context.targetDevice.meshNetworkInfo!.networkID
            case .meshInfoNetworkExtPanID:
                return context.targetDevice.meshNetworkInfo!.extPanID
            case .meshInfoNetworkPanID:
                return String(context.targetDevice.meshNetworkInfo!.panID)
            case .meshInfoNetworkChannel:
                return String(context.targetDevice.meshNetworkInfo!.channel)
            case .meshInfoNetworkDeviceCount:
                if let apiNetworks = context.apiNetworks {
                    for network in apiNetworks {
                        if (context.targetDevice.meshNetworkInfo!.networkID == network.id) {
                            return String(network.deviceCount)
                        }
                    }
                }
                return nil
            case .meshInfoDeviceRole:
                //BUG: fix a bug where this is called for device that has no network role
                return (context.targetDevice.networkRole ?? .node) == .gateway ? MeshSetupStrings.ControlPanel.Mesh.DeviceRoleGateway : MeshSetupStrings.ControlPanel.Mesh.DeviceRoleNode


            case .wifiInfoSSID:
                if let _ = context.targetDevice.wifiNetworkInfo {
                    return context.targetDevice.wifiNetworkInfo!.ssid
                } else {
                    return MeshSetupStrings.ControlPanel.Wifi.NoNetworkInfo
                }
            case .wifiInfoChannel:
                return String(context.targetDevice.wifiNetworkInfo!.channel)
            case .wifiInfoRSSI:
                return String(context.targetDevice.wifiNetworkInfo!.rssi)

            default:
                return nil
        }
    }

    func getCellEnabled(context: MeshSetupContext) -> Bool {
        switch self {
            case .actionChangeSimStatus:
                return false
            case .meshInfoNetworkName, .meshInfoNetworkID, .meshInfoNetworkExtPanID, .meshInfoNetworkPanID, .meshInfoNetworkPanID, .meshInfoNetworkChannel, .meshInfoDeviceRole, .meshInfoNetworkDeviceCount:
                return false
            case .wifiInfoChannel, .wifiInfoRSSI, .wifiInfoSSID:
                return false
            default:
                return true
        }
    }

    func getIcon(context: MeshSetupContext) -> UIImage? {
        switch self {
            case .wifi:
                return UIImage(named: "MeshSetupWifiIcon")
            case .cellular:
                return UIImage(named: "MeshSetupCellularIcon")
            case .ethernet:
                return UIImage(named: "MeshSetupEthernetIcon")
            case .mesh:
                return UIImage(named: "MeshSetupMeshIcon")
            default:
                return nil
        }
    }

    func getDisclosureIndicator(context: MeshSetupContext) -> UITableViewCell.AccessoryType {
        switch self {
            case .unclaim, .actionLeaveMeshNetwork:
                return .none
            case .meshInfoNetworkName, .meshInfoNetworkID, .meshInfoNetworkExtPanID, .meshInfoNetworkPanID, .meshInfoNetworkPanID, .meshInfoNetworkChannel, .meshInfoNetworkDeviceCount, .meshInfoDeviceRole:
                return .none
            case .wifiInfoChannel, .wifiInfoRSSI, .wifiInfoSSID:
                return .none
            case .actionChangeSimStatus:
                return .none
            default:
                return .disclosureIndicator
        }
    }


    static func prepareTableView(_ tableView: UITableView) {
        tableView.register(UINib.init(nibName: "MeshSetupBasicCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicCell")
        tableView.register(UINib.init(nibName: "MeshSetupBasicIconCell", bundle: nil), forCellReuseIdentifier: "MeshSetupBasicIconCell")
        tableView.register(UINib.init(nibName: "MeshSetupButtonCell", bundle: nil), forCellReuseIdentifier: "MeshSetupButtonCell")
        tableView.register(UINib.init(nibName: "MeshSetupSubtitleCell", bundle: nil), forCellReuseIdentifier: "MeshSetupSubtitleCell")
        tableView.register(UINib.init(nibName: "MeshSetupHorizontalDetailCell", bundle: nil), forCellReuseIdentifier: "MeshSetupHorizontalDetailCell")
    }

    func getConfiguredCell(_ tableView: UITableView, context: MeshSetupContext) -> MeshCell {
        let image = self.getIcon(context: context)
        let detail = self.getCellDetails(context: context)
        let enabled = self.getCellEnabled(context: context)
        let accessoryType = self.getDisclosureIndicator(context: context)

        var cell:MeshCell! = nil

        if (self == .unclaim || self == .actionLeaveMeshNetwork) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupButtonCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.RedTextColor : ParticleStyle.DetailsTextColor)
        } else if (self == .actionChangeSimStatus || self == .actionChangePinsStatus) {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupSubtitleCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            cell.cellSubtitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
            cell.cellSubtitleLabel.text = detail
        } else if image != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicIconCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)
        } else if detail != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupHorizontalDetailCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)

            cell.cellDetailLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.DetailsTextColor)
            cell.cellDetailLabel.text = detail
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "MeshSetupBasicCell") as! MeshCell
            cell.cellTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: enabled ? ParticleStyle.PrimaryTextColor : ParticleStyle.DetailsTextColor)
        }

        cell.tintColor = ParticleStyle.DisclosureIndicatorColor
        cell.accessoryType = accessoryType
        cell.cellTitleLabel.text = self.getCellTitle(context: context)
        cell.cellIconImageView?.image = image

        return cell
    }
}
