//
//  MenuView.swift
//  BatteryBoi
//
//  Created by Joe Barbour on 8/4/23.
//

import SwiftUI
import Combine

enum BatteryStyle:String {
    case chunky
    case basic
    
    var radius:CGFloat {
        switch self {
            case .basic : return 3
            case .chunky : return 5
            
        }
        
    }
    
    var size:CGSize {
        switch self {
            case .basic : return .init(width: 28, height: 13)
            case .chunky : return .init(width: 32, height: 15)
            
        }
        
    }
    
    var padding:CGFloat {
        switch self {
            case .basic : return 1
            case .chunky : return 2
            
        }
        
    }
    
}

enum BatteryAnimationType {
    case charging
    case low
    
}

public struct BatteryPulsatingIcon: View {
    @EnvironmentObject var manager:BatteryManager

    @State private var visible:Bool = false
    @State private var icon:String = "ChargingIcon"
    
    init(_ icon:String) {
        self._icon = State(initialValue: icon)
        
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.black)
            .mask(
               Image(icon)
                   .resizable()
                   .aspectRatio(contentMode: .fit)
            
            )
            .frame(width: 5, height: 8)
            .onAppear() {
                withAnimation(Animation.easeInOut) {
                    self.visible = true
                    
                }
            }
            .offset(y:0.4)
            .opacity(self.visible ? 1.0 : 0.0)
            .onChange(of: self.visible) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + (self.visible ? 2.0 : 0.8)) {
                    withAnimation(Animation.easeInOut) {
                        self.visible.toggle()
    
                    }
    
                }
    
            }
           
    }
    
}




public struct BatteryMask: Shape {
    private var radius:CGFloat

    init(_ value: CGFloat) {
        self.radius = value
        
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - self.radius, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: self.radius), control: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - self.radius))
        path.addQuadCurve(to: CGPoint(x: rect.width - self.radius, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))

        return path
        
    }
    
}

private struct BatteryStatus: View {
    @EnvironmentObject var manager:BatteryManager
    @EnvironmentObject var stats:StatsManager

    @State private var size:CGSize
    @State private var font:CGFloat
    @State private var icon:String? = nil

    @Binding private var hover:Bool
    
    init(_ size:CGSize, font:CGFloat, hover:Binding<Bool>) {
        self._size = State(initialValue: size)
        self._font = State(initialValue: font)
        self._hover = hover
        
    }

    var body: some View {
        ZStack {
            if let overlay = self.stats.overlay {
                Text(overlay).style(self.font).offset(y:self.hover ? 0.0 : -self.size.height)
                
            }

            HStack(alignment: .center, spacing:0.4) {
                if let icon = self.icon {
                    BatteryPulsatingIcon(icon)
                    
                }
                
                if let summary = self.stats.display {
                    Text(summary).style(self.font)
                    
                }
                
            }
            .offset(y:self.hover ? self.size.height : 0.0)
            .foregroundColor(Color.black)
            .frame(width: self.size.width, height: self.size.height)
            
        }
        .onAppear() {
            if self.manager.charging.state == .charging && self.manager.percentage != 100 {
                self.icon = "ChargingIcon"
                
            }
            else {
                self.icon = nil

            }
            
        }
        .onChange(of: manager.charging) { newValue in
            if newValue.state == .charging && self.manager.percentage != 100 {
                self.icon = "ChargingIcon"
                
            }
            else {
                self.icon = nil

            }
            
        }
        .onChange(of: manager.percentage) { newValue in
            if self.manager.charging.state == .charging && newValue != 100 {
                self.icon = "ChargingIcon"

            }
            else {
                self.icon = nil

            }
            
        }
        .frame(alignment: .center)
        .foregroundColor(Color.black)
        .animation(Animation.easeInOut, value: self.manager.charging)

    }
    
}

private struct BatteryStub: View {
    @State private var proxy:GeometryProxy
    @State private var size:CGSize

    init(_ proxy: GeometryProxy, size:CGSize) {
        self._proxy = State(initialValue: proxy)
        self._size = State(initialValue: size)
        
    }
    
    var body: some View {
        ZStack {
            BatteryMask(3.4).foregroundColor(Color("BatteryDefault"))

        }
        .position(x:proxy.size.width + 2, y:proxy.size.height / 2)
        .frame(width: 1.6, height: 6)
        .opacity(0.6)

    }
    
}

struct BatteryIcon: View {
    @EnvironmentObject var manager:BatteryManager
    
    @State var size:CGSize
    @State var radius:CGFloat = 25
    @State var max:CGFloat = 25
    @State var font:CGFloat
    @State var padding:CGFloat
    @State var progress:CGFloat
    
    @Binding var hover:Bool

    init(_ size: CGSize, radius: CGFloat, font:CGFloat, hover:Binding<Bool>) {
        self._size = State(initialValue: size)
        self._radius = State(initialValue: radius)
        self._max = State(initialValue: radius)
        self._font = State(initialValue: font)
        self._padding = State(initialValue: 1.6)
        self._progress = State(initialValue: 1.0)
        self._hover = hover

    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Rectangle()
                    .frame(width: self.progress, alignment: .leading)
                    .clipShape(BatteryMask(3.4))
    
            }
            .frame(maxWidth: self.size.width, alignment: .leading)
            .foregroundColor(Color.black)
            .overlay(
                BatteryStatus(size, font: font, hover: $hover)
             
            )
                        
        }
        .animation(.linear, value: self.manager.percentage)
        .inverse(
            BatteryStatus(size, font: font, hover: $hover).mask(
                Rectangle()
                    .fill(.black)
                    .frame(width: self.size.width)
                    .position(x: -(self.size.width / 2) + (self.progress + 2.0), y: self.size.height / 2)

            )
            
        )
        .clipShape(RoundedRectangle(cornerRadius: self.radius - self.padding, style: .continuous))
        .padding(self.padding)
        .onChange(of: self.manager.charging.state, perform: { newValue in
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.9, blendDuration: 1)) {
                self.progress = newValue.progress(self.manager.percentage, width: self.size.width)
                
            }
            
        })
        .onChange(of: self.manager.percentage, perform: { newValue in
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.9, blendDuration: 1)) {
                self.progress = self.manager.charging.state.progress(newValue, width: self.size.width)
                
            }
          
        })
        .onAppear() {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.9, blendDuration: 1)) {
                self.progress = self.manager.charging.state.progress(self.manager.percentage, width: self.size.width)
                
            }
            
        }
       

    }
    
}

struct BatteryContainer: View {
    @EnvironmentObject var manager:BatteryManager
    @EnvironmentObject var updates:UpdateManager
    @EnvironmentObject var stats:StatsManager

    @State private var size:CGSize
    @State private var radius:CGFloat
    @State private var font:CGFloat
    @State private var hover:Bool = false

    init(_ size: CGSize, radius:CGFloat, font:CGFloat) {
        self._size = State(initialValue: size)
        self._radius = State(initialValue: radius)
        self._font = State(initialValue: font)

    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: self.radius, style: .continuous)
                .fill(Color("BatteryDefault"))
                .opacity(0.9)
                .frame(width:self.size.width, height: self.size.height)
                .mask(
                    Rectangle().inverse(BatteryIcon(size, radius: radius, font: font, hover: $hover))
                    
                )

        }
        .onHover { hover in
            if self.stats.overlay != nil {
                withAnimation(Animation.easeOut(duration: 0.3).delay(self.hover ? 0.8 : 0.1)) {
                    self.hover = hover
                    
                }
                
            }
            
        }
        .onChange(of: self.manager.charging, perform: { newValue in
            if newValue.state == .charging && self.hover == true {
                withAnimation(Animation.easeOut(duration: 0.3)) {
                    self.hover = false
                    
                }
            
            }
            
        })
        .overlay(
            GeometryReader { geo in
                if let _ = self.updates.available {
                    Circle()
                        .fill(Color("BatteryEfficient"))
                        .frame(width: 5, height: 5)
                        .position(x:-5, y: (geo.size.height / 2) + 0.5)
                    
                }
                
                BatteryStub(geo, size: .init(width: 4, height: size.height / 2))
                
            }
            
        )
        
    }
    
}

// MARK: - Apple-style menu bar battery (custom)

/// Sizes for the Apple-style menu bar battery, in points.
enum AppleBatteryMetrics {
    static let body = CGSize(width: 25, height: 12)
    static let radius: CGFloat = 3.5
    static let stroke: CGFloat = 1
    static let inset: CGFloat = 2
    static let nub = CGSize(width: 1.5, height: 4)
    static let spacing: CGFloat = 5
    static let font = Font.system(size: 12, weight: .medium).monospacedDigit()
    static let fontNS = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
    static let lowThreshold: Double = 20

    /// Total width of the icon (outline + nub).
    static var iconWidth: CGFloat { body.width + 1 + nub.width }

    /// Width the status item needs for a given label.
    static func itemWidth(_ label: String?) -> CGFloat {
        guard let label = label, label.isEmpty == false else {
            return iconWidth + 8
        }
        let text = (label as NSString).size(withAttributes: [.font: fontNS]).width
        return ceil(text + spacing + iconWidth + 8)
    }
}

/// Battery outline that fills and empties smoothly with the charge level,
/// in the style of the stock macOS battery icon.
struct AppleBatteryIcon: View {
    @EnvironmentObject var manager: BatteryManager

    @State private var level: CGFloat = 1.0

    private var isCharging: Bool { manager.charging.state == .charging }

    private var tint: Color { Color("BatteryDefault") }

    private var fillColor: Color {
        if isCharging { return Color("BatteryCharging") }
        if manager.percentage <= AppleBatteryMetrics.lowThreshold { return Color("BatteryLow") }
        return tint
    }

    private func target(_ percent: Double) -> CGFloat {
        let value = CGFloat(min(max(percent, 0), 100) / 100)
        // keep a visible sliver until the battery is truly empty
        return percent > 0 ? max(value, 0.08) : 0
    }

    var body: some View {
        let m = AppleBatteryMetrics.self
        let innerWidth = m.body.width - (m.inset * 2)
        let innerHeight = m.body.height - (m.inset * 2)

        HStack(alignment: .center, spacing: 1) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: m.radius, style: .continuous)
                    .strokeBorder(tint.opacity(0.45), lineWidth: m.stroke)

                RoundedRectangle(cornerRadius: m.radius - m.inset + 0.5, style: .continuous)
                    .fill(fillColor)
                    .frame(width: innerWidth * level, height: innerHeight)
                    .padding(.leading, m.inset)

                if isCharging {
                    // knock a slightly larger bolt out of the fill, then draw the bolt on top
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10, weight: .black))
                        .frame(width: m.body.width, height: m.body.height)
                        .blendMode(.destinationOut)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(tint)
                        .frame(width: m.body.width, height: m.body.height)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .frame(width: m.body.width, height: m.body.height)
            .compositingGroup()

            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(tint.opacity(0.45))
                .frame(width: m.nub.width, height: m.nub.height)
        }
        .animation(.easeInOut(duration: 0.3), value: isCharging)
        .onAppear {
            level = 0
            withAnimation(.spring(response: 0.9, dampingFraction: 0.85)) {
                level = target(manager.percentage)
            }
        }
        .onChange(of: manager.percentage) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                level = target(newValue)
            }
        }
    }

}

/// Menu bar item: optional label (percentage / time left, from Settings) + battery icon.
struct AppleBatteryContainer: View {
    @EnvironmentObject var stats: StatsManager
    @EnvironmentObject var updates: UpdateManager

    var body: some View {
        HStack(alignment: .center, spacing: AppleBatteryMetrics.spacing) {
            if let label = stats.display, label.isEmpty == false {
                Text(label)
                    .font(AppleBatteryMetrics.font)
                    .foregroundColor(Color("BatteryDefault"))
                    .lineLimit(1)
                    .fixedSize()
            }

            AppleBatteryIcon()
                .overlay(
                    Group {
                        if updates.available != nil {
                            Circle()
                                .fill(Color("BatteryEfficient"))
                                .frame(width: 4, height: 4)
                                .offset(x: 2, y: -2)
                        }
                    },
                    alignment: .topTrailing
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct MenuContainer: View {
    var body: some View {
        AppleBatteryContainer()
            .environmentObject(BatteryManager.shared)
            .environmentObject(StatsManager.shared)
            .environmentObject(UpdateManager.shared)

    }
    
}

struct MenuViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> NSHostingView<MenuContainer> {
        let hostingView = NSHostingView(rootView: MenuContainer())
        hostingView.frame.size = NSSize(width: 100, height: 20)
        return hostingView
        
    }

    func updateNSView(_ nsView: NSHostingView<MenuContainer>, context: Context) {

    }
    
}
