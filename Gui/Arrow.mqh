//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL5_Library\Gui\GuiObject.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Arrow : public GuiObject
  {
public:
                     Arrow() {}
                     Arrow(string _name, datetime _x_start, double _y_start, datetime _x_end, double _y_end) :
                        GuiObject(_name, _x_start, _y_start, _x_end, _y_end, OBJ_ARROWED_LINE)
     {}

   //+------------------------------------------------------------------+
   bool              Create() override
     {      
      if(created)
         return true;
      if(!ObjectCreate(0, name, objectType, 0, x_start, y_start, x_end, y_end))
         return false;
      objectStyle.Apply(name);
      visible = true;
      created = true;
      return true;
     }
  };
//+------------------------------------------------------------------+
