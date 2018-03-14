//
//  ViewController.swift
//  KolodaLooping-Test
//
//  Created by hanhyonsoo on 2018. 3. 10..
//  Copyright © 2018 hansoo.labs. All rights reserved.
//

import UIKit
import Koloda

class ViewController: UIViewController {

    private var kolodaView: MyKolodaView!
    private var dataView: UILabel!
    private var items = ["A", "B", "C", "D", "E", "F"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.8, alpha: 1)
        kolodaView = MyKolodaView()
        view.addSubview(kolodaView)
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        kolodaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        kolodaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        kolodaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 140).isActive = true
        kolodaView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        kolodaView.isLoop = true
        kolodaView.appearanceAnimationDuration = 0.23
        kolodaView.countOfVisibleCards = 3
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        kolodaView.layer.borderColor = UIColor.blue.cgColor
        kolodaView.layer.borderWidth = 1
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.text = """
        This is example for looping feature of Koloda
        Swipe Up: delete card (feature-looping+deletion branch)
        Swipe Down: show next card
        """
        
        dataView = UILabel()
        dataView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dataView)
        dataView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        dataView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        dataView.font = UIFont.systemFont(ofSize: 16, weight: .light)
        dataView.text = items.joined(separator: "  ")
    }
    
    func updateDataView(_ cursor: Int) {
        if dataView == nil {
            return
        }
        let m = items.enumerated().map { (offset, element) -> String in
            if offset == cursor {
                return element.uppercased()
            } else {
                return element.lowercased()
            }
        }
        dataView.text = m.joined(separator: "  ")
    }
}

extension ViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("kolodaDidRunOutOfCards")
        items = ["A", "B", "C", "D", "E", "F"]
        koloda.reloadData()
    }

    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }

    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return true
    }

    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        return true
    }
    func koloda(_ koloda: KolodaView, willSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print("willSwipeAt \(index)")
        if direction == .up && items.count > 0 {
            items.remove(at: index)
        }
        updateDataView(index)
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        print("didSwipeCardAt \(index)")
        // Remove card only swiped on upward
        
        if direction == .up && items.count > 0 {
            print("remove at index: \(index)")
            koloda.removeCardInIndexRange(index..<index+1, animated: false)
            
            let last = min(index + koloda.countOfVisibleCards, self.items.count)
            print("reload \(index) ..< \(last)")
            let range = index..<last
            koloda.reloadCardsInIndexRange(range)
            
            // FIXME: update background cards
            let realVisibleCount = min(koloda.countOfVisibleCards, self.items.count)
            if range.count < realVisibleCount {
                DispatchQueue.main.async {
                    let to = realVisibleCount - range.count
                    print("reload 0 ..< \(to)")
                    koloda.reloadCardsInIndexRange(0..<to)
                }
            }
        }
    }
    
    
}

extension ViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return items.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .slow
    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.down, .bottomLeft, .bottomRight, .up]
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        // print("viewForCardAt \(index)")
        let card = CardView()
        card.title.text = "\(items[index])"
        card.index.text = "index was \(index) at creation"
        return card
    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        print("didShowCardAt \(index)")
        updateDataView(index)
    }
}

class MyKolodaView : KolodaView {
    override func frameForCard(at index: Int) -> CGRect {
        let scalePercent = CGFloat(0.9)
        let width = CardView.defaultSize.width * pow(scalePercent, CGFloat(index))
        let xOffset = (self.frame.width - width) / 2
        let height = CardView.defaultSize.height * pow(scalePercent, CGFloat(index))
        var yOffset: CGFloat
        let frontCardOffsetY = CGFloat(30)
        if index == 0 {
            yOffset = frontCardOffsetY
        } else {
            yOffset = frontCardOffsetY - (8 * CGFloat(index))
        }
        return CGRect(x: xOffset, y: yOffset, width: width, height: height)
    }
}


private class CardView: UIView {

    static let defaultSize = CGSize(width: 290, height: 165)

    convenience public init() {
        self.init(frame: CGRect())
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
    }

    private(set) var title: UILabel!
    private(set) var index: UILabel!

    private func onInit() {

        self.clipsToBounds = false
        self.layer.shadowColor =
                UIColor(red: CGFloat(79 / 255.0), green: CGFloat(132 / 255.0), blue: CGFloat(213 / 255.0), alpha: CGFloat(1)).cgColor
        self.layer.drawsAsynchronously = true
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor.white

        title = UILabel()
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.topAnchor.constraint(equalTo: self.topAnchor, constant: 52).isActive = true
        title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22).isActive = true
        title.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        title.textColor = UIColor.black
        
        index = UILabel()
        self.addSubview(index)
        index.translatesAutoresizingMaskIntoConstraints = false
        index.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12).isActive = true
        index.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 22).isActive = true
        index.font = UIFont.systemFont(ofSize: 12, weight: .light)
        index.textColor = UIColor.darkGray

    }
}
