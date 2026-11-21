import Foundation

nonisolated enum StarterVocabulary {
    enum Group: String, CaseIterable, Identifiable {
        case names = "Names"
        case ukAndIreland = "UK & Ireland"
        case places = "World places"
        case work = "Everyday & work"

        var id: Self {
            self
        }

        var words: [String] {
            switch self {
            case .names:
                [
                    "Aaliyah", "Aarav", "Aisha", "Akira", "Amara", "Amélie", "Anaïs", "Ananya", "Aria", "Arjun", "Ayaan",
                    "Björn", "Camila", "Caoimhe", "Chinonso", "Chloë", "Chukwuemeka", "Ciara", "Dáithí", "Daria", "Diya",
                    "Éabha", "Eleni", "Emilia", "Eoin", "Esme", "Fatima", "Gráinne", "Guillermo", "Haruto",
                    "Hélène", "Ifeoma", "Inez", "Isla", "Joaquín", "José", "Jun", "Kavya", "Khadija", "Kieran",
                    "Kwame", "Léa", "Leilani", "Linh", "Lucía", "Maëlle", "Mateo", "Maya", "Mei", "Michał", "Miguel",
                    "Mohammed", "Muhammad", "Naomi", "Neha", "Nguyễn", "Niamh", "Noëlle", "Nuria", "Oisín", "Oluwaseun",
                    "Pádraig", "Priya", "Quỳnh", "Rafael", "Renée", "Róisín", "Ruairí", "Saanvi", "Saoirse",
                    "Seán", "Shreya", "Siân", "Siobhán", "Sofía", "Soraya", "Søren", "Tadhg", "Thiago", "Tsvetelina",
                    "Valentina", "Wei", "Ximena", "Yuki", "Yusuf", "Zainab", "Zoë",
                ]
            case .ukAndIreland:
                [
                    "Aisling", "Aoife", "Aberystwyth", "Ballymena", "Belfast", "Bicester", "Brighton", "Caernarfon",
                    "Cairngorms", "Cheltenham", "Cirencester", "Connemara", "County Donegal", "Dún Laoghaire", "Dundee",
                    "Edinburgh", "Frome", "Galway", "Glasgow", "Glastonbury", "Greenwich", "Holyrood", "Isle of Skye",
                    "Islington", "Knaresborough", "Leicester", "Leicestershire", "Lewisham", "Loughborough",
                    "Marylebone", "Milton Keynes", "Moseley", "Northumberland", "Nottingham", "Pembrokeshire",
                    "Portsmouth", "Reading", "Salisbury", "Sligo", "Southwark", "St Albans", "St Pancras", "Stirling",
                    "Stratford-upon-Avon", "Torquay", "Westminster", "Wolverhampton", "Worcester", "Worcestershire",
                ]
            case .places:
                [
                    "Aarhus", "Accra", "Aotearoa", "Auckland", "Bengaluru", "Bogotá", "Brisbane", "Bruxelles",
                    "Chișinău", "Copenhagen", "Côte d’Ivoire", "Curaçao", "Da Nang", "Düsseldorf", "Göteborg",
                    "Guadalajara", "Gyeonggi", "Helsinki", "Ho Chi Minh City", "Hyderabad", "Johannesburg",
                    "Kigali", "Kraków", "Kuala Lumpur", "Kyiv", "Ljubljana", "Łódź", "Malmö", "Mexico City",
                    "Montréal", "Nairobi", "Osaka", "Örebro", "Phnom Penh", "Porto", "Québec", "Reykjavík",
                    "São Paulo", "Seoul", "Singapore", "Soweto", "Tāmaki Makaurau", "Thessaloniki", "Timișoara",
                    "Ulaanbaatar", "Valparaíso", "Wrocław", "Xi’an", "Zürich",
                ]
            case .work:
                [
                    "accessibility", "action items", "ad hoc", "agenda", "backlog", "benchmark", "calendar invite",
                    "check-in", "changelog", "co-working", "deliverables", "debrief", "design review", "expense report",
                    "follow-up", "handover", "hybrid working", "inbox zero", "invoice", "knowledge base",
                    "meeting minutes", "milestone", "multifactor authentication", "next steps", "onboarding", "one-to-one",
                    "out of office", "paperwork", "payroll", "proofread", "pull request", "quarterly review",
                    "recap", "retrospective", "screen sharing", "sign-off", "spreadsheet", "stakeholder", "stand-up",
                    "time zone", "timesheet", "touch base", "transcript", "two-factor authentication", "walk-through",
                    "café", "caffè latte", "crème brûlée", "en route", "façade", "jalapeño", "matcha", "mozzarella",
                    "naïve", "pho", "piñata", "ramen", "résumé", "sourdough", "tortilla",
                ]
            }
        }

        func matching(_ query: String) -> [String] {
            let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
            return self.words
                .filter { word in
                    cleaned.isEmpty || word.range(of: cleaned, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) != nil
                }
                .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }
    }

    static func spellingKey(_ word: String) -> String {
        word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func newWords<S: Sequence>(_ words: S, existing: [String]) -> [String] where S.Element == String {
        var seen = Set(existing.map(Self.spellingKey))
        return words.compactMap { word in
            let key = Self.spellingKey(word)
            guard !key.isEmpty, seen.insert(key).inserted else { return nil }
            return word.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
