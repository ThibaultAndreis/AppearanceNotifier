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


        // Ghostty ----------------------------------------------------------------
        DispatchQueue.global().async {
            print("\(Date()) Ghostty: sending command")

            let arguments = buildGhosttyArguments(theme: theme)

            do {
            let res =   try shellOut(to: "/usr/local/bin/theme-switcher.sh", arguments: arguments)
            print(res);
            } catch  {
                let error = error as! ShellOutError
                   print(error.message) // Prints STDERR
                   print(error.output) // Prints STDOUT
                fputs("\(error.message)\n", stderr)
                fputs("\(error.output)\n", stderr)
                
            }
        }

    
}


func buildGhosttyArguments(theme: Theme) -> [String] {
    return [
        "\(getThemeName(theme: theme))",
    ]
}



func getThemeName(theme: Theme) -> String {
    return {
        switch theme {
        case .light:
            return "light"
        case .dark:
            return "dark"
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
