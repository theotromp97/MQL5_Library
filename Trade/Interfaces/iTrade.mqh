//+------------------------------------------------------------------+
//|                                                       iTrade.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
interface iTrade
  {
   bool              IsLong();
   bool              IsShort();

   bool              IsFilled();
   bool              IsCancelled();
   bool              IsOpened();
   bool              IsClosed();
   bool              IsNone();

   bool              IsFilledOS();
   bool              IsCancelledOS();
   bool              IsOpenedOS();
   bool              IsClosedOS();
   };