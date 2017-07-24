//
//  PDFSitemapViewController.swift
//  Pods
//
//  Created by Arne Link on 20.07.17.
//
//

import UIKit

class PDFSitemapViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    public weak var delegate: PDFSitemapViewControllerDelegate?
    public var currentPageIndex: Int?

    public var sitemap: PDFSitemap! {
        didSet {
            if let tableView = tableView {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        if let currentPageIndex = self.currentPageIndex {
            let selectedIdx = sitemap.prefix(while: { sitemapData in
                sitemapData.page <= currentPageIndex + 1
            }).count - 1
            if selectedIdx >= 0 {
                let indexPath = IndexPath(row: selectedIdx, section: 0)
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PDFSitemapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sitemapContent: IPDFSitemapContent = sitemap[indexPath.row]
        delegate?.didSelect(page: sitemapContent.page)
        self.navigationController?.popViewController(animated: true)
    }
}

extension PDFSitemapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sitemap.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PDFSitemapTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let sitemapContent: IPDFSitemapContent = sitemap[indexPath.row]
        cell.titleLabel.text = sitemapContent.title
        cell.numberLabel.text = String(sitemapContent.page)
        return cell
    }
}

protocol PDFSitemapViewControllerDelegate: class {
    func didSelect(page: Int)
}
