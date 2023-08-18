//
//  BMUtil.swift
//  MyBarApp
//
//  Created by 金泉斌 on 2023/7/30.
//

import Foundation

enum AppType: String {
  case femometer, fasting, faceyoga
}

enum DevOpsError: Error {
  case excuteError
}

class DevOps {
 
  var config = [String : Any]()
  
  var root = ""
  
  init() {
    localData()
  }
  
  private func localData() {
    config = localConfig()

    guard let sources = config["sources"] as? [String],
          !sources.isEmpty else { return }
    
    let index = config["sourceIndex"] as? Int ?? 0
    self.root = sources[index].trimmingCharacters(in: CharacterSet.newlines)
  }
  
  lazy var managerPath = "\(root)/devops/manager.sh"
  
  // MARK: Method
  
  func openProj() {
    runCommand("sh \(managerPath) open_project")
  }
  
  func updateDoc() {
    runCommand("sh \(managerPath) update_doc")
  }
  
  func install() {
    runCommand("sh \(managerPath) install")
  }
  
  func setApp(_ type: AppType) {
    runCommand("sh \(managerPath) setapp \(type.rawValue)")
  }
  
  func triggerPackage() {
    runCommand("sh \(managerPath) trigger -N \"daily-package\"")
  }
  
  func editConfig() {
    guard let configPath = Bundle.main.path(forResource: "Config", ofType: "plist") else {
      fatalError("Failed to load configuration file.")
    }

    runCommand("open \(configPath)")
  }
  
  // MARK: Private
  
  private func runCommand(_ cmd: String) {
    do {
      _ = try shell(cmd)
    } catch DevOpsError.excuteError {
      log("error occured")
    } catch {
      fatalError()
    }
  }
  
  // TODO: struct log item
  private func log(_ text: String) {
    print("[Shell]: \(text)")
  }
  
  @discardableResult
  private func shell(_ cmd: String) throws -> String {
    /// Read current process envirment info
    let processInfo = ProcessInfo()
    let envirment = processInfo.environment
    
    let task = Process()
    task.launchPath = "/bin/zsh"
    task.arguments = ["-c", cmd]
    task.environment = envirment
    
    if let path = config["PATH"] as? String {
      task.environment?["PATH"] = path
    }
    task.environment?["LANG"] = "en_US.UTF-8"
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
   
    log(output ?? "")
    
    if task.terminationStatus != 0 {
      throw DevOpsError.excuteError
    }
    
    return output ?? ""
  }
  
}
