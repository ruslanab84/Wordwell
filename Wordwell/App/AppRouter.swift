import Observation
import WordwellData

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
    case quizMe
    case pictureQuiz
    case grammarLesson(id: String)
    case grammarReview
    case grammarMistakes
    case grammarCategory(GrammarCategory, level: GrammarCEFR?)
    case collocations
    case collocationGroup(String)
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
    /// True when each tab shows its root list beside a detail column (unfolded iPhone Duo, iPad).
    var isSplit = false

    func openWord(id: String, fromRoot: Bool = false) {
        let route = AppRoute.dictionaryEntry(wordID: id)
        switch selection {
        case .home: push(route, onto: \.homePath, fromRoot: fromRoot)
        case .grammar: push(route, onto: \.grammarPath, fromRoot: fromRoot)
        case .library: push(route, onto: \.libraryPath, fromRoot: fromRoot)
        case .practice: push(route, onto: \.practicePath, fromRoot: fromRoot)
        case .profile: push(route, onto: \.profilePath, fromRoot: fromRoot)
        }
    }

    /// In two columns a tap in the root list swaps the detail column instead of stacking on it.
    func push(_ route: AppRoute, onto path: ReferenceWritableKeyPath<AppRouter, [AppRoute]>, fromRoot: Bool = true) {
        if isSplit && fromRoot {
            self[keyPath: path] = [route]
        } else {
            self[keyPath: path].append(route)
        }
    }

    func openGrammarLesson(id: String) {
        selection = .grammar
        push(.grammarLesson(id: id), onto: \.grammarPath)
    }

    func startVocabularyReview() {
        selection = .practice
        push(.vocabularyReview, onto: \.practicePath)
    }

    func startSpeaking() {
        selection = .practice
        push(.speaking, onto: \.practicePath)
    }

    func startListening() {
        selection = .practice
        push(.listening, onto: \.practicePath)
    }

    func startQuiz() {
        selection = .practice
        push(.quiz, onto: \.practicePath)
    }

    func startSkillsCheck() {
        selection = .practice
        push(.skillsCheck, onto: \.practicePath)
    }

    func startConversation() {
        selection = .practice
        push(.conversation, onto: \.practicePath)
    }

    func startImproveSentence() {
        selection = .practice
        push(.improveSentence, onto: \.practicePath)
    }

    func startQuizMe() {
        selection = .practice
        push(.quizMe, onto: \.practicePath)
    }
}
