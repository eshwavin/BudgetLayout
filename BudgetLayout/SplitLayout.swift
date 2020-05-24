//
//  GridLayout.swift
//  BudgetLayout
//
//  Created by Srivinayak Chaitanya Eshwa on 24/05/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class SplitLayout: CardLayout {
    
    private weak var budgetList: BudgetList?
    
    weak var scrollView: UIScrollView?
    weak var detailsScrollView: UIScrollView?
    
    var cardViews: [CardView] = [] {
        didSet {
            self.calculateLayoutValues(shouldLayoutView: false)
        }
    }
    
    weak var presentedCardView: CardView? {
        didSet {
            oldValue?.isPresented = false
            presentedCardView?.isPresented = true
        }
    }
    
    weak var grabbedCardView: CardView?
    
    private var grabbedCardViewOriginalX: CGFloat = 0
    
    // MARK: Layout Properties for all in stack
    
    var contentInset: UIEdgeInsets {
        set {
            self.scrollView?.contentInset = UIEdgeInsets(top: 0, left: newValue.left, bottom: 0, right: 0 )
            self.cardViewTopInset = newValue.top
            self.cardViewLeadingInset = newValue.left
            self.cardViewTrailingInset = newValue.right
            self.cardViewBottomInset = newValue.bottom
            self.calculateLayoutValues()
        }
        get {
            return UIEdgeInsets(top: self.scrollView?.contentInset.top ?? 0, left: self.cardViewLeadingInset, bottom: self.scrollView?.contentInset.bottom ?? 0, right: self.cardViewTrailingInset)
        }
    }
    
    private var cardViewTopInset: CGFloat = 0
    private var cardViewLeadingInset: CGFloat = 0
    private var cardViewTrailingInset: CGFloat = 0
    private var cardViewBottomInset: CGFloat = 0
    private var collapsedCardViewStackHeight: CGFloat = 0
    private var cardViewHeight: CGFloat = 0
    private var cardViewWidth: CGFloat = 0
    private var distanceBetweenCardViews: CGFloat = 0
    
    // MARK: Layout Properties when interacting with CardViews
    
    var minimumDistanceBetweenStackedCardViews: CGFloat = 80 { didSet { self.calculateLayoutValues() } }
    var maximumNumberOfCollapsedCardViewsToShow: Int = 5 { didSet { self.calculateLayoutValues() } }
    var minimumDistanceBetweenCollapsedCardViews: CGFloat = 8 { didSet { self.calculateLayoutValues() } }
    var distanceBetweenCollapsedAndPresentedCardViews: CGFloat = 10 { didSet { self.calculateLayoutValues() } }
    var grabPopupOffset: CGFloat = 20 { didSet { self.calculateLayoutValues() } }
    
    // MARK: Setup
    
    init(scrollView: UIScrollView, detailsScrollView: UIScrollView ,budgetList: BudgetList) {
        self.scrollView = scrollView
        self.budgetList = budgetList
        self.detailsScrollView = detailsScrollView
    }
    
    deinit {
        self.cardViews = []
    }
        
    // MARK: Layout
    
    func calculateLayoutValues(shouldLayoutView: Bool = true) {
        
    }
    
    func updateScrollViewContentSize() {
        
    }
    
    func layoutCards(animationDuration: TimeInterval? = nil, animationOptions: UIView.KeyframeAnimationOptions = [.beginFromCurrentState, .calculationModeCubic], placeVisibleCardViews: Bool = true, completion: ((Bool) -> ())? = nil) {
        
    }
    
    func insert(cardViews: [CardView]) {
        
    }
    
    func grab(_ cardView: CardView, popup: Bool) {
        
    }
    
    func updateGrabbedCardView(to offset: CGPoint) {
        
    }
    
    func releaseGrabbedCardView() {
        
    }
    

}
