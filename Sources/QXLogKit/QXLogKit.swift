
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
    public typealias ErrorHandler = (Error)->Void
    /// 日志输出级别
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
    
    // 只有模拟器上需要输出日志
    public var level:Level = .debug
    public var supports:[LogType] = [.default, .error, .warning]
    
    private var handler:ErrorHandler?
    
    public init(with level:Level = .debug, handler:ErrorHandler? = nil) {
        if level == .default {
            self.level   = .debug
        }else {
            self.level   = level
        }
        self.handler = handler
    }
    
    /// 错误日志
    /// - Parameter error: 错误
    public func error(_ error:Error?, level:Level = .debug, module:String? = nil)  {
        guard let error = error else {
            return
        }
        if let handler = self.handler {
            handler(error)
            return
        }
        out(error, type: .error, module: module, level: level)
    }
    public func out(_ items: Any..., type:LogType = .default, module:String? = nil, level:Level = .default)  {
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
        if let name = module {
            msg = "[\(name)] : " + msg
        }
        if type == .warning {
            msg = "\n------------ WARNING ------------\n"
                + msg
                + "\n---------------------------------"
        }else if type == .error {
            msg = "\n------------ ERROR ------------\n"
                + msg
                + "\n--------------------------------"
        }
    }
    
}






