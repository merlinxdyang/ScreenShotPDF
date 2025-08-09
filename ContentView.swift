import SwiftUI
import AppKit
import CoreGraphics
import PDFKit
import Quartz

// 关于页面视图
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 应用图标
            if let nsIcon = NSImage(named: "bearicon") {
                Image(nsImage: nsIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 4)
            }
            
            // 应用标题
            VStack(spacing: 8) {
                Text("M的电子书制作工具")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("v2.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // 分割线
            Divider()
                .padding(.horizontal, 40)
            
            // 关于信息
            VStack(spacing: 12) {
                Text("这是Merlin同学在AI指导下的第一个app。")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("一个高效的macOS电子书制作工具，支持自动翻页和批量截屏，一键生成PDF。")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            // 功能特点
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "camera.fill", text: "精确区域截屏")
                FeatureRow(icon: "arrow.down.square.fill", text: "智能自动翻页")
                FeatureRow(icon: "speedometer", text: "多种速度模式")
                FeatureRow(icon: "folder.fill", text: "批量文件管理")
                FeatureRow(icon: "doc.richtext", text: "PDF自动生成")
            }
            .padding(.horizontal, 20)
            
            // 版权信息
            VStack(spacing: 4) {
                Text("© 2025 Merlin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("使用 SwiftUI 和 ❤️ 制作")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // 关闭按钮
            Button("好的") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding(30)
        .frame(width: 400, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// 功能特点行视图
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.callout)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ContentView: View {
    @StateObject private var screenshotManager = ScreenshotManager()
    @State private var selectedApp: NSRunningApplication?
    @State private var pageCount: String = "10"
    @State private var delay: Double = 0.8
    @State private var savePath: String = ""
    @State private var fileName: String = ""
    @State private var isSelectingArea = false
    @State private var selectedArea: CGRect = .zero
    @State private var isCapturing = false
    @State private var showingAbout = false
    @State private var areaSelector: AreaSelector?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var speedMode: SpeedMode = .normal
    @State private var isGeneratingPDF = false
    
    enum SpeedMode: String, CaseIterable {
        case slow = "慢速"
        case normal = "正常"
        case fast = "快速"
        case turbo = "极速"
        
        var delayRange: ClosedRange<Double> {
            switch self {
            case .slow: return 1.5...3.0
            case .normal: return 0.8...2.0
            case .fast: return 0.3...1.2
            case .turbo: return 0.1...0.8
            }
        }
        
        var defaultDelay: Double {
            switch self {
            case .slow: return 2.0
            case .normal: return 0.8
            case .fast: return 0.5
            case .turbo: return 0.2
            }
        }
        
        var appActivationDelay: Double {
            switch self {
            case .slow: return 0.5
            case .normal: return 0.3
            case .fast: return 0.2
            case .turbo: return 0.1
            }
        }
        
        var fileWriteDelay: Double {
            switch self {
            case .slow: return 0.3
            case .normal: return 0.2
            case .fast: return 0.1
            case .turbo: return 0.05
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                if let nsIcon = NSImage(named: "bearicon") {
                    Image(nsImage: nsIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
                Text("M的电子书制作工具 v2.0")
                    .font(.title)
            }
            .padding()
            
            // 应用选择器
            VStack(alignment: .leading) {
                Text("选择目标应用:")
                    .font(.headline)
                
                AppPickerView(selectedApp: $selectedApp)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 截屏区域选择
            VStack(alignment: .leading) {
                Text("截屏区域:")
                    .font(.headline)
                
                HStack {
                    Button(isSelectingArea ? "取消选择" : "选择区域") {
                        if isSelectingArea {
                            cancelAreaSelection()
                        } else {
                            selectScreenArea()
                        }
                    }
                    .disabled(isCapturing || isGeneratingPDF)
                    
                    if selectedArea != .zero {
                        Text("已选择区域: \(Int(selectedArea.width))×\(Int(selectedArea.height))")
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 文件设置
            VStack(alignment: .leading, spacing: 10) {
                Text("文件设置:")
                    .font(.headline)
                
                HStack {
                    Text("文件名:")
                    TextField("例如: document", text: $fileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("_0001.png")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("保存路径:")
                    if savePath.isEmpty {
                        Text("请选择保存路径")
                            .foregroundColor(.red)
                            .italic()
                    } else {
                        Text(savePath)
                            .foregroundColor(.green)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Button("选择路径") {
                        selectSavePath()
                    }
                    Button("桌面") {
                        selectDesktopPath()
                    }
                    Button("文档") {
                        selectDocumentsPath()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 参数设置
            VStack(alignment: .leading, spacing: 12) {
                Text("参数设置:")
                    .font(.headline)
                
                HStack {
                    Text("页数:")
                    TextField("页数", text: $pageCount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("速度模式:")
                        Picker("速度模式", selection: $speedMode) {
                            ForEach(SpeedMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: speedMode) { newMode in
                            delay = newMode.defaultDelay
                        }
                    }
                    
                    HStack {
                        Text("延迟时间:")
                        Slider(value: $delay, in: speedMode.delayRange, step: 0.1)
                        Text("\(delay, specifier: "%.1f")s")
                            .frame(width: 50)
                    }
                    
                    Text("提示: 极速模式可能导致某些应用翻页不及时")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .opacity(speedMode == .turbo ? 1 : 0)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 控制按钮
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    Button("开始截屏") {
                        startCapturing()
                    }
                    .disabled(!canStartCapturing())
                    .buttonStyle(.borderedProminent)
                    
                    Button("停止") {
                        stopCapturing()
                    }
                    .disabled(!isCapturing)
                    .buttonStyle(.bordered)
                    
                    Button(isGeneratingPDF ? "生成中..." : "转为PDF") {
                        convertToPDF()
                    }
                    .disabled(isCapturing || !canConvertToPDF() || isGeneratingPDF)
                    .buttonStyle(.bordered)
                }
                
                HStack(spacing: 15) {
                    Button("测试截屏") {
                        testScreenshot()
                    }
                    .disabled(selectedArea == .zero || savePath.isEmpty || fileName.isEmpty || isCapturing || isGeneratingPDF)
                    .buttonStyle(.bordered)
                    
                    Button("全屏截屏测试") {
                        testFullScreenshot()
                    }
                    .disabled(savePath.isEmpty || fileName.isEmpty || isCapturing || isGeneratingPDF)
                    .buttonStyle(.bordered)
                    
                    Button("清除日志") {
                        screenshotManager.debugInfo = ""
                    }
                    .buttonStyle(.bordered)
                    
                    Button("关于") {
                        showingAbout = true
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // 状态显示
            if isCapturing {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("正在截屏... \(screenshotManager.currentPage)/\(pageCount)")
                    Text("保存到: \(savePath)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // 性能指标显示
                    if let metrics = screenshotManager.performanceMetrics {
                        HStack(spacing: 16) {
                            Text("速度: \(metrics.averageTimePerPage, specifier: "%.1f")s/页")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("预计剩余: \(metrics.estimatedTimeRemaining, specifier: "%.0f")秒")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // PDF生成状态显示
            if isGeneratingPDF {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("正在生成PDF...")
                    Text("这可能需要几分钟，请耐心等待")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 调试信息
            if !screenshotManager.debugInfo.isEmpty {
                VStack(alignment: .leading) {
                    Text("调试信息:")
                        .font(.headline)
                    ScrollView {
                        Text(screenshotManager.debugInfo)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(height: 120)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            HStack {
                Spacer()
                Text("Developed by Merlin")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(width: 600, height: 950)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func canStartCapturing() -> Bool {
        return selectedApp != nil &&
               selectedArea != .zero &&
               !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !savePath.isEmpty &&
               !isCapturing &&
               !isGeneratingPDF
    }
    
    private func canConvertToPDF() -> Bool {
        guard !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !savePath.isEmpty else {
            return false
        }
        
        let cleanFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileManager = FileManager.default
        
        // 检查是否存在相关的图片文件
        do {
            let files = try fileManager.contentsOfDirectory(atPath: savePath)
            let matchingFiles = files.filter { file in
                file.hasPrefix("\(cleanFileName)_") && file.hasSuffix(".png")
            }
            return !matchingFiles.isEmpty
        } catch {
            return false
        }
    }
    
    private func convertToPDF() {
        let cleanFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanFileName.isEmpty, !savePath.isEmpty else { return }
        
        isGeneratingPDF = true
        
        Task {
            await screenshotManager.convertImagesToPDF(
                folderPath: savePath,
                fileNamePrefix: cleanFileName
            ) { success, message in
                DispatchQueue.main.async {
                    self.isGeneratingPDF = false
                    self.alertMessage = message
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func testFullScreenshot() {
        let cleanFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let testFileName = "\(cleanFileName)_fullscreen_test.png"
        let filePath = (savePath as NSString).appendingPathComponent(testFileName)
        
        Task {
            await screenshotManager.testFullScreenCapture(savePath: filePath)
            
            DispatchQueue.main.async {
                if FileManager.default.fileExists(atPath: filePath) {
                    alertMessage = "全屏截屏测试成功！文件保存在：\(filePath)\n这说明权限正常，可以进行区域截屏测试。"
                } else {
                    alertMessage = "全屏截屏测试失败！请检查调试信息。"
                }
                showingAlert = true
            }
        }
    }
    
    private func testScreenshot() {
        let cleanFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let testFileName = "\(cleanFileName)_test.png"
        let filePath = (savePath as NSString).appendingPathComponent(testFileName)
        
        Task {
            await screenshotManager.testCapture(area: selectedArea, savePath: filePath)
            
            DispatchQueue.main.async {
                if FileManager.default.fileExists(atPath: filePath) {
                    alertMessage = "区域截屏测试成功！文件保存在：\(filePath)"
                } else {
                    alertMessage = "区域截屏测试失败！请检查调试信息。"
                }
                showingAlert = true
            }
        }
    }
    
    private func selectScreenArea() {
        isSelectingArea = true
        
        areaSelector = AreaSelector { selectedRect in
            DispatchQueue.main.async {
                self.selectedArea = selectedRect
                self.isSelectingArea = false
                self.areaSelector = nil
            }
        } onCancel: {
            DispatchQueue.main.async {
                self.isSelectingArea = false
                self.areaSelector = nil
            }
        }
        
        areaSelector?.showSelector()
    }
    
    private func cancelAreaSelection() {
        areaSelector?.hideSelector()
        areaSelector = nil
        isSelectingArea = false
    }
    
    private func selectSavePath() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.title = "选择截屏保存文件夹"
        panel.prompt = "选择"
        
        if panel.runModal() == .OK {
            savePath = panel.url?.path ?? ""
        }
    }
    
    private func selectDesktopPath() {
        savePath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.path ?? NSHomeDirectory() + "/Desktop"
    }
    
    private func selectDocumentsPath() {
        savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? NSHomeDirectory() + "/Documents"
    }
    
    private func startCapturing() {
        guard let app = selectedApp,
              let pages = Int(pageCount),
              pages > 0,
              !fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !savePath.isEmpty else {
            return
        }
        
        isCapturing = true
        
        app.activate(options: [.activateIgnoringOtherApps])
        
        let cleanFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "*", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "\"", with: "_")
            .replacingOccurrences(of: "<", with: "_")
            .replacingOccurrences(of: ">", with: "_")
            .replacingOccurrences(of: "|", with: "_")
        
        screenshotManager.startCapturing(
            app: app,
            area: selectedArea,
            pageCount: pages,
            delay: delay,
            speedMode: speedMode,
            savePath: savePath,
            fileName: cleanFileName
        ) {
            isCapturing = false
        }
    }
    
    private func stopCapturing() {
        screenshotManager.stopCapturing()
        isCapturing = false
    }
}

struct AppPickerView: View {
    @Binding var selectedApp: NSRunningApplication?
    @State private var runningApps: [NSRunningApplication] = []
    
    var body: some View {
        Picker("选择应用", selection: $selectedApp) {
            Text("请选择应用").tag(nil as NSRunningApplication?)
            ForEach(runningApps, id: \.processIdentifier) { app in
                if let name = app.localizedName {
                    Text(name).tag(app as NSRunningApplication?)
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onAppear {
            loadRunningApps()
        }
    }
    
    private func loadRunningApps() {
        runningApps = NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular && app.localizedName != nil
        }
    }
}

class AreaSelector {
    private var overlayWindow: NSWindow?
    private var selectionView: AreaSelectionView?
    private let onSelection: (CGRect) -> Void
    private let onCancel: () -> Void
    
    init(onSelection: @escaping (CGRect) -> Void, onCancel: @escaping () -> Void) {
        self.onSelection = onSelection
        self.onCancel = onCancel
    }
    
    func showSelector() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        overlayWindow = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        overlayWindow?.level = .floating
        overlayWindow?.backgroundColor = NSColor.clear
        overlayWindow?.isOpaque = false
        overlayWindow?.hasShadow = false
        overlayWindow?.ignoresMouseEvents = false
        overlayWindow?.acceptsMouseMovedEvents = true
        
        selectionView = AreaSelectionView(
            frame: screenFrame,
            onSelection: { [weak self] rect in
                self?.onSelection(rect)
                self?.hideSelector()
            },
            onCancel: { [weak self] in
                self?.onCancel()
                self?.hideSelector()
            }
        )
        
        overlayWindow?.contentView = selectionView
        overlayWindow?.makeKeyAndOrderFront(nil)
        
        NSCursor.crosshair.set()
    }
    
    func hideSelector() {
        NSCursor.arrow.set()
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
        selectionView = nil
    }
}

class AreaSelectionView: NSView {
    private var startPoint: NSPoint = .zero
    private var currentPoint: NSPoint = .zero
    private var isSelecting = false
    private let onSelection: (CGRect) -> Void
    private let onCancel: () -> Void
    
    init(frame: NSRect, onSelection: @escaping (CGRect) -> Void, onCancel: @escaping () -> Void) {
        self.onSelection = onSelection
        self.onCancel = onCancel
        super.init(frame: frame)
        self.wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.black.withAlphaComponent(0.3).setFill()
        dirtyRect.fill()
        
        if isSelecting {
            let selectionRect = NSRect(
                x: min(startPoint.x, currentPoint.x),
                y: min(startPoint.y, currentPoint.y),
                width: abs(currentPoint.x - startPoint.x),
                height: abs(currentPoint.y - startPoint.y)
            )
            
            NSColor.clear.setFill()
            selectionRect.fill(using: .copy)
            
            NSColor.white.setStroke()
            let borderPath = NSBezierPath(rect: selectionRect)
            borderPath.lineWidth = 2.0
            borderPath.stroke()
            
            let sizeText = "\(Int(selectionRect.width)) × \(Int(selectionRect.height))"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.white,
                .backgroundColor: NSColor.black.withAlphaComponent(0.7),
                .font: NSFont.systemFont(ofSize: 12)
            ]
            
            let textSize = sizeText.size(withAttributes: attributes)
            let textRect = NSRect(
                x: selectionRect.maxX - textSize.width - 5,
                y: selectionRect.maxY + 5,
                width: textSize.width + 4,
                height: textSize.height + 2
            )
            
            sizeText.draw(in: textRect, withAttributes: attributes)
        }
        
        let instructionText = "拖拽选择截屏区域，按 ESC 取消"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black.withAlphaComponent(0.7),
            .font: NSFont.systemFont(ofSize: 14)
        ]
        
        let textSize = instructionText.size(withAttributes: attributes)
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: bounds.height - textSize.height - 20,
            width: textSize.width + 8,
            height: textSize.height + 4
        )
        
        instructionText.draw(in: textRect, withAttributes: attributes)
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        isSelecting = true
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        if isSelecting {
            currentPoint = convert(event.locationInWindow, from: nil)
            needsDisplay = true
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        if isSelecting {
            let selectionRect = CGRect(
                x: min(startPoint.x, currentPoint.x),
                y: min(startPoint.y, currentPoint.y),
                width: abs(currentPoint.x - startPoint.x),
                height: abs(currentPoint.y - startPoint.y)
            )
            
            if selectionRect.width > 10 && selectionRect.height > 10 {
                let screenHeight = NSScreen.main?.frame.height ?? 1080
                let screenRect = CGRect(
                    x: selectionRect.origin.x,
                    y: screenHeight - selectionRect.origin.y - selectionRect.height,
                    width: selectionRect.width,
                    height: selectionRect.height
                )
                
                onSelection(screenRect)
            }
        }
        
        isSelecting = false
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            onCancel()
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }
}

struct PerformanceMetrics {
    let averageTimePerPage: Double
    let estimatedTimeRemaining: Double
}

class ScreenshotManager: ObservableObject {
    @Published var currentPage = 0
    @Published var debugInfo = ""
    @Published var performanceMetrics: PerformanceMetrics?
    
    private var isCapturing = false
    private var captureTask: Task<Void, Never>?
    private var startTime: Date?
    
    // 优化：缓存的事件源，避免重复创建
    private var eventSource: CGEventSource?
    private var pageDownKeyDown: CGEvent?
    private var pageDownKeyUp: CGEvent?
    
    // 性能优化：减少UI更新频率
    private var lastUIUpdate: Date = Date()
    private let uiUpdateInterval: TimeInterval = 0.5
    
    init() {
        setupKeyEvents()
    }
    
    deinit {
        cleanupKeyEvents()
    }
    
    private func setupKeyEvents() {
        eventSource = CGEventSource(stateID: .hidSystemState)
        pageDownKeyDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x79, keyDown: true)
        pageDownKeyUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x79, keyDown: false)
    }
    
    private func cleanupKeyEvents() {
        eventSource = nil
        pageDownKeyDown = nil
        pageDownKeyUp = nil
    }
    
    func convertImagesToPDF(
        folderPath: String,
        fileNamePrefix: String,
        completion: @escaping (Bool, String) -> Void
    ) async {
        await MainActor.run {
            debugInfo += "=== 开始PDF转换 ===\n"
            debugInfo += "文件夹路径: \(folderPath)\n"
            debugInfo += "文件名前缀: \(fileNamePrefix)\n"
        }
        
        let fileManager = FileManager.default
        
        // 获取所有匹配的图片文件
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: folderPath)
            let imageFiles = allFiles.filter { file in
                file.hasPrefix("\(fileNamePrefix)_") && file.hasSuffix(".png")
            }.sorted { file1, file2 in
                // 提取文件编号进行排序
                let number1 = extractNumber(from: file1, prefix: fileNamePrefix)
                let number2 = extractNumber(from: file2, prefix: fileNamePrefix)
                return number1 < number2
            }
            
            await MainActor.run {
                debugInfo += "找到 \(imageFiles.count) 个匹配的图片文件\n"
            }
            
            if imageFiles.isEmpty {
                completion(false, "未找到匹配的图片文件（格式: \(fileNamePrefix)_xxxx.png）")
                return
            }
            
            // 创建PDF文档
            let pdfDocument = PDFDocument()
            var addedPages = 0
            
            for (index, imageFile) in imageFiles.enumerated() {
                let imagePath = (folderPath as NSString).appendingPathComponent(imageFile)
                
                if let nsImage = NSImage(contentsOfFile: imagePath) {
                    // 将NSImage转换为PDFPage
                    if let pdfPage = createPDFPage(from: nsImage) {
                        pdfDocument.insert(pdfPage, at: pdfDocument.pageCount)
                        addedPages += 1
                        
                        // 每处理10个文件更新一次进度
                        if index % 10 == 0 {
                            await MainActor.run {
                                debugInfo += "已处理: \(index + 1)/\(imageFiles.count)\n"
                            }
                        }
                    } else {
                        await MainActor.run {
                            debugInfo += "⚠️ 无法转换图片: \(imageFile)\n"
                        }
                    }
                } else {
                    await MainActor.run {
                        debugInfo += "⚠️ 无法加载图片: \(imageFile)\n"
                    }
                }
            }
            
            if addedPages == 0 {
                completion(false, "无法转换任何图片文件")
                return
            }
            
            // 保存PDF到截图所在的目录（而不是父目录）
            let pdfFileName = "\(fileNamePrefix).pdf"
            let pdfPath = (folderPath as NSString).appendingPathComponent(pdfFileName)
            
            // 如果文件已存在，添加时间戳
            let finalPdfPath: String
            if fileManager.fileExists(atPath: pdfPath) {
                let timestamp = DateFormatter().string(from: Date()).replacingOccurrences(of: " ", with: "_")
                let pdfFileNameWithTimestamp = "\(fileNamePrefix)_\(timestamp).pdf"
                finalPdfPath = (folderPath as NSString).appendingPathComponent(pdfFileNameWithTimestamp)
            } else {
                finalPdfPath = pdfPath
            }
            
            if pdfDocument.write(to: URL(fileURLWithPath: finalPdfPath)) {
                await MainActor.run {
                    debugInfo += "✓ PDF生成成功！\n"
                    debugInfo += "文件路径: \(finalPdfPath)\n"
                    debugInfo += "总页数: \(addedPages)\n"
                    debugInfo += "==================\n\n"
                }
                completion(true, "PDF生成成功！\n文件保存在: \(finalPdfPath)\n总页数: \(addedPages)")
            } else {
                await MainActor.run {
                    debugInfo += "✗ PDF保存失败\n"
                    debugInfo += "==================\n\n"
                }
                completion(false, "PDF保存失败，请检查文件权限")
            }
            
        } catch {
            await MainActor.run {
                debugInfo += "✗ 读取文件夹失败: \(error.localizedDescription)\n"
                debugInfo += "==================\n\n"
            }
            completion(false, "读取文件夹失败: \(error.localizedDescription)")
        }
    }
    
    private func extractNumber(from fileName: String, prefix: String) -> Int {
        // 从文件名中提取编号，例如从 "document_0001.png" 中提取 1
        let pattern = "\(prefix)_(\\d+)\\.png"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: fileName, options: [], range: NSRange(location: 0, length: fileName.count)),
           let numberRange = Range(match.range(at: 1), in: fileName) {
            return Int(String(fileName[numberRange])) ?? 0
        }
        return 0
    }
    
    private func createPDFPage(from nsImage: NSImage) -> PDFPage? {
        // 获取图片的数据
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let imageData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        // 创建PDF页面
        let pdfPage = PDFPage(image: NSImage(data: imageData) ?? nsImage)
        return pdfPage
    }
    
    func testFullScreenCapture(savePath: String) async {
        await MainActor.run {
            debugInfo = "=== 全屏截屏测试 ===\n"
            debugInfo += "保存路径: \(savePath)\n"
        }
        
        let directory = (savePath as NSString).deletingLastPathComponent
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: [
                .posixPermissions: 0o755
            ])
            await MainActor.run {
                debugInfo += "✓ 目录准备完成\n"
            }
        } catch {
            await MainActor.run {
                debugInfo += "✗ 目录创建失败: \(error.localizedDescription)\n"
            }
            return
        }
        
        if fileManager.fileExists(atPath: savePath) {
            try? fileManager.removeItem(atPath: savePath)
        }
        
        let success = await captureScreenOptimized(area: nil, savePath: savePath)
        
        let fileExists = fileManager.fileExists(atPath: savePath)
        await MainActor.run {
            debugInfo += "文件是否存在: \(fileExists)\n"
            if fileExists {
                let attributes = try? fileManager.attributesOfItem(atPath: savePath)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                debugInfo += "文件大小: \(fileSize) bytes\n"
                
                if fileSize == 0 {
                    debugInfo += "⚠️ 文件大小为0，截屏可能失败\n"
                } else {
                    debugInfo += "✓ 全屏截屏成功！\n"
                }
            } else {
                debugInfo += "✗ 文件创建失败\n"
            }
            debugInfo += "==================\n\n"
        }
    }
    
    func testCapture(area: CGRect, savePath: String) async {
        await MainActor.run {
            debugInfo = "=== 区域截屏测试 ===\n"
            debugInfo += "区域: \(area)\n"
            debugInfo += "保存路径: \(savePath)\n"
        }
        
        let directory = (savePath as NSString).deletingLastPathComponent
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: [
                .posixPermissions: 0o755
            ])
            await MainActor.run {
                debugInfo += "✓ 目录准备完成\n"
            }
        } catch {
            await MainActor.run {
                debugInfo += "✗ 目录创建失败: \(error.localizedDescription)\n"
            }
            return
        }
        
        if fileManager.fileExists(atPath: savePath) {
            try? fileManager.removeItem(atPath: savePath)
        }
        
        let success = await captureScreenOptimized(area: area, savePath: savePath)
        
        let fileExists = fileManager.fileExists(atPath: savePath)
        await MainActor.run {
            debugInfo += "文件是否存在: \(fileExists)\n"
            if fileExists {
                let attributes = try? fileManager.attributesOfItem(atPath: savePath)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                debugInfo += "文件大小: \(fileSize) bytes\n"
                
                if fileSize == 0 {
                    debugInfo += "⚠️ 文件大小为0，截屏可能失败\n"
                } else {
                    debugInfo += "✓ 区域截屏成功！\n"
                }
            } else {
                debugInfo += "✗ 文件创建失败\n"
            }
            debugInfo += "==================\n\n"
        }
    }
    
    func startCapturing(
        app: NSRunningApplication,
        area: CGRect,
        pageCount: Int,
        delay: Double,
        speedMode: ContentView.SpeedMode,
        savePath: String,
        fileName: String,
        completion: @escaping () -> Void
    ) {
        isCapturing = true
        currentPage = 0
        startTime = Date()
        performanceMetrics = nil
        lastUIUpdate = Date()
        
        captureTask = Task {
            await performCapturing(
                app: app,
                area: area,
                pageCount: pageCount,
                delay: delay,
                speedMode: speedMode,
                savePath: savePath,
                fileName: fileName
            )
            
            await MainActor.run {
                completion()
            }
        }
    }
    
    func stopCapturing() {
        isCapturing = false
        captureTask?.cancel()
    }
    
    private func performCapturing(
        app: NSRunningApplication,
        area: CGRect,
        pageCount: Int,
        delay: Double,
        speedMode: ContentView.SpeedMode,
        savePath: String,
        fileName: String
    ) async {
        await MainActor.run {
            debugInfo = "=== 开始批量截屏 ===\n"
            debugInfo += "目标应用: \(app.localizedName ?? "未知")\n"
            debugInfo += "截屏区域: \(area)\n"
            debugInfo += "页数: \(pageCount)\n"
            debugInfo += "速度模式: \(speedMode.rawValue)\n"
            debugInfo += "保存路径: \(savePath)\n"
            debugInfo += "文件名前缀: \(fileName)\n\n"
        }
        
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: savePath, withIntermediateDirectories: true, attributes: [
                .posixPermissions: 0o755
            ])
            await MainActor.run {
                debugInfo += "✓ 保存目录准备完成\n\n"
            }
        } catch {
            await MainActor.run {
                debugInfo += "✗ 无法创建保存目录: \(error.localizedDescription)\n"
            }
            return
        }
        
        app.activate(options: [.activateIgnoringOtherApps])
        try? await Task.sleep(nanoseconds: UInt64(speedMode.appActivationDelay * 1_000_000_000))
        
        var successCount = 0
        var errorCount = 0
        
        for i in 1...pageCount {
            if !isCapturing || Task.isCancelled { break }
            
            let pageStartTime = Date()
            
            let formattedFileName = String(format: "%@_%04d.png", fileName, i)
            let filePath = (savePath as NSString).appendingPathComponent(formattedFileName)
            
            let success = await captureScreenOptimized(area: area, savePath: filePath)
            
            if success {
                successCount += 1
            } else {
                errorCount += 1
            }
            
            if i < pageCount {
                await sendPageDownKeyOptimized()
            }
            
            let now = Date()
            if now.timeIntervalSince(lastUIUpdate) >= uiUpdateInterval || i == pageCount {
                await updateUIWithProgress(
                    currentPage: i,
                    pageCount: pageCount,
                    successCount: successCount,
                    errorCount: errorCount,
                    pageStartTime: pageStartTime
                )
                lastUIUpdate = now
            } else {
                await MainActor.run {
                    self.currentPage = i
                }
            }
            
            if i < pageCount {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        await MainActor.run {
            debugInfo += "截屏完成！成功: \(successCount), 失败: \(errorCount)\n"
            debugInfo += "提示: 您现在可以使用'转为PDF'功能将图片合并为PDF文件\n"
        }
    }
    
    private func captureScreenOptimized(area: CGRect?, savePath: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.launchPath = "/usr/sbin/screencapture"
                
                var arguments = ["-x"]
                
                if let area = area {
                    arguments.append("-R\(Int(area.origin.x)),\(Int(area.origin.y)),\(Int(area.width)),\(Int(area.height))")
                }
                
                arguments.append(savePath)
                task.arguments = arguments
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    continuation.resume(returning: task.terminationStatus == 0)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private func sendPageDownKeyOptimized() async {
        guard let keyDown = pageDownKeyDown,
              let keyUp = pageDownKeyUp else { return }
        
        keyDown.post(tap: .cghidEventTap)
        try? await Task.sleep(nanoseconds: 5_000_000)
        keyUp.post(tap: .cghidEventTap)
    }
    
    private func updateUIWithProgress(
        currentPage: Int,
        pageCount: Int,
        successCount: Int,
        errorCount: Int,
        pageStartTime: Date
    ) async {
        await MainActor.run {
            self.currentPage = currentPage
            
            let statusLine = "第 \(currentPage) 页: 成功 \(successCount), 失败 \(errorCount)\n"
            
            let lines = debugInfo.components(separatedBy: "\n")
            if lines.count > 50 {
                let recentLines = Array(lines.suffix(30))
                debugInfo = recentLines.joined(separator: "\n") + "\n"
            }
            debugInfo += statusLine
            
            if let start = startTime {
                let totalTime = Date().timeIntervalSince(start)
                let averageTime = totalTime / Double(currentPage)
                let remainingPages = pageCount - currentPage
                let estimatedRemaining = averageTime * Double(remainingPages)
                
                performanceMetrics = PerformanceMetrics(
                    averageTimePerPage: averageTime,
                    estimatedTimeRemaining: estimatedRemaining
                )
            }
        }
    }
}
