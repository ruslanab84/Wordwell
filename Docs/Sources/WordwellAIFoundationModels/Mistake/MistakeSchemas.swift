#if canImport(FoundationModels)
import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GMistakeExplanation {
    @Guide(description: "One or two short sentences: why the chosen answer does not fit, in the required response language")
    var whyWrong: String
    @Guide(description: "One or two short sentences: why the correct answer fits, in the required response language")
    var whyRight: String
}
#endif
