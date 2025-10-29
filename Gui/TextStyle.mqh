//+------------------------------------------------------------------+
//|                                                StyleTemplate.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TextStyle
  {
public:
   int               size;
   color             textColor;
   string            font;
                     TextStyle()
     {
      size = 10;
      textColor = clrBlack;
      font = "Tahoma";
     }
                     TextStyle(int _size, color _textColor, string _font)
     {
      size = _size;
      textColor = _textColor;
      font = _font;
     }
     
     bool              Apply(string objectName)
     {
      if(!ObjectSetString(0, objectName, OBJPROP_FONT, font))
         return false;
      if(!ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, size))
         return false;
      if(!ObjectSetInteger(0, objectName, OBJPROP_COLOR, textColor))
         return false;
      return true;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TextStyle textDefaultBlack();
TextStyle textDefaultWhite(10, clrWhite,"Tahoma");
//+------------------------------------------------------------------+
