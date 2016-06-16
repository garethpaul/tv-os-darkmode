//
//  ViewController.swift
//  tvos-darkmode

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard(traitCollection.responds(to: #selector(getter:UITraitCollection.userInterfaceStyle)))
        else { return }
        
        guard(traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle) else { return }
        
        if traitCollection.userInterfaceStyle == .dark {
            // dark interface
            print("dark")
        } else {
            // light interface
            print("light")
        }
    }
}

