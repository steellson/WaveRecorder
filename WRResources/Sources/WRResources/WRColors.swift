import UIKit

//MARK: - Colors

public enum WRColors {
    
    //MARK: Main
    public static let primaryBackground = UIColor(red: 183/255, green: 198/255, blue: 206/255, alpha: 1)
    public static let primaryBackgroundWithLowAlpha = UIColor(red: 183/255, green: 198/255, blue: 206/255, alpha: 0.3)
    public static let secondaryBackground = UIColor.white
    public static let secondaryBackgroundWithHighAlpha = UIColor.white.withAlphaComponent(0.8)
    public static let secondaryBackgroundWithLowAlpha = UIColor.white.withAlphaComponent(0.3)
    
    //MARK: Text
    public static let primaryText = UIColor.black
    public static let secondaryText = UIColor.darkGray
    public static let liteText = UIColor.gray 
    
    //MARK: Subviews
    public static let recoridngWaveLine = UIColor.systemRed
    public static let commonShadow = UIColor.black
    
    //MARK: Actions
    public static let positiveAction = UIColor.systemGreen.withAlphaComponent(0.3)
    public static let negativeAction = UIColor.systemBlue.withAlphaComponent(0.3)
    
    //MARK: Other
    public static let clear = UIColor.clear
}

