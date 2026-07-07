import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editing: StubItem?
    @State private var draft: StubItem = .blank()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    ContentUnavailableView(
                        "No Stubs Yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Tap + to add your first stub.")
                    )
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                draft = item
                                editing = item
                                showingAdd = true
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.eventName.isEmpty ? "Untitled" : item.eventName)
                                        .font(Theme.bodyFont.weight(.semibold))
                                        .foregroundStyle(Theme.ink)
                                    if !item.venue.isEmpty {
                                        Text(item.venue)
                                            .font(.caption)
                                            .foregroundStyle(Theme.ink.opacity(0.6))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .accessibilityIdentifier("row_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                        .listRowBackground(Color.white.opacity(0.6))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Ticket Stub")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            draft = .blank()
                            editing = nil
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditSheet(draft: $draft, isEditing: editing != nil) {
                    if editing != nil {
                        store.update(draft)
                    } else {
                        store.add(draft)
                    }
                    showingAdd = false
                } onCancel: {
                    showingAdd = false
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Theme.accent)
    }
}

private struct AddEditSheet: View {
    @Binding var draft: StubItem
    var isEditing: Bool
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Stub Details") {
                TextField("EventName", text: $draft.eventName)
                    .accessibilityIdentifier("field_eventName")
                TextField("Venue", text: $draft.venue)
                    .accessibilityIdentifier("field_venue")
                TextField("EventDate", text: $draft.eventDate)
                    .accessibilityIdentifier("field_eventDate")
                TextField("Category", text: $draft.category)
                    .accessibilityIdentifier("field_category")
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Stub" : "Add Stub")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(PurchaseManager())
}
