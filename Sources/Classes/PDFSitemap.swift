//
//  Sitemap.swift
//  Pods
//
//  Created by Arne Link on 20.07.17.
//
//

import Foundation

public typealias PDFSitemap = [IPDFSitemapContent]

public protocol IPDFSitemapContent {
    var title: String { get }
    var page: Int { get }
}
