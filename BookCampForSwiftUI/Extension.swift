//
//  Extension.swift
//  BookCampForSwiftUI
//
//  Created by 楊宜濱 on 2025/5/3.
//

import UIKit
import Combine

extension UIColor {
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
}

extension Date {
    func getNextMonth() -> Date? { // 取得下個月份
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    } // 取得下個月份

    func getPreviousMonth() -> Date? { // 取得上個月份
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    } // 取得上個月份
    
    func dayDiff(toDate:Date)->Int { // 相差多少日
        // toDate - self
        let component = Calendar.current.dateComponents([.day], from: self,to: toDate)
        return component.day ?? 0
    }
    
    func getOffsetDay( type:Calendar.Component , offset:Int)->Date {
        return Calendar.current.date( byAdding: type, value: offset, to:self)!
    }
    
    func countOfDaysInMonth()->Int { // 當月天數
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let range = ( calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return (range?.length)!
    }
    
    /// 重載運算子 時間互減
    static func -(d1:Date,d2:Date)->Double {
        let timePassSec = d1.timeIntervalSince1970 - d2.timeIntervalSince1970
        return Double(String(format: "%.3f", timePassSec))!
    }
}


extension UIImage {
    static func rotateImage(_ image: UIImage, withAngle angle: Double) -> UIImage? { // 旋轉圖片
        if angle.truncatingRemainder(dividingBy: 360) == 0 { return image }
        let imageRect = CGRect(origin: .zero, size: image.size)
        let radian = CGFloat(angle / 180 * Double.pi)
        let rotatedTransform = CGAffineTransform.identity.rotated(by: radian)
        var rotatedRect = imageRect.applying(rotatedTransform)
        rotatedRect.origin.x = 0
        rotatedRect.origin.y = 0
        UIGraphicsBeginImageContext(rotatedRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: rotatedRect.width / 2, y: rotatedRect.height / 2)
        context.rotate(by: radian)
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        image.draw(at: .zero)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    } // 旋轉圖片
    func fixOrientation() -> UIImage{ // 防止ios自動旋轉
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi));
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(Double.pi / 2));
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: UInt32(self.cgImage!.bitmapInfo.rawValue)
        )
        
        ctx!.concatenate(transform);
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(self.cgImage!, in: CGRect(x:0 ,y: 0 ,width: self.size.height ,height:self.size.width))
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x:0 ,y: 0 ,width: self.size.width ,height:self.size.height))
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        
        return img;
    }  // 防止ios自動旋轉
    
    func toCircle() -> UIImage { // 將圖片轉成圓型
        //取最短边长
        let shotest = min(self.size.width, self.size.height)
        //输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        //开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        //添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        //绘制图片
        self.draw(in: CGRect(x: (shotest-self.size.width)/2,
                             y: (shotest-self.size.height)/2,
                             width: self.size.width,
                             height: self.size.height))
        //获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return maskedImage ?? UIImage()
    } // 將圖片轉成圓型
    
    // 調整圖片大小  最小邊 變成設定的數值 其餘裁切
    // 小編比例縮放到定位後 切掉多餘的大邊
    
    static func scaleImage(image:UIImage, newSize:CGSize)->UIImage {
        //        获得原图像的尺寸属性
        let imageSize = image.size
        //        获得原图像的宽度数值
        let width = imageSize.width // 500
        //        获得原图像的高度数值
        let height = imageSize.height // 421

        //        计算图像新尺寸与旧尺寸的宽高比例
        let widthFactor = newSize.width/width // 0.115
        let heightFactor = newSize.height/height // 0.136579
        //        获取小邊的比例
        let scalerFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor // 0.136579

        //        计算图像新的高度和宽度，并构成标准的CGSize对象
        let scaledWidth = width * scalerFactor // 68.289
        let scaledHeight = height * scalerFactor // 57.49999
        let targetSize = CGSize(width: scaledWidth, height: scaledHeight)

        //        创建绘图上下文环境，
        UIGraphicsBeginImageContextWithOptions(targetSize,false,0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        //        获取上下文里的内容，将视图写入到新的图像对象
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 裁截
        let newWidth = newSize.width
        let newHeight = newSize.height
        
        let renderer = UIGraphicsImageRenderer(size:newSize)
        if let img = newImage {
            let x = -( img.size.width - newWidth ) / 2
            let y = -( img.size.height - newHeight ) / 2
            newImage = renderer.image { (context) in
                img.draw(at: CGPoint(x: x, y: y))
            }
        }
        return newImage ?? image

    } // 調整圖片大小
    
    static func resize_no_cut(image:UIImage , newSize:CGSize)->UIImage { // 短邊縮放置 對應長度  長編會超出比例
        // 获得原图像的尺寸属性
        let imageSize = image.size
        // 获得原图像的宽度数值
        let width = imageSize.width
        // 获得原图像的高度数值
        let height = imageSize.height
        // 取最大的縮小因子
        let factor = min(newSize.width/width,newSize.height/height)
        // 比例縮放
        let scaledWidth = width * factor
        let scaledHeight = height * factor
        let targetSize = CGSize(width: scaledWidth, height: scaledHeight) // 獲取全新的size
        //        创建绘图上下文环境，
        
        //UIGraphicsBeginImageContext(targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize,false,0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
        //        获取上下文里的内容，将视图写入到新的图像对象
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //返回一个将白色背景变透明的UIImage
    func imageByRemoveWhiteBg() -> UIImage? {
        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]
        return transparentColor(colorMasking: colorMasking)
    }
     
    //返回一个将黑色背景变透明的UIImage
    func imageByRemoveBlackBg() -> UIImage? {
        let colorMasking: [CGFloat] = [0, 32, 0, 32, 0, 32]
        return transparentColor(colorMasking: colorMasking)
    }
     
    func transparentColor(colorMasking:[CGFloat]) -> UIImage? {
        if let rawImageRef = self.cgImage {
            UIGraphicsBeginImageContext(self.size)
            if let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) {
                let context: CGContext = UIGraphicsGetCurrentContext()!
                context.translateBy(x: 0.0, y: self.size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                context.draw(maskedImageRef, in: CGRect(x:0, y:0, width:self.size.width,
                                                        height:self.size.height))
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return result
            }
        }
        return nil
    }
}


extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
    
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}


extension Publishers {
    private final class UIControlSubscription<S:Subscriber,Control:UIControl>:Subscription where S.Input == Control, S.Failure == Never {
        private var subscriber:S?
        private let control:Control
        private let event:Control.Event
        
        init(subscriber:S, control:Control, event:Control.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            subscribe()
        }
        
        deinit {
            print("subscribtion deinit")
        }
        
        func request(_ demand: Subscribers.Demand) { // 限制只能接收多少資訊
            
        }
        
        func cancel() {
            subscriber = nil
        }
        
        private func subscribe() { // 創建時 呼叫 (init那邊)
            self.control.addTarget(self, action: #selector(eventHandler), for: self.event)
        }
        
        @objc private func eventHandler() {
            // 發布 訊息
            _ = subscriber?.receive(self.control) // 呼叫 Publisher 的 map 對資料做加工  反回觸發的元件讓他去判斷
        }
    }
    
    struct UIControlPublisher<Control:UIControl>:Publisher {
        // 底下兩個為 Publisher Protocol , OutPut 為 要監聽的元件 , Failure 為 失敗事件
        typealias Output = Control
        typealias Failure = Never
        
        let control:Control
        let controlEvent:UIControl.Event
        
        init(control:Control, event:UIControl.Event) {
            self.control = control
            self.controlEvent = event
        }
        
        // 實現這個方法 將調用 subscribe(_:)  訂閱的訂閱者附加到發布者上  subscriber -> subscription publisher
        func receive<S>(subscriber:S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input { // 外部呼叫 sink 時  呼叫此  代表要訂閱了 ( 這是 Publisher 的 protocol )
            let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: controlEvent) // 建立 Subscription
            // subscriber receive 時 主動調用subscription的 request 方法
            subscriber.receive(subscription: subscription) // 訂閱
        }
        
        // 將訂閱者附加到發布者上 內部將調用receive方法
        /*func subscribe<S>(_ subscriber:S ) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
           
        }*/
    }
}

struct SplitedResult { // 正規表達式 切割字串
    let fragment: String
    let isMatched: Bool
    let captures: [String?]
}

extension String {
    //返回第一次出现的指定子字符串在此字符串中的索引
    //（如果backwards参数设置为true，则返回最后出现的位置）
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = -1
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    var base64String: String {
        return Data(utf8).base64EncodedString()
    }
    var hexa2Bytes: [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap { UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
    
    /// 字串補 base64 的等號（不然他會轉譯失敗）
    private func addBase64EqualString(_ str:String)->String {
        let addCount = str.count == 0 ? 0 : (3 - ((str.count - 1)%3 + 1))
        var equalSign = ""
        for _ in 0..<addCount { equalSign += "=" }
        return str + equalSign
    }
    
    /// 變完整的Base64再轉成 Hex(16進位) 型態
    var HexBase64Hash:String {
        let urlTurnStr = self.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        return Data(base64Encoded: addBase64EqualString(urlTurnStr))!.hexEncodedString()
    }
    
    func jsonToDictionary() throws -> [String: Any] {
        guard let data = self.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any] ?? [:]
    }
    
    func stringToDictionary()-> [String:String] {
        let list = self.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").components(separatedBy: ",")
        var dict:[String:String] = [:]
        for item in list {
            let argument = item.replacingOccurrences(of: "\"", with: "").components(separatedBy: ":")
            dict[argument[0]] = argument[1]
        }
        return dict
    }
    
    //使用正則表達式替換
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with)
    }
    
  
    var base64Tobase64URL:String {
        return self .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "=", with: "")
    }
    
    var base64URLTobase64:String {
        var base64 = self .replacingOccurrences(of: "-", with: "+")
                          .replacingOccurrences(of: "_", with: "/")
        if ( base64.count % 4 != 0 ) {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    // data -> Hex String
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0 as! CVarArg) }.joined()
    }
    
    /// 正则分割字符串
    func split(
        usingRegex pattern: String,
        options: NSRegularExpression.Options = .dotMatchesLineSeparators
    ) -> [SplitedResult] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
            
            var currentIndex = startIndex
            var range: Range<String.Index>
            var captures: [String?] = []
            var results: [SplitedResult] = []
            for match in matches {
                range = Range(match.range, in: self)!
                if range.lowerBound > currentIndex {
                    results.append(SplitedResult(fragment: String(self[currentIndex..<range.lowerBound]), isMatched: false, captures: []))
                }
                
                if match.numberOfRanges > 1 {
                    for i in 1..<match.numberOfRanges {
                        if let _range = Range(match.range(at: i), in: self) {
                            captures.append(String(self[_range]))
                        } else {
                            captures.append(nil)
                        }
                    }
                }
                
                results.append(SplitedResult(fragment: String(self[range]), isMatched: true, captures: captures))
                currentIndex = range.upperBound
                captures.removeAll()
            }
            
            if endIndex > currentIndex {
                results.append(SplitedResult(fragment: String(self[currentIndex..<endIndex]), isMatched: false, captures: []))
            }
            
            return results
        } catch {
            fatalError("正则表达式有误，请更正后再试！")
        }
    }

}

extension Data {
    var integer: Int {
        return withUnsafeBytes { $0.load(as: Int.self) }
    }
    var int32: Int32 {
        return withUnsafeBytes { $0.load(as: Int32.self) }
    }
    var float: Float {
        return withUnsafeBytes { $0.load(as: Float.self) }
    }
    var double: Double {
        return withUnsafeBytes { $0.load(as: Double.self) }
    }
    var string: String? {
        return String(data: self, encoding: .utf8)
    }
    
    init?(base64EncodedURLSafe string: String, options: Base64DecodingOptions = []) {
        let string = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        self.init(base64Encoded: string, options: options)
    }
    
    // data -> Hex String
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
    func fourBytesToInt()->Int {
        var value : UInt32 = 0
        let data = self.reserve()
        
        let nsData = NSData(bytes: [UInt8](data), length: self.count)
        nsData.getBytes(&value, length: self.count)
        value = UInt32(bigEndian: value)
        return Int(value)
    }
    
    func reserve()->Data {
        let count:Int = self.count ;
        var array = Data(count:count)
        for i in 0..<count {
            array[i] = self[count - 1 - i]
        }
        
        return array
    }
    
}
