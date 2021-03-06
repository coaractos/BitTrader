//
//  RxSendOrderViewModel.swift
//  BitTrader
//
//  Created by chako on 2016/11/28.
//  Copyright © 2016年 Bit Trader. All rights reserved.
//

import RxCocoa
import RxSwift

class RxSendOrderViewModel {
    
    let productType: Variable<Bitflyer.ProductCodeType>
    let selectedOrder: Variable<Enums.Order>
    let selectedCondition: Variable<Enums.Condition>
    
    init(productType: Bitflyer.ProductCodeType, order: Enums.Order, condition: Enums.Condition) {
        
        self.productType = Variable(productType)
        self.selectedOrder = Variable(order)
        self.selectedCondition = Variable(condition)
    }
    
    func tradeTypeComponentCount() -> Int {
        return 2
    }
    
    func tradeTypeCount(numberOfRowsInComponent component: Int) -> Int {        
        if component == 0 {
            return Enums.Order.count
        }
        return Enums.Condition.count
    }
    
    func tradeTypeTitleForRow(_ row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Enums.Order(rawValue: row)?.name
        } else if component == 1 {
            return Enums.Condition(rawValue: row)?.name
        } else {
            return nil
        }
    }
    
    func updateDidSelectedPicker(row: Int, inComponent component: Int) {
        
        if component == 0 {
            // 注文方法の更新
            if let order = Enums.Order(rawValue: row) {
                selectedOrder.value = order
            }
        } else if component == 1 {
            // 注文の執行条件の更新
            if let condition = Enums.Condition(rawValue: row) {
                selectedCondition.value = condition
            }
        }
    }
}
