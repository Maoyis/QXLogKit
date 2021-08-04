
import Foundation


/// 判断是否为模拟器，切模拟器下执行指定任务块
/// - Parameter block: 只在模拟器下才会执行的代码
/// - Returns: true: 是模拟器， false：非模拟器
@discardableResult
func qx_simulator(block:(()->Void)? = nil) -> Bool {
    #if targetEnvironment(simulator)
    block?()
    return true
    #else
    return false
    #endif
}

@discardableResult
func qx_debug(block:(()->Void)? = nil) -> Bool {
    #if DEBUG
    block?()
    return true
    #else
    return false
    #endif
}

public struct QXLog {
    public typealias ErrorHandler = (QXLog, Error, Source)->Void
    /// 日志输出级别
    public enum Source {
        case unknown
        case file(id:String = #file, line:Int = #line)
        case funcation(file:String = #fileID, name:String = #function, line:Int = #line)
        
        public var info:String {
            switch self {
            case .file(let path, let line): do {
                return "\nFile:\(path)\nLine:\(line)\n"
            }
            case .funcation(let file, let name, let line): return "\nFile:\(file)\nFuncation:\(name)\nLine:\(line)\n"
            default:
                break
            }
            return ""
        }
    }
    public enum Level {
        case `default`
        /// 关闭输出
        case close
        /// 只处理错误
        case error
        /// DEBUG模式输出
        case debug
        /// 只在模拟器上输出
        case simulator
    }
    /// 日志类型
    public enum LogType {
        case `default`
        case error
        case warning
    }
    /// 日志模块名称
    public var module:String?
    public var level:Level = .debug
    public var supports:[LogType] = [.default, .error, .warning]
    
    private var handler:ErrorHandler?
    
    public init(with level:Level = .debug, module:String? = nil, handler:ErrorHandler? = nil) {
        if level == .default {
            self.level   = .debug
        }else {
            self.level   = level
        }
        self.module = module
        self.handler = handler
    }
    
    /// 错误日志
    /// - Parameter error: 错误
    public func error(_ error:Error?, source:Source = .unknown, level:Level = .debug)  {
        guard let error = error else {
            return
        }
        if let handler = self.handler {
            handler(self, error, source)
            return
        }
        out(error, type: .error, level: level, source: source)
    }
    public func out(_ items: Any..., type:LogType = .default, level:Level = .default, source:Source = .unknown)  {
        guard supports.contains(type) else {
            return
        }
        var out:Bool = false
        let outLevel = level == .default ? self.level : level
        switch outLevel {
        case .debug: out = qx_debug()
        case .simulator: out = qx_simulator()
        default:
            break
        }
        guard out else {
            return
        }
        var  msg = items.map({"\($0)"}).joined(separator: " ")
        if source.info.count > 0 {
            msg = source.info + "message : " + msg
        }
        let name = self.module != nil ? "[\(self.module!)] : " : ""
        if type == .warning {
            msg = "\n------------ \(name)WARNING ------------\n"
                + msg
                + "\n---------------------------------"
        }else if type == .error {
            msg = "\n------------ \(name)ERROR ------------\n"
                + msg
                + "\n--------------------------------"
        }else {
            msg = name + msg
        }
        print(msg)
    }
    
}






