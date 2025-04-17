//+------------------------------------------------------------------+
//|                                                       Button.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <MQL_Lib\StyleTemplate.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Button
  {
public:
   string            name;
   StyleTemplate     style;
   int               x, y, width, height;
   bool              created;
                     Button(string _name, int _x, int _y, int _width, int _height)
     {
      name = _name;
      x = _x;
      y = _y;
      width = _width;
      height = _height;
      style = defaultStyle;
      created = ObjectCreate(0, "btn", OBJ_BUTTON, 0, x, y, x+width, y+height);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, style.font.size);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrRed);
     }

   bool              Delete()
     {
      return false;
     }

   bool              SetVisibilty(bool visible)
     {
      return false;
     }
  };
//+------------------------------------------------------------------+
