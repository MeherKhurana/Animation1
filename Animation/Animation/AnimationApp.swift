import SwiftUI

@main
struct AnimationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        WifiView()
    }
}

struct WifiView: View {
    
    // MARK: - Variables
    @State private var isAnimating: Bool = false
    @State private var isConnected: Bool = false
    
    @State private var circleOffset: CGFloat = 20
    @State private var smallArcOffset: CGFloat = 16
    @State private var mediumArcOffset: CGFloat = 14.5
    @State private var largeArcOffset: CGFloat = 14
    
    @State private var arcColor: Color = Color.white
    @State private var shadowColor: Color = Color.blue
    @State private var wifiHeaderLabel: String = "Wi-Fi"
    
    static private var animationMovingUpwards: Bool = true
    static private var moveArc: Bool = true
    
    private var animationDuration: Double = 0.35
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.wifiBackground
                .edgesIgnoringSafeArea(.all)
            CircleEmitter(isAnimating: $isConnected)
            ZStack {
                Circle()
                    .fill(self.arcColor)
                    .scaleEffect(0.075)
                    .shadow(color: Color.blue, radius: 5)
                    .offset(y: self.circleOffset)
                    .animation(Animation.easeOut(duration: animationDuration))
                ZStack {
                    ArcView(radius: 12, fillColor: $arcColor, shadowColor: $shadowColor)
                        .rotationEffect(getRotation(arcBoolean: Self.moveArc))
                        .offset(y: smallArcOffset)
                        .animation(Animation.easeOut(duration: self.animationDuration))
                    
                    ArcView(radius: 24, fillColor: $arcColor, shadowColor: $shadowColor)
                        .rotationEffect(getRotation(arcBoolean: Self.moveArc))
                        .offset(y: self.mediumArcOffset)
                        .animation(Animation.easeOut(duration: self.animationDuration).delay(self.animationDuration))
                    
                    ArcView(radius: 36, fillColor: $arcColor, shadowColor: $shadowColor)
                        .rotationEffect(getRotation(arcBoolean: Self.moveArc))
                        .offset(y: self.largeArcOffset)
                        .animation(Animation.easeOut(duration: self.animationDuration).delay(self.animationDuration * 1.9))
                    
                    Circle().stroke(style: StrokeStyle(lineWidth: 2.5))
                        .foregroundColor(Color.white)
                        .opacity(0.8)
                    
                    Circle().fill(Color.blue.opacity(0.1))
                    Circle().fill(Color.blue.opacity(0.025))
                        .scaleEffect(self.isAnimating ? 5 : 0)
                        .animation(self.isAnimating ? Animation.easeIn(duration: animationDuration * 2.5).repeatForever(autoreverses: false) : Animation.linear(duration: 0))
                }
            }.frame(height: 120)
            .onTapGesture {
                resetValues()
                animate()
                
                Timer.scheduledTimer(withTimeInterval: self.animationDuration * 12, repeats: false) { (_) in
                    self.restoreAnimation()
                    self.arcColor = Color.wifiConnected
                    self.shadowColor = Color.white.opacity(0.5)
                    self.wifiHeaderLabel = "Connected"
                    self.isConnected.toggle()
                    
                    Timer.scheduledTimer(withTimeInterval: self.animationDuration + 0.05, repeats: false) { (Timer) in
                        self.isConnected.toggle()
                    }
                }
            }
            
            Text(self.wifiHeaderLabel)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .opacity(self.isAnimating ? 0 : 1)
                .foregroundColor(Color.white)
                .offset(y: 100)
                .animation(self.isAnimating ? Animation.spring().speed(0.65).repeatForever(autoreverses: false) : Animation.linear(duration: 0).repeatCount(0))
        }
    }
    
    // MARK: - Functions
    private func getRotation(arcBoolean: Bool) -> Angle {
        if (self.isAnimating && arcBoolean) {
            return Angle.degrees(180)
        } else if (self.isAnimating && arcBoolean) {
            return Angle.degrees(-180)
        }
        return Angle.degrees(0)
    }
    
    private func animate() {
        Timer.scheduledTimer(withTimeInterval: self.animationDuration, repeats: true) { (arcTimer) in
            if (self.isAnimating) {
                self.circleOffset += Self.animationMovingUpwards ? -15 : 15
                self.smallArcOffset += Self.moveArc ? -15 : 15
                if (self.circleOffset == -25) {
                    Self.animationMovingUpwards = false
                } else if (self.circleOffset == 20) {
                    Self.animationMovingUpwards = true
                }
                if (Self.moveArc) {
                    self.mediumArcOffset += -15
                }
            } else {
                arcTimer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: (self.animationDuration) * 2, repeats: true) { (arcTimer) in
            if (self.isAnimating) {
                self.mediumArcOffset += 15
            } else {
                arcTimer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: (self.animationDuration) * 3, repeats: true) { (arcTimer) in
            if (self.isAnimating) {
                Self.moveArc.toggle()
                self.smallArcOffset = !Self.moveArc ? -15 : 8.5
                if (Self.animationMovingUpwards) {
                    self.largeArcOffset = -19
                    self.mediumArcOffset = -5.5
                } else {
                    self.largeArcOffset = 14
                    self.mediumArcOffset = 0
                }
            } else {
                arcTimer.invalidate()
            }
        }
    }
    
    private func restoreAnimation() {
        self.isAnimating = false
        Self.animationMovingUpwards = true
        Self.moveArc = true
        
        self.circleOffset = 20
        self.smallArcOffset = 16
        self.mediumArcOffset = 14.5
        self.largeArcOffset = 14
    }
    
    private func resetValues() {
        self.isAnimating.toggle()
        self.wifiHeaderLabel = "Searching"
        self.smallArcOffset -= 7.5
        self.circleOffset -= 15
        self.mediumArcOffset = -5.5
        self.largeArcOffset = -19
        self.isConnected = false
        self.arcColor = Color.white
        self.shadowColor = Color.blue
    }
}

// ArcView
extension WifiView {
    struct ArcView: View {
        var radius: CGFloat
        @Binding var fillColor: Color
        @Binding var shadowColor: Color

        var body: some View {
            ArcShape(radius: radius)
                .fill(fillColor)
                .shadow(color: shadowColor, radius: 5)
                .frame(height: radius)
                .animation(Animation.spring().speed(0.75))
                .onTapGesture {
                    self.fillColor = Color.wifiConnected
                }
        }
    }
}

// CircleEmitter
extension WifiView {
    struct CircleEmitter: View {
        @Binding var isAnimating: Bool
        
        var body: some View {
            ForEach(0 ..< 50) { ix in
                Circle()
                    .fill(Color.white.opacity(0.75))
                    .frame(width: 6, height: 6)
                    .offset(x: CGFloat.random(in: -250 ..< 250), y: CGFloat.random(in: -200 ..< 250))
                    .scaleEffect(self.isAnimating ? 1 : 0)
                    .animation(self.isAnimating ? Animation.easeInOut(duration: 0.125).delay(0.01 * Double(ix)) : .none)
            }
        }
    }
}

// ArcShape
extension WifiView {
    struct ArcShape : Shape {
        var radius: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius, startAngle: .degrees(220), endAngle: .degrees(320), clockwise: false)
            return p.strokedPath(.init(lineWidth: 6, lineCap: .round))
        }
    }
}

// Circles
extension WifiView {
    struct Circles : Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: rect.origin)
            for _ in 0 ..< 18 {
                let barHeight = CGFloat.random(in: 2.5 ..< 7)
                let barRect = CGRect(x: CGFloat.random(in: rect.minX ..< rect.midX),
                                     y: CGFloat.random(in: rect.minY ..< rect.midY),
                                     width: barHeight,
                                     height: barHeight)
                path.addRoundedRect(in: barRect, cornerSize: CGSize(width: barHeight / 2, height: barHeight / 2))
            }
            for _ in 0 ..< 18 {
                let barHeight = CGFloat.random(in: 2.5 ..< 7)
                let barRect = CGRect(x: CGFloat.random(in: rect.midX ..< rect.maxX),
                                     y: CGFloat.random(in: rect.minY ..< rect.midY),
                                     width: barHeight,
                                     height: barHeight)
                path.addRoundedRect(in: barRect, cornerSize: CGSize(width: barHeight / 2, height: barHeight / 2))
            }
            return path
        }
    }
}

// Color extension for custom colors
extension Color {
    static let wifiConnected = Color.green
    static let wifiBackground = Color.blue.opacity(0.3)
}

struct WifiView_Previews: PreviewProvider {
    static var previews: some View {
        WifiView()
    }
}
