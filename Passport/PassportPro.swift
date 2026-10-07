import SwiftUI
import StoreKit

@MainActor final class PassportPro: ObservableObject {
    static let monthlyID = "com.vano.memorypassport.pro.monthly"
    @Published var product: Product?
    @Published var active = false
    @Published var busy = false
    @Published var message: String?
    private var listener: Task<Void, Never>?
    init() {
        listener = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result, transaction.productID == Self.monthlyID {
                    await self.refresh()
                    await transaction.finish()
                }
            }
        }
        Task { await load() }
    }
    deinit { listener?.cancel() }
    func load() async {
        do { product = try await Product.products(for: [Self.monthlyID]).first }
        catch { message = "The App Store could not load the plan. Try again later." }
        await refresh()
    }
    func refresh() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.monthlyID,
               transaction.revocationDate == nil,
               transaction.expirationDate.map({ $0 > Date() }) ?? false { entitled = true }
        }
        active = entitled
    }
    func purchase() async {
        guard !busy, let product else { return }
        busy = true; message = nil
        defer { busy = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                guard case .verified(let transaction) = result else { message = "Purchase could not be verified. Your notebook remains available."; return }
                await refresh()
                await transaction.finish()
                message = active ? "Passport Pro is active." : "Purchase received. The App Store has not confirmed active access yet."
            case .pending: message = "Purchase is awaiting approval. You have not been upgraded yet."
            case .userCancelled: break
            @unknown default: message = "Purchase was not completed."
            }
        } catch { message = "Purchase did not complete. Please try again." }
    }
    func restore() async {
        guard !busy else { return }
        busy = true; message = nil
        defer { busy = false }
        do { try await AppStore.sync(); await refresh(); message = active ? "Passport Pro restored." : "No active Passport Pro subscription found." }
        catch { message = "Could not restore purchases. Try again later." }
    }
}

struct PassportProView: View {
    @EnvironmentObject var pro: PassportPro
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("A bigger notebook.").font(.system(.largeTitle, design: .serif))
                    Text("Free includes 30 memories, the visual map, search and context export. Pro lets you keep adding memories without that limit.").font(.title3)
                    Text("Existing notes stay readable, editable and exportable if you cancel. Account connections, automatic AI history sync and cloud storage are not included.").foregroundStyle(.secondary)
                    if pro.active {
                        Label("Passport Pro is active", systemImage: "checkmark.circle")
                    } else if let product = pro.product {
                        Text("\(product.displayPrice) per month").font(.title2.weight(.semibold))
                        Text("Auto-renews monthly until cancelled. Payment is charged to your Apple account. Manage or cancel in App Store subscription settings.").font(.footnote).foregroundStyle(.secondary)
                        Button("Subscribe for \(product.displayPrice)/month") { Task { await pro.purchase() } }.buttonStyle(.borderedProminent).disabled(pro.busy)
                    } else {
                        Text("Subscriptions are not available from the App Store yet. You cannot be charged here.").font(.headline)
                        Button("Retry loading plan") { Task { await pro.load() } }.buttonStyle(.bordered)
                    }
                    if pro.busy { ProgressView("Contacting App Store") }
                    if let message = pro.message { Text(message).accessibilityIdentifier("purchaseStatus") }
                    Button("Restore purchases") { Task { await pro.restore() } }.disabled(pro.busy)
                    Link("Manage subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    Text("Privacy: your notebook is stored on this device. This build has no analytics or AI requests. Copying or sharing sends only the context you select to your chosen destination.").font(.footnote)
                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Text("No subscription is needed to export your saved notes.").font(.footnote).foregroundStyle(.secondary)
                }.padding(24).frame(maxWidth: 650)
            }.navigationTitle("Passport Pro").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
