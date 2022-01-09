import UIKit

extension UIView {
	@discardableResult
	public func make(_ a1: NSLayoutConstraint.Attribute,
					 _ relation: NSLayoutConstraint.Relation,
					 to a2: NSLayoutConstraint.Attribute = .notAnAttribute,
					 of v2: UIView? = nil,
					 _ c: CGFloat = 0)  -> NSLayoutConstraint {
		return make(a1, relation, to: 1, a2, of: v2, c)
	}

	@discardableResult
	public func make(_ a1: NSLayoutConstraint.Attribute,
					 _ relation: NSLayoutConstraint.Relation,
					 to m: CGFloat,
					 _ a2: NSLayoutConstraint.Attribute = .notAnAttribute,
					 of v2: UIView? = nil,
					 _ c: CGFloat = 0) -> NSLayoutConstraint {
		
		self.translatesAutoresizingMaskIntoConstraints = false
		v2?.translatesAutoresizingMaskIntoConstraints = false
		
		var a2 = a2
		if v2 != nil && a2 == .notAnAttribute {
			a2 = a1
		}
		
		let constraint = NSLayoutConstraint.init(
			item: self,
			attribute: a1,
			relatedBy: relation,
			toItem: v2,
			attribute: a2,
			multiplier: m,
			constant: c
		)
		
		guard let ancestor = self.commonAncestor(with: v2) else {
			fatalError("VIEW1 AND VIEW2 MUST HAVE A COMMON ANCESTOR!\n\(self)\n\(String(describing: v2))")
		}
		
		ancestor.addConstraint(constraint)
		
		return constraint
	}

	@discardableResult
	public func make(_ attribute: NSLayoutConstraint.Attribute,
					 _ relation: NSLayoutConstraint.Relation,
					 to v2: UIView? = nil,
					 _ constant: CGFloat = 0) -> NSLayoutConstraint {
		
		return make(attribute, relation, to: 1, of: v2, constant)
	}

	@discardableResult
	public func make(_ attributes: [NSLayoutConstraint.Attribute],
					 _ relation: NSLayoutConstraint.Relation,
					 to v2: UIView? = nil,
					 _ constants: [CGFloat] = [0]) -> [NSLayoutConstraint] {
		
		return make(attributes, relation, of: v2, constants)
	}

	@discardableResult
	public func make(_ attributes: [NSLayoutConstraint.Attribute],
					 _ relation: NSLayoutConstraint.Relation,
					 to multipliers: [CGFloat] = [1],
					 _ correspondingAttributes: [NSLayoutConstraint.Attribute] = [],
					 of v2: UIView? = nil,
					 _ constants: [CGFloat] = [0]) -> [NSLayoutConstraint] {
		
		var correspondingAttributes = correspondingAttributes
		if correspondingAttributes.isEmpty {
			correspondingAttributes = attributes
		}
		
		if attributes.count != correspondingAttributes.count {
			fatalError("ATTRIBUTE SETS MUST CONTAIN SAME AMOUNT OF ELEMENTS!")
		}
		
		var constants = constants
		if constants.count == 1 {
			constants = .init(repeating: constants[0], count: attributes.count)
		}
		
		if attributes.count != constants.count {
			fatalError("CONSTANTS MUST CORRESPOND ITS ATTRIBUTES!")
		}
		
		var multipliers = multipliers
		if multipliers.count == 1 {
			multipliers = .init(repeating: multipliers[0], count: attributes.count)
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

public extension UIView {
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
	static let hEdges: [Element] = [.leading, .trailing]
	static let vEdges: [Element] = [.top, .bottom]
	static func edges(except e: Element) -> Self {
		return edges.filter{ $0 != e }
	}
}

