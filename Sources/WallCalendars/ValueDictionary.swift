import Foundation
import Capsule

indirect enum Value: Equatable, Hashable {
	case string(String)
	case integer(Int)
	case date(Date)
	case boolean(Bool)
	case dictionary(ValueDictionary)
	case array([Value])
}

typealias ValueDictionary = HashMap<String, Value>
