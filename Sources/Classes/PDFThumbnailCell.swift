//
//  PDFThumbnailCell.swift
//  PDFReader
//
//  Created by Ricardo Nunez on 7/9/16.
//  Copyright © 2016 AK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// An individual thumbnail in the collection view
internal final class PDFThumbnailCell: UICollectionViewCell {
    /// Preferred size of each cell
    static let cellSize = CGSize(width: 24, height: 44)

    fileprivate var bag = DisposeBag()
    
    @IBOutlet var imageView: UIImageView?

    override var alpha: CGFloat {
        didSet {
            print("new alpha value: \(alpha) for view \(self.hash)")
        }
    }

    public var image: Variable<UIImage?>? {
        didSet {
            if let imageVar = self.image {
                self.imageView?.image = imageVar.value
                if imageVar.value == nil {
                    imageVar.asDriver().drive(onNext: { [weak self] uiImage in
                        self?.imageView?.image = uiImage
                        self?.bag = DisposeBag()
                    }).disposed(by: bag)
                }
            } else {
                imageView?.image = nil
            }
        }
    }

    override func prepareForReuse() {
        bag = DisposeBag()
        super.prepareForReuse()
    }
}
