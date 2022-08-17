//
//  FillRenderer.swift
//  pip-custom
//
//  Created by Naruki Chigira on 2022/08/13.
//

import CoreGraphics
import CoreMedia
import UIKit

class FillRenderer: PiPRenderer {
    /// アスペクト比
    enum AspectRatio: Int {
        /// 16:9
        case wideScreen = 0
        /// 1:1
        case square
        /// 5:1
        case flat
    }
    
    /// グラデーションの1周にかかるフレーム数
    private let gradationInterval: Int
    private var counter: Int = 0
    
    var aspectRatio: AspectRatio = .wideScreen
    
    init(gradationInterval: Int) {
        guard gradationInterval > 0 else {
            fatalError("'gradationInterval' must be lager than 0 (\(gradationInterval).")
        }
        self.gradationInterval = gradationInterval
    }
    
    var preferedCanvasSize: CGSize {
        switch aspectRatio {
        case .wideScreen:
            return .init(width: 160, height: 90)
        case .square:
            return .init(width: 200, height: 200)
        case .flat:
            return .init(width: 200, height: 40)
        }
    }
    
    func render(on sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let pixelBuffer = imageBuffer as CVPixelBuffer

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        
        // CGContext の生成
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: data,
            width: Int(preferedCanvasSize.width),
            height: Int(preferedCanvasSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return
        }
        
        // グラデーションの描画
        counter += 1
        let hue = CGFloat(counter % gradationInterval) / CGFloat(gradationInterval)
        let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).cgColor
        context.setFillColor(color)
        context.fill(.init(origin: .zero, size: preferedCanvasSize))
    }
}
