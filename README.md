# YeahLayout
iOS constraint maker you always wanted. Write constraints like sentences in English.</br>
Simple. Intuitive. No frightening abstractions. One file.

* You want your ```view```'s height to be equal to width of other view? Here you go: ```view.make(.height, .equal, to: .width, of: otherView)```
* Or some ```view```'s width to be 100? Even simpler: ```someView.make(.width, .equal, 100)```
* Place a view under upper view? You are welcome: ```someView.make(.top, .equal, to: .bottom, of: upperView, +20)```
* Manage several layout attributes at once, set multipliers and insets? Also possible:  ```view.make([.leading, .trailing], .equal, to: [0.5, 0.8], of: otherView, [20, -20]) ```
* Set your constraint's priority? There is a ```*=``` operator: ```view.make(.height, .equal, 44) *= 750```

Every ```make``` method and ```*=``` operator returns you one (or more) ```NSLayoutConstraint```'s you can store for later use.
