import XCTest
@testable import Stack

final class StackTests: XCTestCase {
    var stack = Stack<Int>()

    func testPush() {
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.push(4)
        stack.push(5)
        XCTAssertEqual(stack.description, "1 2 3 4 5")
        XCTAssertNotEqual(stack.description, "")
    }

      func test_pop() {
    XCTAssertEqual(stack.pop(), 4)
  }

    static var allTests = [
        ("testPush", testPush),
    ]
}
