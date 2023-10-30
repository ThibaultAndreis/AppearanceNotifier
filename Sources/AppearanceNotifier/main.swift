import AppKit
import Foundation
import ShellOut

private let kAppleInterfaceThemeChangedNotification = "AppleInterfaceThemeChangedNotification"

enum Theme {
    case light
    case dark
}

class ThemeChangeObserver {
    func observe() {
        print("Observing")

        DistributedNotificationCenter.default.addObserver(
            forName: Notification.Name(kAppleInterfaceThemeChangedNotification),
            object: nil,
            queue: nil,
            using: interfaceModeChanged(notification:)
        )
    }

    func interfaceModeChanged(notification _: Notification) {
        let themeRaw = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"

        let theme = notificationToTheme(themeRaw: themeRaw)!

        notify(theme: theme)

        respond(theme: theme)
    }
}

func notificationToTheme(themeRaw: String) -> Theme? {
    return {
        switch themeRaw {
        case "Light":
            return Theme.light
        case "Dark":
            return Theme.dark
        default:
            return nil
        }
    }()
}

func notify(theme: Theme) {
    print("\(Date()) Theme changed: \(theme)")
}

func respond(theme: Theme) {


        // Kitty ----------------------------------------------------------------
        DispatchQueue.global().async {
            print("\(Date()) kitty: sending command")

            let arguments = buildKittyArguments(theme: theme)

            do {
                try shellOut(to: "kitty", arguments: arguments)
            } catch {
                print("\(Date()) kitty: command failed")
            }
        }

    
}


func buildKittyArguments(theme: Theme) -> [String] {
    return [
        "+kitten",
        "themes",
        "--reload-in=all",
        "--config-file-name",
        "themes.conf",
        "\(getThemeName(theme: theme))",
    ]
}



func getThemeName(theme: Theme) -> String {
    return {
        switch theme {
        case .light:
            return "Rosé Pine Dawn"
        case .dark:
            return "Rosé Pine Moon"
        }
    }()
}

let app = NSApplication.shared

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        let observer = ThemeChangeObserver()
        observer.observe()
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
