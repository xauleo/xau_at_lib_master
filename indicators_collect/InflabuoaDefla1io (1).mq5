//+------------------------------------------------------------------+
//|                                        Inflation & Deflation.mq5 |
//|                        Copyright 2023-24, Xaunomad - Hydra Group |
//|                                                   myIG: XAUNOMAD |
//+------------------------------------------------------------------+
//
// Parts based on CCFp.mq4, downloaded from mql4.com
// TMA Calculations © 2012 by ZZNBRM
// again added CHF as requested by milanese
//23 may,2014 modified for use without CHF milanese
//14 may,2014 modified milanese
//12/04/2014 added alerts by milanese
//09/04/2014 6xx build version by milanese
#property copyright "Copyright 2023-24, Xaunomad - Hydra Group"
#property link      "https://www.instagram.com/xaunomad/"
#property strict
//----
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 8

#define version            "v3.6"

#property indicator_type1  DRAW_LINE
#property indicator_type2  DRAW_LINE
#property indicator_type3  DRAW_LINE
#property indicator_type4  DRAW_LINE
#property indicator_type5  DRAW_LINE
#property indicator_type6  DRAW_LINE
#property indicator_type7  DRAW_LINE
#property indicator_type8  DRAW_LINE
//+------------------------------------------------------------------+
//| Release Notes                                                    |
//+------------------------------------------------------------------+
// v1.0.0 (alpha), 6/1/12
// * Added support to auto create symbolnames
// * Added 'maxBars' setting to limit number of history bars calculated and improve performance
// v1.0.0, 6/4/12
// * BUG: added (almost) unique identifier for objects to get multiple instances in one window (thanks, Verb)
// * New default for user setting 'SymbolsToWeigh', it now has all symbols that the NanningBob 10.2 system looks at
// v1.0.1, 6/11/12
// * Added a alert for crosses of the Currency Slope Strength
// * Added user settings for the colo(u)r of weak, normal and strong cross alerts.
// * Added user setting 'autoTimeFrame' to use timeframe on chart. If set to false setting 'timeFrame' is used.
// * User can now set all timeframes.
// v1.0.2, 6/12/12
// * Added option to disable so-called 'repainting', that is not to consider future bars for any calculation
// * Changed indicator short name
// * Code optimization
// v1.0.3, 6/26/12
// * Improved display format for 'showOnlySymbolsOnChart' is set to 'true'
// * Added background indicator line for difference of two Slope lines, difference must be over threshold
// v1.0.4, 12/4/12
// * Fixed bug in 'showOnlySymbolsOnChart' logic, thanks George
// v1.0.5, 3/28/13
// * Merged code from SlopeValues
// * Exclude symbols the broker does not offer
// v1.0.6, 4/17/13
// * Added timeframe in display table
// v1.0.7, 4/26/13
// * Fixed issue for single symbol use
// * Introduced user variable for single symbol use
// * Introduced multi colored background for single symbol use
// v1.0.8, 8/19/13
// * Optimized code
// v1.0.9, 12/4/13
// * Changed output format to correct datetime when autoTimeFrame is false
// v1.0.10NB, 1/9/14
// * Added level cross option
// v1.0.11, 2/3/14
// * Added extra timeframe/table
//updated 5/14/2014

#include "InflabuoaDefla1io_Export.mqh"

#define CURRENCYCOUNT      8

//---- parameters

input string  gen               = "----General inputs----";
input bool    autoSymbols       = false;
input string  symbolsToWeigh    = "AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADJPY,CHFJPY,EURAUD,EURCAD,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";//CADCHF,NZDCAD,EURCHF,EURGBP,
input int     maxBars           = 200;
input bool    weighOnlySymbolOnChart = false;
input string  nonPropFont       = "Lucida Console";
input bool    addSundayToMonday = true;
input bool    showOnlySymbolOnChart = false;

input string  ind               = "----Indicator inputs----";
input bool    autoTimeFrame     = true;
input string  ind_tf            = "timeFrame M1,M5,M15,M30,H1,H4,D1,W1,MN";
input string  timeFrame         = "D1";
input string  extraTimeFrame    = "D1";
input bool    ignoreFuture      = true;
input bool    showCrossAlerts   = true;
input double  differenceThreshold= 0.0;
input bool    showLevelCross    = true;
input double  levelCrossValue   = 0.20;
input bool      PopupAlert=true;
input bool      EmailAlert= false;
input bool      PushAlert=false;

input string  cur               = "----Currency inputs----";
input bool    USD               = true;
input bool    EUR               = true;
input bool    GBP               = true;
input bool    CHF               = true;
input bool    JPY               = true;
input bool    AUD               = true;
input bool    CAD               = true;
input bool    NZD               = true;

input string  exp               = "----Export Settings----";
input bool    ShowExportButton  = true;     // Show export button
int     ExportMaxBars     = maxBars;      
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string  colour              = "----Colo(u)r inputs----";
input color   Color_USD         = Red;
input color   Color_EUR         = DeepSkyBlue;
input color   Color_GBP         = RoyalBlue;
input color   Color_CHF         = PaleTurquoise;
input color   Color_JPY         = Gold;
input color   Color_AUD         = Orange;
input color   Color_CAD         = Maroon;
input color   Color_NZD         = Tan;
input int     line_widht_USD    = 1;
input int     line_style_USD    = 0;
input int     line_widht_EUR    = 1;
input int     line_style_EUR    = 0;
input int     line_widht_GBP    = 1;
input int     line_style_GBP    = 0;
input int     line_widht_JPY    = 1;
input int     line_style_JPY    = 0;
input int     line_widht_AUD    = 1;
input int     line_style_AUD    = 0;
input int     line_widht_CAD    = 1;
input int     line_style_CAD    = 0;
input int     line_widht_NZD    = 1;
input int     line_style_NZD    = 0;
input int     line_widht_CHF    = 1;
input int     line_style_CHF    = 0;
input color   colorWeakCross    = Gold;//OrangeRed;
input color   colorNormalCross  = Gold;
input color   colorStrongCross  = Gold;//LimeGreen;
input color   colorDifferenceUp = 0x303000;
input color   colorDifferenceDn = 0x000030;
input color   colorDifferenceLo = 0x005454;
input color   colorTimeframe    = White;
input color   colorLevelHigh    = LimeGreen;
input color   colorLevelLow     = Crimson;


// global indicator variables
string   indicatorName = "Inflação&Deflação";
string   shortName;
ENUM_TIMEFRAMES userTimeFrame;
ENUM_TIMEFRAMES userExtraTimeFrame;
string   almostUniqueIndex;
bool     sundayCandlesDetected;

// indicator buffers
double   arrUSD[];
double   arrEUR[];
double   arrGBP[];
double   arrJPY[];
double   arrAUD[];
double   arrCAD[];
double   arrNZD[];
double   arrCHF[];

// symbol & currency variables
int      symbolCount;
string   symbolNames[];
string   currencyNames[CURRENCYCOUNT]        = { "USD", "EUR", "GBP",  "JPY", "AUD", "CAD", "NZD","CHF" };
double   currencyValues[CURRENCYCOUNT];      // Currency slope strength
double   currencyValuesPrior[CURRENCYCOUNT]; // Currency slope strength prior bar
double   currencyOccurrences[CURRENCYCOUNT]; // Holds the number of occurrences of each currency in symbols
int   line_widht[CURRENCYCOUNT];
int   line_style[CURRENCYCOUNT];
color    currencyColors[CURRENCYCOUNT];

// object parameters
int      verticalShift = 14;
int      verticalOffset = 30;
int      horizontalShift = 100;
int      horizontalOffset = 10;
int      windex;
//----
bool showOnlySymbolsOnChart=showOnlySymbolOnChart;
string SymbolsToWeigh=symbolsToWeigh;
ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_UPPER;
double tempCurrencyValues[CURRENCYCOUNT][3];
bool          isButtonCreated   = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorSetInteger(INDICATOR_DIGITS,Digits()-1);
   initSymbols();
   string now = (string)TimeCurrent();
   almostUniqueIndex = StringSubstrOld(now, StringLen(now) - 2) + (string)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//---- indicators
   shortName = indicatorName + " - " + version + " - id" + (string)ChartGetInteger(0,CHART_WINDOWS_TOTAL) + StringSubstrOld(now, StringLen(now) - 1);
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
//----
   currencyColors[0] = Color_USD;
   line_widht[0]=line_widht_USD;
   line_style[0]=line_style_USD;
   SetIndexBuffer(0, arrUSD);
   SetIndexLabel(0, "USD");
   currencyColors[1] = Color_EUR;
   line_widht[1]=line_widht_EUR;
   line_style[1]=line_style_EUR;
   SetIndexBuffer(1, arrEUR);
   SetIndexLabel(1, "EUR");
   currencyColors[2] = Color_GBP;
   line_widht[2]=line_widht_GBP;
   line_style[2]=line_style_GBP;
   SetIndexBuffer(2, arrGBP);
   SetIndexLabel(2, "GBP");
   currencyColors[3] = Color_JPY;
   line_widht[3]=line_widht_JPY;
   line_style[3]=line_style_JPY;
   SetIndexBuffer(3, arrJPY);
   SetIndexLabel(3, "JPY");
   currencyColors[4] = Color_AUD;
   line_widht[4]=line_widht_AUD;
   line_style[4]=line_style_AUD;
   SetIndexBuffer(4, arrAUD);
   SetIndexLabel(4, "AUD");
   currencyColors[5] = Color_CAD;
   line_widht[5]=line_widht_CAD;
   line_style[5]=line_style_CAD;
   SetIndexBuffer(5, arrCAD);
   SetIndexLabel(5, "CAD");
   currencyColors[6] = Color_NZD;
   line_widht[6]=line_widht_NZD;
   line_style[6]=line_style_NZD;
   SetIndexBuffer(6, arrNZD);
   SetIndexLabel(6, "NZD");
   currencyColors[7] = Color_CHF;
   line_widht[7]=line_widht_CHF;
   line_style[7]=line_style_CHF;
   SetIndexBuffer(7, arrCHF);
   SetIndexLabel(7, "CHF");
//----
   sundayCandlesDetected = false;
   for(int i = 0; i < 8; i++)
     {
      if(TimeDayOfWeek(iTime(NULL, PERIOD_D1, i)) == 0)
        {
         sundayCandlesDetected = true;
         break;
        }
     }
   for(int i = 0; i < CURRENCYCOUNT; i++)
     {
      // SetIndexStyle( i, DRAW_LINE, line_style[i], line_widht[i], currencyColors[i] );
      PlotIndexSetInteger(i,PLOT_LINE_STYLE,line_style[i]);
      PlotIndexSetInteger(i,PLOT_LINE_COLOR,currencyColors[i]);
      PlotIndexSetInteger(i,PLOT_LINE_WIDTH,line_widht[i]);
     }
   ArraySetAsSeries(arrUSD,true);
   ArraySetAsSeries(arrEUR,true);
   ArraySetAsSeries(arrGBP,true);
   ArraySetAsSeries(arrJPY,true);
   ArraySetAsSeries(arrAUD,true);
   ArraySetAsSeries(arrCAD,true);
   ArraySetAsSeries(arrNZD,true);
   ArraySetAsSeries(arrCHF,true);

   if(weighOnlySymbolOnChart)
      showOnlySymbolsOnChart = true;
   windex = ChartWindowFind(0, shortName);
   if(ShowExportButton && !isButtonCreated)
   {
       isButtonCreated = CInflabuoaDefla1io_Export::CreateExportButton();
   }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Initialize Symbols Array                                         |
//+------------------------------------------------------------------+
int initSymbols()
  {
   int i;
// Get extra characters on this crimmal's symbol names
   string symbolExtraChars = StringSubstrOld(Symbol(), 6, 4);
   if(weighOnlySymbolOnChart)
     {
      SymbolsToWeigh = Symbol();
     }
// Trim user input
   StringTrimLeft(SymbolsToWeigh);
   StringTrimRight(SymbolsToWeigh);
// Add extra comma
   if(StringSubstrOld(SymbolsToWeigh, StringLen(SymbolsToWeigh) - 1) != ",")
     {
      SymbolsToWeigh = (SymbolsToWeigh+ ",");
     }
// Build symbolNames array as the user likes it
   int size;
   if(autoSymbols)
     {
      createSymbolNamesArray();
     }
   else
     {
      // Split user input
      i = StringFind(SymbolsToWeigh, ",");
      while(i != -1)
        {
         size = ArraySize(symbolNames);
         string newSymbol = (StringSubstrOld(SymbolsToWeigh, 0, i)+ symbolExtraChars);
         ArrayResize(symbolNames, size + 1);
         // Set array
         symbolNames[size] = newSymbol;
         // Trim symbols
         SymbolsToWeigh = StringSubstrOld(SymbolsToWeigh, i + 1);
         i = StringFind(SymbolsToWeigh, ",");
        }
     }
// Kill unwanted symbols from array
   if(showOnlySymbolsOnChart)
     {
      symbolCount = ArraySize(symbolNames);
      string tempNames[];
      for(i = 0; i < symbolCount; i++)
        {
         for(int j = 0; j < CURRENCYCOUNT; j++)
           {
            if(StringFind(Symbol(), currencyNames[j]) == -1)
              {
               continue;
              }
            if(StringFind(symbolNames[i], currencyNames[j]) != -1)
              {
               size = ArraySize(tempNames);
               ArrayResize(tempNames, size + 1);
               tempNames[size] = symbolNames[i];
               break;
              }
           }
        }
      for(i = 0; i < ArraySize(tempNames); i++)
        {
         ArrayResize(symbolNames, i + 1);
         symbolNames[i] = tempNames[i];
        }
     }
   symbolCount = ArraySize(symbolNames);
// Print("symbolCount: ", symbolCount);
   for(i = 0; i < symbolCount; i++)
     {
      // Increase currency occurrence
      int currencyIndex = getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3));
      currencyOccurrences[currencyIndex]++;
      currencyIndex = getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3));
      currencyOccurrences[currencyIndex]++;
     }
   userTimeFrame = PERIOD_D1;
   if(autoTimeFrame)
     {
      userTimeFrame = (ENUM_TIMEFRAMES)Period();
     }
   else
     {
      if(timeFrame == "M1")
         userTimeFrame = PERIOD_M1;
      else
         if(timeFrame == "M5")
            userTimeFrame = PERIOD_M5;
         else
            if(timeFrame == "M15")
               userTimeFrame = PERIOD_M15;
            else
               if(timeFrame == "M30")
                  userTimeFrame = PERIOD_M30;
               else
                  if(timeFrame == "H1")
                     userTimeFrame = PERIOD_H1;
                  else
                     if(timeFrame == "H4")
                        userTimeFrame = PERIOD_H4;
                     else
                        if(timeFrame == "D1")
                           userTimeFrame = PERIOD_D1;
                        else
                           if(timeFrame == "W1")
                              userTimeFrame = PERIOD_W1;
                           else
                              if(timeFrame == "MN")
                                 userTimeFrame = PERIOD_MN1;
      if(userTimeFrame < Period())
        {
         userTimeFrame = (ENUM_TIMEFRAMES)Period();
        }
     }
   userExtraTimeFrame = (ENUM_TIMEFRAMES)PERIOD_D1;
   if(extraTimeFrame == "M1")
      userExtraTimeFrame = PERIOD_M1;
   else
      if(extraTimeFrame == "M5")
         userExtraTimeFrame = PERIOD_M5;
      else
         if(extraTimeFrame == "M15")
            userExtraTimeFrame = PERIOD_M15;
         else
            if(extraTimeFrame == "M30")
               userExtraTimeFrame = PERIOD_M30;
            else
               if(extraTimeFrame == "H1")
                  userExtraTimeFrame = PERIOD_H1;
               else
                  if(extraTimeFrame == "H4")
                     userExtraTimeFrame = PERIOD_H4;
                  else
                     if(extraTimeFrame == "D1")
                        userExtraTimeFrame = PERIOD_D1;
                     else
                        if(extraTimeFrame == "W1")
                           userExtraTimeFrame = PERIOD_W1;
                        else
                           if(extraTimeFrame == "MN")
                              userExtraTimeFrame = PERIOD_MN1;
   return(0);
  }

//+------------------------------------------------------------------+
//| getCurrencyIndex(string currency)                                |
//+------------------------------------------------------------------+
int getCurrencyIndex(string currency)
  {
   for(int i = 0; i < CURRENCYCOUNT; i++)
     {
      if(currencyNames[i] == currency)
        {
         return(i);
        }
     }
   return (-1);
  }

//+------------------------------------------------------------------+
//| createSymbolNamesArray()                                         |
//+------------------------------------------------------------------+
void createSymbolNamesArray()
  {
   /*int hFileName = FileOpenHistory ("symbols.raw", FILE_BIN|FILE_READ );
   int recordCount = (int)FileSize ( hFileName ) / 1936;
   int counter = 0;
   for ( int i = 0; i < recordCount; i++ ) {
     string tempSymbol = StringTrimLeft ( StringTrimRight ( FileReadString ( hFileName, 12 ) ) );
     if ( MarketInfo ( tempSymbol, MODE_BID ) > 0 && MarketInfo ( tempSymbol, MODE_TRADEALLOWED ) ) {
       ArrayResize( symbolNames, counter + 1 );
       symbolNames[counter] = tempSymbol;
       counter++;
     }
     FileSeek( hFileName, 1924, SEEK_CUR );
   }
   FileClose( hFileName );*/
  }

//+------------------------------------------------------------------+
//| GetTimeframeString( int tf )                                     |
//+------------------------------------------------------------------+
string GetTimeframeString(int tf)
  {
   string result;
   switch(tf)
     {
      case PERIOD_M1:
         result = "M1";
         break;
      case PERIOD_M5:
         result = "M5";
         break;
      case PERIOD_M15:
         result = "M15";
         break;
      case PERIOD_M30:
         result = "M30";
         break;
      case PERIOD_H1:
         result = "H1";
         break;
      case PERIOD_H4:
         result = "H4";
         break;
      case PERIOD_D1:
         result = "D1";
         break;
      case PERIOD_W1:
         result = "W1";
         break;
      case PERIOD_MN1:
         result = "MN1";
         break;
      default:
         result = "SRITSOD";
     }
   return (result);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   if(windex > 0)
     {
      ObjectsDeleteAll(0, windex);
     }
   ChartRedraw();
//----
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(prev_calculated==0)
     {
      ArrayInitialize(arrUSD,EMPTY_VALUE);
      ArrayInitialize(arrEUR,EMPTY_VALUE);
      ArrayInitialize(arrGBP,EMPTY_VALUE);
      ArrayInitialize(arrJPY,EMPTY_VALUE);
      ArrayInitialize(arrAUD,EMPTY_VALUE);
      ArrayInitialize(arrCAD,EMPTY_VALUE);
      ArrayInitialize(arrNZD,EMPTY_VALUE);
      ArrayInitialize(arrCHF,EMPTY_VALUE);
     }

   int limit;
   int counted_bars = prev_calculated;
// if (rates_total-prev_calculated = 0)  return( rates_total );
   if(counted_bars > 0)
      counted_bars -= 10;
   limit = rates_total - counted_bars;
   if(maxBars > 0)
     {
      limit = MathMin(maxBars, limit);
     }
   ArraySetAsSeries(time,true);
   string objectName;

   int lowLimit = 0;
   limit = (int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
   lowLimit = limit - (int)ChartGetInteger(0,CHART_VISIBLE_BARS,0);
// Print(limit);
   for(int i = limit; i >= lowLimit; i--)
     {
      if(i<0)
         continue;
      double diff = 0.0;
      ArrayInitialize(currencyValues, 0.0);
      int bar = iBarShift(NULL, userTimeFrame, time[i]);
      // Calc Slope into currencyValues[]
      calcCSS(userTimeFrame, bar);
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "USD") != -1)) || (!showOnlySymbolsOnChart && USD))
        {
         arrUSD[i] = currencyValues[0];
         if(diff == 0)
            diff += currencyValues[0];
         else
            diff -= currencyValues[0];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "EUR") != -1)) || (!showOnlySymbolsOnChart && EUR))
        {
         arrEUR[i] = currencyValues[1];
         if(diff == 0)
            diff += currencyValues[1];
         else
            diff -= currencyValues[1];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "GBP") != -1)) || (!showOnlySymbolsOnChart && GBP))
        {
         arrGBP[i] = currencyValues[2];
         if(diff == 0)
            diff += currencyValues[2];
         else
            diff -= currencyValues[2];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "JPY") != -1)) || (!showOnlySymbolsOnChart && JPY))
        {
         arrJPY[i] = currencyValues[3];
         if(diff == 0)
            diff += currencyValues[4];
         else
            diff -= currencyValues[4];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "AUD") != -1)) || (!showOnlySymbolsOnChart && AUD))
        {
         arrAUD[i] = currencyValues[4];
         if(diff == 0)
            diff += currencyValues[5];
         else
            diff -= currencyValues[5];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "CAD") != -1)) || (!showOnlySymbolsOnChart && CAD))
        {
         arrCAD[i] = currencyValues[5];
         if(diff == 0)
            diff += currencyValues[6];
         else
            diff -= currencyValues[6];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "NZD") != -1)) || (!showOnlySymbolsOnChart && NZD))
        {
         arrNZD[i] = currencyValues[6];
         if(diff == 0)
            diff += currencyValues[7];
         else
            diff -= currencyValues[7];
        }
      if((showOnlySymbolsOnChart && (StringFind(Symbol(), "CHF") != -1)) || (!showOnlySymbolsOnChart && CHF))
        {
         arrCHF[i] = currencyValues[7];
         if(diff == 0)
            diff += currencyValues[8-1];
         else
            diff -= currencyValues[8-1];
        }
      if(i == 1)
        {
         ArrayCopy(currencyValuesPrior, currencyValues);
        }
      if(i == 0)
        {
         // Show ordered table
         ShowCurrencyTable(userTimeFrame);
         ShowCurrencyTable(userExtraTimeFrame, false);
        }
      // Only two currencies, show background
      if(showOnlySymbolsOnChart)
        {
         // Create background object
         objectName = almostUniqueIndex + "_diff_" + (string)time[i];
         if(ObjectFind(0, objectName) == -1)
           {
            if(ObjectCreate(0, objectName, OBJ_VLINE, windex, time[i], 0))
              {
               ObjectSetInteger(0,  objectName, OBJPROP_BACK, true);
               ObjectSetInteger(0,  objectName, OBJPROP_WIDTH, 8);
              }
           }
         // Determine background color
         if(MathAbs(diff) > differenceThreshold)
           {
            // Check diff sign
            double cssLong = currencyValues[getCurrencyIndex(StringSubstrOld(Symbol(), 0, 3))];
            double cssShort = currencyValues[getCurrencyIndex(StringSubstrOld(Symbol(), 3, 3))];
            if(cssLong > cssShort)
               ObjectSetInteger(0,  objectName, OBJPROP_COLOR, colorDifferenceUp);
            else
               ObjectSetInteger(0,  objectName, OBJPROP_COLOR, colorDifferenceDn);
           }
         else
           {
            // Below threshold
            ObjectSetInteger(0,  objectName, OBJPROP_COLOR, colorDifferenceLo);
           }
        }
     }
   if(showLevelCross)
     {
      objectName = almostUniqueIndex + "_high";
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_HLINE, windex, 0, levelCrossValue))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_BACK, true);
            ObjectSetInteger(0,  objectName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0,  objectName, OBJPROP_COLOR, colorLevelHigh);
           }
        }
      objectName = almostUniqueIndex + "_low";
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_HLINE, windex, 0, -levelCrossValue))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_BACK, true);
            ObjectSetInteger(0,  objectName, OBJPROP_WIDTH, 2);
            ObjectSetInteger(0,  objectName, OBJPROP_COLOR, colorLevelLow);
           }
        }
     }
   bars=rates_total;
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| getSlope()                                                       |
//+------------------------------------------------------------------+
int bars=0;
double getSlope(string symbol, ENUM_TIMEFRAMES tf, int shift)
  {
   double dblTma, dblPrev;
   int shiftWithoutSunday = shift;
   if(addSundayToMonday && sundayCandlesDetected && tf == PERIOD_D1)
     {
      if(TimeDayOfWeek(iTime(symbol, PERIOD_D1, shift)) == 0)
         shiftWithoutSunday++;
     }
   double average=0;
   int range=100;
   for(int z = shiftWithoutSunday + 10; z < range+shiftWithoutSunday + 10; z++)
      average+=iHigh(symbol,tf,z)-iLow(symbol,tf,z);
   average/=range;
   double atr = average/*iATR(symbol, tf, 100, shiftWithoutSunday + 10)*/ / 10;
   double gadblSlope = 0.0;
   if(atr != 0)
     {
      if(ignoreFuture)
        {
         // int barSymbol = iBarShift( symbol, tf, iTime( Symbol(), tf, shiftWithoutSunday ), true );
         //dblTma = iMA( symbol, tf, 21, 0, MODE_LWMA, PRICE_CLOSE, shiftWithoutSunday );
         double close_array[];
         if(CopyClose(symbol, tf, shiftWithoutSunday, 21, close_array)==-1)
           {
            Print("--->>>>>>>>>>>>>>>>>> ",symbol," :",EnumToString(tf));
            return 0;
           }
         ArraySetAsSeries(close_array,true);
         dblTma = LWMA(bars, close_array, 21, shiftWithoutSunday);
         if(CopyClose(symbol, tf, shiftWithoutSunday+1, 21, close_array)==-1)
           {
            Print("--->>>>>>>>>>>>>>>>>> ",symbol," : ",EnumToString(tf));
            return 0;
           }
         ArraySetAsSeries(close_array,true);
         dblPrev = (LWMA(bars, close_array, 21, shiftWithoutSunday+1)/*iMA( symbol, tf, 21, 0, MODE_LWMA, PRICE_CLOSE, shiftWithoutSunday + 1 )*/ * 231 + iClose(symbol, tf, shiftWithoutSunday) * 20) / 251;
        }
      else
        {
         dblTma = calcTma(symbol, tf, shiftWithoutSunday);
         dblPrev = calcTma(symbol, tf, shiftWithoutSunday + 1);
        }
      gadblSlope = (dblTma - dblPrev) / atr;
     }
   return (gadblSlope);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LWMA(const int rates_total,const double &array_src[],const int period,const int shift)
  {
   if(period<1 || shift>rates_total-period-1)
      return 0;
   double sum=0;
   double weight=0;
   for(int i=0; i<period; i++)
     {
      weight+=(period-i);
      sum+=array_src[i]*(period-i);
     }
   return(weight>0 ? sum/weight : 0);
  }
//+------------------------------------------------------------------+
//| calcTma()                                                        |
//+------------------------------------------------------------------+
double calcTma(string symbol, ENUM_TIMEFRAMES tf,  int shift)
  {
   double dblSum  = iClose(symbol, tf, shift) * 21;
   double dblSumw = 21;
   int jnx, knx;
   for(jnx = 1, knx = 20; jnx <= 20; jnx++, knx--)
     {
      dblSum  += iClose(symbol, tf, shift + jnx) * knx;
      dblSumw += knx;
      if(jnx <= shift)
        {
         dblSum  += iClose(symbol, tf, shift - jnx) * knx;
         dblSumw += knx;
        }
     }
   return (dblSum / dblSumw);
  }


//+------------------------------------------------------------------+
//| calcCSS(int tf, int shift                 |
//+------------------------------------------------------------------+
void calcCSS(ENUM_TIMEFRAMES tf, int shift)
  {
   int i;
// Get Slope for all symbols and totalize for all currencies
   for(i = 0; i < symbolCount; i++)
     {
      double slope = getSlope(symbolNames[i], tf, shift);
      currencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))] += slope;
      currencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))] -= slope;
     }
   for(i = 0; i < CURRENCYCOUNT; i++)
     {
      // average
      if(currencyOccurrences[i] > 0)
         currencyValues[i] /= currencyOccurrences[i];
      else
         currencyValues[i] = 0;
     }
  }

//+------------------------------------------------------------------+
//| ShowCurrencyTable()                                              |
//+------------------------------------------------------------------+
void ShowCurrencyTable(ENUM_TIMEFRAMES tf, bool mainTable = true)
  {
   int i = 0;
   int tempValue;
   int tempValue_2;
   string objectName;
   string showText;
   string showText_2;
   color showColor;
   int tableOffset = -100;
   if(mainTable)
      tableOffset = 0;
   static datetime tLastAlert[8];
   static datetime tLastAlert_1[8];
   static datetime tLastAlert_2[8];
   if(showOnlySymbolsOnChart)
     {
      // Header
      objectName = almostUniqueIndex + "_css_obj_column_currency_tf";
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
            ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 70 + tableOffset);
            ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, verticalOffset - 18);
           }
        }
      showText = "TF ";
      ObjectSetText(objectName, showText, 14, nonPropFont, colorTimeframe);
      objectName = almostUniqueIndex + "_css_obj_column_value_tf";
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
            ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 65 + 70 + tableOffset);
            ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, verticalOffset - 18);
           }
        }
      ObjectSetText(objectName, GetTimeframeString(tf), 14, nonPropFont, colorTimeframe);
      // Chart symbols only
      // Loop currency values and header output objects, creating them if necessary
      for(i = 0; i < 2; i++)
        {
         int index = getCurrencyIndex(StringSubstrOld(Symbol(), 3 * i, 3));
         objectName = almostUniqueIndex + "_css_obj_column_currency_" + (string)i;
         if(ObjectFind(0, objectName) == -1)
           {
            if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
              {
               ObjectSetInteger(0, objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
               ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
               ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 70 + tableOffset);
               ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * (i + 1) + verticalOffset - 18);
              }
           }
         ObjectSetText(objectName, currencyNames[index], 14, nonPropFont, currencyColors[index]);
         objectName = almostUniqueIndex + "_css_obj_column_value_" + (string)i;
         if(ObjectFind(0, objectName) == -1)
           {
            if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
              {
               ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
               ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
               ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 65 + 70 + tableOffset);
               ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * (i + 1) + verticalOffset - 18);
              }
           }
         showText = RightAlign(DoubleToString(currencyValues[index], 2), 5);
         ObjectSetText(objectName, showText, 14, nonPropFont, currencyColors[index]);
        }
      objectName = almostUniqueIndex + "_css_obj_column_currency_3";
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
            ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 5 + tableOffset);
            ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 6) * 3 + verticalOffset - 10);
           }
        }
      showText = "threshold = " + DoubleToString(differenceThreshold, 1);
      ObjectSetText(objectName, showText, 8, nonPropFont, Yellow);
     }
   else
     {
      // Header
      objectName = almostUniqueIndex + "_css_obj_column_currency_tf" + GetTimeframeString(tf);
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
            ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 150 + tableOffset);
            ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18);
           }
        }
      showText = "TF ";
      ObjectSetText(objectName, showText, 12, nonPropFont, colorTimeframe);
      objectName = almostUniqueIndex + "_css_obj_column_value_tf" + GetTimeframeString(tf);
      if(ObjectFind(0, objectName) == -1)
        {
         if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
           {
            ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
            ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
            ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 150 + tableOffset);
            ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * i + verticalOffset - 18);
           }
        }
      ObjectSetText(objectName, GetTimeframeString(tf), 12, nonPropFont, colorTimeframe);
      // Full table

      ArrayInitialize(tempCurrencyValues, 0.0);
      if(mainTable)
        {
         for(i = 0; i < CURRENCYCOUNT; i++)
           {
            tempCurrencyValues[i][0] = currencyValues[i];
            tempCurrencyValues[i][1] = NormalizeDouble(currencyValuesPrior[i], 2);
            tempCurrencyValues[i][2] = i;
           }
        }
      else
        {
         for(i = 0; i < symbolCount; i++)
           {
            double slope = getSlope(symbolNames[i], tf, 0);
            tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 0, 3))][0] += slope;
            tempCurrencyValues[getCurrencyIndex(StringSubstrOld(symbolNames[i], 3, 3))][0] -= slope;
           }
         for(i = 0; i < CURRENCYCOUNT; i++)
           {
            tempCurrencyValues[i][2] = i;
            // average
            if(currencyOccurrences[i] > 0)
               tempCurrencyValues[i][0] /= currencyOccurrences[i];
            else
               tempCurrencyValues[i][0] = 0;
           }
        }
      // Sort currency to values
      //ArraySort(tempCurrencyValues/*, WHOLE_ARRAY, 0, MODE_DESCEND*/);
      ArraySortBubbleTwoDims3(tempCurrencyValues,0,1);
      int horizontalOffsetCross = 0;
      // Loop currency values and header output objects, creating them if necessary
      for(i = 0; i < CURRENCYCOUNT; i++)
        {
         objectName = almostUniqueIndex + "_css_obj_column_currency_" + GetTimeframeString(tf) + "_" + (string)i;
         if(ObjectFind(0, objectName) == -1)
           {
            if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
              {
               ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
               ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
               ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset + 150 + tableOffset);
               ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * (i + 1) + verticalOffset - 18);
              }
           }
         tempValue = (int)tempCurrencyValues[i][2];
         showText = currencyNames[tempValue];
         ObjectSetText(objectName, showText, 12, nonPropFont, currencyColors[tempValue]);
         objectName = almostUniqueIndex + "_css_obj_column_value_" + GetTimeframeString(tf) + "_" + (string)i;
         if(ObjectFind(0, objectName) == -1)
           {
            if(ObjectCreate(0, objectName, OBJ_LABEL, windex, 0, 0))
              {
               ObjectSetInteger(0,  objectName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
               ObjectSetInteger(0,objectName,OBJPROP_ANCHOR,anchor);
               ObjectSetInteger(0,  objectName, OBJPROP_XDISTANCE, horizontalShift * 0 + horizontalOffset - 55 + 150 + tableOffset);
               ObjectSetInteger(0,  objectName, OBJPROP_YDISTANCE, (verticalShift + 2) * (i + 1) + verticalOffset - 18);
              }
           }
         showText = RightAlign(DoubleToString(tempCurrencyValues[i][0], 2), 5);
         ObjectSetText(objectName, showText, 12, nonPropFont, currencyColors[tempValue]);
         // Continue if this is a secondary table
         if(!mainTable)
            continue;
         // PopUp alert Stuff
         if(showCrossAlerts
            && i < CURRENCYCOUNT - 1
            && NormalizeDouble(tempCurrencyValues[i][0],2) > NormalizeDouble(tempCurrencyValues[i+1][0],2)
            && NormalizeDouble(tempCurrencyValues[i][1],2) < NormalizeDouble(tempCurrencyValues[i+1][1],2)
           )
           {
            if(tLastAlert[i]<iTime(NULL,0,0))
              {
               tempValue = (int)tempCurrencyValues[i][2];
               tempValue_2 = (int)tempCurrencyValues[i+1][2];
               showText = currencyNames[tempValue];
               showText_2 = currencyNames[tempValue_2];
               fireAlerts(showText+" did a cross up "+showText_2);
               tLastAlert[i]=iTime(NULL,0,0);
              }
           }
         // Detect and show crosses if users want to
         // Test for normalized values to filter trivial crosses
         objectName = almostUniqueIndex + "_css_obj_column_cross_" + (string)i;
         if(showCrossAlerts
            && i < CURRENCYCOUNT - 1
            && NormalizeDouble(tempCurrencyValues[i][0], 2) > NormalizeDouble(tempCurrencyValues[i + 1][0], 2)
            && tempCurrencyValues[i][1] < tempCurrencyValues[i + 1][1]
           )
           {
            showColor = colorStrongCross;
            if(tempCurrencyValues[i][0] > 0.8 || tempCurrencyValues[i + 1][0] < -0.8)
              {
               showColor = colorWeakCross;
              }
            else
               if(tempCurrencyValues[i][0] > 0.4 || tempCurrencyValues[i + 1][0] < -0.4)
                 {
                  showColor = colorNormalCross;
                 }
            // Prior values of this currency is lower than next currency, this is a cross.
            DrawCell(windex, objectName, horizontalShift * 0 + horizontalOffset + 88 + horizontalOffsetCross, (verticalShift + 2) * (i + 1) + verticalOffset - 20, 3, 27, showColor);
            // Move cross location to next column if necessary
            if(horizontalOffsetCross == 0)
              {
               horizontalOffsetCross = -4;
              }
            else
              {
               horizontalOffsetCross = 0;
              }
           }
         else
           {
            DeleteCell(objectName);
            horizontalOffsetCross = 0;
           }
         if(showLevelCross)
           {
            // Show level cross
            double currentValue = tempCurrencyValues[i][0];
            double priorValue=0;
            switch(tempValue)
              {
               case 0:
                  priorValue = arrUSD[1];
                  break;
               case 1:
                  priorValue = arrEUR[1];
                  break;
               case 2:
                  priorValue = arrGBP[1];
                  break;
               case 3:
                  priorValue = arrJPY[1];
                  break;
               case 4:
                  priorValue = arrAUD[1];
                  break;
               case 5:
                  priorValue = arrCAD[1];
                  break;
               case 6:
                  priorValue = arrNZD[1];
                  break;
               case 7:
                  priorValue = arrCHF[1];
                  break;
              }
            objectName = almostUniqueIndex + "_css_obj_column_level_" + (string)i;
            // START DEBUG CODE
            // DrawBullet( windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelHigh );
            // showText = RightAlign(DoubleToString(priorValue, 2), 5);
            // ObjectSetText ( objectName, showText, 12, nonPropFont, colorLevelHigh );
            // END DEBUG CODE
            //OLD CODE cross -20 and 0 up and +20 and 0 down
            // if ( priorValue > levelCrossValue && currentValue < levelCrossValue )
            //{
            //    DrawBullet( windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelHigh );
            // }
            //  else if ( priorValue > 0 && currentValue < 0 )
            //  {
            //      DrawBullet( windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelHigh );
            //  }
            //  else if ( priorValue < -levelCrossValue && currentValue > -levelCrossValue )
            //  {
            //     DrawBullet( windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelLow );
            //  }
            //  else if ( priorValue < 0 && currentValue > 0 )
            //  {
            //     DrawBullet( windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelLow );
            //  }
            //   else
            //  {
            //     ObjectDelete( objectName );
            //NEW CODE cross 0 +20 up and 0 -20 down
            if(priorValue > 0 && currentValue < 0)
              {
               DrawBullet(windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelHigh);
              }
            if(priorValue < levelCrossValue && currentValue > levelCrossValue)      // change from - to none
              {
               DrawBullet(windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelHigh);
               if(tLastAlert_1[i]<iTime(NULL,0,0))
                 {
                  showText = currencyNames[tempValue];
                  fireAlerts(showText+" did a cross up "+(string)levelCrossValue);
                  tLastAlert_1[i]=iTime(NULL,0,0);
                 }
              }
            if(priorValue < 0 && currentValue > 0)
              {
               DrawBullet(windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelLow);
              }
            if(priorValue > -levelCrossValue && currentValue < -levelCrossValue)      //change from none to -
              {
               DrawBullet(windex, objectName, horizontalShift * 0 + horizontalOffset - 55 + 136, (verticalShift + 2) * (i + 1) + verticalOffset - 21, colorLevelLow);
               if(tLastAlert_2[i]<iTime(NULL,0,0))
                 {
                  showText = currencyNames[tempValue];
                  fireAlerts(showText+" did a cross down "+string(-levelCrossValue));
                  tLastAlert_2[i]=iTime(NULL,0,0);
                 }
              }
            else
              {
               ObjectDelete(0, objectName);
               // break here if changing back to old code.
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Right Align Text                                                 |
//+------------------------------------------------------------------+
string RightAlign(string text, int length = 10, int trailing_spaces = 0)
  {
   string text_aligned = text;
   for(int i = 0; i < length - StringLen(text) - trailing_spaces; i++)
     {
      text_aligned = " " + text_aligned;
     }
   return (text_aligned);
  }
//+------------------------------------------------------------------+
//| DrawCell(), credits go to Alexandre A. B. Borela                 |
//+------------------------------------------------------------------+
void DrawCell(int nWindow, string nCellName, double nX, double nY, double nWidth, double nHeight, color nColor)
  {
   double   iHeight, iWidth, iXSpace;
   int      iSquares, i;
   if(nWidth > nHeight)
     {
      iSquares = (int)MathCeil(nWidth / nHeight);    // Number of squares used.
      iHeight  = MathRound((nHeight * 100) / 77);      // Real height size.
      iWidth   = MathRound((nWidth * 100) / 77);      // Real width size.
      iXSpace  = iWidth / iSquares - ((iHeight / (9 - (nHeight / 100))) * 2);
      for(i = 0; i < iSquares; i++)
        {
         ObjectCreate(0, nCellName + (string)i, OBJ_LABEL, nWindow, 0, 0);
         ObjectSetText(nCellName + (string)i, CharToString(110), (int)iHeight, "Wingdings", nColor);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_XDISTANCE, int(nX + iXSpace * i));
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_YDISTANCE, (int)nY);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_BACK, true);
        }
     }
   else
     {
      iSquares = (int)MathCeil(nHeight / nWidth);    // Number of squares used.
      iHeight  = MathRound((nHeight * 100) / 77);      // Real height size.
      iWidth   = MathRound((nWidth * 100) / 77);      // Real width size.
      iXSpace  = iHeight / iSquares - ((iWidth / (9 - (nWidth / 100))) * 2);
      for(i = 0; i < iSquares; i++)
        {
         ObjectCreate(0, nCellName + (string)i, OBJ_LABEL, nWindow, 0, 0);
         ObjectSetText(nCellName + (string)i, CharToString(110), (int)iWidth, "Wingdings", nColor);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_XDISTANCE, (int)nX);
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_YDISTANCE, int(nY + iXSpace * i));
         ObjectSetInteger(0, nCellName + (string)i, OBJPROP_BACK, true);
        }
     }
  }

//+------------------------------------------------------------------+
//| DeleteCell()                                                     |
//+------------------------------------------------------------------+
void DeleteCell(string name)
  {
   int square = 0;
   while(ObjectFind(0, name + (string)square) > -1)
     {
      ObjectDelete(0, name + (string)square);
      square++;
     }
  }


//+------------------------------------------------------------------+
//| DrawBullet()                                                     |
//+------------------------------------------------------------------+
void DrawBullet(int window, string cellName, int col, int row, color bulletColor)
  {
   if(ObjectFind(0, cellName) == -1)
     {
      if(ObjectCreate(0, cellName, OBJ_LABEL, window, 0, 0))
        {
         ObjectSetInteger(0, cellName, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
         ObjectSetInteger(0,cellName,OBJPROP_ANCHOR,anchor);
         ObjectSetInteger(0, cellName, OBJPROP_XDISTANCE, col);
         ObjectSetInteger(0, cellName, OBJPROP_YDISTANCE, row);
         ObjectSetInteger(0, cellName, OBJPROP_BACK, true);
         ObjectSetText(cellName, CharToString(108), 12, "Wingdings", bulletColor);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fireAlerts(string sMsg)
  {
   if(PopupAlert)
      Alert(sMsg);
   if(EmailAlert)
      SendMail("CSS Alert "+"",sMsg);
   if(PushAlert)
      SendNotification(sMsg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringSubstrOld(string x,int a,int b=-1)
  {
   if(a < 0)
      a= 0; // Stop odd behaviour
   if(b<=0)
      b = -1; // new MQL4 EOL flag
   return StringSubstr(x,a,b);
  }
//+------------------------------------------------------------------+
#ifdef __MQL5__
void SetIndexLabel(int index,string text)
  {
   PlotIndexSetString(index,PLOT_LABEL,text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectSetText(string name,
                   string text,
                   int fs,
                   string font,
                   color text_color)
  {
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fs);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
#endif
//===============================================================================================
//------------------------- Пузырьковая сортировка двумерного массива --------------------------|
// Сортировка по первому измерению по возрастанию                                               |
//   ArraySortBubbleTwoDims(array);                                                             |
// Сортировка по первому измерению по убыванию                                                  |
//   ArraySortBubbleTwoDims(array,0,1);                                                         |
// Сортировка по второму измерению по возрастанию                                               |
//   ArraySortBubbleTwoDims(array,1);                                                           |
// Сортировка по второму измерению по убыванию                                                  |
//   ArraySortBubbleTwoDims(array,1,1);                                                         |
//===============================================================================================
template<typename T>
void ArraySortBubbleTwoDims3(T& array[][3], int sort_dimension=0, int sort_direction=0)
  {
   T   t=0;
   int k=ArrayRange(array,1); // Количество колонок
   int n=ArrayRange(array,0); // Количество строк
//---
   if(sort_dimension<0)
      sort_dimension=0;
   if(sort_dimension>k)
      sort_dimension=k;
//---
   for(int i=n-1; i>0; i--)
     {
      for(int j=0; j<i; j++)
        {
         //--- по возрастанию
         if(sort_direction==0)
           {
            if(array[j][sort_dimension]>array[j+1][sort_dimension])
              {
               for(int e=0; e<k; e++)
                 {
                  t=array[j][e];
                  array[j][e]=array[j+1][e];
                  array[j+1][e]=t;
                 }
              }
           }
         else
           {
            //--- по убыванию
            if(array[j][sort_dimension]<array[j+1][sort_dimension])
              {
               for(int e=0; e<k; e++)
                 {
                  t=array[j][e];
                  array[j][e]=array[j+1][e];
                  array[j+1][e]=t;
                 }
              }
           }
        }
     }
  }
//------------------------------------------------------------------+
// Custom functions                                                 |
//                                                                  |
//                                                                  |
// double _price  = getPrice(inpPrice,open,close,high,low,i);       |
//------------------------------------------------------------------+

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    // Handle button click
    if(id == CHARTEVENT_OBJECT_CLICK && sparam == "ExportButton")
    {
        datetime time[];
        ArraySetAsSeries(time, true);
        
        // Use the minimum between ExportMaxBars and maxBars
        int barsToExport = MathMin(ExportMaxBars, maxBars);
        CopyTime(_Symbol, PERIOD_CURRENT, 0, barsToExport, time);
        
        if(CInflabuoaDefla1io_Export::ExportToJson(
            arrUSD, arrEUR, arrGBP, arrJPY, 
            arrAUD, arrCAD, arrNZD, arrCHF,
            time, barsToExport))
        {
            Print("Data exported successfully - Bars exported: ", barsToExport);
            Alert("Indicator data has been exported successfully!");
        }
        else
        {
            Print("Failed to export data");
            Alert("Failed to export indicator data!");
        }
    }
}
