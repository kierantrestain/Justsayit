import SwiftUI

struct StarterVocabularySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var group: StarterVocabulary.Group = .names
    @State private var selected = Set<String>()
    @State private var errorMessage: String?
    @State private var enableBoosting: Bool
    private let savedWords: Set<String>
    private let availableSlots: Int
    private let onAdd: ([String], Bool) throws -> Void

    init(
        savedWords: [String],
        availableSlots: Int,
        boostingEnabled: Bool,
        onAdd: @escaping ([String], Bool) throws -> Void
    ) {
        self.savedWords = Set(savedWords.map(StarterVocabulary.spellingKey))
        self.availableSlots = availableSlots
        self._enableBoosting = State(initialValue: boostingEnabled)
        self.onAdd = onAdd
    }

    private var isSearching: Bool {
        !self.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var results: [(group: StarterVocabulary.Group, words: [String])] {
        let groups = self.isSearching ? StarterVocabulary.Group.allCases : [self.group]
        return groups.map { ($0, $0.matching(self.query)) }.filter { !$0.words.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Starter Vocabulary")
                    .font(.title2.bold())
                Text("Choose names and terms you say often. Parakeet word boosting gives them extra weight when you dictate.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            TextField("Search all starter words", text: self.$query)
                .textFieldStyle(.roundedBorder)
            if !self.isSearching {
                Picker("Category", selection: self.$group) {
                    ForEach(StarterVocabulary.Group.allCases) { group in
                        Text(group.rawValue).tag(group)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            if self.results.isEmpty {
                ContentUnavailableView.search(text: self.query)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(self.results, id: \.group) { result in
                        Section(result.group.rawValue) {
                            ForEach(result.words, id: \.self) { word in
                                self.wordRow(word)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Toggle("Enable Parakeet word boosting", isOn: self.$enableBoosting)
                .toggleStyle(.checkbox)
            if self.availableSlots == 0 {
                Text("Your word list is full. Remove a saved boost word to make room.")
                    .foregroundStyle(.secondary)
            }
            if let errorMessage = self.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
            HStack {
                Text("\(self.selected.count) selected")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                Spacer()
                Button("Cancel", role: .cancel) { self.dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Add Selected", action: self.addSelected)
                    .keyboardShortcut(.defaultAction)
                    .disabled(self.selected.isEmpty)
            }
        }
        .padding(22)
        .frame(width: 540, height: 570)
    }

    private func wordRow(_ word: String) -> some View {
        let saved = self.savedWords.contains(StarterVocabulary.spellingKey(word))
        let isSelected = self.selected.contains(word)
        return Toggle(isOn: Binding(
            get: { isSelected || saved },
            set: { isOn in
                if isOn {
                    self.selected.insert(word)
                } else {
                    self.selected.remove(word)
                }
            }
        )) {
            HStack {
                Text(word)
                Spacer()
                if saved {
                    Text("Added").foregroundStyle(.secondary)
                }
            }
        }
        .toggleStyle(.checkbox)
        .disabled(saved || (!isSelected && self.selected.count >= self.availableSlots))
    }

    private func addSelected() {
        do {
            try self.onAdd(self.selected.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }, self.enableBoosting)
            self.dismiss()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
