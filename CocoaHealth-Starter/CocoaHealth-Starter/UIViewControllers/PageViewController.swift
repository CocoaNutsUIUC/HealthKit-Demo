//
//  PageViewController.swift
//  CocoaHealth-Starter
//
//  Created by Steven Shang on 9/8/18.
//  Copyright © 2018 cocoanuts. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    private let orderedIdentifiers = ["BMIViewController", "activityViewController"]
    
    private lazy var orderedViewControlelrs: [UIViewController] = {
        return orderedIdentifiers.map({ instantiateViewController(identifier: $0) })
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource = self
        guard let firstVC = orderedViewControlelrs.first else {
            fatalError("Initial view controller cannot be instantiated!")
        }
        setViewControllers([firstVC],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        // UIPageViewController's background color will seep through. Set it to the same color as all view controllers.
        self.view.backgroundColor = UIColor.yellow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func instantiateViewController(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }

}

extension PageViewController: UIPageViewControllerDataSource {
    
    private func indexInRange(index: Int) -> Bool {
        return index > 0 && index < orderedViewControlelrs.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentVCIndex = orderedViewControlelrs.index(of: viewController) else {
            print("Cannot find current view controller.")
            return nil
        }
        let lastVCIndex = orderedViewControlelrs.index(before: currentVCIndex)
        guard indexInRange(index: lastVCIndex) else {
            return nil
        }
        return orderedViewControlelrs[lastVCIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentVCIndex = orderedViewControlelrs.index(of: viewController) else {
            print("Cannot find current view controller.")
            return nil
        }
        let nextVCIndex = orderedViewControlelrs.index(after: currentVCIndex)
        guard indexInRange(index: nextVCIndex) else {
            return nil
        }
        return orderedViewControlelrs[nextVCIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControlelrs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

}
