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

    public var image: Observable<UIImage?>? {
        didSet {
            if let image = self.image {
                self.imageView?.image = nil
                image.subscribe(onNext: { [weak self] uiImage in
                    self?.imageView?.image = uiImage
                }).disposed(by: bag)
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
