import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellData
import WordwellDomain

struct ContentView: View {
    @State private var router: AppRouter
    @AppStorage("wordwell.appearance") private var appearance: AppAppearance = .system
    @AppStorage("wordwell.lastFeaturedWordID") private var lastFeaturedWordID = ""
    @State private var featuredWord: WordEntry?
    @State private var isLoadingFeaturedWord = true
    @State private var featuredTopicID: String?
    @State private var featuredReason: String?
    @AppStorage("wordwell.wordForYouPick") private var wordForYouPick = ""
    private let dictionaryRepository: any DictionaryRepository
    private let libraryRepository: any WordLibraryRepository
    private let progressRepository: any ProgressRepository
    private let settingsRepository: any LearningSettingsRepository
    private let illustrationRepository: any IllustrationBindingRepository
    private let aiService: any LearningAI
    private let examPractice: (any ExamPracticeService)?
    private let conversation: (any ConversationService)?
    private let mistakeExplainer: (any MistakeExplainerService)?
    private let semanticSearch: (any SemanticSearchService)?
    private let speechRecognizer: OnDeviceSpeechRecognizer
    private let pronunciationPlayer: PronunciationPlayer
    private let dailyWordNotifications: DailyWordNotifications
    @Environment(\.scenePhase) private var scenePhase

    init(container: AppContainer) {
        _router = State(initialValue: container.router)
        dictionaryRepository = container.dictionaryRepository
        libraryRepository = container.libraryRepository
        progressRepository = container.progressRepository
        settingsRepository = container.settingsRepository
        illustrationRepository = container.illustrationRepository
        aiService = container.aiService
        examPractice = container.examPractice
        conversation = container.conversation
        mistakeExplainer = container.mistakeExplainer
        semanticSearch = container.semanticSearch
        speechRecognizer = container.speechRecognizer
        pronunciationPlayer = container.pronunciationPlayer
        dailyWordNotifications = DailyWordNotifications(dictionary: container.dictionaryRepository,
                                                        library: container.libraryRepository)
    }

    var body: some View {
        TabView(selection: $router.selection) {
            Tab("Home", systemImage: "house", value: .home) {
                NavigationStack(path: $router.homePath) {
                    HomeScreen(library: libraryRepository, progress: progressRepository, featuredWord: featuredWord,
                               isLoadingFeaturedWord: isLoadingFeaturedWord, featuredReason: featuredReason,
                               onOpenWord: { router.openWord(id: $0) },
                               onSearch: { router.homePath.append(.search) },
                               onPractice: { router.selection = .practice })
                        .navigationDestination(for: AppRoute.self, destination: routeDestination)
                }
            }
            Tab("Grammar", systemImage: "text.book.closed", value: .grammar) {
                NavigationStack(path: $router.grammarPath) {
                    GrammarScreen(settings: settingsRepository)
                        .navigationDestination(for: AppRoute.self, destination: routeDestination)
                }
            }
            Tab("Library", systemImage: "books.vertical", value: .library) {
                NavigationStack(path: $router.libraryPath) {
                    LibraryScreen(dictionary: dictionaryRepository, library: libraryRepository,
                                  illustrations: illustrationRepository) { router.openWord(id: $0) }
                        .navigationDestination(for: AppRoute.self, destination: routeDestination)
                }
            }
            Tab("Practice", systemImage: "pencil.line", value: .practice) {
                NavigationStack(path: $router.practicePath) {
                    PracticeScreen(progress: progressRepository,
                                   onStartReview: { router.startVocabularyReview() },
                                   onStartSpeaking: { router.startSpeaking() },
                                   onStartListening: { router.startListening() },
                                   onStartQuiz: { router.startQuiz() },
                                   onStartSkillsCheck: { router.startSkillsCheck() },
                                   onStartConversation: { router.startConversation() },
                                   onStartImproveSentence: { router.startImproveSentence() },
                                   onStartQuizMe: { router.startQuizMe() },
                                   onStartGrammar: { router.openGrammarLesson(id: GrammarProgressStore().nextLessonID()) })
                        .navigationDestination(for: AppRoute.self, destination: routeDestination)
                }
            }
            Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                NavigationStack(path: $router.profilePath) {
                    ProfileScreen(library: libraryRepository, progress: progressRepository,
                                  onProgress: { router.profilePath.append(.progress) },
                                  onSettings: { router.profilePath.append(.settings) })
                        .navigationDestination(for: AppRoute.self, destination: routeDestination)
                }
            }
        }
        .environment(\.mistakeExplainer, mistakeExplainer)
        .tint(WordwellColor.ink)
        .tabBarMinimizeBehavior(.never)
        .preferredColorScheme(appearance.colorScheme)
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await refreshFeaturedWord()
            if let profile = try? await settingsRepository.profile() {
                try? await dailyWordNotifications.refresh(for: profile)
            }
        }
        .task(id: router.selection) {
            // Topic is picked in Settings; re-pick the Home word when coming back with a new one.
            guard router.selection == .home, !isLoadingFeaturedWord,
                  let profile = try? await settingsRepository.profile(),
                  profile.wordTopicID != featuredTopicID else { return }
            await refreshFeaturedWord()
        }
    }

    private func refreshFeaturedWord() async {
        isLoadingFeaturedWord = true
        let profile = try? await settingsRepository.profile()
        let topicID = profile?.wordTopicID
        var word: WordEntry?
        var reason: String?
        if let personal = await wordForYou(profile: profile) {
            (word, reason) = personal
        } else {
            let topicIDs = VocabularyTopic.all.first { $0.id == topicID }.map { Set($0.wordIDs) }
            word = try? await dictionaryRepository.featuredEntry(excluding: lastFeaturedWordID, among: topicIDs)
        }
        guard !Task.isCancelled else { return }
        featuredWord = word
        featuredReason = reason
        featuredTopicID = topicID
        isLoadingFeaturedWord = false
        if let word {
            lastFeaturedWordID = word.id
        }
    }

    /// Deterministic pick from weak words, history and level (spec §13); nil falls back to a random word.
    private func wordForYou(profile: LearningProfile?) async -> (WordEntry, String)? {
        let day = Date.now.formatted(.iso8601.year().month().day().dateSeparator(.omitted))
        let topicID = profile?.wordTopicID
        let level = profile?.cefrLevel ?? .b1
        // Keep today's pick so saving the word (or reopening the app) does not swap it.
        let parts = wordForYouPick.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        if parts.count == 4, parts[0] == day, parts[1] == (topicID ?? ""),
           let entry = try? await dictionaryRepository.entry(id: parts[2]) {
            return (entry, parts[3])
        }
        let saved = (try? await libraryRepository.allSavedWords()) ?? []
        let signals = WordForYouSignals(
            weakIDs: (try? await progressRepository.weakQuizWordIDs(limit: 20)) ?? [],
            viewedIDs: (try? await libraryRepository.recentlyViewedWordIDs(limit: 20)) ?? [],
            savedIDs: Set(saved.map(\.wordID)),
            masteredIDs: Set(saved.filter { $0.status == .mastered }.map(\.wordID)),
            topicID: topicID, dayKey: day)
        for candidate in WordForYou.candidates(signals) {
            guard let entry = try? await dictionaryRepository.entry(id: candidate.wordID),
                  WordForYou.isWithinReach(entry.cefrLevel, learner: level) else { continue }
            wordForYouPick = [day, topicID ?? "", entry.id, candidate.reason].joined(separator: "|")
            return (entry, candidate.reason)
        }
        return nil
    }

    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .search:
            SearchScreen(repository: dictionaryRepository, semantic: semanticSearch, settings: settingsRepository) { router.openWord(id: $0) }
        case .topic(let id):
            if let topic = VocabularyTopic.all.first(where: { $0.id == id }) {
                TopicWordsScreen(topic: topic, dictionary: dictionaryRepository)
            } else {
                ContentUnavailableView("Topic unavailable", systemImage: "books.vertical")
            }
        case .dictionaryEntry(let wordID):
            DictionaryEntryScreen(wordID: wordID, repository: dictionaryRepository, library: libraryRepository,
                                  settings: settingsRepository, illustrations: illustrationRepository,
                                  player: pronunciationPlayer, ai: aiService)
        case .grammarLesson(let id):
            GrammarLessonRoute(id: id, settings: settingsRepository)
        case .vocabularyReview:
            VocabularyReviewScreen(dictionary: dictionaryRepository, library: libraryRepository,
                                   progress: progressRepository, illustrations: illustrationRepository)
        case .speaking:
            SpeakingScreen(progress: progressRepository, ai: aiService, settings: settingsRepository,
                           dictionary: dictionaryRepository, library: libraryRepository, recorder: speechRecognizer)
        case .listening:
            ChoicePracticeScreen(mode: .listening, dictionary: dictionaryRepository,
                                 library: libraryRepository, progress: progressRepository,
                                 settings: settingsRepository, player: pronunciationPlayer)
        case .quiz:
            ChoicePracticeScreen(mode: .quiz, dictionary: dictionaryRepository,
                                 library: libraryRepository, progress: progressRepository,
                                 settings: settingsRepository, player: pronunciationPlayer)
        case .skillsCheck:
            SkillsCheckScreen(progress: progressRepository, settings: settingsRepository,
                              exam: examPractice, recorder: speechRecognizer,
                              player: pronunciationPlayer)
        case .conversation:
            ConversationScreen(service: conversation, settings: settingsRepository, progress: progressRepository,
                               dictionary: dictionaryRepository, library: libraryRepository)
        case .improveSentence:
            ImproveSentenceScreen(ai: aiService, settings: settingsRepository)
        case .quizMe:
            QuizMeScreen(ai: aiService, dictionary: dictionaryRepository, progress: progressRepository,
                         settings: settingsRepository)
        case .progress:
            ProgressScreen(progress: progressRepository)
        case .settings:
            SettingsScreen(settings: settingsRepository, progress: progressRepository,
                           ai: aiService, notifications: dailyWordNotifications, appearance: $appearance)
        }
    }
}

#Preview {
    ContentView(container: .live)
}
