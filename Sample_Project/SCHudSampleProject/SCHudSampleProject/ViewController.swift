//
//  ViewController.swift
//  SCHudSampleProject
//
//  Created by Xiaodan Wang on 8/17/17.
//  Copyright © 2017 Xiaodan Wang. All rights reserved.
//

import UIKit
import SCHud

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let hud = SCHudView()
        hud.viewSize = .large
        hud.viewTheme = .rainbow
        
        hud.titleDesc = "Loading..."
        hud.show(to: view)
    }
    
}

