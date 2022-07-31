protocol RedundantProtocol {
}

public class SomeClass: RedundantProtocol {
    enum SomeEnum {
        case usedCase
        case unusedCase
    }

    var unusedProperty = 0
    private var assignOnlyProperty = 0


    public func methodWithRedundantPublicAccessibility(_ unusedParameter: Int) {
        assignOnlyProperty = 0
        _ = SomeEnum.usedCase
    }

    func unusedMethod() {
    }
}

SomeClass().methodWithRedundantPublicAccessibility(0)
