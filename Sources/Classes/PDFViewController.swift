//  PDFViewController.swift
//  PDFReader
//
//  Created by ALUA KINZHEBAYEVA on 4/19/15.
//  Copyright (c) 2015 AK. All rights reserved.
//

import UIKit

extension PDFViewController {
    /// Initializes a new `PDFViewController`
    ///
    /// - parameter document:            PDF document to be displayed
    /// - parameter title:               title that displays on the navigation bar on the PDFViewController; 
    ///                                  if nil, uses document's filename
    /// - parameter startPageIndex:      page index to start on load, defaults to 0; if out of bounds, set to 0
    /// - parameter sitemap:             Sitemap data, activates sitemap button if set
    ///
    /// - returns: a `PDFViewController`
    public class func createNew(with document: PDFDocument, title: String? = nil, startPageIndex: Int = 0, sitemap: PDFSitemap? = nil) -> PDFViewController {
        let storyboard = UIStoryboard(name: "PDFReader", bundle: Bundle(for: PDFViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! PDFViewController
        controller.document = document
        controller.actionStyle = .print

        if let title = title {
            controller.title = title
        } else {
            controller.title = document.fileName
        }

        if startPageIndex >= 0 && startPageIndex < document.pageCount {
            controller.currentPageIndex = startPageIndex
        } else {
            controller.currentPageIndex = 0
        }

        controller.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: controller, action: #selector(actionButtonPressed))

        controller.sitemap = sitemap

        return controller
    }
}

/// Controller that is able to interact and navigate through pages of a `PDFDocument`
public final class PDFViewController: UIViewController {
    /// Action button style
    public enum ActionStyle {
        /// Brings up a print modal allowing user to print current PDF
        case print
        
        /// Brings up an activity sheet to share or open PDF in another app
        case activitySheet
        
        /// Performs a custom action
        case customAction((Void) -> ())
    }

    /// Container view showing the current page count when navigating
    @IBOutlet public var pageCounterContainer: UIView!
    
    /// Collection veiw where all the pdf pages are rendered
    @IBOutlet public var collectionView: UICollectionView!
    
    /// Height of the thumbnail bar (used to hide/show)
    @IBOutlet fileprivate var thumbnailCollectionControllerHeight: NSLayoutConstraint!
    
    /// Distance between the bottom thumbnail bar with bottom of page (used to hide/show)
    @IBOutlet fileprivate var thumbnailCollectionControllerBottom: NSLayoutConstraint!
    
    /// Width of the thumbnail bar (used to resize on rotation events)
    @IBOutlet private var thumbnailCollectionControllerWidth: NSLayoutConstraint!
    
    /// PDF document that should be displayed
    fileprivate var document: PDFDocument! {
        didSet {
            setPageCounter()
        }
    }
    
    fileprivate var actionStyle = ActionStyle.print

    fileprivate var sitemap: PDFSitemap?

    fileprivate var disableScrollUpdates = false
    
    /// Current page being displayed
    fileprivate var currentPageIndex: Int = 0 {
        didSet {
            setPageCounter()
        }
    }

    /// Page Number controller
    fileprivate var pageNumberController: PDFPageNumberViewController?

    /// Bottom thumbnail controller
    fileprivate var thumbnailCollectionController: PDFThumbnailCollectionViewController?
    
    /// UIBarButtonItem used to override the default action button
    fileprivate var actionButton: UIBarButtonItem?
    
    /// Backbutton used to override the default back button
    fileprivate var backButton: UIBarButtonItem?
    
    /// Background color to apply to the collectionView.
    public var backgroundColor: UIColor? = .lightGray {
        didSet {
            collectionView?.backgroundColor = backgroundColor
        }
    }
    
    /// Whether or not the thumbnails bar should be enabled
    fileprivate var isThumbnailsEnabled = true {
        didSet {
            if thumbnailCollectionControllerHeight == nil {
                _ = view
            }
            if !isThumbnailsEnabled {
                thumbnailCollectionControllerHeight.constant = 0
            }
        }
    }
    
    /// Slides horizontally (from left to right, default) or vertically (from top to bottom)
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal {
        didSet {
            if collectionView == nil {  // if the user of the controller is trying to change the scrollDiecton before it
                _ = view                // is on the sceen, we need to show it ofscreen to access it's collectionView.
            }
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = scrollDirection
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.backgroundColor = backgroundColor
        collectionView.register(PDFPageCollectionViewCell.self, forCellWithReuseIdentifier: "page")

        var rightButtons: [UIBarButtonItem] = []
        if let actionButton = self.actionButton {
            rightButtons.append(actionButton)
        }
        if sitemap != nil {
            let sitemapButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(sitemapButtonPressed))
            rightButtons.append(sitemapButton)
        }

        navigationItem.rightBarButtonItems = rightButtons
        if let backItem = backButton {
            navigationItem.leftBarButtonItem = backItem
        }

        setPageCounter()
        updateThumbnailCollectionControllerWidth(size: view.bounds.size)
    }

    override public func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            document.invalidate()
        }
        super.willMove(toParentViewController: parent)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didSelectIndexPath(IndexPath(row: currentPageIndex, section: 0))
    }
    
    override public var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isThumbnailsEnabled
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PDFThumbnailCollectionViewController {
            thumbnailCollectionController = controller
            controller.document = document
            controller.delegate = self
            controller.currentPageIndex = currentPageIndex
        } else if let controller = segue.destination as? PDFPageNumberViewController {
            pageNumberController = controller
            setPageCounter()
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let currentIndexPath = IndexPath(row: self.currentPageIndex, section: 0)
        self.disableScrollUpdates = true
        coordinator.animate(alongsideTransition: { context in
            self.updateThumbnailCollectionControllerWidth(size: size)
            self.thumbnailCollectionController?.currentPageIndex = self.currentPageIndex
            self.collectionView.reloadItems(at: [currentIndexPath])
            self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        }) { context in
            self.disableScrollUpdates = false
        }

    }

    /// Takes an appropriate action based on the current action style
    func actionButtonPressed() {
        switch actionStyle {
        case .print:
            print()
        case .activitySheet:
            presentActivitySheet()
        case .customAction(let customAction):
            customAction()
        }
    }

    /// Takes an appropriate action based on the current action style
    func sitemapButtonPressed() {
        if let sitemap = self.sitemap {
            let storyboard = UIStoryboard(name: "PDFReader", bundle: Bundle(for: PDFViewController.self))
            let controller = storyboard.instantiateViewController(withIdentifier: "PDFSitemapViewController") as! PDFSitemapViewController
            controller.sitemap = sitemap
            controller.currentPageIndex = self.currentPageIndex
            controller.delegate = self
            if let navigationController = navigationController {
                navigationController.pushViewController(controller, animated: true)
            } else {
                present(controller, animated: true)
            }
        }
    }
    
    /// Presents activity sheet to share or open PDF in another app
    private func presentActivitySheet() {
        let controller = UIActivityViewController(activityItems: [document.fileData], applicationActivities: nil)
        controller.popoverPresentationController?.barButtonItem = actionButton
        present(controller, animated: true, completion: nil)
    }
    
    /// Presents print sheet to print PDF
    private func print() {
        guard UIPrintInteractionController.isPrintingAvailable else { return }
        guard UIPrintInteractionController.canPrint(document.fileData) else { return }
        guard document.password == nil else { return }
        let printInfo = UIPrintInfo.printInfo()
        printInfo.duplex = .longEdge
        printInfo.outputType = .general
        printInfo.jobName = document.fileName
        
        let printInteraction = UIPrintInteractionController.shared
        printInteraction.printInfo = printInfo
        printInteraction.printingItem = document.fileData
        printInteraction.showsPageRange = true
        printInteraction.present(animated: true, completionHandler: nil)
    }

    private func setPageCounter() {
        pageNumberController?.pageCount = PageCount(currentPage: currentPageIndex + 1, pageCount: document.pageCount)
    }

    private func updateThumbnailCollectionControllerWidth(size: CGSize) {
        let numberOfPages = CGFloat(document.pageCount)
        let cellSpacing = CGFloat(2.0)
        let totalSpacing = (numberOfPages - 1.0) * cellSpacing
        let thumbnailWidth = (numberOfPages * PDFThumbnailCell.cellSize.width) + totalSpacing
        let width = min(thumbnailWidth, size.width)
        thumbnailCollectionControllerWidth.constant = width
    }
}

extension PDFViewController: PDFThumbnailControllerDelegate {
    func didSelectIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        thumbnailCollectionController?.currentPageIndex = currentPageIndex
    }
}

extension PDFViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.pageCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "page", for: indexPath) as! PDFPageCollectionViewCell
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: document, pageCollectionViewCellDelegate: self)
        return cell
    }
}

extension PDFViewController: PDFSitemapViewControllerDelegate {
    func didSelect(page: Int) {
        let pageIndex = page - 1
        let thumbnailIndexPath = IndexPath(row: pageIndex, section: 0)
        collectionView.scrollToItem(at: thumbnailIndexPath, at: .left, animated: false)
        thumbnailCollectionController?.currentPageIndex = pageIndex
    }
}

extension PDFViewController: PDFPageCollectionViewCellDelegate {
    /// Toggles the hiding/showing of the thumbnail controller
    ///
    /// - parameter shouldHide: whether or not the controller should hide the thumbnail controller
    private func hideThumbnailController(_ shouldHide: Bool) {
        self.thumbnailCollectionControllerBottom.constant = shouldHide ? -thumbnailCollectionControllerHeight.constant : 0
        pageCounterContainer.alpha = shouldHide ? 0 : 1
    }
    
    func handleSingleTap(_ cell: PDFPageCollectionViewCell, pdfPageView: PDFPageView) {
        let shouldHide: Bool = {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }()
        pageCounterContainer.isHidden = false
        pageCounterContainer.alpha = shouldHide ? 1 : 0
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, animations: {
            self.hideThumbnailController(shouldHide)
            self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        }, completion: { _ in
            self.pageCounterContainer.isHidden = shouldHide
        })
    }
}


extension PDFViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

extension PDFViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if disableScrollUpdates {
            return
        }
        let updatedPageIndex: Int
        if self.scrollDirection == .vertical {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.y, 0) / scrollView.bounds.height))
        } else {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.x, 0) / scrollView.bounds.width))
        }
        
        if updatedPageIndex != currentPageIndex {
            currentPageIndex = updatedPageIndex
            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
    }
}
