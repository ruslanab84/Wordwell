import Observation

enum AppTab: Hashable, CaseIterable {
    case home, grammar, library, practice, profile
}

enum AppRoute: Hashable {
    case search
    case topic(id: String)
    case dictionaryEntry(wordID: String)
    case vocabularyReview
    case speaking
    case listening
    case quiz
    case skillsCheck
    case conversation
    case improveSentence
    case grammarLesson(id: String)
    case progress
    case settings
}

@MainActor
@Observable
final class AppRouter {
    var selection: AppTab = .home
    var homePath: [AppRoute] = []
    var grammarPath: [AppRoute] = []
    var libraryPath: [AppRoute] = []
    var practicePath: [AppRoute] = []
    var profilePath: [AppRoute] = []

    func openWord(id: String) {
        let route = AppRoute.dictionaryEntry(wordID: id)
        switch selection {
        case .home: homePath.append(route)
        case .grammar: grammarPath.append(route)
        case .library: libraryPath.append(route)
        case .practice: practicePath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    func openGrammarLesson(id: String) {
        selection = .grammar
        grammarPath.append(.grammarLesson(id: id))
    }

    func startVocabularyReview() {
        selection = .practice
        practicePath.append(.vocabularyReview)
    }

    func startSpeaking() {
        selection = .practice
        practicePath.append(.speaking)
    }

    func startListening() {
        selection = .practice
        practicePath.append(.listening)
    }

    func startQuiz() {
        selection = .practice
        practicePath.append(.quiz)
    }

    func startSkillsCheck() {
        selection = .practice
        practicePath.append(.skillsCheck)
    }

    func startConversation() {
        selection = .practice
        practicePath.append(.conversation)
    }

    func startImproveSentence() {
        selection = .practice
        practicePath.append(.improveSentence)
    }
}
