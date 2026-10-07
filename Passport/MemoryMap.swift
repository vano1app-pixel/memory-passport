import SwiftUI

struct MapNode: Identifiable {
    var id: String
    var title: String
    var kind: String
    var memory: Memory?
}

struct MemoryMapView: View {
    @EnvironmentObject var notebook: Notebook
    @State private var selected: String?
    @State private var draft: Memory?
    @State private var query = ""
    @State private var scale: CGFloat = 1
    @State private var showingContext = false
    private let green = Color(red: 0.12, green: 0.28, blue: 0.22)
    var filtered: [Memory] { notebook.memories.filter { query.isEmpty || "\($0.text) \($0.project) \($0.source)".localizedCaseInsensitiveContains(query) } }
    var nodes: [MapNode] {
        [MapNode(id: "you", title: "My memory", kind: "root")] +
        Set(filtered.map(\.project)).sorted().map { MapNode(id: "p:" + $0, title: $0, kind: "project") } +
        Set(filtered.map(\.source)).sorted().map { MapNode(id: "s:" + $0, title: $0, kind: "source") } +
        filtered.prefix(36).map { MapNode(id: $0.id.uuidString, title: String($0.text.prefix(32)), kind: "memory", memory: $0) }
    }
    func position(_ node: MapNode, size: CGSize) -> CGPoint {
        if node.kind == "root" { return CGPoint(x: size.width / 2, y: size.height / 2) }
        let group = nodes.filter { $0.kind == node.kind }
        let index = group.firstIndex(where: { $0.id == node.id }) ?? 0
        let offset: Double = node.kind == "project" ? -1.5 : node.kind == "source" ? 0.7 : 0
        let angle = Double(index) / Double(max(group.count, 1)) * .pi * 2 + offset
        let radius = min(size.width, size.height) * (node.kind == "memory" ? 0.42 : node.kind == "source" ? 0.30 : 0.19)
        return CGPoint(x: size.width / 2 + cos(angle) * radius, y: size.height / 2 + sin(angle) * radius)
    }
    var selectedEntries: [Memory] {
        guard let selected else { return filtered }
        if selected.hasPrefix("p:") { return filtered.filter { $0.project == String(selected.dropFirst(2)) } }
        if selected.hasPrefix("s:") { return filtered.filter { $0.source == String(selected.dropFirst(2)) } }
        return filtered.filter { $0.id.uuidString == selected }
    }
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your memory map").font(.system(.largeTitle, design: .serif))
                        Text("Projects, sources and the things you know.").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { draft = Memory(text: "", project: "Personal", source: "Added by me") } label: { Image(systemName: "plus") }.buttonStyle(.bordered).accessibilityLabel("Add memory")
                }.padding(.horizontal, 20)
                TextField("Find a memory or project", text: $query).textFieldStyle(.roundedBorder).padding(.horizontal, 20)
                GeometryReader { geometry in
                    ZStack {
                        Canvas { context, size in
                            for x in stride(from: 0.0, through: size.width, by: 24) {
                                for y in stride(from: 0.0, through: size.height, by: 24) {
                                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)), with: .color(green.opacity(0.15)))
                                }
                            }
                            for node in nodes where node.kind != "root" {
                                let target: String = node.kind == "memory" ? "p:" + (node.memory?.project ?? "") : "you"
                                guard let parent = nodes.first(where: { $0.id == target }) else { continue }
                                var path = Path(); path.move(to: position(parent, size: size)); path.addLine(to: position(node, size: size))
                                context.stroke(path, with: .color(green.opacity(0.28)), lineWidth: 1)
                                if let memory = node.memory, let source = nodes.first(where: { $0.id == "s:" + memory.source }) {
                                    var link = Path(); link.move(to: position(node, size: size)); link.addLine(to: position(source, size: size))
                                    context.stroke(link, with: .color(green.opacity(0.12)), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                                }
                            }
                        }
                        ForEach(nodes) { node in
                            Button { selected = node.id == "you" ? nil : node.id } label: {
                                VStack(spacing: 5) {
                                    Circle().fill(node.kind == "source" ? Color.brown : green).frame(width: node.kind == "root" ? 22 : node.kind == "memory" ? 8 : 14, height: node.kind == "root" ? 22 : node.kind == "memory" ? 8 : 14)
                                    Text(node.title).font(node.kind == "root" ? .subheadline.weight(.semibold) : .caption2).lineLimit(2).frame(width: 85).foregroundStyle(green)
                                }.padding(6).background(selected == node.id ? Color.white.opacity(0.9) : Color.clear).clipShape(RoundedRectangle(cornerRadius: 8))
                            }.position(position(node, size: geometry.size)).accessibilityLabel("\(node.kind): \(node.title)")
                        }
                        if filtered.isEmpty {
                            VStack(spacing: 12) {
                                Text("A home for your AI context.").font(.title2)
                                Text("Add a memory to start your web.\nNothing is connected yet.").multilineTextAlignment(.center).foregroundStyle(.secondary)
                                Button("Add your first memory") { draft = Memory(text: "", project: "Personal", source: "Added by me") }.buttonStyle(.borderedProminent)
                            }.padding(24).background(.regularMaterial).clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }.scaleEffect(scale).clipped()
                }.frame(minHeight: 280)
                HStack {
                    Text("\(filtered.count) memories · links show shared projects and sources").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button { scale = max(0.7, scale - 0.15) } label: { Image(systemName: "minus.magnifyingglass") }.accessibilityLabel("Zoom out")
                    Button { scale = min(1.6, scale + 0.15) } label: { Image(systemName: "plus.magnifyingglass") }.accessibilityLabel("Zoom in")
                }.padding(.horizontal, 20)
                if selected != nil {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Text(nodes.first(where: { $0.id == selected })?.title ?? "Selection").font(.headline); Spacer(); Button("Clear") { selected = nil } }
                        ScrollView { VStack(alignment: .leading, spacing: 12) { ForEach(selectedEntries) { memory in
                            Button { draft = memory } label: { VStack(alignment: .leading) { Text(memory.text).lineLimit(3); Text(memory.source).font(.caption).foregroundStyle(.secondary) } }.buttonStyle(.plain)
                        } } }.frame(maxHeight: 110)
                        Button("Use this context") { showingContext = true }.buttonStyle(.borderedProminent).disabled(selectedEntries.isEmpty)
                    }.padding(20).background(.white.opacity(0.7))
                } else {
                    Text("Tap a dot to explore. Your map stays on this device.").font(.footnote).foregroundStyle(.secondary).padding(.horizontal, 20).padding(.bottom, 12)
                }
            }.padding(.top, 16).background(Color(red: 0.97, green: 0.96, blue: 0.92)).tint(green)
            .sheet(item: $draft) { MemoryEditor(memory: $0) }
            .sheet(isPresented: $showingContext) { ContextPreview(text: notebook.brief(selectedEntries)) }
        }
    }
}

struct SourcesView: View {
    @EnvironmentObject var notebook: Notebook
    @State private var draft: Memory?
    @State private var showPro = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Bring your context together.").font(.system(.title, design: .serif))
                    Text("Choose a source, paste the memories you want to keep, then review and save. Saved notes appear in your map.").foregroundStyle(.secondary)
                }
                Section("AI sources") {
                    ForEach(["ChatGPT", "Claude", "Gemini", "Grok"], id: \.self) { name in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack { Text(name).font(.headline); Spacer(); Text("Import only").font(.caption).foregroundStyle(.secondary) }
                            Text("\(notebook.memories.filter { $0.source == name }.count) saved notes · account not connected").font(.caption).foregroundStyle(.secondary)
                            Button("Add context from \(name)") { draft = Memory(text: "", project: "Personal", source: name) }
                        }.padding(.vertical, 8)
                    }
                }
                Section("Your work") {
                    Button("Add context from GitHub") { draft = Memory(text: "", project: "My project", source: "GitHub") }
                    Text("Paste a README or project notes. GitHub sign-in and repository sync are not configured yet.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Account connections") {
                    Text("Automatic account connections are not available in this build. Signing in to an AI service does not necessarily allow access to past conversations.").font(.footnote)
                    Link("About ChatGPT sign-in", destination: URL(string: "https://developers.openai.com/siwc/quickstart")!)
                }
                Section("Passport Pro") {
                    Button("View Pro plan") { showPro = true }
                    Text("30 memories free. Existing memories stay accessible after cancellation.").font(.footnote)
                }
            }.navigationTitle("Sources").sheet(item: $draft) { MemoryEditor(memory: $0) }
            .sheet(isPresented: $showPro) { PassportProView() }
        }
    }
}
