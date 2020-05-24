//
//  BudgetList.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 23/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class BudgetList: UIView {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.clipsToBounds = false
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.backgroundColor = UIColor.black // debug
        scrollView.accessibilityIdentifier = "scrollView" // debug
        
        return scrollView
    }()
    
    private let detailsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.backgroundColor = UIColor.systemPink // debug
        scrollView.accessibilityIdentifier = "detailsScrollView" // debug
        
        return scrollView
    }()

    var cardViews: [CardView] = [] {
        didSet {
            self.currentLayout?.insert(cardViews: self.cardViews)
        }
    }
    
    var currentLayout: CardLayout? {
        didSet {
            self.currentLayout?.insert(cardViews: self.cardViews)
        }
    }
    
    // MARK: Constraints
    
    private var scrollViewGridConstraints: [NSLayoutConstraint]?
    private var scrollViewNormalConstraints: [NSLayoutConstraint]?
    
    // MARK: Miscellaneous Properties
    
    private var didLayoutSubViewsForTheFirstTime: Bool = false
    private static var observerContext = 0
    
    // MARK: Layout Properties
    
    lazy var verticalCardLayout: VerticalCardLayout = {
        return VerticalCardLayout(scrollView: self.scrollView, budgetList: self)
    }()
    
    lazy var horizontalCardLayout: HorizontalCardLayout = {
        return HorizontalCardLayout(scrollView: self.scrollView, budgetList: self)
    }()
    
    lazy var splitCardLayout: SplitLayout = {
        return SplitLayout(scrollView: self.scrollView, detailsScrollView: self.detailsScrollView, budgetList: self)
    }()
    
    lazy var verticalLayoutContentInset: UIEdgeInsets = {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }()
    
    lazy var horizontalLayoutContentInset: UIEdgeInsets = {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }()
    
    
    
    // MARK: Initialisation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addObservers()
        self.prepareScrollView()
        self.setCardLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addObservers()
        self.prepareScrollView()
        self.setCardLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayoutSubViewsForTheFirstTime {
            self.currentLayout?.calculateLayoutValues()
        }
    }
    
    private func prepareScrollView() {
        
        self.addSubview(self.scrollView)
        
        self.constrainScrollView()
        
    }
    
    // MARK: Layout
    
    private func setCardLayout() {
        
        switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass) {
        case (.regular, .compact), (.compact, .compact):
            
            // 1. Constrain scrollView if required
            if let _ = self.currentLayout as? SplitLayout {
                self.constrainScrollView()
            }
            
            // 2. Set new layout and transfer presented view
            let presentedCardView = self.currentLayout?.presentedCardView
            
            self.currentLayout = self.verticalCardLayout
            self.currentLayout?.presentedCardView = presentedCardView
            
            // 3. Set contentInset
            self.currentLayout?.contentInset = self.verticalLayoutContentInset
            
            // 4. Set scrollView scrolling direction
            self.scrollView.alwaysBounceVertical = true
            self.scrollView.alwaysBounceHorizontal = false
            
        case (.compact, .regular):
            
            // 1. Constrain scrollView if required
            if let _ = self.currentLayout as? SplitLayout {
                self.constrainScrollView()
            }
            
            // 2. Set new layout and transfer presented view
            let presentedCardView = self.currentLayout?.presentedCardView
            
            self.currentLayout = self.horizontalCardLayout
            self.currentLayout?.presentedCardView = presentedCardView
            
            // 3. Set contentInset
            self.currentLayout?.contentInset = self.horizontalLayoutContentInset
            
            // 4. Set scrollView scrolling direction
            self.scrollView.alwaysBounceVertical = false
            self.scrollView.alwaysBounceHorizontal = true
        
        case (.regular, .regular):
            
            // 1. Constrain both scroll views as
            self.constrainScrollViewsForGridLayout()
            
            self.currentLayout = self.splitCardLayout
            
        default:
            ()
        }
        
    }
    
    
    private func constrainScrollView() {
        
        // remove detailsScrollView From superview
        self.detailsScrollView.removeFromSuperview()
        
        NSLayoutConstraint.deactivate(self.scrollViewGridConstraints ?? [])
        
        if self.scrollViewNormalConstraints == nil {
            self.scrollViewNormalConstraints = [
                self.scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                self.scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
                self.scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
                self.scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(scrollViewNormalConstraints ?? [])
        
    }
    
    private func constrainScrollViewsForGridLayout() {
        
        NSLayoutConstraint.deactivate(self.scrollViewNormalConstraints ?? [])
        
        if self.scrollViewGridConstraints == nil {
            self.scrollViewGridConstraints = [
                self.scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                self.scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
                self.scrollView.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 1/3),
                self.scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(self.scrollViewGridConstraints ?? [])
        
        self.addSubview(self.detailsScrollView)
        
        let detailsScrollViewConstraints = [
            self.detailsScrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.detailsScrollView.leadingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.detailsScrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.detailsScrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(detailsScrollViewConstraints)
    }
    
    // MARK: Observers
    
    func addObservers() {
        
        let options: NSKeyValueObservingOptions = [.new, .old, .initial]

        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.frame), options: options, context: &BudgetList.observerContext)
        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.bounds), options: options, context: &BudgetList.observerContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &BudgetList.observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(UIScrollView.bounds) {
            self.currentLayout?.layoutCards()
        } else if keyPath == #keyPath(UIScrollView.frame) {
            self.currentLayout?.calculateLayoutValues()
        }
    }
    
    // MARK: Handling Orientation Changes
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        self.didLayoutSubViewsForTheFirstTime = true
        
        if traitCollection.horizontalSizeClass == previousTraitCollection?.horizontalSizeClass && traitCollection.verticalSizeClass == previousTraitCollection?.verticalSizeClass {
            return
        }
        
        self.setCardLayout()
        
    }
    
}
