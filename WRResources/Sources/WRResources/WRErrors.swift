//MARK: Erorrs

public enum WRErrors {
    
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

