//
//  RxSendOrderRootViewController.swift
//  BitTrader
//
//  Created by chako on 2016/11/21.
//  Copyright © 2016年 Bit Trader. All rights reserved.
//

import UIKit

protocol RxSendOrderRootViewControllerProtocol: NSObjectProtocol {
    func willNeedBidRate(rateType: RateType) -> String?
    func willNeedAskRate(rateType: RateType) -> String?
}

class RxSendOrderRootViewController: UIViewController, ViewContainer, UIPickerViewDelegate, UIPickerViewDataSource, ApiExecuterDelegate, RxSendOrderRootViewControllerProtocol {

    private var activeViewController: RxBaseSendOrderViewController?

    private var productType: Bitflyer.ProductCodeType?
    private var selectedOrder: Enums.Order?
    private var selectedCondition: Enums.Condition?
    private var response: BitflyerTickerResponse?
    private var timer: Timer?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var bidRateLabel: UILabel!
    @IBOutlet weak var askRateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        productType = .fxBtcJpy

        guard let productType = productType else {
            return
        }

        title = productType.rawValue

        selectedOrder = Enums.Order(rawValue: 0)
        selectedCondition = Enums.Condition(rawValue: 0)

        activeViewController = RxSimpleOrderViewController(productType: productType, condition: .limit, delegete: self)
        addChildContainerViewController(activeViewController!, atContainerView: containerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.pickerView.dataSource = self
        self.pickerView.delegate = self

        ratePolling()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.ratePolling), userInfo: nil, repeats: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        timer?.invalidate()
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return Enums.Order.count
        }
        return Enums.Condition.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Enums.Order(rawValue: row)?.name
        }
        return Enums.Condition(rawValue: row)?.name
    }

    func onSuccess<ApiExecuter: ApiExecuterProtocol>(_ apiExecuter: ApiExecuter, value: ApiExecuter.ModelType) {
        guard apiExecuter.dtoType == BitflyerTickerResponse.self, let response = value as? BitflyerTickerResponse else {
            return
        }
        self.response = response
        bidRateLabel.text = NSNumber(integerLiteral: response.bestBid).formatComma()
        askRateLabel.text = NSNumber(integerLiteral: response.bestAsk).formatComma()
    }

    func onFailure<ApiExecuter: ApiExecuterProtocol>(_ apiExecuter: ApiExecuter, error: ApiResponseError) {

    }

    func willNeedBidRate(rateType: RateType) -> String? {
        guard let response = response else {
            return nil
        }
        return String(describing: response.bestBid)
    }

    func willNeedAskRate(rateType: RateType) -> String? {
        guard let response = response else {
            return nil
        }
        return String(describing: response.bestAsk)
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            // 注文方法の更新
            selectedOrder = Enums.Order(rawValue: row)
            guard let activeViewController = activeViewController,
                let productType = productType,
                let selectedOrder = selectedOrder,
                let selectedCondition = selectedCondition,
                let newAvc = createOrderViewController(productType, selectedOrder, selectedCondition) else {
                return
            }
            removeChildContainerViewController(activeViewController)
            self.activeViewController = newAvc
            addChildContainerViewController(newAvc, atContainerView: containerView)

        case 1:
            // 注文の執行条件の更新
            selectedCondition = Enums.Condition(rawValue: row)
            guard let selectedCondition = selectedCondition else {
                return
            }
            activeViewController?.updateCondition(selectedCondition)
        default:
            break
        }
    }

    func ratePolling() {
        guard let productType = productType else {
            return
        }
        let apiExecuter = createBitflyerFxTickerRequestExecuter(productType)
        apiExecuter.delegate = self
        ApiClient.execute(apiExecuter)
    }

    @IBAction func onBidButton(_ sender: UIButton) {
        guard let response = response else {
            return
        }
        activeViewController?.updateBidRate(rate: String(describing: response.bestBid))
    }

    @IBAction func onAskButton(_ sender: UIButton) {
        guard let response = response else {
            return
        }
        activeViewController?.updateAskRate(rate: String(describing: response.bestAsk))
    }

    private func createOrderViewController(_ productType: Bitflyer.ProductCodeType, _ order: Enums.Order, _ condition: Enums.Condition) -> RxBaseSendOrderViewController? {
        switch order {
        case .simple:
            return RxSimpleOrderViewController(productType: productType, condition: condition, delegete: self)
        case .ifd:
            return RxIfdOrderViewController(productType: productType, condition: condition, delegete: self)
        case .oco:
            return RxOcoOrderViewController(productType: productType, condition: condition, delegete: self)
        case .ifdoco:
            return RxIfdocoOrderViewController(productType: productType, condition: condition, delegete: self)
        default:
            return nil
        }
    }

    private func createBitflyerFxTickerRequestExecuter(_ productType: Bitflyer.ProductCodeType) -> ApiKitApiExecuter<BitflyerTickerRequest, BitflyerTickerResponse> {
        let bitflyerFxTickerReuqestParameter = BitflyerTickerRequestParameter(productCode: productType)
        let bitflyerFxTickerRequest = BitflyerTickerRequest(requestParameter: bitflyerFxTickerReuqestParameter)
        return ApiKitApiExecuter<BitflyerTickerRequest, BitflyerTickerResponse>(bitflyerFxTickerRequest)
    }
}