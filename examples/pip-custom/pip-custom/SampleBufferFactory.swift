//
//  SampleBufferFactory.swift
//  pip-custom
//
//  Created by Naruki Chigira on 2022/08/13.
//

import CoreMedia

/// CVPixelBufferPool を活用して CMSampleBuffer の生成をする
class CMSampleBufferFactory {
    /// サイズごとの CVPixelBufferPool のキャッシュ
    private var pixelBufferPoolDictionary: [String: CVPixelBufferPool] = [:]

    /// CMSampleBuffer の生成
    func make(width: Int, height: Int, presentationTimeStamp: CMTime, refreshRate: Int) -> CMSampleBuffer? {
        let pixelBufferPoolKey = makePixelBufferPoolDictionaryKey(width: width, height: height)
        
        /// 新しいサイズのための CVPixelBufferPool が必要な場合は生成して保存する
        if pixelBufferPoolDictionary[pixelBufferPoolKey] == nil, let pixelBufferPool = makePixelBufferPool(width: width, height: height) {
            pixelBufferPoolDictionary[pixelBufferPoolKey] = pixelBufferPool
        }
        guard let pixelBufferPool = pixelBufferPoolDictionary[pixelBufferPoolKey] else {
            print("Failed to get pixelBufferPool.")
            return nil
        }
        
        /// CVPixelBuffer の生成
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &pixelBuffer)
        guard let pixelBuffer = pixelBuffer else {
            print("Failed to create pixelBuffer.")
            return nil
        }

        /// CMSampleBuffer の生成
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
        guard let formatDescription = formatDescription else {
            print("Failed to create CMFormatDescription.")
            return nil
        }

        var sampleTiming = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: CMTimeScale(refreshRate)),
            presentationTimeStamp: presentationTimeStamp,
            decodeTimeStamp: presentationTimeStamp
        )
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription,
            sampleTiming: &sampleTiming,
            sampleBufferOut: &sampleBuffer
        )
        return sampleBuffer
    }

    /// pixelBufferPoolDictionary のキーとなる文字列を生成する
    private func makePixelBufferPoolDictionaryKey(width: Int, height: Int) -> String {
        "\(width),\(height)"
    }
    
    /// CVPixelBufferPool の生成
    private func makePixelBufferPool(width: Int, height: Int) -> CVPixelBufferPool? {
        let attributes = [
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferBytesPerRowAlignmentKey as String: width * 4,
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ] as CFDictionary
        var pixelBufferPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(nil, nil, attributes, &pixelBufferPool)
        return pixelBufferPool
    }
}
