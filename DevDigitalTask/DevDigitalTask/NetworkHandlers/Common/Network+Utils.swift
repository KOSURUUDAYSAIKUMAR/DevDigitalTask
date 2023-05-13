

import Foundation

extension Reachability {
    public static func isNetwrokReachable() -> Bool {
        let connection = try? Reachability().connection
        if connection == .unavailable {
            return false
        }
        return true
    }
}
