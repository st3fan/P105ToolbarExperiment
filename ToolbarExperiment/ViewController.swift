//
//  ViewController.swift
//  ToolbarExperiment
//
//  Created by Stefan Arentz (Mozilla) on 2014-10-16.
//  Copyright (c) 2014 Stefan Arentz. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    override func viewDidAppear(animated: Bool) {
        let viewController: UIViewController = ToolbarViewController(nibName: "ToolbarViewController", bundle: nil);
        self.presentViewController(viewController, animated: false, completion: nil)
    }
}

