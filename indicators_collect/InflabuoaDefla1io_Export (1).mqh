//+------------------------------------------------------------------+
//| Export functions and utilities for InflabuoaDefla1io indicator    |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Files/FileTxt.mqh>
#include <Tools/DateTime.mqh>

#property copyright "Copyright 2023-24, Xaunomad - Hydra Group"
#property link      "https://www.instagram.com/xaunomad/"
#property version   "3.6"

// Function declarations
class CInflabuoaDefla1io_Export
{
public:
    static bool CreateExportButton();
    static bool ExportToJson(double &arrUSD[], double &arrEUR[], double &arrGBP[],
                           double &arrJPY[], double &arrAUD[], double &arrCAD[],
                           double &arrNZD[], double &arrCHF[], datetime &time[],
                           int maxBars);
private:
    static string TimeToStr(datetime time) { return TimeToString(time); }
};

// Implementation of export functions
bool CInflabuoaDefla1io_Export::CreateExportButton()
{
    string buttonName = "ExportButton";
    
    if(ObjectFind(0, buttonName) >= 0)
        ObjectDelete(0, buttonName);
        
    if(!ObjectCreate(0, buttonName, OBJ_BUTTON, 0, 0, 0))
    {
        Print("Error creating button: ", GetLastError());
        return false;
    }
    
    ObjectSetString(0, buttonName, OBJPROP_TEXT, "Export Data");
    ObjectSetInteger(0, buttonName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, buttonName, OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, buttonName, OBJPROP_XSIZE, 100);
    ObjectSetInteger(0, buttonName, OBJPROP_YSIZE, 30);
    ObjectSetInteger(0, buttonName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, buttonName, OBJPROP_BGCOLOR, clrDarkGray);
    ObjectSetInteger(0, buttonName, OBJPROP_COLOR, clrWhite);
    
    return true;
}

bool CInflabuoaDefla1io_Export::ExportToJson(double &arrUSD[], double &arrEUR[], double &arrGBP[],
                                           double &arrJPY[], double &arrAUD[], double &arrCAD[],
                                           double &arrNZD[], double &arrCHF[], datetime &time[],
                                           int maxBars)
{
    string filename = "InflabuoaDefla1io_" + Symbol() + "_" + 
                     EnumToString((ENUM_TIMEFRAMES)Period()) + "_" + 
                     TimeToString(TimeCurrent(), TIME_DATE) + ".json";
    
    string commonPath = "Data\\InflabuoaDefla1io";
    if(!FolderCreate(commonPath))
    {
        int error = GetLastError();
        if(error != 4301) // Directory already exists
        {
            Print("Failed to create directory: ", error);
            return false;
        }
    }
    
    int handle = FileOpen(commonPath + "\\" + filename, FILE_WRITE|FILE_TXT|FILE_ANSI);
    
    if(handle == INVALID_HANDLE)
    {
        Print("Failed to open file: ", GetLastError());
        return false;
    }
    
    // Write enhanced JSON header with metadata
    FileWrite(handle, "{");
    FileWrite(handle, "  \"metadata\": {");
    FileWrite(handle, "    \"indicator\": \"InflabuoaDefla1io\",");
    FileWrite(handle, "    \"version\": \"" + version + "\",");
    FileWrite(handle, "    \"symbol\": \"" + Symbol() + "\",");
    FileWrite(handle, "    \"timeframe\": \"" + EnumToString((ENUM_TIMEFRAMES)Period()) + "\",");
    FileWrite(handle, "    \"export_time\": \"" + TimeToString(TimeCurrent()) + "\",");
    FileWrite(handle, "    \"bars_exported\": " + IntegerToString(maxBars));
    FileWrite(handle, "  },");
    FileWrite(handle, "  \"data\": [");
    
    // Write data points with improved formatting
    for(int i = 0; i < maxBars && i < ArraySize(arrUSD); i++)
    {
        string comma = (i < maxBars-1 && i < ArraySize(arrUSD)-1) ? "," : "";
        
        string json_line = StringFormat(
            "    {\"time\": \"%s\", \"values\": {\"USD\": %.5f, \"EUR\": %.5f, \"GBP\": %.5f, \"JPY\": %.5f, \"AUD\": %.5f, \"CAD\": %.5f, \"NZD\": %.5f, \"CHF\": %.5f}}%s",
            TimeToString(time[i]),
            arrUSD[i], arrEUR[i], arrGBP[i],
            arrJPY[i], arrAUD[i], arrCAD[i],
            arrNZD[i], arrCHF[i],
            comma
        );
        
        FileWrite(handle, json_line);
    }
    
    // Close JSON structure
    FileWrite(handle, "  ]");
    FileWrite(handle, "}");
    
    FileClose(handle);
    Print("Data exported to: ", commonPath + "\\" + filename);
    return true;
} 