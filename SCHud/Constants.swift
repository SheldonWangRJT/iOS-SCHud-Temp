//
//  Constants.swift
//  SCHud
//
//  Created by Xiaodan Wang on 8/19/17.
//  Copyright © 2017 Xiaodan Wang. All rights reserved.
//

public enum SCViewSize: CGFloat {
    case tiny = 0.1
    case small = 0.2
    case medium = 0.3
    case large = 0.4
    case huge = 0.5
}

public enum SCCubeTheme {
    case blackWhite
    case rainbow
    ///Custom theme needs 6 requried colors for 6 surface and 1 color for the edges
    case custom(UIColor, UIColor, UIColor, UIColor, UIColor, UIColor, UIColor)
}
