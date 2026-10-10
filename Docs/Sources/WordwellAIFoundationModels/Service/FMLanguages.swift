import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Keeps only the languages the on-device model can answer in. English is always kept.
public func onDeviceSupportedLanguages(
    _ all: [(code: String, name: String)],
    supports: (@Sendable (String) -> Bool)? = nil
) -> [(code: String, name: String)] {
    guard let supports = supports ?? systemSupports() else { return all }
    return all.filter { $0.code == "en" || supports($0.code) }
}

private func systemSupports() -> (@Sendable (String) -> Bool)? {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, macOS 26.0, *) {
        return { SystemLanguageModel.default.supportsLocale(Locale(identifier: $0)) }
    }
    #endif
    return nil
}
