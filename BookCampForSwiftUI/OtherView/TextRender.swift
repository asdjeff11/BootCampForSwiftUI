//
//  TextRender.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/4.
//
import SwiftUI

extension Text.Layout {
  var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
    flatMap { line in
      line
    }
  }
    
  var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
    flattenedRuns.flatMap(\.self)
  }
}

struct BlurAttribute: TextAttribute {}

struct CustomTextRenderer: TextRenderer {
    let timeOffset: Double // Time offset
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let count = layout.flattenedRunSlices.count
        let width = layout.first?.typographicBounds.rect.width ?? 0 // 第一行寬度
        let height = layout.first?.typographicBounds.rect.height ?? 0 // 第一行高度

        for (index, slice) in layout.flattenedRunSlices.enumerated() {
            let offset = animatedSineWaveOffset(
                forCharacterAt: index,
                amplitude: height / 2, // 中間為基準線
                wavelength: width,
                phaseOffset: timeOffset,
                totalCharacters: count
              )
            
            var ctx = context
            if ( slice[BlurAttribute.self] != nil ) {
                var blurContext = ctx
                let radius = slice.typographicBounds.rect.height / 5
                blurContext.addFilter(.blur(radius: radius))
                blurContext.translateBy(x: 0, y: offset)
                blurContext.draw(slice)
            }
            
            ctx.translateBy(x: 0, y: offset)
            ctx.draw(slice)
            
        }
    }
    
    func animatedSineWaveOffset(forCharacterAt index: Int, amplitude: Double, wavelength: Double, phaseOffset: Double, totalCharacters: Int) -> Double {
        let x = Double(index)
        let position = (x / Double(totalCharacters)) * wavelength
        let radians = ((position + phaseOffset) / wavelength) * 2 * .pi
        return sin(radians) * amplitude
    }
}
