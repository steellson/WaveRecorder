//MARK: Erorrs

public enum WRErrors {
    
    //MARK: Main View Model
    public static let cantGetRecordsFromStorage = "ERROR <MainViewModel>: Cant get records from storage! "
    public static let cantRenameRecord = "ERROR <MainViewModel>: Cant rename record! "
    public static let cantSearchRecordsWithText = "ERROR <MainViewModel>: Cant search records with text: "
    public static let cantDeleteRecordWithName = "ERROR <MainViewModel>: Cant delete record with name "
    public static let notificationCouldntBeActivated = "ERROR <MainViewModel>: Notification couldnt be activated"
    public static let notificationCouldntBeRemoved = "ERROR <MainViewModel>: Notification couldnt be removed"
    
    //MARK: Main View
    public static let cantDequeReusableCell = "ERROR <MainView>: Cant dequeue reusable cell"
    public static let tableViewModelIsntSetted = "ERROR <MainView>: There is no viewModel for TableView now"
    public static let wrongFieldResponder = "ERROR <MainView>: Wrong field responder"
    
    //MARK: Main Table View Cell
    public static let cellIsNotConfigured = "ERROR <MainCell>: Cell is not configured!"
    
    //MARK: Edit View
    public static let editViewModelIsNotSetted = "ERROR <EditView>: EditViewModel isn't setted!"
    
    //MARK: Play View Model
    public static let audioIsAlreadyPlaying = "ERROR <PlayViewModel>: Audio is already playing!"
    public static let playViewModelIsNotSetted = "ERROR <PlayViewModel>: PlayViewModel isn't setted!"
    public static let cantPlayAudio = "ERROR <PlayViewModel>: Cant play audio!"
    public static let cantStopAudio = "ERROR <PlayViewModel>: Cant stop audio!"
    
    //MARK: Play View
    public static let playButtonsActionCorrupted = "ERROR <PlayToolbarView>: Play buttons action error!"
    
    //MARK: Video Section View
    public static let videoRecordUrlNotFound = "ERROR <VideoSectionView>: Video record url is not found, section configured with empty!"
}

