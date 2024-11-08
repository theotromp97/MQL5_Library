//+------------------------------------------------------------------+
//|                                                   TradeAssistant |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
string SuperTrendPath = "SuperTrend.ex5";
string ErgodicPath = "ErgodicTSI.ex5";

datetime previousBar;

enum IndicatorType
  {
// entry indicators
   entryEngulfing,
   entryBollingerBands,
   entryRsi,
   entryErgodicTSI,


// trend indicators
   trendSuperTrend,
   trendAdx
  };


enum Signal
  {
   signalLong,
   signalShort,
   signalNone
  };

//+---
bool BarClose(ENUM_TIMEFRAMES timeframe)
  {
   bool retval = previousBar != iTime(_Symbol, timeframe, 0);
   previousBar = iTime(_Symbol, timeframe, 0);
   return retval;
  }
//+----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicators
  {
public:
   static void              Init()
     {
      //GetAdxSignal();
      GetSuperTrend(PERIOD_M15);
      GetSuperTrend(PERIOD_H1);
      //GetErgodicTSI(PERIOD_CURRENT, 25, 13, 5);
      //GetBollingerBands();
      GetRsi();

     }
   static Signal                     GetIndicator(IndicatorType _indicatorType, ENUM_TIMEFRAMES period)
     {
      switch(_indicatorType)
        {
         default:
            return signalNone;
         case entryEngulfing:
            return GetEngulfing();
         case entryBollingerBands:
            return GetBollingerBands();
         case entryRsi:
            return GetRsi();
         case entryErgodicTSI:
            return GetErgodicTSI(period, 25, 13, 5);


         // trend indicators
         case trendSuperTrend:
            return GetSuperTrend(period);
         case trendAdx:
            return GetAdxSignal();
        }
     }

private:
   static Signal            GetBollingerBands()
     {
      // init adx
      static int handle = 0;
      if(handle == 0)
        {
         //handle = iBands(_Symbol, PERIOD_CURRENT, 21);
        }

      // get value
      double array[];
      CopyBuffer(handle, 0, 0, 1, array);
      //return adxHandle[0] == 1.0 ? 1 : SuperTrendDirectionArray[0] == -1.0 ? -1 : 0;
      return signalNone;
     }

   static Signal            GetEngulfing()
     {
      double open1 = iOpen(_Symbol, PERIOD_CURRENT, 2);
      double close1 = iClose(_Symbol, PERIOD_CURRENT, 2);
      double open2 = iOpen(_Symbol, PERIOD_CURRENT, 1);
      double close2 = iClose(_Symbol, PERIOD_CURRENT, 1);
      if(BarClose(PERIOD_CURRENT))
        {
         // bullish
         if(open1 > close1 && open2 < close2 && close2 > open1)
           {
            return signalLong;
           }
         // bearish
         if(close1 > open1 && close2 < open2 && close2 < open1)
           {
            return signalShort;
           }
        }
      return signalNone;
     }

   static Signal            GetErgodicTSI(ENUM_TIMEFRAMES tf, int period1, int period2, int period3)
     {
      // init supertrend
      // TODO
      int handle = 0;
      if(handle == 0)
        {
         handle =  iCustom(_Symbol, tf, ErgodicPath);
        }

      // get value
      double array[];
      CopyBuffer(handle, 2, 0, 1, array);
      if(array[0] == 1.0)
        {
         return signalLong;
        }
      else
         if(array[0] == 2.0)
           {
            return signalShort;
           }
         else
            return signalNone;
     }

   static Signal            GetAdxSignal()
     {
      // init adx
      static int handle = 0;
      if(handle == 0)
        {
         handle = iADX(_Symbol, PERIOD_CURRENT, 21);
        }

      // get value
      double array[];
      CopyBuffer(handle, 0, 0, 1, array);
      //return adxHandle[0] == 1.0 ? 1 : SuperTrendDirectionArray[0] == -1.0 ? -1 : 0;
      return signalNone;
     }

   static Signal     GetSuperTrend(ENUM_TIMEFRAMES period)
     {
      // init supertrend
      int handle = 0;
      if(handle == 0)
        {
         handle =  iCustom(_Symbol, period, SuperTrendPath,21,3, false, period);
        }

      // get value
      double array[];
      // check value of supertrend
      CopyBuffer(handle, 7, 0, 1, array);
      if(array[0] == 0.0)
         return signalNone;
      
      // if value is ok, check signal
      CopyBuffer(handle, 8, 0, 1, array);
      if(array[0] == 1.0)
        {
         return signalLong;
        }
      else
         if(array[0] == -1.0)
           {
            return signalShort;
           }
         else
            return signalNone;
     }

   static Signal     GetRsi()
     {
      // init rsi
      static int handle = 0;
      if(handle == 0)
        {
         handle =  iRSI(_Symbol, PERIOD_CURRENT,14, PRICE_CLOSE);
        }

      // get value
      double array[];
      CopyBuffer(handle, 0, 0, 1, array);
      if(array[0] > 50.0)
        {
         return signalLong;
        }
      if(array[0] < 50.0)
        {
         return signalShort;
        }
      return signalNone;
     }
  };
//+------------------------------------------------------------------+
