//
//  GetBoardRequestParameter.swift
//  BitTrader
//
//  Created by chako on 2016/10/14.
//  Copyright © 2016年 Bit Trader. All rights reserved.
//

struct GetBoardRequestParameter {
    let productCode: ProductCodeType?
}

extension GetBoardRequestParameter: BitTraderRequestParameter {
    
    func createParameters() -> [String : String]? {
        
        var dic = [String: String]()
        if let productCode = self.productCode {
            dic["product_code"] = productCode.rawValue
        }
        
        if 0 < dic.count {
            return dic
        } else {
            return nil
        }
    }
}