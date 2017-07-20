//
//  PDFPageNumberViewController.swift
//  Pods
//
//  Created by Arne Link on 20.07.17.
//
//

import UIKit

public struct PageCount {
    let currentPage: Int
    let pageCount: Int
}

class PDFPageNumberViewController: UIViewController {
    @IBOutlet weak var pageCountLabel: UILabel?

    public var pageCount: PageCount! {
        didSet {
            if let pageCountLabel = self.pageCountLabel {
                pageCountLabel.text = String(format: "%d von %d", pageCount.currentPage, pageCount.pageCount)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
