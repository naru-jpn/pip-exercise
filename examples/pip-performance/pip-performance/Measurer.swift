//
//  Measurer.swift
//  pip-performance
//
//  Created by Naruki Chigira on 2022/08/14.
//

import CoreImage
import CoreVideo
import UIKit

@MainActor
/// 描画コストに関する処理の計測
class Measurer: ObservableObject {
    /// 試行回数
    let numberOfTrials: Int = 1000
    /// 生成する CVPixelBuffer のサイズ
    let pixelBufferSize: CGSize = .init(width: 2000, height: 2000)
    /// 描画するビューのサイズ
    let viewSize: CGSize = .init(width: 160, height: 90)
    /// ビューを重ねる数
    let subviewCount: Int = 10
    
    @Published var contextCreateAverageTimeMS: TimeInterval?
    @Published var pixelBufferCreateAverageTimeMS: TimeInterval?
    @Published var pixelBufferCreateFromPoolAverageTimeMS: TimeInterval?
    @Published var singleViewImageCreateAverageTimeMS: TimeInterval?
    @Published var multipleViewImageCreateAverageTimeMS: TimeInterval?
    @Published var singleImageViewImageCreateAverageTimeMS: TimeInterval?
    @Published var multipleImageViewImageCreateAverageTimeMS: TimeInterval?
    
    /// CIContect の生成コストの計測
    func measureContextCreateAverageTime() {
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            _ = CIContext()
            totalTime += Date().timeIntervalSince1970 - startTime
        }
        contextCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// CVPixelBuffer の生成コストの計測
    func measurePixelBufferCreateAverageTime() {
        // prepare
        let size = pixelBufferSize
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ] as CFDictionary
        var pixelBufferOut: CVPixelBuffer?
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attributes, &pixelBufferOut)
            totalTime += Date().timeIntervalSince1970 - startTime
            // check
            guard pixelBufferOut != nil else {
                fatalError("Failed to create pixel buffer.")
            }
            // avoid memory leak
            pixelBufferOut = nil
        }
        pixelBufferCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// CVPixelBufferPool から 生成する場合の CVPixelBuffer の生成コストの計測
    func measurePixelBufferCreateFromPoolAverageTime() {
        func makePixelBufferPool(width: Int, height: Int) -> CVPixelBufferPool? {
            let attributes = [
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferBytesPerRowAlignmentKey as String: width * 4,
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ] as CFDictionary
            var pixelBufferPool: CVPixelBufferPool?
            CVPixelBufferPoolCreate(nil, nil, attributes, &pixelBufferPool)
            return pixelBufferPool
        }
        // prepare
        let size = pixelBufferSize
        guard let pixelBufferPool = makePixelBufferPool(width: Int(size.width), height: Int(size.height)) else {
            fatalError("Failed to create pixel buffer pool.")
        }
        var pixelBufferOut: CVPixelBuffer?
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBufferOut)
            totalTime += Date().timeIntervalSince1970 - startTime
            // check
            guard pixelBufferOut != nil else {
                fatalError("Failed to create pixel buffer from pool.")
            }
            // avoid memory leak
            pixelBufferOut = nil
        }
        pixelBufferCreateFromPoolAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// 単一のビューから　UIImage を生成する際のコストの計測
    func measureCreateUIImageFromSingleView() {
        // prepare
        let view = makeDrawnView(isSingle: true)
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            let renderer = UIGraphicsImageRenderer.init(size: view.frame.size)
            _ = renderer.image { context in
                view.layer.render(in: context.cgContext)
            }
            totalTime += Date().timeIntervalSince1970 - startTime
            // avoid memory leak
            Thread.sleep(forTimeInterval: 0.0)
        }
        singleViewImageCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// 重ねられたビューから　UIImage を生成する際のコストの計測
    func measureCreateUIImageFromMultipleView() {
        // prepare
        let view = makeDrawnView(isSingle: false)
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            let renderer = UIGraphicsImageRenderer.init(size: view.frame.size)
            _ = renderer.image { context in
                view.layer.render(in: context.cgContext)
            }
            totalTime += Date().timeIntervalSince1970 - startTime
            // avoid memory leak
            Thread.sleep(forTimeInterval: 0.0)
        }
        multipleViewImageCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// 単一のイメージビューから　UIImage を生成する際のコストの計測
    func measureCreateUIImageFromSingleImageView() {
        // prepare
        let view = makeDrawnImageView(isSingle: true)
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            let renderer = UIGraphicsImageRenderer.init(size: view.frame.size)
            _ = renderer.image { context in
                view.layer.render(in: context.cgContext)
            }
            totalTime += Date().timeIntervalSince1970 - startTime
            // avoid memory leak
            Thread.sleep(forTimeInterval: 0.0)
        }
        singleImageViewImageCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// 重ねられたイメージビューから　UIImage を生成する際のコストの計測
    func measureCreateUIImageFromMultipleImageView() {
        // prepare
        let view = makeDrawnImageView(isSingle: false)
        // measure
        var totalTime: TimeInterval = 0
        for _ in 0..<numberOfTrials {
            let startTime = Date().timeIntervalSince1970
            let renderer = UIGraphicsImageRenderer.init(size: view.frame.size)
            _ = renderer.image { context in
                view.layer.render(in: context.cgContext)
            }
            totalTime += Date().timeIntervalSince1970 - startTime
            // avoid memory leak
            Thread.sleep(forTimeInterval: 0.0)
        }
        multipleImageViewImageCreateAverageTimeMS = totalTime / TimeInterval(numberOfTrials) * 1000
    }
    
    /// 描画対象のビューを生成する
    ///
    /// - Parameters:
    ///   - isSingle: 単一のビューであるか
    private func makeDrawnView(isSingle: Bool) -> UIView {
        let size = viewSize
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        view.backgroundColor = .white
        if !isSingle {
            for _ in 0..<subviewCount {
                let subview = UIView()
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.backgroundColor = .init(white: 0, alpha: 0.1)
                view.addSubview(subview)
                subview.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                subview.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            }
        }
        view.layoutIfNeeded()
        return view
    }
    
    /// 描画対象のイメージビューを生成する
    ///
    /// - Parameters:
    ///   - isSingle: 単一のビューであるか
    private func makeDrawnImageView(isSingle: Bool) -> UIView {
        guard let image = UIImage(named: "image") else {
            fatalError("Failed to get image.")
        }
        let size = viewSize
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        view.image = image
        if !isSingle {
            for _ in 0..<subviewCount {
                let subview = UIImageView()
                subview.translatesAutoresizingMaskIntoConstraints = false
                subview.image = image
                view.addSubview(subview)
                subview.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                subview.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            }
        }
        view.layoutIfNeeded()
        return view
    }
}
