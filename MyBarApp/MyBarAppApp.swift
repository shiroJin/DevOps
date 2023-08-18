//
//  MyBarAppApp.swift
//  MyBarApp
//
//  Created by 金泉斌 on 2023/7/27.
//

import SwiftUI
import UserNotifications

@main
struct MyBarAppApp: App {
  
  @State var isExcuting = false
  @State var appType: AppType = .fasting
  @State var sources: [String] = {
    let config = localConfig()
    let items = config["sources"] as? [String]
    return items ?? []
  }()
  
  let devops = DevOps()
  
  init() {
    UNUserNotificationCenter.current().requestAuthorization { _, _ in
      
    }
  }
  
  var body: some Scene {
    MenuBarExtra("\(isExcuting ? "🚧" : "") DevOps") {
      Button("Open project") {
        devops.openProj()
      }
      .keyboardShortcut("o")
      
      Menu("Switch App") {
        Button("fasting") {
          devops.setApp(.fasting)
        }
        Button("femometer") {
          devops.setApp(.femometer)
        }
      }
      
      Button("Update doc") {
        excute {
          devops.updateDoc()
        }
      }
      .keyboardShortcut("u")
      
      Button("Pod install") {
        excute {
          devops.install()
        }
      }
      .keyboardShortcut("i")
     
      Divider()
     
      Menu("Publish") {
        Button("EasyInstall") {
          excute {
            devops.triggerPackage()
          }
        }
        Button("Prod") {
          excute {
            devops.triggerPackage()
          }
        }
      }
            
      Divider()
      
      Menu("Settings") {
        Menu("Sources") {
          ForEach(sources, id: \.self) { item in
            Button(item) {
              devops.root = item.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
          }
        }

        Button("Edit") {
          devops.editConfig()
        }
        
        Button("Reload config") {
          if let sources = localConfig()["sources"] as? [String] {
            self.sources = sources
          }
        }
      }
      
      Button("Exit") {
        NSApplication.shared.terminate(nil)
      }
      .keyboardShortcut("q")
      
    }
  }
  
  private func excute(_ task: @escaping () -> ()) {
    isExcuting = true
    DispatchQueue.global().async {
      task()
      DispatchQueue.main.async {
        isExcuting = false
      }
    }
  }
  
  
}

func localConfig() -> [String : Any] {
  guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
        let configData = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
        let config = try? PropertyListSerialization.propertyList(from: configData, format: nil) as? [String: Any] else {
    fatalError("Failed to load configuration file.")
  }
  return config
}
