//
//  PDFSitemapTableViewCell.swift
//  Pods
//
//  Created by Arne Link on 20.07.17.
//
//

import UIKit
import Reusable

final class PDFSitemapTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
