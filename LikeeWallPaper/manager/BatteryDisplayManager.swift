import Foundation

class PowerManagement {
    static let shared = PowerManagement()
    // ac 休眠时间
    var acSleepTime = getDisplaySleepTimes()[1]
    // battery 休眠时间
    var batterySleepTime = getDisplaySleepTimes()[0]
    //
    var offset = 20
    private init() {}

    // 执行 shell 命令并返回结果
    private static func runShellCommand(_ command: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        let handle = pipe.fileHandleForReading

        do {
            try process.run()
            let data = handle.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error executing command: \(error)")
            return nil
        }
    }

    // 使用 grep 获取 displaysleep 设置
    //[Battery, AC Power]
    private static func getDisplaySleepTimes() -> [Int] {
        var displaySleepTimes: [Int] = []

        // 执行 pmset -g custom 命令并使用 grep 提取 displaysleep
        if let output = runShellCommand("pmset -g custom | grep displaysleep") {
            let lines = output.split(separator: "\n")
            for line in lines {
                // 使用范围查找并提取显示休眠时间
                if let range = line.range(of: "displaysleep") {
                    let timeString = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if let time = Int(timeString) {
                        displaySleepTimes.append(time * 60)
                    }
                }
            }
        }
        
        return displaySleepTimes
    }


}
