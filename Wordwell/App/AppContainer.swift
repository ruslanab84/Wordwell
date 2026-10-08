import WordwellAICore
import WordwellAIFoundationModels
import WordwellData
import WordwellDomain

@MainActor
struct AppContainer {
    let router: AppRouter
    let dictionaryRepository: any DictionaryRepository
    let libraryRepository: any WordLibraryRepository
    let progressRepository: any ProgressRepository
    let settingsRepository: any LearningSettingsRepository
    let illustrationRepository: any IllustrationBindingRepository
    let aiService: any LearningAI
    let examPractice: (any ExamPracticeService)?
    let conversation: (any ConversationService)?
    let mistakeExplainer: (any MistakeExplainerService)?
    let speechRecognizer: OnDeviceSpeechRecognizer
    let pronunciationPlayer: PronunciationPlayer

    init(
        router: AppRouter,
        dictionaryRepository: any DictionaryRepository,
        libraryRepository: any WordLibraryRepository,
        progressRepository: any ProgressRepository,
        settingsRepository: any LearningSettingsRepository,
        illustrationRepository: any IllustrationBindingRepository,
        aiService: any LearningAI,
        examPractice: (any ExamPracticeService)?,
        conversation: (any ConversationService)?,
        mistakeExplainer: (any MistakeExplainerService)?,
        speechRecognizer: OnDeviceSpeechRecognizer,
        pronunciationPlayer: PronunciationPlayer
    ) {
        self.router = router
        self.dictionaryRepository = dictionaryRepository
        self.libraryRepository = libraryRepository
        self.progressRepository = progressRepository
        self.settingsRepository = settingsRepository
        self.illustrationRepository = illustrationRepository
        self.aiService = aiService
        self.examPractice = examPractice
        self.conversation = conversation
        self.mistakeExplainer = mistakeExplainer
        self.speechRecognizer = speechRecognizer
        self.pronunciationPlayer = pronunciationPlayer
    }

    static let live: AppContainer = {
        let dictionary = makeDictionaryRepository()
        let library: any WordLibraryRepository = (try? LocalWordLibraryRepository()) ?? UnavailableWordLibraryRepository()
        let lookup = DictionaryAILookupAdapter(repository: dictionary)
        let examPractice: (any ExamPracticeService)?
        if #available(iOS 26.0, *), let policy = try? RestrictedTermsPolicy.bundled() {
            examPractice = ResilientExamPractice(primary: FoundationModelsExamPractice(), policy: policy)
        } else {
            examPractice = nil
        }
        let conversation: (any ConversationService)?
        if #available(iOS 26.0, *) {
            conversation = ResilientConversation(primary: FoundationModelsConversation())
        } else {
            conversation = nil
        }
        let mistakeExplainer: (any MistakeExplainerService)?
        if #available(iOS 26.0, *) {
            mistakeExplainer = ResilientMistakeExplainer(primary: FoundationModelsMistakeExplainer())
        } else {
            mistakeExplainer = nil
        }
        let primary: any LearningAI
        if #available(iOS 26.0, *) {
            primary = FoundationModelsLearningAI(dictionary: lookup)
        } else {
            primary = UnavailableLearningAI(reason: .osTooOld)
        }
        return AppContainer(
            router: AppRouter(),
            dictionaryRepository: dictionary,
            libraryRepository: library,
            progressRepository: (try? LocalProgressRepository()) ?? UnavailableProgressRepository(),
            settingsRepository: LocalLearningSettingsRepository(),
            illustrationRepository: LocalIllustrationBindingRepository(),
            aiService: ResilientLearningAI(
                primary: primary,
                cache: AIResponseCache(storage: InMemoryAICacheStorage())
            ),
            examPractice: examPractice,
            conversation: conversation,
            mistakeExplainer: mistakeExplainer,
            speechRecognizer: OnDeviceSpeechRecognizer(),
            pronunciationPlayer: PronunciationPlayer()
        )
    }()

    private static func makeDictionaryRepository() -> any DictionaryRepository {
        (try? LocalDictionaryRepository()) ?? UnavailableDictionaryRepository()
    }
}
