//
//  DetailViewController.swift
//  multipeer
//
//  Created by Priscila Rosa on 10/6/16.
//  Copyright © 2016 Isabella Vieira. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var passedValue: UIImage!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if passedValue != nil {
            imageView.image = passedValue
            imageView.contentMode = .scaleAspectFit
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
