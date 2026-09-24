public struct VocabularyTopic: Identifiable, Sendable {
    public let title: String
    public let symbol: String
    public let words: [String]

    public var id: String { title }
    public var wordIDs: [String] { words.map { "oewn:\($0):n" } }

    public static let all: [VocabularyTopic] = [
        .init(title: "Work", symbol: "briefcase", words: [
            "job", "office", "meeting", "manager", "colleague", "salary", "deadline", "project", "interview", "career",
            "business", "company", "employee", "employer", "team", "task", "schedule", "contract", "client", "customer",
            "department", "promotion", "resume", "skill", "position", "workplace", "profession", "occupation", "income", "shift",
            "assignment", "agency", "applicant", "application", "boss", "branch", "desk", "director", "industry", "leadership",
            "organization", "overtime", "pension", "staff", "training", "wage", "worker", "workforce", "employment", "labor"
        ]),
        .init(title: "Everyday life", symbol: "house", words: [
            "home", "family", "morning", "routine", "shopping", "laundry", "neighbor", "errand", "weekend", "commute",
            "day", "house", "apartment", "room", "kitchen", "bathroom", "chore", "cleaning", "cooking", "meal",
            "habit", "evening", "afternoon", "night", "parent", "child", "partner", "household", "street", "bus",
            "alarm", "breakfast", "clock", "coffee", "dinner", "door", "electricity", "furniture", "garage", "grocery",
            "light", "lunch", "mailbox", "newspaper", "phone", "schedule", "soap", "table", "toothbrush", "towel"
        ]),
        .init(title: "Travel", symbol: "airplane", words: [
            "airport", "passport", "ticket", "luggage", "hotel", "destination", "journey", "map", "train", "vacation",
            "trip", "tourist", "tourism", "flight", "airplane", "station", "bus", "road", "route", "beach",
            "city", "country", "border", "visa", "suitcase", "reservation", "accommodation", "guide", "departure", "arrival",
            "adventure", "airline", "backpack", "bicycle", "boat", "cabin", "campsite", "car", "cruise", "ferry",
            "harbor", "holiday", "island", "landmark", "passenger", "platform", "railway", "resort", "sail", "subway"
        ]),
        .init(title: "Health", symbol: "cross.case", words: [
            "health", "doctor", "hospital", "symptom", "medicine", "pharmacy", "exercise", "sleep", "diet", "pain",
            "body", "illness", "disease", "fever", "cough", "cold", "injury", "treatment", "nurse", "patient",
            "clinic", "appointment", "prescription", "drug", "tablet", "rest", "recovery", "fitness", "nutrition", "wellness",
            "allergy", "ambulance", "blood", "bone", "brain", "breathing", "cancer", "checkup", "dentist", "diagnosis",
            "emergency", "eye", "fatigue", "heart", "hygiene", "infection", "muscle", "operation", "pill", "pulse"
        ]),
        .init(title: "Food", symbol: "fork.knife", words: [
            "food", "breakfast", "lunch", "dinner", "restaurant", "menu", "recipe", "ingredient", "vegetable", "dessert",
            "meal", "snack", "fruit", "bread", "meat", "fish", "rice", "pasta", "soup", "salad",
            "cheese", "milk", "egg", "coffee", "tea", "cake", "sandwich", "apple", "banana", "cooking",
            "bacon", "bean", "beef", "beer", "biscuit", "butter", "carrot", "cereal", "chicken", "chocolate",
            "cream", "cucumber", "eggplant", "garlic", "grape", "honey", "jam", "juice", "lemon", "mushroom"
        ]),
        .init(title: "Technology & IT", symbol: "desktopcomputer", words: [
            "computer", "software", "internet", "website", "password", "data", "device", "keyboard", "laptop", "email",
            "phone", "smartphone", "application", "program", "file", "folder", "screen", "monitor", "printer", "camera",
            "battery", "charger", "network", "connection", "browser", "search", "account", "message", "tablet", "server",
            "algorithm", "button", "cable", "chip", "code", "database", "display", "electricity", "function", "hardware",
            "icon", "information", "input", "interface", "link", "machine", "memory", "mouse", "notification", "output"
        ]),
        .init(title: "Social life", symbol: "person.2", words: [
            "friend", "invitation", "conversation", "community", "celebration", "relationship", "guest", "event", "gathering", "neighbor",
            "people", "person", "acquaintance", "friendship", "party", "wedding", "birthday", "meeting", "group", "club",
            "society", "visitor", "host", "chat", "discussion", "contact", "kindness", "support", "trust", "family",
            "adult", "affection", "agreement", "ally", "audience", "baby", "bond", "brother", "ceremony", "child",
            "cousin", "crowd", "daughter", "date", "dinner", "father", "festival", "grandmother", "greeting", "husband"
        ]),
        .init(title: "Education", symbol: "graduationcap", words: [
            "school", "teacher", "student", "lesson", "exam", "homework", "university", "course", "classroom", "knowledge",
            "education", "book", "textbook", "notebook", "library", "college", "degree", "subject", "study", "learning",
            "reading", "writing", "question", "answer", "test", "grade", "pupil", "professor", "lecture", "science",
            "academy", "attendance", "certificate", "chapter", "chemistry", "class", "classmate", "curriculum", "diploma", "discipline",
            "essay", "experiment", "geography", "grammar", "history", "instruction", "literature", "mathematics", "memory", "paper"
        ]),
        .init(title: "Shopping & money", symbol: "cart", words: [
            "shop", "price", "discount", "receipt", "budget", "payment", "cash", "purchase", "refund", "wallet",
            "store", "market", "supermarket", "basket", "cart", "product", "item", "cost", "money", "coin",
            "bank", "card", "bill", "sale", "bargain", "seller", "buyer", "checkout", "tax", "fee",
            "advertisement", "allowance", "amount", "auction", "change", "charge", "credit", "currency", "customer", "deal",
            "debt", "deposit", "dollar", "expense", "finance", "fund", "gift", "grocery", "income", "invoice"
        ]),
        .init(title: "Nature", symbol: "leaf", words: [
            "weather", "rain", "forest", "river", "mountain", "animal", "tree", "climate", "pollution", "environment",
            "sun", "moon", "sky", "cloud", "snow", "storm", "ocean", "sea", "lake", "beach",
            "island", "valley", "hill", "flower", "plant", "grass", "bird", "insect", "wildlife", "earth",
            "autumn", "butterfly", "cave", "coast", "dolphin", "drought", "eagle", "ecosystem", "field", "fire",
            "frog", "garden", "glacier", "habitat", "jungle", "leaf", "lightning", "meadow", "pond", "rainbow"
        ]),
        .init(title: "Hobbies", symbol: "paintpalette", words: [
            "hobby", "music", "movie", "game", "sport", "art", "dance", "photography", "reading", "garden",
            "painting", "drawing", "singing", "guitar", "piano", "instrument", "football", "tennis", "swimming", "hiking",
            "camping", "fishing", "cooking", "knitting", "collection", "camera", "picture", "photograph", "pastime", "exercise",
            "activity", "basketball", "bicycle", "bowling", "chess", "choir", "cinema", "club", "craft", "cycling",
            "diving", "entertainment", "film", "gardening", "golf", "jogging", "karaoke", "leisure", "model", "museum"
        ]),
        .init(title: "Feelings", symbol: "heart", words: [
            "emotion", "happiness", "sadness", "anger", "fear", "surprise", "hope", "joy", "worry", "confidence",
            "love", "hate", "excitement", "anxiety", "grief", "pleasure", "pride", "shame", "guilt", "envy",
            "boredom", "loneliness", "curiosity", "interest", "satisfaction", "frustration", "courage", "disappointment", "gratitude", "sympathy",
            "affection", "amusement", "annoyance", "anticipation", "appreciation", "attraction", "calm", "compassion", "contentment", "delight",
            "desire", "despair", "distress", "eagerness", "empathy", "enthusiasm", "longing", "insecurity", "inspiration", "irritation"
        ]),
    ]

    private init(title: String, symbol: String, words: [String]) {
        self.title = title
        self.symbol = symbol
        self.words = words
    }
}
