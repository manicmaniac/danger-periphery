protocol RedundantProtocol {
}

class SomeClass: RedundantProtocol {
    enum SomeEnum {
        case usedCase
        case unusedCase
    }

    var unusedProperty = 0
    private var assignOnlyProperty = 0


    public func functionWithRedundantPublicAccessibility(_ unusedParameter: Int) {
        assignOnlyProperty = 0
        _ = SomeEnum.usedCase
    }

    func unusedFunction() {
    }
}

SomeClass().functionWithRedundantPublicAccessibility(0)
