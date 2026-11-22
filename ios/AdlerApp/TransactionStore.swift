import Foundation

final class TransactionStore: ObservableObject {
    @Published var items: [Transaction] = [] {
        didSet { save() }
    }

    private let url: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("transactions.json")

    init() { load() }

    var income: Double { items.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var expense: Double { items.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var balance: Double { income - expense }

    func add(_ t: Transaction) { items.append(t) }

    func update(_ t: Transaction) {
        if let i = items.firstIndex(where: { $0.id == t.id }) { items[i] = t }
    }

    func delete(_ t: Transaction) { items.removeAll { $0.id == t.id } }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Transaction].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
