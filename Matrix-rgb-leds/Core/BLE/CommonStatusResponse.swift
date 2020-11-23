//
//  CommonStatusResponse.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

class CommonStatusResponse: BLEResponse {
    var status: Bool!
    
    override init?(rawData: Data?) {
        super.init(rawData: rawData)
        
        guard let data = dataArray else {
            return nil
        }
        
        guard data.count >= 3 && data[0] == 0xB0 else {
            return nil
        }
        
        guard data.count-2 == data[1] else {
            return nil
        }
        
        status = Int(data[2]) > 0
    }
}
