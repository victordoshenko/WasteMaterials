//
//  DetailsViewController.swift
//  WasteMaterials
//
//  Created by Victor Doshchenko on 30.03.2020.
//

import UIKit

class DetailsViewController: UIViewController {

    public var name = ""
    @IBOutlet weak var labelName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        labelName.text = name

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
