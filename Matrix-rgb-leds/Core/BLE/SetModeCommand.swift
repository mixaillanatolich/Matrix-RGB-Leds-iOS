//
//  SetModeCommand.swift
//  Matrix RGB Leds
//
//  Created by Mixaill on 23.11.2020.
//  Copyright © 2020 M-Technologies. All rights reserved.
//

import Foundation

class SetModeCommand: BLECommand {

    override func handleResponse() -> Bool {
        guard let response = CommonStatusResponse(rawData: rawResponse) else {
            return false
        }
        self.response = response
        return true
    }
    
}
