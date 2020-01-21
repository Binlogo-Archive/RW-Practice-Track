struct Stack<Element> {
	private var storage: [Element] = []
	
	mutating func push(_ element: Element) {
		storage.append(element)
	}
	
}

extension Stack: CustomStringConvertible {
	var description: String {
		return storage.map { "\($0)" }.joined(separator: " ")
	}
}