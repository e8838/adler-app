import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TransactionStore
    @State private var showAdd = false
    @State private var editing: Transaction?

    private var grouped: [(day: Date, items: [Transaction])] {
        let dict = Dictionary(grouping: store.items) { Calendar.current.startOfDay(for: $0.date) }
        return dict.keys.sorted(by: >).map { day in
            (day: day, items: (dict[day] ?? []).sorted { $0.date > $1.date })
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.background.ignoresSafeArea()

                List {
                    Section {
                        BalanceCard()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)

                    if store.items.isEmpty {
                        Section {
                            Text("Aún no hay movimientos.\nToca + para agregar el primero.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(Theme.muted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    ForEach(grouped, id: \.day) { group in
                        Section {
                            ForEach(group.items) { t in
                                TransactionRow(t: t)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editing = t }
                                    .listRowBackground(Theme.card)
                                    .swipeActions {
                                        Button(role: .destructive) { store.delete(t) } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text(group.day, format: .dateTime.day().month(.wide).year())
                                .foregroundColor(Theme.muted)
                        }
                    }

                    Color.clear.frame(height: 70)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)

                Button { showAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 62, height: 62)
                        .background(Theme.accent)
                        .clipShape(Circle())
                        .shadow(color: Theme.accent.opacity(0.5), radius: 12, y: 4)
                }
                .padding(24)
            }
            .navigationTitle("Adler App")
        }
        .sheet(isPresented: $showAdd) { TransactionForm(existing: nil) }
        .sheet(item: $editing) { t in TransactionForm(existing: t) }
    }
}

struct BalanceCard: View {
    @EnvironmentObject var store: TransactionStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saldo")
                .font(.subheadline)
                .foregroundColor(Theme.muted)
            Text(store.balance, format: .currency(code: currencyCode))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(store.balance >= 0 ? .white : Theme.expense)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            HStack {
                summary("Ingresos", store.income, Theme.income, "arrow.down.circle.fill")
                Spacer()
                summary("Egresos", store.expense, Theme.expense, "arrow.up.circle.fill")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Theme.card, Color(red: 0.12, green: 0.13, blue: 0.22)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func summary(_ label: String, _ value: Double, _ color: Color, _ icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(Theme.muted)
                Text(value, format: .currency(code: currencyCode))
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
        }
    }
}

struct TransactionRow: View {
    let t: Transaction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: t.type == .income ? "arrow.down.left" : "arrow.up.right")
                .foregroundColor(t.type == .income ? Theme.income : Theme.expense)
                .frame(width: 40, height: 40)
                .background((t.type == .income ? Theme.income : Theme.expense).opacity(0.15))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(t.title.isEmpty ? t.category : t.title)
                    .foregroundColor(.white)
                Text(t.category).font(.caption).foregroundColor(Theme.muted)
            }
            Spacer()
            Text((t.type == .income ? "+ " : "− ") + t.amount.formatted(.currency(code: currencyCode)))
                .font(.subheadline.bold())
                .foregroundColor(t.type == .income ? Theme.income : Theme.expense)
        }
        .padding(.vertical, 4)
    }
}
