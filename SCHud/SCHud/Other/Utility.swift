//
//  Utility.swift
//  SCHud
//
//  Created by Xiaodan Wang on 8/17/17.
//  Copyright © 2017 Xiaodan Wang. All rights reserved.
//

import UIKit

class Utility {
    //MARK: - LOG
    class func log(message: String = "", funcName: String = #function, lineNumber: Int = #line, fileName: String = #file) {
        print("+++ Message +++:\n--- \(message) ---\nCalled by \(funcName) @ line #\(lineNumber) in file: \(fileName)")
    }
}
