import Foundation

extension ConversationScenario {
    /// Bundled catalog. Target lemmas are everyday words that exist in the dictionary.
    public static let catalog: [ConversationScenario] = [
        ConversationScenario(
            id: "airport", title: "At the airport",
            setting: "The learner is checking in for a flight.",
            partnerRole: "a check-in agent at an airport desk",
            objective: "Check in, ask about your seat and find out when boarding starts.",
            level: .a2, targetLemmas: ["passport", "luggage", "ticket", "gate", "seat", "flight"],
            openingLine: "Good morning! Where are you flying today?"),
        ConversationScenario(
            id: "hotel", title: "Hotel reception",
            setting: "The learner arrives at a hotel late in the evening.",
            partnerRole: "a hotel receptionist",
            objective: "Check in, ask about breakfast and report a problem with the room.",
            level: .a2, targetLemmas: ["reservation", "room", "key", "breakfast", "bill", "floor"],
            openingLine: "Good evening, welcome to the hotel. Do you have a reservation?"),
        ConversationScenario(
            id: "restaurant", title: "In a restaurant",
            setting: "The learner is having dinner in a small restaurant.",
            partnerRole: "a friendly waiter",
            objective: "Order a meal, ask what is in a dish and ask for the bill.",
            level: .a2, targetLemmas: ["menu", "order", "dish", "bill", "table", "dessert"],
            openingLine: "Hello! A table for how many people?"),
        ConversationScenario(
            id: "doctor", title: "At the doctor",
            setting: "The learner does not feel well and visits a clinic.",
            partnerRole: "a family doctor",
            objective: "Describe your symptoms and understand the advice you are given.",
            level: .b1, targetLemmas: ["symptom", "pain", "fever", "medicine", "appointment", "advice"],
            openingLine: "Hello, please sit down. What seems to be the problem?"),
        ConversationScenario(
            id: "interview", title: "Job interview",
            setting: "The learner is interviewing for a job at a small company.",
            partnerRole: "an interviewer at a small company",
            objective: "Introduce yourself, talk about your experience and ask one question about the job.",
            level: .b1, targetLemmas: ["experience", "skill", "team", "salary", "position", "colleague"],
            openingLine: "Thanks for coming in. Could you start by telling me a little about yourself?"),
        ConversationScenario(
            id: "meeting", title: "Team meeting",
            setting: "The learner takes part in a short work meeting.",
            partnerRole: "a project manager leading a meeting",
            objective: "Give a short update, suggest one idea and agree on the next step.",
            level: .b1, targetLemmas: ["deadline", "project", "suggest", "agree", "schedule", "progress"],
            openingLine: "Let's get started. Could you give us a quick update on your part of the project?"),
        ConversationScenario(
            id: "directions", title: "Asking the way",
            setting: "The learner is lost in a new city.",
            partnerRole: "a helpful local",
            objective: "Ask how to get to the station and check that you understood the way.",
            level: .a1, targetLemmas: ["street", "corner", "station", "straight", "left", "right"],
            openingLine: "Hi there! You look a little lost. Can I help?"),
    ]
}
