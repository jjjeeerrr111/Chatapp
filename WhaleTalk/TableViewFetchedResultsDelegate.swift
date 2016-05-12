//
//  TableViewFetchedResultsDelegate.swift
//  WhaleTalk
//
//  Created by Jeremy Sharvit on 2016-05-12.
//  Copyright © 2016 com.whaletalk. All rights reserved.
//

import UIKit
import CoreData

class TableViewFetchedResultsDelegate: NSObject, NSFetchedResultsControllerDelegate {

    
    private var tableView :UITableView!
    private var displayer : TableViewFetchedResultsDisplayer!
    
    init(tableView: UITableView, displayer: TableViewFetchedResultsDisplayer) {
        self.tableView = tableView
        self.displayer = displayer
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            displayer.configureCell(cell!, atIndexPath: indexPath!)
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    
}


protocol TableViewFetchedResultsDisplayer {
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
}