import UIKit

public enum YeahRelation: Equatable {
    case equal
    case less
    case greater
    case toSuperview
}

extension UIView {
    @discardableResult
    public func make(_ a1: NSLayoutConstraint.Attribute,
                     _ relation: [YeahRelation] = .equal,
                     to a2: NSLayoutConstraint.Attribute = .notAnAttribute,
                     of v2: Any? = nil,
                     _ c: CGFloat = 0)  -> NSLayoutConstraint {
        return make(a1, relation, to: 1, a2, of: v2, c)
    }

    @discardableResult
    public func make(_ a1: NSLayoutConstraint.Attribute,
                     _ relation: [YeahRelation] = .equal,
                     to m: CGFloat,
                     _ a2: NSLayoutConstraint.Attribute = .notAnAttribute,
                     of v2: Any? = nil,
                     _ c: CGFloat = 0) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        (v2 as? UIView)?.translatesAutoresizingMaskIntoConstraints = false

        var a2 = a2
        if v2 != nil && a2 == .notAnAttribute {
            a2 = a1
        }

        var v2 = v2
        if relation.contains(.toSuperview) {
            if v2 == nil {
                v2 = superview
                if a2 == .notAnAttribute {
                    a2 = a1
                }
            } else {
                fatalError("WHEN SPECIFIED .toSuperview RELATION YOU MUST PROVIDE NIL AS A SECOND VIEW!")
            }
        }

        let constraint = NSLayoutConstraint.init(
            item: self,
            attribute: a1,
            relatedBy: relation.nsLayoutRelation,
            toItem: v2,
            attribute: a2,
            multiplier: m,
            constant: c
        )

		var secondView: UIView?
		if v2 == nil {
			secondView = nil
		} else if let view = v2 as? UIView {
			secondView = view
		} else if let guide = v2 as? UILayoutGuide {
			secondView = guide.owningView
		} else {
			fatalError("VIEW2 CANNOT BE USED IN LAYOUT CONSTRAINING! \(String(describing: v2))")
		}

		if let ancestor =  self.commonAncestor(with: secondView) {
			ancestor.addConstraint(constraint)
		} else {
			fatalError("VIEW1 AND VIEW2 MUST HAVE A COMMON ANCESTOR!\n\(self)\n\(String(describing: v2))")
		}

        return constraint
    }

    @discardableResult
    public func make(_ attribute: NSLayoutConstraint.Attribute,
                     _ relation: [YeahRelation] = .equal,
                     to v2: Any? = nil,
                     _ constant: CGFloat = 0) -> NSLayoutConstraint
    {
        return make(attribute, relation, to: 1, of: v2, constant)
    }

    @discardableResult
    public func make(_ attributes: [NSLayoutConstraint.Attribute],
                     _ relation: [YeahRelation] = .equal,
                     to v2: Any? = nil,
                     _ constants: [CGFloat] = []) -> [NSLayoutConstraint]
    {
        return make(attributes, relation, of: v2, constants)
    }

    @discardableResult
    public func make(_ attributes: [NSLayoutConstraint.Attribute],
                     _ relation: [YeahRelation] = .equal,
                     as multipliers: [CGFloat] = [],
                     _ correspondingAttributes: [NSLayoutConstraint.Attribute] = [],
                     of v2: Any? = nil,
                     _ constants: [CGFloat] = []) -> [NSLayoutConstraint]
    {
        var correspondingAttributes = correspondingAttributes
        if correspondingAttributes.isEmpty {
            correspondingAttributes = attributes
        }

        if attributes.count != correspondingAttributes.count {
            fatalError("ATTRIBUTE SETS MUST CONTAIN SAME AMOUNT OF ELEMENTS!")
        }

        var constants = constants
        if constants.isEmpty {
            constants = .init(repeating: 0, count: attributes.count)
        }

        if attributes.count != constants.count {
            fatalError("CONSTANTS MUST CORRESPOND ITS ATTRIBUTES!")
        }

        var multipliers = multipliers
        if multipliers.isEmpty {
            multipliers = .init(repeating: 1, count: attributes.count)
        }
        if attributes.count != multipliers.count {
            fatalError("MULTIPLIERS MUST CORRESPOND ITS ATTRIBUTES!")
        }

        var results = [NSLayoutConstraint]()

        for i in 0..<attributes.count {
            let a1 = attributes[i]
            let a2 = correspondingAttributes[i]
            let m = multipliers[i]
            let c = constants[i]

            let constraint = make(a1, relation, to: m, a2, of: v2, c)

            results.append(constraint)
        }

        return results
    }
}

private extension UIView {
    func commonAncestor(with view: UIView?) -> UIView? {
        guard let view = view else {
            return self
        }
        if self === view {
            return self
        }
        if self.orDescendants(contain: view) {
            return self
        }
        if view.orDescendants(contain: self) {
            return view
        }

        var ancestor: UIView?
        ancestor = self.ancestor(containing: view)
        ancestor = ancestor ?? view.ancestor(containing: self)

        return ancestor
    }

    func orDescendants(except e: UIView? = nil, contain view: UIView) -> Bool {
        for subview in subviews {
            if subview === view {
                return true
            }
            if let e = e, subview === e {
                continue
            }
            if subview.orDescendants(contain: view) {
                return true
            }
        }

        return false
    }

    func ancestor(containing view: UIView) -> UIView? {
        while let superview = superview {
            if superview.orDescendants(except: self, contain: view) {
                return superview
            }
        }

        return nil
    }
}

public extension Array where Element == NSLayoutConstraint.Attribute {
    static let center: [Element] = [.centerX, .centerY]
    static let edges: [Element] = [.top, .leading, .bottom, .trailing]
    static let size: [Element] = [.width, .height]
    static let hEdges: [Element] = [.leading, .trailing]
    static let vEdges: [Element] = [.top, .bottom]
    static func edges(except e: Element) -> Self {
        return edges.filter{ $0 != e }
    }
}

public extension Array where Element == YeahRelation {
    static let equalToSuperview: [Element] = [.equal, .toSuperview]
    static let lessThanOrEqualToSuperview: [Element] = [.equal, .less, .toSuperview]
    static let greaterThanOrEqualToSuperview: [Element] = [.equal, .greater, .toSuperview]
    static let equal: [Element] = [.equal]
    static let lessThanOrEqual: [Element] = [.equal, .less]
    static let greaterThanOrEqual: [Element] = [.equal, .greater]

    var nsLayoutRelation: NSLayoutConstraint.Relation {
        if self == .equalToSuperview || self == .equal {
            return .equal
        }
        if self == .lessThanOrEqualToSuperview || self == .lessThanOrEqual  {
            return .lessThanOrEqual
        }
        if self == .greaterThanOrEqualToSuperview || self == .greaterThanOrEqual {
            return .greaterThanOrEqual
        }
        fatalError("INCORRECT YEAH RELATION MASK \(self)")
    }
}

@discardableResult
public func ^(lhs: NSLayoutConstraint, rhs: Float) -> NSLayoutConstraint {
    lhs ^ UILayoutPriority.init(rhs)
    return lhs
}

@discardableResult
public func ^(lhs: [NSLayoutConstraint], rhs: Float) -> [NSLayoutConstraint] {
    lhs.forEach { $0 ^ rhs }
    return lhs
}

@discardableResult
public func ^(lhs: NSLayoutConstraint, rhs: UILayoutPriority) -> NSLayoutConstraint {
    let active = lhs.isActive
    lhs.isActive = false
    lhs.priority = rhs
    lhs.isActive = active
    return lhs
}

@discardableResult
public func ^(lhs: [NSLayoutConstraint], rhs: UILayoutPriority) -> [NSLayoutConstraint] {
    lhs.forEach { $0 ^ rhs }
    return lhs
}
