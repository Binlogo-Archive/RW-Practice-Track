/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import RealmSwift

struct Exams {

  // MARK: - copy a file
  static func copyInitialData(_ from: URL, to: URL) {
    let copy = {
      _ = try? FileManager.default.removeItem(at: to)
      try! FileManager.default.copyItem(at: from, to: to)
    }

    let exists: Bool
    do {
      exists = try to.checkPromisedItemIsReachable()
    } catch {
      copy()
      return
    }
    if !exists {
      copy()
    }
  }

  // MARK: - migration helpers

  fileprivate static var migratedStatuses: [String: MigrationObject]?

  fileprivate static func addOrReuseStatus(_ migration: Migration, text: String) -> MigrationObject {
    if let existingStatus = migratedStatuses?[text] {
      return existingStatus
    } else {
      let status = migration.create("Status", value: ["status": text])
      migratedStatuses?[text] = status
      return status
    }
  }

  // MARK: - migration
  static func migrate(_ migration: Migration, fileSchemaVersion: UInt64) {

    migratedStatuses = [:]

    if fileSchemaVersion == 1 {
      print("migrate from version 1")

      let now = Date()
      let thePast = Date(timeIntervalSince1970: 0)

      migration.enumerateObjects(ofType: "Exam", { oldObject, newObject in

        var statuses = [MigrationObject]()

        if let newObject = newObject {
          if let date = newObject["date"] as? Date {

            let statusText: String

            if date.compare(now) == .orderedDescending {
              statusText = "pending"
            } else {
              statusText = "completed"
            }

            let completeness = migration.create("Status",
                                                value: ["status": statusText])
            statuses.append(completeness)
          }

          newObject["icon"] = "🙈"
          
          if let oldObject = oldObject,
            let multi = oldObject["multipleChoice"] as? Bool, multi {
            //newObject["name"] = "\(newObject["name"]!)(multiple choice)"
            let multipleChoice = addOrReuseStatus(migration, text: "multiple choice")
            statuses.append(multipleChoice)
          }

          // fix broken dates
          if let date = newObject["date"] as? NSDate,
            date.compare(thePast) == .orderedAscending {
            newObject["date"] = now
          }

          newObject["statuses"] = statuses
        }
      })
    }

    if fileSchemaVersion == 2 {
      print("migrate from 2 to 3")

      migration.renameProperty(onType: "Exam", from: "emoji", to: "icon")

      migration.enumerateObjects(ofType: "Exam", { oldObject, newObject in
        if let newObject = newObject, let statusText = oldObject?["status"] as? String {
          let completeness = addOrReuseStatus(migration, text: statusText)
          newObject["statuses"] = [completeness]
        }
      })
    }

    migratedStatuses = nil
  }

}
