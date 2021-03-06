//
//  BitflyerGetPositionsParameter.swift
//  BitTrader
//
//  Created by chako on 2016/11/03.
//  Copyright © 2016年 Bit Trader. All rights reserved.
//

struct BitflyerGetPositionsParameter {
    let productCode: Bitflyer.ProductCodeType = .fxBtcJpy
}

extension BitflyerGetPositionsParameter: BitTraderRequestParameter {
    
    func createParameters() -> [String : Any]? {
        var dic = [String: Any]()
        dic[Bitflyer.ApiKey.productCode.rawValue] = productCode.rawValue
        
        return dic
    }
}
