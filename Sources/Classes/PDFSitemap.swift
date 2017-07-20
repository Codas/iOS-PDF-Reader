//
//  Sitemap.swift
//  Pods
//
//  Created by Arne Link on 20.07.17.
//
//

import Foundation

public typealias PDFSitemap = [PDFSitemapContent]

public struct PDFSitemapContent {
    public let title: String
    public let page: Int
}
