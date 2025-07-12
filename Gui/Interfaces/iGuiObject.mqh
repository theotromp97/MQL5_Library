//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


#include <MQL5_Library\Gui\ObjectStyle.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
interface   iGuiObject
  {
   bool              Create();
   bool              Delete();
   bool              Hide();
   bool              Show();
   bool              ApplyObjectStyle();
   bool              Move(int _relX, int _relY);
   bool              SetWidth(int _width);
   bool              SetHeight(int _height);
  };
//+------------------------------------------------------------------+
