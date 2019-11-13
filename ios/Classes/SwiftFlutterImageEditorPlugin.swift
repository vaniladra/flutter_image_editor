import Flutter
import UIKit

public class SwiftFlutterImageEditorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "top.kikt/flutter_image_editor", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterImageEditorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getCachePath":
            result(NSTemporaryDirectory())
        case "memoryToFile":
            handleResult(call: call, outputMemory: false, result: result)
        case "memoryToMemory":
            handleResult(call: call, outputMemory: true, result: result)
        case "fileToMemory":
            handleResult(call: call, outputMemory: true, result: result)
        case "fileToFile":
            handleResult(call: call, outputMemory: false, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func handleResult(call: FlutterMethodCall, outputMemory: Bool, result: @escaping FlutterResult) {
        DispatchQueue.global().async{
            guard let wrapper = call.getUIImageWrapper() else {
                DispatchQueue.main.sync {
                     result(FlutterError(code: "decode image error", message: nil, details: nil))
                }
                return
            }
            
            guard let image = wrapper.image else{
                DispatchQueue.main.sync {
                     result(FlutterError(code: "decode image error", message: nil, details: nil))
                }
                return
            }

            let args = call.arguments as! [String: Any]
            let imageHandler = UIImageHandler(image: image)

            let optionMap = args["options"] as! [Any]
            let options = ConvertUtils.getOptions(options: optionMap)
            let format = ConvertUtils.getFormat(args: args)
            let keepExif = args["keepExif"] as! Bool
            
            imageHandler.handleImage(options: options)

            if outputMemory {
                var momery = imageHandler.outputMemory(format: format)
                if keepExif, wrapper.exifKeeper != nil {
                    momery = wrapper.exifKeeper!.saveExif(data: momery)
                }
                DispatchQueue.main.sync {
                    result(momery)
                }
            } else {
                let target = args["target"] as! String
                imageHandler.outputFile(targetPath: target, format: format)
                if keepExif, wrapper.exifKeeper != nil {
                    wrapper.exifKeeper!.saveExif(path: target)
                }
                DispatchQueue.main.sync {
                    result(target)
                }
            }
        }
    }
}

extension FlutterMethodCall {
    func getUIImage() -> UIImage? {
        let args = arguments as! [String: Any]

        let src = args["src"] as? String

        if src != nil {
            let url = URL(fileURLWithPath: src!)
            return UIImage(contentsOfFile: url.absoluteString)
        }

        guard let data = args["image"] as? FlutterStandardTypedData else {
            return nil
        }

        let image = data.data

        return UIImage(data: image)
    }
    
    func getUIImageWrapper() -> UIImageWrapper? {
        let args = arguments as! [String: Any]

        let src = args["src"] as? String

        if src != nil {
            let url = URL(fileURLWithPath: src!)
            let image = UIImage(contentsOfFile: url.absoluteString)
            let data = try? Data(contentsOf: url)
            let keeper = ExifKeeper(data: data)
            if image == nil{
                return nil
            }
            return UIImageWrapper(image: image, exifKeeper: keeper)
        }

        guard let imageArgs = args["image"] as? FlutterStandardTypedData else {
            return nil
        }

        let data = imageArgs.data
        let keeper = ExifKeeper(data: data)
        let image = UIImage(data: data)
        return UIImageWrapper(image: image, exifKeeper: keeper)
    }
    
    
}
