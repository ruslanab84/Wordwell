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
    private let dictionaryRepository: any DictionaryRepository
    private let libraryRepository: any WordLibraryRepository
    private let progressRepository: any ProgressRepository
    private let settingsRepository: any LearningSettingsRepository
    private let illustrationRepository: any IllustrationBindingRepository
    private let aiService: any LearningAI
    private let examPractice: (any ExamPracticeService)?
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
                               isLoadingFeaturedWord: isLoadingFeaturedWord,
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
                                   onStartSkillsCheck: { router.startSkillsCheck() })
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
    }

    private func refreshFeaturedWord() async {
        isLoadingFeaturedWord = true
        let word = try? await dictionaryRepository.featuredEntry(excluding: lastFeaturedWordID)
        guard !Task.isCancelled else { return }
        featuredWord = word
        isLoadingFeaturedWord = false
        if let word {
            lastFeaturedWordID = word.id
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .search:
            SearchScreen(repository: dictionaryRepository) { router.openWord(id: $0) }
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
        case .vocabularyReview:
            VocabularyReviewScreen(dictionary: dictionaryRepository, library: libraryRepository,
                                   progress: progressRepository, illustrations: illustrationRepository)
        case .speaking:
            SpeakingScreen(progress: progressRepository, ai: aiService, recorder: speechRecognizer)
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
