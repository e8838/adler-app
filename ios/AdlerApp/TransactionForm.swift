import SwiftUI

struct TransactionForm: View {
    @EnvironmentObject var store: TransactionStore
    @Environment(\.dismiss) private var dismiss

    let existing: Transaction?

    @State private var type: TransactionType
    @State private var amountText: String
    @State private var title: String
    @State private var category: String
    @State private var date: Date

    init(existing: Transaction?) {
        self.existing = existing
        let t = existing?.type ?? .expense
        _type = State(initialValue: t)
        _amountText = State(initialValue: existing.map { String($0.amount) } ?? "")
        _title = State(initialValue: existing?.title ?? "")
        _category = State(initialValue: existing?.category ?? Categories.list(for: t)[0])
        _date = State(initialValue: existing?.date ?? Date())
    }

    private var amount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $type) {
                        ForEach(TransactionType.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }

                Section("Monto") {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title2.bold())
                        .foregroundColor(type == .income ? Theme.income : Theme.expense)
                }
                .listRowBackground(Theme.card)

                Section("Detalles") {
                    TextField("Descripción (opcional)", text: $title)
                    Picker("Categoría", selection: $category) {
                        ForEach(Categories.list(for: type), id: \.self) { Text($0).tag($0) }
                    }
                    DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                .listRowBackground(Theme.card)

                if let existing {
                    Section {
                        Button("Eliminar movimiento", role: .destructive) {
                            store.delete(existing)
                            dismiss()
                        }
                    }
                    .listRowBackground(Theme.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle(existing == nil ? "Nuevo movimiento" : "Editar movimiento")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: type) { newType in
                if !Categories.list(for: newType).contains(category) {
                    category = Categories.list(for: newType)[0]
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(amount <= 0)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        if var t = existing {
            t.type = type; t.amount = amount; t.title = title; t.category = category; t.date = date
            store.update(t)
        } else {
            store.add(Transaction(type: type, amount: amount, title: title, category: category, date: date))
        }
        dismiss()
    }
}
