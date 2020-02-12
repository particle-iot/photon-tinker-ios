//
// Created by Raimundas Sakalauskas on 9/20/18.
// Copyright (c) 2018 Particle. All rights reserved.
//

import UIKit

class Gen3SetupPricingInfoViewController: Gen3SetupViewController, Storyboardable {

    @IBOutlet weak var titleLabel: ParticleLabel!

    @IBOutlet weak var planTitleLabel: ParticleLabel!
    @IBOutlet weak var planTextLabel: ParticleLabel!
    
    @IBOutlet weak var priceFreeLabel: ParticleLabel!
    @IBOutlet weak var priceLabel: ParticleLabel!
    @IBOutlet weak var priceNoteLabel: ParticleLabel!
    @IBOutlet weak var priceStrikethroughView: UIView!
    
    @IBOutlet weak var planFeaturesTitleLabel: ParticleLabel!
    @IBOutlet weak var planTitleLine1: UIView!
    @IBOutlet weak var planTitleLine2: UIView!
    
    @IBOutlet weak var planFeatureStackView: UIStackView!
    @IBOutlet var planFeatureLables: [ParticleLabel]!
    
    @IBOutlet weak var continueButton: ParticleButton!

    private var pricingInfo: ParticlePricingInfo!
    private var callback: (() -> ())!

    func setup(didPressContinue: @escaping () -> (), pricingInfo: ParticlePricingInfo) {
        self.callback = didPressContinue
        self.pricingInfo = pricingInfo
    }

    override func setStyle() {
        if (ScreenUtils.getPhoneScreenSizeClass() <= .iPhone5) {
            planFeatureStackView.spacing = 10

            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            planTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.SmallSize, color: ParticleStyle.BillingTextColor)
            planTextLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.SmallSize, color: ParticleStyle.BillingTextColor)

            priceFreeLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)

            priceLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.PriceSize - 10, color: ParticleStyle.PrimaryTextColor)
            priceNoteLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.BillingTextColor)

            priceStrikethroughView.backgroundColor = ParticleStyle.StrikeThroughColor

            planFeaturesTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.DetailSize, color: ParticleStyle.SecondaryTextColor)
            planTitleLine1.backgroundColor = ParticleStyle.SecondaryTextColor
            planTitleLine2.backgroundColor = ParticleStyle.SecondaryTextColor

            for label in planFeatureLables {
                label.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.SmallSize, color: ParticleStyle.PrimaryTextColor)
            }

            continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)

        } else {
            planFeatureStackView.spacing = 15

            titleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

            planTitleLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.SmallSize, color: ParticleStyle.BillingTextColor)
            planTextLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.SmallSize, color: ParticleStyle.BillingTextColor)

            priceFreeLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.LargeSize, color: ParticleStyle.PrimaryTextColor)

            priceLabel.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.PriceSize, color: ParticleStyle.PrimaryTextColor)
            priceNoteLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.LargeSize, color: ParticleStyle.BillingTextColor)

            priceStrikethroughView.backgroundColor = ParticleStyle.StrikeThroughColor

            planFeaturesTitleLabel.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.DetailSize, color: ParticleStyle.SecondaryTextColor)
            planTitleLine1.backgroundColor = ParticleStyle.SecondaryTextColor
            planTitleLine2.backgroundColor = ParticleStyle.SecondaryTextColor

            for label in planFeatureLables {
                label.setStyle(font: ParticleStyle.RegularFont, size: ParticleStyle.RegularSize, color: ParticleStyle.PrimaryTextColor)
            }

            continueButton.setStyle(font: ParticleStyle.BoldFont, size: ParticleStyle.RegularSize)
        }
    }

    override func setContent() {

        self.priceFreeLabel.isHidden = false
        self.priceStrikethroughView.isHidden = false

        for label in planFeatureLables {
            label.text = ""
        }

        switch self.pricingInfo.planSlug ?? "" {
            case "DeviceCloudCellularSelfServe": //add-device-to_user + cellular
                titleLabel.text = Gen3SetupStrings.PricingInfo.PaidGatewayDeviceTitle
                planTitleLabel.text = Gen3SetupStrings.PricingInfo.DeviceCloudPlanTitle
                planTextLabel.text = Gen3SetupStrings.PricingInfo.CellularDeviceText

                priceFreeLabel.text = Gen3SetupStrings.PricingInfo.FreeMonthsText.replacingOccurrences(of: "{{freeMonths}}", with: "\(pricingInfo.plan.freeMonths)")
                planFeaturesTitleLabel.text = Gen3SetupStrings.PricingInfo.DeviceCloudFeatures

                planFeatureLables[0].text = Gen3SetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = Gen3SetupStrings.PricingInfo.FeaturesDataAllowence.replacingOccurrences(of: "{{dataAllowance}}", with: "\(pricingInfo.plan.includedDataMb)").replacingOccurrences(of: "{{pricePerMB}}", with: formatCurrency(pricingInfo.plan.overageMinCostMb!))
                planFeatureLables[2].text = Gen3SetupStrings.PricingInfo.FeaturesStandardSupport
            case "MeshMicroCellular": //create-network + cellular
                titleLabel.text = Gen3SetupStrings.PricingInfo.PaidNetworkTitle
                planTitleLabel.text = Gen3SetupStrings.PricingInfo.MicroNetworkPlanTitle
                planTextLabel.text = Gen3SetupStrings.PricingInfo.CellularGatewayText

                priceFreeLabel.text = Gen3SetupStrings.PricingInfo.FreeMonthsText.replacingOccurrences(of: "{{freeMonths}}", with: "\(pricingInfo.plan.freeMonths)")
                planFeaturesTitleLabel.text = Gen3SetupStrings.PricingInfo.MeshNetworkFeatures

                planFeatureLables[0].text = Gen3SetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = Gen3SetupStrings.PricingInfo.FeaturesMaxDevices.replacingOccurrences(of: "{{maxDevices}}", with: "\(pricingInfo.plan.includedNodeCount)")
                planFeatureLables[2].text = Gen3SetupStrings.PricingInfo.FeaturesMaxGateways.replacingOccurrences(of: "{{maxGateways}}", with: "\(pricingInfo.plan.includedGatewayCount)")
                planFeatureLables[3].text = Gen3SetupStrings.PricingInfo.FeaturesDataAllowence.replacingOccurrences(of: "{{dataAllowance}}", with: "\(pricingInfo.plan.includedDataMb)").replacingOccurrences(of: "{{pricePerMB}}", with: formatCurrency(pricingInfo.plan.overageMinCostMb!))
                planFeatureLables[4].text = Gen3SetupStrings.PricingInfo.FeaturesStandardSupport

            case "MeshMicroWifi": //create-network + wifi
                titleLabel.text = Gen3SetupStrings.PricingInfo.FreeNetworkTitle
                planTitleLabel.text = Gen3SetupStrings.PricingInfo.MicroNetworkPlanTitle
                planTextLabel.text = Gen3SetupStrings.PricingInfo.WifiGatewayText

                priceFreeLabel.text = Gen3SetupStrings.PricingInfo.FreeNetworksText.replacingOccurrences(of: "{{freeNetworksCount}}", with: "\(pricingInfo.plan.freeWifiNetworkMaxCount)")
                planFeaturesTitleLabel.text = Gen3SetupStrings.PricingInfo.MeshNetworkFeatures

                planFeatureLables[0].text = Gen3SetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = Gen3SetupStrings.PricingInfo.FeaturesMaxDevices.replacingOccurrences(of: "{{maxDevices}}", with: "\(pricingInfo.plan.includedNodeCount)")
                planFeatureLables[2].text = Gen3SetupStrings.PricingInfo.FeaturesMaxGateways.replacingOccurrences(of: "{{maxGateways}}", with: "\(pricingInfo.plan.includedGatewayCount)")
                planFeatureLables[3].text = Gen3SetupStrings.PricingInfo.FeaturesStandardSupport

            default: //add-device-to-user + wifi
                titleLabel.text = Gen3SetupStrings.PricingInfo.FreeGatewayDeviceTitle
                planTitleLabel.text = Gen3SetupStrings.PricingInfo.DeviceCloudPlanTitle
                planTextLabel.text = Gen3SetupStrings.PricingInfo.WifiDeviceText

                priceFreeLabel.text = Gen3SetupStrings.PricingInfo.FreeDevicesText.replacingOccurrences(of: "{{freeDeviceCount}}", with: "\(pricingInfo.plan.freeDeviceMaxCount)")
                planFeaturesTitleLabel.text = Gen3SetupStrings.PricingInfo.DeviceCloudFeatures

                planFeatureLables[0].text = Gen3SetupStrings.PricingInfo.FeaturesDeviceCloud
                planFeatureLables[1].text = Gen3SetupStrings.PricingInfo.FeaturesStandardSupport
        }

        priceLabel.text = Gen3SetupStrings.PricingInfo.PriceText.replacingOccurrences(of: "{{price}}", with: formatCurrency(pricingInfo.plan.monthlyBaseAmount!))
        priceNoteLabel.text = Gen3SetupStrings.PricingInfo.PriceNoteText

        for label in planFeatureLables {
            label.isHidden = (label.text!.count == 0)
        }

        if self.pricingInfo.chargeable {
            self.continueButton.setTitle(Gen3SetupStrings.PricingInfo.ButtonEnroll, for: .normal)
        } else {
            self.continueButton.setTitle(Gen3SetupStrings.PricingInfo.ButtonNext, for: .normal)
        }
    }

    private func formatCurrency(_ decimal: NSDecimalNumber) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.groupingSeparator = ","

        currencyFormatter.decimalSeparator = "."
        currencyFormatter.minimumIntegerDigits = 1

        currencyFormatter.usesSignificantDigits = false
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 2

        return currencyFormatter.string(from: decimal)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addFadableViews()
    }

    private func addFadableViews() {
        if viewsToFade == nil {
            viewsToFade = [UIView]()
        }

        viewsToFade!.append(titleLabel)

        viewsToFade!.append(planTitleLabel)
        viewsToFade!.append(planTextLabel)

        viewsToFade!.append(priceFreeLabel)
        viewsToFade!.append(priceLabel)
        viewsToFade!.append(priceNoteLabel)
        viewsToFade!.append(priceStrikethroughView)

        viewsToFade!.append(planTitleLabel)
        viewsToFade!.append(planTitleLine1)
        viewsToFade!.append(planTitleLine2)
        viewsToFade!.append(planFeatureStackView)

        viewsToFade!.append(continueButton)
    }





    @IBAction func continueButtonTapped(_ sender: Any) {
        self.fade()

        callback()
    }
}
