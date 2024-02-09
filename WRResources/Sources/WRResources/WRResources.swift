import UIKit


//MARK: Titles

public enum RTitles {
    
    //MARK: Main Screen
    public static let navigationTitleMain = "All records"
    public static let editButtonTitle = "Edit"
    public static let stopEditButtonTitle = "Cancel"
    public static let searchTextFieldPlaceholder = "Search"
}


//MARK: Identity

public enum RIdentifiers {
    public static let cellIdentifier = "RecordsCellIdentifier"
}


//MARK: Logs

public enum RLogs {
    public static let recordDeleted = "SUCCESS: Record deleted. Name: "
    public static let searchedRecordsEmpty = "ATTENTION: Searched records is empty!"
}


//MARK: Erorrs

public enum RErrors {
    
    //MARK: Main View Model
    public static let cantGetRecordsFromStorage = "ERROR: Cant get records from storage! "
    public static let cantRenameRecord = "ERROR: Cant rename record! "
    public static let cantSearchRecordsWithText = "ERROR: Cant search records with text: "
    public static let cantDeleteRecordWithName = "ERROR: Cant delete record with name "
    public static let notificationCouldntBeActivated = "ERROR: Notification couldnt be activated"
    public static let notificationCouldntBeRemoved = "ERROR: Notification couldnt be removed"
    
    //MARK: Main View
    public static let cantDequeReusableCell = "ERROR: Cant dequeue reusable cell"
    public static let wrongFieldResponder = "ERROR: Wrong field responder"
    
    //MARK: Main Table View Cell
    public static let cellIsNotConfigured = "ERROR: Cell is not configured!"
    
    
    //MARK: Edit View
    public static let editViewModelIsNotSetted = "ERROR: EditViewModel isn't setted!"
    
    
    
    //MARK: Play View Model
    public static let audioIsAlreadyPlaying = "ERROR: Audio is already playing!"
    public static let playViewModelIsNotSetted = "ERROR: PlayViewModel isn't setted!"
    
    //MARK: Play View
    public static let playButtonsActionCorrupted = "ERROR: Play buttons action error!"
}


//MARK: - Colors

public enum RColors {
    public static let primaryBackgroundColor = UIColor(red: 183/255, green: 198/255, blue: 206/255, alpha: 1)
    public static let secondaryBackgroundColor = UIColor.white
}

